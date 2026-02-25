import 'package:app_rtsg_client/core/constants/api_constants.dart';

import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class MapboxGeocoder {
  final http.Client _client;
  MapboxGeocoder({http.Client? client}) : _client = client ?? http.Client();

  Future<String?> reverse({required double lat, required double lon}) async {
    try {
      final uri = Uri.https(
        ApiConstants.mapboxBaseUrl,
        '${ApiConstants.mapboxGeocodingPath}/$lon,$lat.json',
        {
          'access_token': ApiConstants.mapboxAccessToken,
          'language': ApiConstants.mapboxLanguage,
          'limit': '1',
          'types': ApiConstants.mapboxTypes,
        },
      );

      final res = await _client.get(uri).timeout(const Duration(seconds: 6));
      if (res.statusCode != 200) return null;

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final features = (data['features'] as List?) ?? const [];
      if (features.isEmpty) return null;

      return (features.first as Map<String, dynamic>)['place_name'] as String?;
    } catch (_) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> search({
    required String query,
    double? userLat,
    double? userLon,
    int limit = 5,
    double? maxDistanceKm,
    String? country, // ej: 'ec'
  }) async {
    final q = query.trim();
    if (q.isEmpty) return [];

    final safeLimit = limit.clamp(1, 10);

    try {
      final encodedQuery = Uri.encodeComponent(q);

      // ✅ Asegura que types incluya POI (para "rotonda", lugares, etc.)
      // Si ApiConstants.mapboxTypes no tiene 'poi', lo añadimos sin romper tu constante.
      final rawTypes = ApiConstants.mapboxTypes.trim();
      final normalizedTypes = rawTypes.isEmpty ? 'poi,address,place' : rawTypes;
      final types = normalizedTypes.contains('poi')
          ? normalizedTypes
          : '$normalizedTypes,poi';

      final uri = Uri.https(
        ApiConstants.mapboxBaseUrl,
        '${ApiConstants.mapboxGeocodingPath}/$encodedQuery.json',
        {
          'access_token': ApiConstants.mapboxAccessToken,
          'language': ApiConstants.mapboxLanguage,
          'limit': '$safeLimit',
          'types': types,

          // ✅ mejora resultados
          'autocomplete': 'true',
          'fuzzyMatch': 'true',

          // ✅ limita país si lo envías (recomendado: 'ec')
          if (country != null && country.trim().isNotEmpty) 'country': country,

          // ✅ sesga a tu ubicación
          if (userLat != null && userLon != null)
            'proximity': '$userLon,$userLat',
        },
      );

      final res = await _client.get(uri).timeout(const Duration(seconds: 6));
      if (res.statusCode != 200) return [];

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final features = (data['features'] as List?) ?? const [];

      final List<Map<String, dynamic>> suggestions = features.map((item) {
        final m = item as Map<String, dynamic>;
        final center = m['center'] as List?;
        final double lon = (center != null && center.isNotEmpty)
            ? ((center[0] as num?)?.toDouble() ?? 0)
            : 0;
        final double lat = (center != null && center.length > 1)
            ? ((center[1] as num?)?.toDouble() ?? 0)
            : 0;

        return {
          'display_name': m['place_name'] ?? 'Sin nombre',
          'lat': lat,
          'lon': lon,
        };
      }).toList();

      // ✅ filtra por radio
      List<Map<String, dynamic>> filtered = suggestions;
      if (maxDistanceKm != null && userLat != null && userLon != null) {
        filtered = suggestions.where((s) {
          final lat = (s['lat'] as num).toDouble();
          final lon = (s['lon'] as num).toDouble();
          final d = _distanceKm(userLat, userLon, lat, lon);
          return d <= maxDistanceKm;
        }).toList();
      }

      // ✅ ordena por cercanía
      if (userLat != null && userLon != null) {
        filtered.sort((a, b) {
          final la = (a['lat'] as num).toDouble();
          final loa = (a['lon'] as num).toDouble();
          final lb = (b['lat'] as num).toDouble();
          final lob = (b['lon'] as num).toDouble();

          final da = _distanceKm(userLat, userLon, la, loa);
          final db = _distanceKm(userLat, userLon, lb, lob);
          return da.compareTo(db);
        });
      }

      return filtered;
    } catch (_) {
      return [];
    }
  }

  // ---------------------------------------------------------------------------
  // ✅ NUEVO: Ruta + distancia + duración (Mapbox Directions)
  // Retorna:
  // {
  //   'distance_m': double,
  //   'duration_s': double,
  //   'points': List<LatLng>,
  // }
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>?> route({
    required LatLng origin,
    required LatLng destination,
    String profile = 'driving',
  }) async {
    try {
      // Requiere en ApiConstants:
      // static const String mapboxDirectionsPath = '/directions/v5/mapbox';
      final path =
          '${ApiConstants.mapboxDirectionsPath}/$profile/${origin.longitude},${origin.latitude};${destination.longitude},${destination.latitude}';

      final uri = Uri.https(ApiConstants.mapboxBaseUrl, path, {
        'access_token': ApiConstants.mapboxAccessToken,
        'language': ApiConstants.mapboxLanguage,
        'geometries': 'geojson',
        'overview': 'full',
        'alternatives': 'false',
      });

      final res = await _client.get(uri).timeout(const Duration(seconds: 8));
      if (res.statusCode != 200) return null;

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final routes = (data['routes'] as List?) ?? const [];
      if (routes.isEmpty) return null;

      final r0 = routes.first as Map<String, dynamic>;
      final distanceM = (r0['distance'] as num?)?.toDouble() ?? 0.0;
      final durationS = (r0['duration'] as num?)?.toDouble() ?? 0.0;

      final geometry = r0['geometry'] as Map<String, dynamic>?;
      final coords = (geometry?['coordinates'] as List?) ?? const [];

      final points = coords.map((c) {
        final pair = c as List;
        final lon = (pair[0] as num).toDouble();
        final lat = (pair[1] as num).toDouble();
        return LatLng(lat, lon);
      }).toList();

      return {
        'distance_m': distanceM,
        'duration_s': durationS,
        'points': points,
      };
    } catch (_) {
      return null;
    }
  }

  /// Distancia Haversine en km
  double _distanceKm(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371.0;
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);

    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) *
            cos(_deg2rad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _deg2rad(double deg) => deg * (pi / 180);

  void dispose() => _client.close();
}

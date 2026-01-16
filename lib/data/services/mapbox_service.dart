// import 'package:app_rtsg_client/core/constants/api_constants.dart';

// import 'dart:convert';
// import 'dart:math';
// import 'package:http/http.dart' as http;

// class MapboxGeocoder {
//   final http.Client _client;
//   MapboxGeocoder({http.Client? client}) : _client = client ?? http.Client();

//   Future<String?> reverse({required double lat, required double lon}) async {
//     final uri = Uri.https(
//       ApiConstants.mapboxBaseUrl,
//       '${ApiConstants.mapboxGeocodingPath}/$lon,$lat.json',
//       {
//         'access_token': ApiConstants.mapboxAccessToken,
//         'language': ApiConstants.mapboxLanguage,
//         'limit': '1',
//         'types': ApiConstants.mapboxTypes,
//       },
//     );

//     final res = await _client.get(uri).timeout(const Duration(seconds: 6));
//     if (res.statusCode != 200) return null;

//     final data = jsonDecode(res.body) as Map<String, dynamic>;
//     final features = (data['features'] as List?) ?? const [];
//     if (features.isEmpty) return null;

//     return features.first['place_name'] as String?;
//   }

//   Future<List<Map<String, dynamic>>> search({
//     required String query,
//     double? userLat,
//     double? userLon,
//     int limit = 5,
//     double? maxDistanceKm,
//   }) async {
//     if (query.trim().isEmpty) return [];

//     final uri = Uri.https(
//       ApiConstants.mapboxBaseUrl,
//       '${ApiConstants.mapboxGeocodingPath}/$query.json',
//       {
//         'access_token': ApiConstants.mapboxAccessToken,
//         'language': ApiConstants.mapboxLanguage,
//         'limit': '$limit',
//         'types': ApiConstants.mapboxTypes,
//         // Esto NO limita, pero sesga los resultados hacia tu posición
//         if (userLat != null && userLon != null)
//           'proximity': '$userLon,$userLat',
//       },
//     );

//     final res = await _client.get(uri).timeout(const Duration(seconds: 6));
//     if (res.statusCode != 200) return [];

//     final data = jsonDecode(res.body) as Map<String, dynamic>;
//     final features = (data['features'] as List?) ?? const [];

//     final List<Map<String, dynamic>> suggestions = features.map((item) {
//       final center = item['center'] as List?;
//       final double lon = (center?[0] as num?)?.toDouble() ?? 0;
//       final double lat = (center?[1] as num?)?.toDouble() ?? 0;

//       return {
//         'display_name': item['place_name'] ?? 'Sin nombre',
//         'lat': lat,
//         'lon': lon,
//       };
//     }).toList();

//     // 🔒 Filtro por distancia máxima (si se configuró)
//     if (maxDistanceKm != null && userLat != null && userLon != null) {
//       return suggestions.where((s) {
//         final lat = (s['lat'] as num).toDouble();
//         final lon = (s['lon'] as num).toDouble();
//         final d = _distanceKm(userLat, userLon, lat, lon);
//         return d <= maxDistanceKm;
//       }).toList();
//     }

//     return suggestions;
//   }

//   /// Distancia Haversine en km
//   double _distanceKm(double lat1, double lon1, double lat2, double lon2) {
//     const R = 6371.0; // Radio de la Tierra
//     final dLat = _deg2rad(lat2 - lat1);
//     final dLon = _deg2rad(lon2 - lon1);

//     final a =
//         sin(dLat / 2) * sin(dLat / 2) +
//         cos(_deg2rad(lat1)) *
//             cos(_deg2rad(lat2)) *
//             sin(dLon / 2) *
//             sin(dLon / 2);

//     final c = 2 * atan2(sqrt(a), sqrt(1 - a));
//     return R * c;
//   }

//   double _deg2rad(double deg) => deg * (pi / 180);

//   void dispose() => _client.close();
// }
import 'package:app_rtsg_client/core/constants/api_constants.dart';

import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

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
  }) async {
    final q = query.trim();
    if (q.isEmpty) return [];

    // normaliza límite
    final safeLimit = limit.clamp(1, 10);

    try {
      final encodedQuery = Uri.encodeComponent(q);

      final uri = Uri.https(
        ApiConstants.mapboxBaseUrl,
        '${ApiConstants.mapboxGeocodingPath}/$encodedQuery.json',
        {
          'access_token': ApiConstants.mapboxAccessToken,
          'language': ApiConstants.mapboxLanguage,
          'limit': '$safeLimit',
          'types': ApiConstants.mapboxTypes,
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

      // 🔒 Filtro por distancia máxima (si se configuró)
      if (maxDistanceKm != null && userLat != null && userLon != null) {
        return suggestions.where((s) {
          final lat = (s['lat'] as num).toDouble();
          final lon = (s['lon'] as num).toDouble();
          final d = _distanceKm(userLat, userLon, lat, lon);
          return d <= maxDistanceKm;
        }).toList();
      }

      return suggestions;
    } catch (_) {
      return [];
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

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:app_rtsg_client/core/constants/geoapify_config.dart';
import 'package:app_rtsg_client/data/services/mapbox_service.dart';

/// Adapts Geoapify responses to the location contract already used by the UI.
class GeoapifyGeocoder extends MapboxGeocoder {
  GeoapifyGeocoder({http.Client? client}) : this._(client ?? http.Client());
  GeoapifyGeocoder._(this._http) : super(client: _http);
  final http.Client _http;

  Future<Map<String, dynamic>?> _get(
    String endpoint,
    Map<String, String> parameters,
  ) async {
    try {
      final uri = Uri.parse(endpoint).replace(
        queryParameters: {...parameters, 'apiKey': GeoapifyConfig.apiKey},
      );
      final response = await _http.get(uri).timeout(GeoapifyConfig.timeout);
      if (kDebugMode) {
        debugPrint(
          '[RTSG][GEOAPIFY] ${uri.path} status=${response.statusCode}',
        );
      }
      if (response.statusCode != 200) return null;
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return data is Map<String, dynamic> ? data : null;
    } catch (_) {
      if (kDebugMode) {
        debugPrint('[RTSG][GEOAPIFY] No se pudo completar la consulta');
      }
      return null;
    }
  }

  @override
  Future<String?> reverse({required double lat, required double lon}) async {
    final data = await _get('${GeoapifyConfig.geocodingUrl}/reverse', {
      'lat': '$lat',
      'lon': '$lon',
      'lang': GeoapifyConfig.language,
      'limit': '1',
      'format': 'json',
    });
    final results = data?['results'];
    if (results is! List || results.isEmpty) return null;
    final first = results.first;
    return first is Map ? first['formatted'] as String? : null;
  }

  @override
  Future<List<Map<String, dynamic>>> search({
    required String query,
    double? userLat,
    double? userLon,
    int limit = 5,
    double? maxDistanceKm,
    String? country,
  }) async {
    if (query.trim().isEmpty) return [];
    final data = await _get('${GeoapifyConfig.geocodingUrl}/autocomplete', {
      'text': query.trim(),
      'lang': GeoapifyConfig.language,
      'limit': '${limit.clamp(1, 10)}',
      'format': 'json',
      if (country != null && country.trim().isNotEmpty)
        'filter': 'countrycode:${country.trim().toLowerCase()}',
      if (userLat != null && userLon != null)
        'bias': 'proximity:$userLon,$userLat',
    });
    final results = data?['results'];
    if (results is! List) return [];
    final suggestions = <Map<String, dynamic>>[];
    for (final item in results.whereType<Map>()) {
      final lat = (item['lat'] as num?)?.toDouble();
      final lon = (item['lon'] as num?)?.toDouble();
      if (lat == null ||
          lon == null ||
          !lat.isFinite ||
          !lon.isFinite ||
          lat.abs() > 90 ||
          lon.abs() > 180) {
        continue;
      }
      suggestions.add({
        'display_name': item['formatted'] ?? item['name'] ?? 'Sin nombre',
        'lat': lat,
        'lon': lon,
      });
    }
    if (userLat != null && userLon != null) {
      double distance(Map<String, dynamic> item) => const Distance()(
        LatLng(userLat, userLon),
        LatLng(item['lat'] as double, item['lon'] as double),
      );
      if (maxDistanceKm != null) {
        suggestions.removeWhere(
          (item) => distance(item) > maxDistanceKm * 1000,
        );
      }
      suggestions.sort((a, b) => distance(a).compareTo(distance(b)));
    }
    return suggestions;
  }

  @override
  Future<Map<String, dynamic>?> route({
    required LatLng origin,
    required LatLng destination,
    String profile = 'driving',
  }) async {
    final data = await _get(GeoapifyConfig.routingUrl, {
      'waypoints':
          '${origin.latitude},${origin.longitude}|${destination.latitude},${destination.longitude}',
      'mode': profile == 'walking'
          ? 'walk'
          : profile == 'cycling'
          ? 'bicycle'
          : 'drive',
      'lang': GeoapifyConfig.language,
      'units': 'metric',
      'format': 'geojson',
    });
    final features = data?['features'];
    if (features is! List || features.isEmpty || features.first is! Map) {
      return null;
    }
    final feature = features.first as Map;
    final properties = feature['properties'];
    final geometry = feature['geometry'];
    if (properties is! Map || geometry is! Map) return null;
    final distance = (properties['distance'] as num?)?.toDouble();
    final time = (properties['time'] as num?)?.toDouble();
    if (distance == null ||
        time == null ||
        !distance.isFinite ||
        !time.isFinite ||
        distance <= 0 ||
        time <= 0) {
      return null;
    }
    final coordinates = geometry['coordinates'];
    if (coordinates is! List) return null;
    final lines = geometry['type'] == 'LineString'
        ? [coordinates]
        : coordinates;
    final points = <LatLng>[];
    for (final line in lines.whereType<List>()) {
      for (final pair in line.whereType<List>()) {
        if (pair.length < 2 || pair[0] is! num || pair[1] is! num) continue;
        final lon = (pair[0] as num).toDouble(),
            lat = (pair[1] as num).toDouble();
        if (lat.isFinite &&
            lon.isFinite &&
            lat.abs() <= 90 &&
            lon.abs() <= 180) {
          points.add(LatLng(lat, lon));
        }
      }
    }
    if (points.length < 2) return null;
    return {'distance_m': distance, 'duration_s': time, 'points': points};
  }
}

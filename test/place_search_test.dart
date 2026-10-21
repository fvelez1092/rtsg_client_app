import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:app_rtsg_client/data/services/mapbox_service.dart';

Map<String, dynamic> feature(String name, double lon, double lat) => {
  'place_name': name,
  'center': [lon, lat],
};

void main() {
  test(
    'Search encodes accents and spaces exactly once and sends Portoviejo proximity',
    () async {
      final client = MockClient((request) async {
        expect(
          request.url.path,
          '/geocoding/v5/mapbox.places/terminal terrestre José.json',
        );
        expect(request.url.toString(), isNot(contains('%2520')));
        expect(request.url.queryParameters['proximity'], '-80.4553,-1.0546');
        expect(request.url.queryParameters['country'], 'ec');
        return http.Response(jsonEncode({'features': []}), 200);
      });
      await MapboxGeocoder(client: client).search(
        query: 'terminal terrestre José',
        userLat: -1.0546,
        userLon: -80.4553,
        country: 'ec',
      );
    },
  );
  test(
    'Nearby terminal is returned first while places beyond 50 km are excluded',
    () async {
      final service = MapboxGeocoder(
        client: MockClient(
          (_) async => http.Response(
            jsonEncode({
              'features': [
                feature('Terminal Terrestre, Mocache', -79.502554, -1.183806),
                feature('Otro lugar cercano', -80.49, -1.08),
                feature(
                  'Terminal Terrestre de Portoviejo (fixture)',
                  -80.455,
                  -1.055,
                ),
              ],
            }),
            200,
          ),
        ),
      );
      final results = await service.search(
        query: 'terminal terrestre',
        userLat: -1.0546,
        userLon: -80.4553,
        maxDistanceKm: 50,
      );
      expect(results.length, 2);
      expect(results.first['display_name'], contains('Portoviejo'));
      expect(results.first['lat'], -1.055);
      expect(results.first['lon'], -80.455);
    },
  );
  test(
    'Actual provider result for generic terminal query is outside the configured radius',
    () async {
      // Coordinates observed in the live response; this is not a Portoviejo POI.
      final service = MapboxGeocoder(
        client: MockClient(
          (_) async => http.Response(
            jsonEncode({
              'features': [
                feature(
                  'Terminal Terrestre, Mocache - Los Ríos, Ecuador',
                  -79.502554,
                  -1.183806,
                ),
                feature(
                  'Autopista Narcisa de Jesús, Guayaquil, Ecuador',
                  -79.896375,
                  -2.086701,
                ),
              ],
            }),
            200,
          ),
        ),
      );
      final results = await service.search(
        query: 'terminal terrestre',
        userLat: -1.0546,
        userLon: -80.4553,
        country: 'ec',
        maxDistanceKm: 50,
      );
      expect(results, isEmpty);
    },
  );
  test('Empty query makes no network request', () async {
    final service = MapboxGeocoder(
      client: MockClient((_) async => throw StateError('Must not request')),
    );
    expect(await service.search(query: '  '), isEmpty);
  });
}

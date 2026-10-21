import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:latlong2/latlong.dart';
import 'package:app_rtsg_client/data/services/geoapify_service.dart';
import 'package:app_rtsg_client/data/services/location_service_factory.dart';

void main() {
  test('Temporary factory selects Geoapify', () {
    final service = createLocationService();
    expect(service, isA<GeoapifyGeocoder>());
    service.dispose();
  });
  test(
    'Autocomplete sends country and proximity and adapts nearby results',
    () async {
      final service = GeoapifyGeocoder(
        client: MockClient((request) async {
          expect(request.url.path, '/v1/geocode/autocomplete');
          expect(request.url.queryParameters['text'], 'terminal terrestre');
          expect(request.url.queryParameters['filter'], 'countrycode:ec');
          expect(
            request.url.queryParameters['bias'],
            'proximity:-80.4553,-1.0546',
          );
          return http.Response(
            jsonEncode({
              'results': [
                {
                  'formatted': 'Terminal Portoviejo',
                  'lat': -1.055,
                  'lon': -80.455,
                },
                {'formatted': 'Mocache', 'lat': -1.183806, 'lon': -79.502554},
                {'formatted': 'Invalid', 'lat': 95, 'lon': 0},
              ],
            }),
            200,
          );
        }),
      );
      final results = await service.search(
        query: 'terminal terrestre',
        userLat: -1.0546,
        userLon: -80.4553,
        country: 'ec',
        maxDistanceKm: 50,
      );
      expect(results.single['display_name'], 'Terminal Portoviejo');
    },
  );
  test('Reverse geocodes the selected coordinates', () async {
    final service = GeoapifyGeocoder(
      client: MockClient((request) async {
        expect(request.url.path, '/v1/geocode/reverse');
        expect(request.url.queryParameters['lat'], '-1.05');
        return http.Response(
          jsonEncode({
            'results': [
              {'formatted': 'Portoviejo, Ecuador'},
            ],
          }),
          200,
        );
      }),
    );
    expect(
      await service.reverse(lat: -1.05, lon: -80.45),
      'Portoviejo, Ecuador',
    );
  });
  test('Routing adapts multi-line geometry, meters and seconds', () async {
    final service = GeoapifyGeocoder(
      client: MockClient((request) async {
        expect(request.url.path, '/v1/routing');
        expect(
          request.url.queryParameters['waypoints'],
          '-1.05,-80.45|-1.06,-80.46',
        );
        expect(request.url.queryParameters['mode'], 'drive');
        return http.Response(
          jsonEncode({
            'features': [
              {
                'properties': {'distance': 2500, 'time': 360},
                'geometry': {
                  'type': 'MultiLineString',
                  'coordinates': [
                    [
                      [-80.45, -1.05],
                      [-80.46, -1.06],
                    ],
                  ],
                },
              },
            ],
          }),
          200,
        );
      }),
    );
    final route = await service.route(
      origin: const LatLng(-1.05, -80.45),
      destination: const LatLng(-1.06, -80.46),
    );
    expect(route!['distance_m'], 2500);
    expect(route['duration_s'], 360);
    expect((route['points'] as List).first, const LatLng(-1.05, -80.45));
  });
  test('Provider rejection does not invent results or routes', () async {
    final service = GeoapifyGeocoder(
      client: MockClient((_) async => http.Response('{}', 429)),
    );
    expect(await service.search(query: 'terminal'), isEmpty);
    expect(await service.reverse(lat: -1, lon: -80), isNull);
    expect(
      await service.route(
        origin: const LatLng(-1, -80),
        destination: const LatLng(-1.1, -80.1),
      ),
      isNull,
    );
  });
}

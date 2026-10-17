import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_rtsg_client/data/models/tariff_configuration.dart';
import 'package:app_rtsg_client/data/services/tariff_configuration_service.dart';
import 'profile_photo_test.dart' show PhotoAdapter;

Map<String, dynamic> configuration() => {
  'company_id': 17,
  'moneda': 'USD',
  'configuracion_predeterminada': false,
  'actualizado_en': '2026-10-17T20:00:00.000Z',
  'hora_inicio_diurno': '06:00',
  'hora_inicio_nocturno': '19:00',
  'arranque_diurno': 0.5,
  'arranque_nocturno': 0.63,
  'costo_km_diurno': 0.34,
  'costo_km_nocturno': 0.43,
  'carrera_minima_diurna': 1.25,
  'carrera_minima_nocturna': 1.5,
  'distancia_minima_km': 2.2,
  'costo_minuto_espera': 0.1,
};

void main() {
  test(
    'Minimum covers first 2.2 km; only excess and actual waiting are added',
    () {
      final config = TariffConfiguration.fromJson(configuration());
      final day = DateTime.parse('2026-10-17T17:00:00Z');
      final night = DateTime.parse('2026-10-18T02:00:00Z');
      expect(config.estimate(distanceKm: 1, at: day), 1.25);
      expect(config.estimate(distanceKm: 2.2, at: day), 1.25);
      expect(config.estimate(distanceKm: 5, at: day), 2.20);
      expect(config.estimate(distanceKm: 2.2, at: night), 1.50);
      expect(config.estimate(distanceKm: 5, at: night), 2.70);
      expect(config.estimate(distanceKm: 5, at: day, waitingMinutes: 3), 2.50);
      expect(
        () => config.estimate(distanceKm: double.nan, at: day),
        throwsArgumentError,
      );
    },
  );
  test(
    'Configuration uses authenticated client path and parses server fields',
    () async {
      final adapter = PhotoAdapter()
        ..responseBody = {'estado': true, 'datos': configuration()};
      final dio = Dio(
        BaseOptions(
          baseUrl: 'https://example.test/api/v3',
          headers: {'x-access-token': 'jwt'},
        ),
      )..httpClientAdapter = adapter;
      final config = await TariffConfigurationService(
        dio: dio,
      ).getConfiguration();
      expect(adapter.request!.method, 'GET');
      expect(adapter.request!.uri.path, '/api/v3/tarifa.configuracion');
      expect(adapter.request!.headers['x-access-token'], 'jwt');
      expect(config.companyId, 17);
      expect(config.currency, 'USD');
      expect(config.minimumDistanceKm, 2.2);
      expect(config.waitCostPerMinute, .1);
      adapter.responseBody = {'estado': false, 'observacion': 'Sin acceso'};
      await expectLater(
        TariffConfigurationService(dio: dio).getConfiguration(),
        throwsException,
      );
    },
  );
  test(
    'Day and night follow company boundaries regardless of device timezone',
    () {
      final config = TariffConfiguration.fromJson(configuration());
      expect(config.isNightAt(DateTime.parse('2026-10-17T10:59:59Z')), isTrue);
      expect(config.isNightAt(DateTime.parse('2026-10-17T11:00:00Z')), isFalse);
      expect(config.isNightAt(DateTime.parse('2026-10-17T23:59:59Z')), isFalse);
      expect(config.isNightAt(DateTime.parse('2026-10-18T00:00:00Z')), isTrue);
    },
  );
  test(
    'Malformed or negative tariff values are rejected instead of quoted as zero',
    () {
      expect(
        () => TariffConfiguration.fromJson(
          configuration()..remove('costo_km_diurno'),
        ),
        throwsFormatException,
      );
      expect(
        () => TariffConfiguration.fromJson(
          configuration()..['arranque_diurno'] = -1,
        ),
        throwsFormatException,
      );
      expect(
        () => TariffConfiguration.fromJson(
          configuration()..['hora_inicio_nocturno'] = '29:00',
        ),
        throwsFormatException,
      );
    },
  );
}

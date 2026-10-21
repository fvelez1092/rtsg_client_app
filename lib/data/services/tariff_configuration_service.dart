import 'package:app_rtsg_client/data/services/trip_diagnostics.dart';
import 'package:dio/dio.dart';
import 'package:app_rtsg_client/data/network/dio_client.dart';
import 'package:app_rtsg_client/data/models/tariff_configuration.dart';

class TariffConfigurationService {
  TariffConfigurationService({Dio? dio}) : _providedDio = dio;
  final Dio? _providedDio;
  Dio get _dio => _providedDio ?? ApiClient.dio;

  Future<TariffConfiguration> getConfiguration() async {
    try {
      final response = await _dio.get('/tarifa.configuracion');
      final body = response.data;
      logTripEvent('tarifa.respuesta', {
        'url': response.requestOptions.uri.toString(),
        'http_status': response.statusCode,
        'tipo_respuesta': body.runtimeType.toString(),
        'respuesta': body is Map ? body : '[Respuesta no JSON]',
      });
      if (body is! Map || body['estado'] != true || body['datos'] is! Map) {
        throw Exception(
          body is Map
              ? body['observacion'] ??
                    'No se pudo cargar la configuración de tarifas.'
              : 'Respuesta de tarifas inválida.',
        );
      }
      return TariffConfiguration.fromJson(
        Map<String, dynamic>.from(body['datos'] as Map),
      );
    } on DioException catch (error) {
      final body = error.response?.data;
      logTripEvent('tarifa.errorHttp', {
        'url': error.requestOptions.uri.toString(),
        'http_status': error.response?.statusCode,
        'tipo_error': error.type.name,
        'observacion': body is Map
            ? body['observacion'] ?? body['message']
            : null,
        'tipo_respuesta': body.runtimeType.toString(),
      });
      rethrow;
    } on FormatException catch (error) {
      logTripEvent('tarifa.errorFormato', {'motivo': error.message});
      rethrow;
    }
  }
}

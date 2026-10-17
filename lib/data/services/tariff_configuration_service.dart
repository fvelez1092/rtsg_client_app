import 'package:dio/dio.dart';
import 'package:app_rtsg_client/data/network/dio_client.dart';
import 'package:app_rtsg_client/data/models/tariff_configuration.dart';

class TariffConfigurationService {
  TariffConfigurationService({Dio? dio}) : _providedDio = dio;
  final Dio? _providedDio;
  Dio get _dio => _providedDio ?? ApiClient.dio;

  Future<TariffConfiguration> getConfiguration() async {
    final response = await _dio.get('/tarifa.configuracion');
    final body = response.data;
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
  }
}

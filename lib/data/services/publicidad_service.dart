import 'package:app_rtsg_client/data/models/partnert_model.dart';
import 'package:app_rtsg_client/data/network/dio_client.dart';
import 'package:dio/dio.dart';

class PublicidadService {
  final Dio _dio = ApiClient.dio;

  Future<List<PartnerAdModel>> getPublicidades() async {
    final response = await _dio.get('/publicidades');
    final body = _asMap(response.data, response.requestOptions);

    final success = body['estado'] == true || body['ok'] == true;
    if (!success) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
        error: (body['observacion'] ?? body['message'] ?? 'No se pudieron cargar las publicidades').toString(),
      );
    }

    final raw = body['datos'] ?? body['data'];
    if (raw is! List) return const <PartnerAdModel>[];

    final items = raw
        .whereType<Map>()
        .map((item) => PartnerAdModel.fromJson(Map<String, dynamic>.from(item)))
        .where((ad) => ad.active)
        .toList();

    items.sort((a, b) => b.priority.compareTo(a.priority));
    return items;
  }

  Map<String, dynamic> _asMap(dynamic data, RequestOptions requestOptions) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);

    throw DioException(
      requestOptions: requestOptions,
      type: DioExceptionType.badResponse,
      error: 'Respuesta no válida del servidor',
    );
  }
}

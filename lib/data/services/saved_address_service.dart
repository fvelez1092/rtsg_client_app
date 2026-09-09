import 'package:app_rtsg_client/data/models/saved_address_model.dart';
import 'package:app_rtsg_client/data/network/dio_client.dart';
import 'package:app_rtsg_client/global_memory.dart';
import 'package:dio/dio.dart';

class SavedAddressService {
  final Dio _dio = ApiClient.dio;

  int get _personId {
    final personId = GlobalMemory.to.user?.idPerson;
    if (personId == null) {
      throw StateError('No se encontró la persona del usuario autenticado');
    }
    return personId;
  }

  Future<List<SavedAddress>> getAll() async {
    final response = await _dio.get(
      '/direccion',
      queryParameters: {'persona_id': _personId},
    );
    final body = _asMap(response.data, response.requestOptions);

    if (body['estado'] != true && body['ok'] != true) {
      throw _apiException(response, body);
    }

    final raw = body['datos'] ?? body['data'];
    if (raw is! List) return const <SavedAddress>[];

    return raw
        .whereType<Map>()
        .map((item) => SavedAddress.fromJson(Map<String, dynamic>.from(item)))
        .where((address) => address.active)
        .toList();
  }

  Future<void> save(SavedAddress address) async {
    final addresses = await getAll();
    final id = address.id;
    final index = id == null
        ? -1
        : addresses.indexWhere((item) => item.id == id);

    if (index >= 0) {
      addresses[index] = address;
    } else {
      addresses.add(address);
    }

    await updateAll(addresses);
  }

  Future<void> remove(int? id) async {
    if (id == null) return;
    final addresses = (await getAll())
      ..removeWhere((address) => address.id == id);
    await updateAll(addresses);
  }

  Future<void> updateAll(List<SavedAddress> addresses) async {
    final response = await _dio.put(
      '/direccion',
      data: {
        'persona_id': _personId,
        'direcciones': addresses
            .map((address) => address.toUpdateJson())
            .toList(),
      },
    );
    final body = _asMap(response.data, response.requestOptions);

    if (body['estado'] != true && body['ok'] != true) {
      throw _apiException(response, body);
    }
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

  DioException _apiException(
    Response<dynamic> response,
    Map<String, dynamic> body,
  ) {
    return DioException(
      requestOptions: response.requestOptions,
      response: response,
      type: DioExceptionType.badResponse,
      error: (body['observacion'] ??
              body['message'] ??
              'No se pudieron actualizar las direcciones')
          .toString(),
    );
  }
}

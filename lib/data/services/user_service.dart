import 'package:app_rtsg_client/data/models/user_model.dart';
import 'package:app_rtsg_client/data/network/dio_client.dart';
import 'package:dio/dio.dart';

class UserService {
  final Dio _dio = ApiClient.dio;

  Future<User> getUserByToken() async {
    try {
      final response = await _dio.get('/user.by.token');
      final raw = response.data;

      if (raw is! Map) {
        throw Exception('Respuesta de usuario no válida');
      }

      final body = Map<String, dynamic>.from(raw);
      if (body['estado'] == false || body['ok'] == false) {
        throw Exception(
          (body['observacion'] ??
                  body['message'] ??
                  'No se pudo obtener el usuario')
              .toString(),
        );
      }

      dynamic data = body['datos'] ?? body['data'] ?? body['user'] ?? body;
      if (data is List) {
        if (data.isEmpty) throw Exception('No se encontró el usuario');
        data = data.first;
      }
      if (data is Map && data['user'] is Map) {
        data = data['user'];
      }
      if (data is! Map) {
        throw Exception('Datos de usuario no válidos');
      }

      return User.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (error) {
      throw Exception(
        'Error al obtener usuario: ${error.response?.data ?? error.message}',
      );
    }
  }

  /// GET: obtiene perfil usando id_person
  Future<User> getProfileByPersonId(int idPerson) async {
    try {
      final Response resp = await _dio.get(
        '/client/search',
        queryParameters: {'id_person': idPerson},
      );

      final List dataList = resp.data['data'];
      if (dataList.isEmpty) throw Exception('No se encontró el usuario');

      final data = dataList.first;
      return User.fromJson(data);
    } on DioException catch (e) {
      throw Exception(
        'Error al obtener perfil: ${e.response?.data ?? e.message}',
      );
    }
  }

  Future<User> updateUser(Map<String, dynamic> payload) async {
    try {
      final Response resp = await _dio.put(
        '/client',
        data: {
          "data": payload, // 👈 el backend espera el objeto dentro de "data"
        },
      );

      // Si el backend responde igual con { "data": { ...usuario... } }
      // entonces tomamos resp.data['data']
      final data = resp.data is Map && resp.data['data'] != null
          ? resp.data['data']
          : resp.data;

      return User.fromJson(data[0]);
    } on DioException catch (e) {
      throw Exception(
        'Error al actualizar perfil: ${e.response?.data ?? e.message}',
      );
    }
  }

  /// GET /client/address
  /// Devuelve la lista de direcciones guardadas por el usuario actual
  // Future<List<Address>> getAddresses() async {
  //   try {
  //     final Response resp = await _dio.get('/client/address/user');
  //     final data = resp.data['data'];

  //     if (data is List) {
  //       return data
  //           .map((json) => Address.fromJson(json as Map<String, dynamic>))
  //           .toList();
  //     }

  //     // si no es lista, fallback vacío (o lanzar)
  //     return [];
  //   } on DioException catch (e) {
  //     throw Exception(
  //       'Error al obtener direcciones: ${e.response?.data ?? e.message}',
  //     );
  //   }
  // }

  Future<void> createAddress(Map<String, dynamic> data) async {
    final resp = await _dio.post('/client/address', data: data);
    // o '/user/address' según tu backend
    if (resp.statusCode != 200 && resp.statusCode != 201) {
      throw Exception('No se pudo crear la dirección');
    }
  }

  // Future<Address> updateAddress(Map<String, dynamic> payload) async {
  //   try {
  //     final Response resp = await _dio.put(
  //       '/client/address',
  //       data: {"data": payload},
  //     );
  //     final data = resp.data is Map && resp.data['data'] != null
  //         ? resp.data['data']
  //         : resp.data;

  //     if (data is List && data.isNotEmpty) {
  //       return Address.fromJson(data.first);
  //     }
  //     if (data is Map<String, dynamic>) {
  //       return Address.fromJson(data);
  //     }

  //     throw Exception(
  //       'Respuesta inesperada del servidor al actualizar dirección',
  //     );
  //   } on DioException catch (e) {
  //     throw Exception(
  //       'Error al actualizar dirección: ${e.response?.data ?? e.message}',
  //     );
  //   }
  // }
}

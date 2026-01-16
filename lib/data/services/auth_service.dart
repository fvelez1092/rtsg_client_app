import 'package:app_rtsg_client/data/network/dio_client.dart';
import 'package:dio/dio.dart';

class AuthService {
  final Dio _dio = ApiClient.dio;

  // Future<LoginResponse> login(LoginRequest loginRequest) async {
  //   try {
  //     final Response response = await _dio.post(
  //       '/auth',
  //       data: {
  //         "user": loginRequest.userName,
  //         "password": loginRequest.password,
  //       },
  //     );
  //     return LoginResponse.fromJson(response.data);
  //   } on DioException catch (e) {
  //     if (e.response?.statusCode == 500) {
  //       try {
  //         final err = LoginResponseError.fromJson(e.response?.data);
  //         throw Exception("Error del servidor: ${err.observacion}");
  //       } catch (_) {
  //         throw Exception("Error del servidor (500)");
  //       }
  //     }
  //     final msg = e.response?.data is Map<String, dynamic>
  //         ? (e.response?.data['message'] ?? e.message)
  //         : e.message;
  //     throw Exception("Error de autenticación: $msg");
  //   } catch (e) {
  //     throw Exception("Error de inicio de sesión: $e");
  //   }
  // }

  Future<void> registerDevice(String deviceCode) async {
    try {
      final response = await _dio.post(
        '/register/device',
        data: {"device_code": deviceCode},
      );

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final map = response.data as Map<String, dynamic>;
        final ok = map['ok'] == true;

        if (!ok) {
          final msg = map['error'] ?? map['message'] ?? 'Error desconocido';
          throw Exception('Error al registrar dispositivo: $msg');
        }
        print('✅ Dispositivo registrado correctamente: ${map['message']}');
        return;
      } else {
        throw Exception('Respuesta inesperada del servidor');
      }
    } on DioException catch (e) {
      final msg = e.response?.data is Map<String, dynamic>
          ? (e.response?.data['error'] ?? e.response?.data['message'])
          : e.message;
      throw Exception('Error al registrar dispositivo: $msg');
    } catch (e) {
      throw Exception('Error general al registrar dispositivo: $e');
    }
  }
}

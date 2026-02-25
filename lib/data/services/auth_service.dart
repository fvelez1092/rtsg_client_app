import 'package:dio/dio.dart';
import 'package:app_rtsg_client/data/network/dio_client.dart';

import 'package:app_rtsg_client/data/models/request/login_request.dart';
import 'package:app_rtsg_client/data/models/response/login_response.dart';

class AuthService {
  final Dio _dio = ApiClient.dio;

  Future<LoginResponse> login(LoginRequest req) async {
    try {
      final res = await _dio.post(
        '/auth',
        data: {"user": req.userName, "password": req.password},
      );
      return LoginResponse.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_extractMessage(e));
    }
  }

  /// 🔎 Consultar cliente por código (ya lo estabas usando)
  Future<Map<String, dynamic>> fetchClientByCode(String code) async {
    try {
      final res = await _dio.get(
        '/usuarios/mostrar.clientes',
        queryParameters: {"codigocliente": code},
      );
      if (res.data is Map<String, dynamic>) {
        return res.data as Map<String, dynamic>;
      }
      throw Exception("Cliente no encontrado");
    } on DioException catch (e) {
      throw Exception(_extractMessage(e));
    }
  }

  /// ✅ Generar clave (endpoint nuevo)
  Future<void> generatePassword({required String email}) async {
    try {
      await _dio.post('/api/v1/generar', data: {"correo": email});
    } on DioException catch (e) {
      throw Exception(_extractMessage(e));
    }
  }

  /// ✅ Actualizar usuario (endpoint nuevo)
  Future<void> updateUser(Map<String, dynamic> payload) async {
    try {
      await _dio.post('/usuarios/actualizar.usuario', data: payload);
    } on DioException catch (e) {
      throw Exception(_extractMessage(e));
    }
  }

  /// 🟡 Crear usuario: pendiente (simulado por ahora)
  Future<void> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    // Por ahora NO se llama en producción (pendiente)
    await Future.delayed(const Duration(milliseconds: 700));
  }

  String _extractMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      final msg = (data['error'] ?? data['message'] ?? '').toString();
      if (msg.trim().isNotEmpty) return msg;
    }
    return e.message ?? 'Auth error';
  }
}

import 'package:app_rtsg_client/routes/rtsg_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:app_rtsg_client/data/models/request/login_request.dart';
import 'package:app_rtsg_client/data/services/auth_service.dart';
import 'package:app_rtsg_client/global_memory.dart';

class AuthController extends GetxController {
  final AuthService _authService;
  final GlobalMemory _memory = GlobalMemory.to;

  AuthController({required AuthService authService})
      : _authService = authService;

  final RxBool isLoading = false.obs;
  final RxBool isPasswordVisible = false.obs;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final RxString error = ''.obs;

  Future<void> login() async {
    FocusManager.instance.primaryFocus?.unfocus();
    error.value = '';

    final email = emailController.text.trim();
    final pass = passwordController.text.trim();

    if (email.isEmpty || pass.isEmpty) {
      _showError('Ingresa tu usuario y contraseña.');
      return;
    }

    isLoading.value = true;

    try {
      final response = await _authService.login(LoginRequest(email, pass));

      if (!response.success) {
        throw Exception(
          response.error ??
              response.message ??
              'No fue posible iniciar sesión.',
        );
      }

      final token = response.token;
      final user = response.user;

      if (token == null || token.trim().isEmpty) {
        throw Exception('El servidor no devolvió un token de sesión.');
      }

      if (user == null) {
        throw Exception('El servidor no devolvió los datos del usuario.');
      }

      await _memory.setToken(token);
      await _memory.setUser(user);

      Get.offAllNamed(AppRoutes.DASHBOARD);
    } catch (e) {
      _showError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }

  void _showError(String message) {
    error.value = message;
    Get.snackbar(
      'No pudimos iniciar sesión',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF202020),
      colorText: Colors.white,
      margin: const EdgeInsets.all(10),
      borderRadius: 10,
    );
  }

  Future<void> logout() async {
    await _memory.logout();
    Get.offAllNamed(AppRoutes.LOGIN);
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}

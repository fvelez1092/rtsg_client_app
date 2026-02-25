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
    isLoading.value = true;

    try {
      final email = emailController.text.trim();
      final pass = passwordController.text.trim();

      if (email.isEmpty || pass.isEmpty) {
        throw Exception('Please enter your credentials');
      }

      final res = await _authService.login(LoginRequest(email, pass));

      if (res.ok != true) {
        throw Exception(res.error ?? res.message ?? 'Invalid credentials');
      }

      final token = res.token;
      final user = res.data?.user;

      if (token == null || token.trim().isEmpty)
        throw Exception('Token not received');
      if (user == null) throw Exception('User not received');

      await _memory.setToken(token);
      await _memory.setUser(user);

      Get.offAllNamed(AppRoutes.HOME);
    } catch (e) {
      error.value = e.toString().replaceFirst('Exception: ', '');
      Get.snackbar(
        'Error',
        error.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF202020),
        colorText: Colors.white,
        margin: const EdgeInsets.all(10),
        borderRadius: 10,
      );
    } finally {
      isLoading.value = false;
    }
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

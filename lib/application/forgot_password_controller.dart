import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:app_rtsg_client/data/services/auth_service.dart';

class ForgotPasswordController extends GetxController {
  final AuthService _authService;
  ForgotPasswordController({required AuthService authService})
    : _authService = authService;

  final RxBool isLoading = false.obs;
  final emailController = TextEditingController();

  Future<void> sendReset() async {
    FocusManager.instance.primaryFocus?.unfocus();
    isLoading.value = true;

    try {
      final email = emailController.text.trim();
      if (email.isEmpty) throw Exception('Enter your email');

      //await _authService.requestPasswordReset(email: email);

      Get.snackbar(
        'Done',
        'Check your email for reset instructions',
        snackPosition: SnackPosition.BOTTOM,
      );
      Get.back();
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF202020),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}

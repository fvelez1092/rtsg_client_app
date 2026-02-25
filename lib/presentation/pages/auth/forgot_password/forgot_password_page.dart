import 'package:app_rtsg_client/application/forgot_password_controller.dart';
import 'package:app_rtsg_client/core/theme/app_colors.dart';
import 'package:app_rtsg_client/presentation/pages/auth/components/auth_header.dart';
import 'package:app_rtsg_client/presentation/pages/auth/components/auth_primary_button.dart';
import 'package:app_rtsg_client/presentation/pages/auth/components/auth_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgotPasswordPage extends GetView<ForgotPasswordController> {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('Forgot password'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AuthHeader(
                  title: 'Reset password',
                  subtitle: 'We will send you an email with instructions',
                ),
                const SizedBox(height: 18),

                AuthTextField(
                  controller: controller.emailController,
                  label: 'Email',
                  icon: Icons.mail_outline,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 18),

                AuthPrimaryButton(
                  text: 'Send reset link',
                  isLoading: controller.isLoading,
                  onPressed: controller.sendReset,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:app_rtsg_client/core/theme/app_colors.dart';
import 'package:app_rtsg_client/presentation/pages/auth/components/auth_header.dart';
import 'package:app_rtsg_client/presentation/pages/auth/components/auth_link_button.dart';
import 'package:app_rtsg_client/presentation/pages/auth/components/auth_password.dart';
import 'package:app_rtsg_client/presentation/pages/auth/components/auth_primary_button.dart';
import 'package:app_rtsg_client/presentation/pages/auth/components/auth_text_field.dart';
import 'package:app_rtsg_client/routes/rtsg_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:app_rtsg_client/application/auth_controller.dart';

class LoginPage extends GetView<AuthController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AuthHeader(
                  title: 'RadioTaxi "San Gregorio"',
                  subtitle: 'Sign in with your email',
                ),
                const SizedBox(height: 18),

                AuthTextField(
                  controller: controller.emailController,
                  label: 'Email',
                  icon: Icons.person_outline,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),

                AuthPasswordField(
                  controller: controller.passwordController,
                  label: 'Password',
                  isVisible: controller.isPasswordVisible,
                  onToggle: controller.isPasswordVisible.toggle,
                ),
                const SizedBox(height: 18),

                AuthPrimaryButton(
                  text: 'Sign In',
                  isLoading: controller.isLoading,
                  onPressed: controller.login,
                ),

                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AuthLinkButton(
                      text: 'Create account',
                      onTap: () => Get.toNamed(AppRoutes.REGISTER),
                    ),
                    AuthLinkButton(
                      text: 'Forgot password?',
                      onTap: () => Get.toNamed(AppRoutes.FORGOT_PASSWORD),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

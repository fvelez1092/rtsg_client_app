import 'package:app_rtsg_client/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class LoginInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;

  const LoginInput({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.textSecondary),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.borderSoft),
          borderRadius: BorderRadius.circular(50),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.borderSoft),
          borderRadius: BorderRadius.circular(50),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.surface,
      ),
      style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
      cursorColor: AppColors.textPrimary,
    );
  }
}

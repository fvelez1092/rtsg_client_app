import 'package:app_rtsg_client/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PasswordInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final RxBool isVisible;
  final VoidCallback onToggle;

  const PasswordInput({
    super.key,
    required this.controller,
    required this.label,
    required this.isVisible,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final visible = isVisible.value;
      return TextFormField(
        controller: controller,
        obscureText: !visible,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: IconButton(
            icon: Icon(
              visible ? Icons.visibility_off : Icons.visibility,
              color: AppColors.textSecondary,
            ),
            onPressed: onToggle,
          ),
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
    });
  }
}

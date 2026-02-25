import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app_rtsg_client/core/theme/app_colors.dart';

class AuthPasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final RxBool isVisible;
  final VoidCallback onToggle;

  const AuthPasswordField({
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
          filled: true,
          fillColor: AppColors.surface,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: const BorderSide(color: AppColors.borderSoft),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: const BorderSide(color: AppColors.borderSoft),
          ),
        ),
        style: const TextStyle(color: AppColors.textPrimary),
      );
    });
  }
}

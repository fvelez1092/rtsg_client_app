import 'package:app_rtsg_client/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginButton extends StatelessWidget {
  final RxBool isLoading;
  final VoidCallback onPressed;
  final String text;

  const LoginButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final loading = isLoading.value;

      return SizedBox(
        height: 52,
        child: ElevatedButton(
          onPressed: loading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.taxiYellow,
            foregroundColor: AppColors.textPrimary,
            padding: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          child: loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(text),
        ),
      );
    });
  }
}

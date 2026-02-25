import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app_rtsg_client/core/theme/app_colors.dart';

class AuthPrimaryButton extends StatelessWidget {
  final String text;
  final RxBool isLoading;
  final VoidCallback onPressed;

  const AuthPrimaryButton({
    super.key,
    required this.text,
    required this.isLoading,
    required this.onPressed,
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
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

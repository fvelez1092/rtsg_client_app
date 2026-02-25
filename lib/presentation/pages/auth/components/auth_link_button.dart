import 'package:flutter/material.dart';
import 'package:app_rtsg_client/core/theme/app_colors.dart';

class AuthLinkButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const AuthLinkButton({super.key, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: Text(
          text,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }
}

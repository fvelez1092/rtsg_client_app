import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app_rtsg_client/application/splash_controller.dart';
import 'package:app_rtsg_client/core/theme/app_colors.dart';

class SplashPage extends GetView<SplashController> {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    controller; // ensure init

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: TweenAnimationBuilder(
          duration: const Duration(milliseconds: 900),
          tween: Tween<double>(begin: 0.7, end: 1),
          builder: (context, double value, child) {
            return Transform.scale(
              scale: value,
              child: Opacity(opacity: value, child: child),
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/app_logo.png', height: 120),
              const SizedBox(height: 16),
              const Text(
                "RadioTaxi San Gregorio",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 18),
              const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

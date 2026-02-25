import 'package:app_rtsg_client/routes/rtsg_routes.dart';
import 'package:flutter/material.dart';
import 'package:app_rtsg_client/core/theme/app_colors.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ListTile(
              title: Text(
                'Menú',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Divider(height: 1),
            ListTile(
              onTap: () {
                Get.toNamed(AppRoutes.PROFILE);
              },
              leading: const Icon(Icons.person, color: AppColors.textPrimary),
              title: const Text(
                'Perfil',
                style: TextStyle(color: AppColors.textPrimary),
              ),
            ),
            const ListTile(
              leading: Icon(Icons.history, color: AppColors.textPrimary),
              title: Text(
                'Historial',
                style: TextStyle(color: AppColors.textPrimary),
              ),
            ),
            const ListTile(
              leading: Icon(Icons.settings, color: AppColors.textPrimary),
              title: Text(
                'Configuración',
                style: TextStyle(color: AppColors.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

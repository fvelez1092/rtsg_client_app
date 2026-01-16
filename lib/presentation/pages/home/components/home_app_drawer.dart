import 'package:flutter/material.dart';
import 'package:app_rtsg_client/core/theme/app_colors.dart';

class HomeAppDrawer extends StatelessWidget {
  const HomeAppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text(
                'Menú',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Divider(height: 1),
            ListTile(
              leading: Icon(Icons.person, color: AppColors.textPrimary),
              title: Text(
                'Perfil',
                style: TextStyle(color: AppColors.textPrimary),
              ),
            ),
            ListTile(
              leading: Icon(Icons.history, color: AppColors.textPrimary),
              title: Text(
                'Historial',
                style: TextStyle(color: AppColors.textPrimary),
              ),
            ),
            ListTile(
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

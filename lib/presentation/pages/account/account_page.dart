import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:app_rtsg_client/core/theme/app_colors.dart';
import 'package:app_rtsg_client/global_memory.dart';
import 'package:app_rtsg_client/presentation/pages/account/saved_addresses_page.dart';
import 'package:app_rtsg_client/presentation/widgets/main_bottom_navigation.dart';
import 'package:app_rtsg_client/routes/rtsg_routes.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = GlobalMemory.to.user;
    final name = (user?.razonSocial ?? user?.username ?? user?.user ?? 'Usuario RTSG')
        .trim();
    final email = (user?.email ?? 'usuario@rtsg.ec').trim();
    final phone = (user?.cellphone ?? '+593 99 000 0000').trim();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
          children: [
            const Text(
              'Mi cuenta',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 25,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.borderSoft),
              ),
              child: Row(
                children: [
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: AppColors.brandGreen.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      size: 36,
                      color: AppColors.brandGreen,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name.isEmpty ? 'Usuario RTSG' : name,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          phone,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const _SectionTitle('Perfil y seguridad'),
            const SizedBox(height: 10),
            _AccountOption(
              icon: Icons.badge_outlined,
              title: 'Información personal',
              subtitle: 'Nombre, teléfono, dirección y foto',
              onTap: () => Get.toNamed(AppRoutes.PROFILE),
            ),
            _AccountOption(
              icon: Icons.location_on_outlined,
              title: 'Direcciones guardadas',
              subtitle: 'Casa, trabajo y lugares frecuentes',
              onTap: () => Get.to(() => const SavedAddressesPage()),
            ),
            _AccountOption(
              icon: Icons.shield_outlined,
              title: 'Seguridad',
              subtitle: 'Contraseña y acceso a tu cuenta',
              onTap: () => _mockMessage('Seguridad de la cuenta'),
            ),
            const SizedBox(height: 20),
            const _SectionTitle('Preferencias'),
            const SizedBox(height: 10),
            _AccountOption(
              icon: Icons.notifications_none_rounded,
              title: 'Notificaciones',
              subtitle: 'Viajes, promociones y recordatorios',
              onTap: () => _mockMessage('Preferencias de notificaciones'),
            ),
            _AccountOption(
              icon: Icons.help_outline_rounded,
              title: 'Ayuda y soporte',
              subtitle: 'Preguntas frecuentes y contacto',
              onTap: () => _mockMessage('Centro de ayuda'),
            ),
            _AccountOption(
              icon: Icons.description_outlined,
              title: 'Términos y privacidad',
              subtitle: 'Información legal de RTSG',
              onTap: () => _mockMessage('Términos y privacidad'),
            ),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: () async {
                await GlobalMemory.to.logout();
                Get.offAllNamed(AppRoutes.LOGIN);
              },
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Cerrar sesión'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.brandRed,
                side: const BorderSide(color: AppColors.brandRed),
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const MainBottomNavigation(currentIndex: 3),
    );
  }

  static void _mockMessage(String feature) {
    Get.snackbar(
      feature,
      'Vista preparada para conectar esta función al backend.',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _AccountOption extends StatelessWidget {
  const _AccountOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(17),
        ),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.brandGreen.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.brandGreen),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

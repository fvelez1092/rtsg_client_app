import 'package:app_rtsg_client/application/profile_controller.dart';
import 'package:app_rtsg_client/core/theme/light_theme.dart';
import 'package:app_rtsg_client/data/services/local_storage_service.dart';
import 'package:app_rtsg_client/presentation/pages/profile/components/profile_info_card.dart';
import 'package:app_rtsg_client/presentation/pages/profile/components/profile_section_title.dart';
import 'package:app_rtsg_client/routes/rtsg_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfilePage extends GetView<ProfileController> {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // ---------------- HEADER (kept in page) ----------------
          Container(
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [cs.primary, _darken(cs.primary, 0.12)],
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _iconButton(
                      context,
                      Icons.arrow_back,
                      onTap: () => Get.back(),
                    ),
                    Text(
                      "Mi Perfil",
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: cs.onPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 40, height: 40), // no edit icon
                  ],
                ),
                const SizedBox(height: 24),

                // Avatar + camera button
                Stack(
                  children: [
                    Obx(() {
                      final provider = controller.avatarImageProvider;

                      return CircleAvatar(
                        radius: 48,
                        backgroundColor: Colors.white24,
                        backgroundImage: provider,
                        child: provider == null
                            ? const Icon(
                                Icons.person,
                                size: 48,
                                color: Colors.white,
                              )
                            : null,
                      );
                    }),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => _showPhotoPickerSheet(context),
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: cs.secondary,
                          child: Icon(
                            Icons.camera,
                            size: 14,
                            color: ColorsApp.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),
                Obx(() {
                  return Text(
                    controller.fullName,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: cs.onPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  );
                }),
                const SizedBox(height: 4),
                Text(
                  "Conductor Profesional",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onPrimary.withValues(alpha: 0.75),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.star, color: cs.secondary, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      "4.8",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "156 viajes",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onPrimary.withValues(alpha: 0.75),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ---------------- BODY ----------------
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(32),
              ),
            ),
            child: Obx(() {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // Personal
                  const ProfileSectionTitle(
                    icon: Icons.person,
                    title: "Información Personal",
                  ),
                  const SizedBox(height: 12),
                  ProfileInfoCard(
                    items: [
                      ProfileInfoItem(
                        label: "Nombre completo",
                        value: controller.fullName,
                      ),
                      ProfileInfoItem(
                        label: "Teléfono",
                        value: controller.phone,
                      ),
                      ProfileInfoItem(
                        label: "Correo electrónico",
                        value: controller.email,
                      ),
                      ProfileInfoItem(
                        label: "Dirección principal",
                        value: controller.address,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Vehicle
                  ProfileSectionTitle(
                    icon: Icons.car_crash_outlined,
                    title: "Información del Vehículo",
                    //onPress: () {},
                  ),
                  const SizedBox(height: 16),

                  // ---------------- SETTINGS (kept in page) ----------------
                  ProfileSectionTitle(
                    icon: Icons.settings,
                    title: "Configuración",
                  ),
                  const SizedBox(height: 12),
                  _settingsTile(
                    context,
                    icon: Icons.notifications,
                    label: "Notificaciones",
                  ),
                  _settingsTile(
                    context,
                    icon: Icons.privacy_tip_outlined,
                    label: "Privacidad",
                  ),
                  _settingsTile(context, icon: Icons.headset, label: "Soporte"),

                  const SizedBox(height: 12),

                  // ---------------- LOGOUT (kept in page) ----------------
                  _logoutButton(context),

                  const SizedBox(height: 80),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  // --------------------- UI HELPERS (page-level) ---------------------

  Widget _iconButton(
    BuildContext context,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: cs.onPrimary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: cs.onPrimary.withValues(alpha: 0.10)),
        ),
        child: Icon(icon, color: cs.onPrimary),
      ),
    );
  }

  Widget _settingsTile(
    BuildContext context, {
    required IconData icon,
    required String label,
  }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cs.onSurface.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: cs.onSurface.withValues(alpha: 0.55)),
              const SizedBox(width: 12),
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          Icon(
            Icons.chevron_right,
            color: cs.onSurface.withValues(alpha: 0.45),
          ),
        ],
      ),
    );
  }

  Widget _logoutButton(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: cs.surface,
            title: Text(
              "Cerrar sesión",
              style: theme.textTheme.titleMedium?.copyWith(
                color: cs.onSurface,
                fontWeight: FontWeight.w900,
              ),
            ),
            content: Text(
              "¿Estás seguro de que quieres cerrar sesión?",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.75),
                fontWeight: FontWeight.w600,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Cancelar",
                  style: TextStyle(color: cs.onSurface.withValues(alpha: 0.75)),
                ),
              ),
              TextButton(
                onPressed: () {
                  Get.find<LocalStorage>().clearData();
                  Get.offAllNamed(AppRoutes.LOGIN);
                },
                child: Text(
                  "Cerrar sesión",
                  style: TextStyle(
                    color: cs.secondary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Color.alphaBlend(
            Colors.red.withValues(alpha: 0.10),
            cs.surface,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.red.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.output_outlined, color: Colors.red),
            const SizedBox(width: 8),
            Text(
              "Cerrar sesión",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPhotoPickerSheet(BuildContext context) {
    final controller = Get.find<ProfileController>();
    final cs = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text("Tomar foto"),
                  onTap: () async {
                    Navigator.pop(context);
                    await controller.pickPhoto(ProfilePhotoSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text("Elegir de galería"),
                  onTap: () async {
                    Navigator.pop(context);
                    await controller.pickPhoto(ProfilePhotoSource.gallery);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.close),
                  title: const Text("Cancelar"),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

Color _darken(Color c, double amount) {
  final hsl = HSLColor.fromColor(c);
  final light = (hsl.lightness - amount).clamp(0.0, 1.0);
  return hsl.withLightness(light).toColor();
}

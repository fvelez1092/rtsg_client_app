import 'package:app_rtsg_client/application/profile_controller.dart';
import 'package:app_rtsg_client/core/theme/app_colors.dart';
import 'package:app_rtsg_client/presentation/pages/profile/components/profile_photo_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class ProfilePage extends GetView<ProfileController> {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    appBar: AppBar(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.textPrimary,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      title: const Text(
        'Información personal',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
      ),
    ),
    body: SafeArea(
      top: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          _card(
            Column(
              children: [
                ProfilePhotoEditor(controller: controller),
                const SizedBox(height: 12),
                Obx(
                  () => Text(
                    controller.fullName.isEmpty
                        ? 'Cliente RTSG'
                        : controller.fullName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Tu perfil de cliente',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.inputFill,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Obx(() {
                    final code = controller.customerCode;
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                      ),
                      leading: const Icon(
                        Icons.badge_outlined,
                        color: AppColors.brandGreen,
                      ),
                      title: const Text(
                        'Código de cliente',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      subtitle: Text(
                        code,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      trailing: code == 'No disponible'
                          ? null
                          : IconButton(
                              tooltip: 'Copiar código',
                              icon: const Icon(Icons.copy_outlined, size: 20),
                              onPressed: () async {
                                await Clipboard.setData(
                                  ClipboardData(text: code),
                                );
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Código copiado'),
                                    ),
                                  );
                                }
                              },
                            ),
                    );
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Datos personales',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Obx(
            () => _card(
              Column(
                children: [
                  _detail(
                    Icons.person_outline_rounded,
                    'Nombre completo',
                    controller.fullName,
                  ),
                  const Divider(height: 28, color: AppColors.borderSoft),
                  _detail(Icons.phone_outlined, 'Teléfono', controller.phone),
                  const Divider(height: 28, color: AppColors.borderSoft),
                  _detail(
                    Icons.mail_outline_rounded,
                    'Correo electrónico',
                    controller.email,
                  ),
                  const Divider(height: 28, color: AppColors.borderSoft),
                  _detail(
                    Icons.location_on_outlined,
                    'Dirección principal',
                    controller.loadingAddresses.value
                        ? 'Cargando dirección…'
                        : controller.address,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _card(Widget child) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: AppColors.borderSoft),
    ),
    child: child,
  );

  Widget _detail(IconData icon, String label, String value) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.inputFill,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 21, color: AppColors.brandGreen),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value.trim().isEmpty ? 'Sin registrar' : value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

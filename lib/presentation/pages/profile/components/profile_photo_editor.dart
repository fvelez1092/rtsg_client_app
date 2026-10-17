import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app_rtsg_client/application/profile_controller.dart';
import 'package:app_rtsg_client/core/theme/app_colors.dart';
import 'package:app_rtsg_client/data/services/user_service.dart';
import 'package:app_rtsg_client/global_memory.dart';

class ProfilePhotoEditor extends StatelessWidget {
  const ProfilePhotoEditor({
    super.key,
    required this.controller,
    this.size = 88,
  });
  final ProfileController controller;
  final double size;

  Future<void> _choosePhoto(BuildContext context) async {
    final source = await showModalBottomSheet<ProfilePhotoSource>(
      context: context,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'Cambiar foto de perfil',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Tomar foto'),
              onTap: () =>
                  Navigator.pop(sheetContext, ProfilePhotoSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Elegir de galería'),
              onTap: () =>
                  Navigator.pop(sheetContext, ProfilePhotoSource.gallery),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
    if (source != null && context.mounted) await controller.pickPhoto(source);
  }

  @override
  Widget build(BuildContext context) => Obx(() {
    final saving = controller.isUploadingPhoto.value;
    final local = controller.localPhotoPath.value;
    final url = UserService.profilePhotoUrl(
      GlobalMemory.to.userRx.value?.photo,
    );
    final provider = local != null
        ? controller.avatarImageProvider
        : url == null
        ? null
        : NetworkImage(url);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          label: 'Cambiar foto de perfil',
          button: true,
          child: SizedBox(
            width: size + 12,
            height: size + 12,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Material(
                  color: AppColors.brandGreen.withValues(alpha: 0.10),
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: saving ? null : () => _choosePhoto(context),
                    child: SizedBox(
                      width: size,
                      height: size,
                      child: provider == null
                          ? Icon(
                              Icons.person_rounded,
                              size: size * .5,
                              color: AppColors.brandGreen,
                            )
                          : Image(
                              image: provider,
                              fit: BoxFit.cover,
                              errorBuilder: (_, error, stack) => Icon(
                                Icons.person_rounded,
                                size: size * .5,
                                color: AppColors.brandGreen,
                              ),
                            ),
                    ),
                  ),
                ),
                if (saving)
                  Positioned.fill(
                    child: Center(
                      child: Container(
                        width: size,
                        height: size,
                        decoration: const BoxDecoration(
                          color: Colors.black38,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: IconButton.filled(
                    tooltip: 'Cambiar foto de perfil',
                    onPressed: saving ? null : () => _choosePhoto(context),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.brandGreen,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(40, 40),
                    ),
                    icon: const Icon(Icons.camera_alt_outlined, size: 19),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (saving)
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Text(
              'Guardando foto…',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
        if (controller.photoError.value.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              controller.photoError.value,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: AppColors.brandRed),
            ),
          ),
          if (controller.canRetryPhoto)
            TextButton(
              onPressed: saving ? null : controller.retryPhotoUpload,
              child: const Text('Reintentar'),
            ),
        ],
      ],
    );
  });
}

import 'dart:io';

import 'package:app_rtsg_client/data/models/client_model.dart';
import 'package:app_rtsg_client/global_memory.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

enum ProfilePhotoSource { camera, gallery }

class ProfileController extends GetxController {
  final GlobalMemory _globalMemory = GlobalMemory.to;

  final Rx<Client?> currentClient = Rx<Client?>(null);

  /// Local preview after picking an image (camera/gallery)
  final RxnString localPhotoPath = RxnString();

  /// Used by UI to trigger bottom sheet; controller does NOT show UI.
  final Rxn<ProfilePhotoSource> requestedPhotoSource =
      Rxn<ProfilePhotoSource>();

  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    _loadClient();
  }

  Future<void> _loadClient() async {
    //currentClient.value = await _globalMemory.getDriverData();
  }

  /// UI calls this to request showing bottom sheet
  void requestPhotoPicker() {
    requestedPhotoSource.value = null; // reset
  }

  /// UI calls this when user picked a source (camera/gallery)
  Future<void> pickPhoto(ProfilePhotoSource source) async {
    try {
      final XFile? img = await _picker.pickImage(
        source: source == ProfilePhotoSource.camera
            ? ImageSource.camera
            : ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1024,
      );
      if (img == null) return;

      localPhotoPath.value = img.path;

      // TODO: uploadPhoto(File(img.path)) if you have API
    } catch (_) {
      // No UI here; just expose error via state if you want
      Get.snackbar("Error", "Could not pick image");
    }
  }

  ImageProvider? get avatarImageProvider {
    final path = localPhotoPath.value;
    if (path != null && path.isNotEmpty) {
      return FileImage(File(path));
    }

    // If Driver has a photo URL, map it here:
    // final url = currentDriver.value?.photoUrl;
    // if (url != null && url.isNotEmpty) return NetworkImage(url);

    return null;
  }

  // ------- read-only getters to keep UI light (this is OK: not UI, just mapping data) -------
  String get fullName => currentClient.value?.razonSocial ?? "";
  String get phone => currentClient.value?.cellular ?? "";
  String get email => currentClient.value?.email ?? "";
  String get address => currentClient.value?.address ?? "";
}

import 'dart:io';

import 'package:app_rtsg_client/data/models/saved_address_model.dart';
import 'package:app_rtsg_client/data/services/saved_address_service.dart';
import 'package:app_rtsg_client/data/models/user_model.dart';
import 'package:app_rtsg_client/global_memory.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

enum ProfilePhotoSource { camera, gallery }

class ProfileController extends GetxController {
  ProfileController(this._addressService);

  final SavedAddressService _addressService;
  final GlobalMemory _globalMemory = GlobalMemory.to;

  final Rxn<User> currentUser = Rxn<User>();
  final RxList<SavedAddress> addresses = <SavedAddress>[].obs;
  final RxBool loadingAddresses = false.obs;
  final RxString addressError = ''.obs;

  final RxnString localPhotoPath = RxnString();
  final Rxn<ProfilePhotoSource> requestedPhotoSource =
      Rxn<ProfilePhotoSource>();
  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    currentUser.value = _globalMemory.user;
    addresses.assignAll(currentUser.value?.addresses ?? const []);
    loadAddresses();
  }

  Future<void> loadAddresses() async {
    loadingAddresses.value = true;
    addressError.value = '';

    try {
      addresses.assignAll(await _addressService.getAll());
    } catch (error) {
      addressError.value = error.toString();
    } finally {
      loadingAddresses.value = false;
    }
  }

  void requestPhotoPicker() {
    requestedPhotoSource.value = null;
  }

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
    } catch (_) {
      Get.snackbar('Error', 'No se pudo seleccionar la imagen');
    }
  }

  ImageProvider? get avatarImageProvider {
    final path = localPhotoPath.value;
    if (path != null && path.isNotEmpty) return FileImage(File(path));

    final photo = currentUser.value?.photo;
    if (photo is String && photo.trim().isNotEmpty) {
      return NetworkImage(photo.trim());
    }
    return null;
  }

  SavedAddress? get defaultAddress {
    for (final address in addresses) {
      if (address.isDefault) return address;
    }
    return addresses.isEmpty ? null : addresses.first;
  }

  String get fullName => currentUser.value?.displayName ?? '';
  String get phone => currentUser.value?.cellphone ?? '';
  String get email => currentUser.value?.email ?? '';
  String get role => currentUser.value?.role ?? 'Cliente RTSG';
  String get address =>
      defaultAddress?.address ?? currentUser.value?.address ?? '';
}

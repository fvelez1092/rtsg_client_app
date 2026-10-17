import 'package:app_rtsg_client/data/services/user_service.dart';
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
  ProfileController(
    this._addressService, {
    UserService? userService,
    ImagePicker? picker,
  }) : _userService = userService ?? UserService(),
       _picker = picker ?? ImagePicker();
  final UserService _userService;

  final SavedAddressService _addressService;
  final GlobalMemory _globalMemory = GlobalMemory.to;

  final Rxn<User> currentUser = Rxn<User>();
  final RxList<SavedAddress> addresses = <SavedAddress>[].obs;
  final RxBool loadingAddresses = false.obs;
  final RxString addressError = ''.obs;

  final RxnString localPhotoPath = RxnString();
  final Rxn<ProfilePhotoSource> requestedPhotoSource =
      Rxn<ProfilePhotoSource>();
  final ImagePicker _picker;
  final RxBool isUploadingPhoto = false.obs;
  final RxString photoError = ''.obs;
  XFile? _pendingPhoto;
  bool _photoPickerOpen = false;
  bool _photoAlreadyUploaded = false;

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
    if (_photoPickerOpen || isUploadingPhoto.value) return;
    _photoPickerOpen = true;
    try {
      final image = await _picker.pickImage(
        source: source == ProfilePhotoSource.camera
            ? ImageSource.camera
            : ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
        requestFullMetadata: false,
      );
      if (image == null || isClosed) return;
      _pendingPhoto = image;
      _photoAlreadyUploaded = false;
      await retryPhotoUpload();
    } catch (_) {
      photoError.value =
          'No se pudo abrir la cámara o galería. Revisa sus permisos en los ajustes del teléfono.';
    } finally {
      _photoPickerOpen = false;
    }
  }

  Future<void> retryPhotoUpload() async {
    final image = _pendingPhoto;
    if (image == null || isUploadingPhoto.value) return;
    isUploadingPhoto.value = true;
    photoError.value = '';
    final previousPath = localPhotoPath.value;
    localPhotoPath.value = image.path;
    try {
      if (!_photoAlreadyUploaded) {
        await _userService.updateProfilePhoto(
          bytes: await image.readAsBytes(),
          filename: image.name,
          mimeType: image.mimeType,
        );
        _photoAlreadyUploaded = true;
      }
      // El GET conocido evita depender de un formato no documentado del PUT.
      final user = await _userService.getUserByToken();
      if (isClosed) return;
      final photoUrl = UserService.profilePhotoUrl(user.photo);
      if (photoUrl == null) {
        throw Exception('El perfil aún no devuelve la dirección de la foto.');
      }
      await NetworkImage(photoUrl).evict();
      await _globalMemory.setUser(user);
      currentUser.value = user;
      localPhotoPath.value = null;
      _pendingPhoto = null;
      _photoAlreadyUploaded = false;
      Get.snackbar(
        'Perfil actualizado',
        'Tu foto de perfil se guardó correctamente.',
      );
    } catch (error) {
      if (isClosed) return;
      if (!_photoAlreadyUploaded) localPhotoPath.value = previousPath;
      photoError.value = _photoAlreadyUploaded
          ? 'La foto se guardó, pero no pudimos actualizar el perfil. Reintenta para cargar los datos.'
          : error.toString().replaceFirst('Exception: ', '');
    } finally {
      isUploadingPhoto.value = false;
    }
  }

  bool get canRetryPhoto => _pendingPhoto != null;

  ImageProvider? get avatarImageProvider {
    final path = localPhotoPath.value;
    if (path != null && path.isNotEmpty) return FileImage(File(path));

    final photo = UserService.profilePhotoUrl(currentUser.value?.photo);
    if (photo != null) return NetworkImage(photo);
    return null;
  }

  SavedAddress? get defaultAddress {
    for (final address in addresses) {
      if (address.isDefault) return address;
    }
    return addresses.isEmpty ? null : addresses.first;
  }

  String get fullName => currentUser.value?.displayName ?? '';
  String get customerCode =>
      currentUser.value?.customerCode?.toString() ?? 'No disponible';
  String get phone => currentUser.value?.cellphone ?? '';
  String get email => currentUser.value?.email ?? '';
  String get role => currentUser.value?.role ?? 'Cliente RTSG';
  String get address =>
      defaultAddress?.address ?? currentUser.value?.address ?? '';
}

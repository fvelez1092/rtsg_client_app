import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import 'package:app_rtsg_client/data/services/auth_service.dart';
import 'package:app_rtsg_client/presentation/pages/map/map_select_page.dart';
import 'package:app_rtsg_client/data/models/map_point_result_model.dart';

class RegisterController extends GetxController {
  final AuthService _authService;
  RegisterController({required AuthService authService})
    : _authService = authService;

  // --------------------------
  // STEP CONTROL
  // --------------------------
  final RxInt step = 0.obs;
  void nextStep() {
    if (step.value < 3) step.value++;
  }

  void previousStep() {
    if (step.value > 0) step.value--;
  }

  // --------------------------
  // LOADING
  // --------------------------
  final RxBool isLoading = false.obs;

  // --------------------------
  // MODE
  // --------------------------
  final RxBool isCodeMode = false.obs; // ✅ true si viene por código

  // IDs / datos backend (para actualizar)
  final RxnInt userId = RxnInt();
  final RxnInt baseId = RxnInt();
  final RxnInt codigoCliente = RxnInt();

  // --------------------------
  // STEP 1 - CLIENT CODE
  // --------------------------
  final clientCodeController = TextEditingController();
  final RxMap<String, dynamic> clientData = <String, dynamic>{}.obs;

  Future<void> fetchClientByCode() async {
    final code = clientCodeController.text.trim();
    if (code.isEmpty) {
      Get.snackbar("Error", "Ingrese el código de cliente");
      return;
    }

    try {
      isLoading.value = true;

      final data = await _authService.fetchClientByCode(code);
      clientData.assignAll(data);

      isCodeMode.value = true;

      // 🔒 Intenta capturar IDs (según cómo venga la respuesta)
      userId.value =
          _tryInt(data['id']) ??
          _tryInt(data['idusuario']) ??
          _tryInt(data['id_usuario']);
      codigoCliente.value =
          _tryInt(data['codigocliente']) ??
          _tryInt(data['codigo_cliente']) ??
          _tryInt(code);
      baseId.value = _tryInt(data['baseid']) ?? _tryInt(data['base_id']);

      // Autocomplete
      fullNameController.text = (data['nombres'] ?? data['nombre'] ?? '')
          .toString();
      lastNameFatherController.text =
          (data['apellidopaterno'] ?? data['apellido_paterno'] ?? '')
              .toString();
      lastNameMotherController.text =
          (data['apellidomaterno'] ?? data['apellido_materno'] ?? '')
              .toString();

      emailController.text = (data['correo'] ?? data['email'] ?? '').toString();
      phoneController.text = (data['telefonocelular'] ?? data['telefono'] ?? '')
          .toString();

      // Si ya trae dirección / coords, precargar
      addressController.text = (data['direccion'] ?? '').toString();
      detailController.text = (data['ubicacionexacta'] ?? '').toString();
      referenceController.text = (data['observacionpersona'] ?? '').toString();

      final coords = data['coordenadaspersona'];
      if (coords is Map<String, dynamic>) {
        final lat = _tryDouble(coords['lat']);
        final lng = _tryDouble(coords['lng']);
        if (lat != null && lng != null)
          selectedLocation.value = LatLng(lat, lng);
      }

      nextStep(); // pasa a datos básicos
    } catch (e) {
      Get.snackbar("Error", e.toString().replaceFirst("Exception: ", ""));
    } finally {
      isLoading.value = false;
    }
  }

  // --------------------------
  // STEP 2 - BASIC DATA
  // --------------------------
  final fullNameController = TextEditingController();
  final lastNameFatherController = TextEditingController();
  final lastNameMotherController = TextEditingController();

  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  // En modo código NO pedimos password manual (se genera)
  final passwordController = TextEditingController();
  final RxBool isPasswordVisible = false.obs;

  void validateBasicData() {
    final nameOk = fullNameController.text.trim().isNotEmpty;
    final emailOk = emailController.text.trim().isNotEmpty;
    final phoneOk = phoneController.text.trim().isNotEmpty;

    if (!nameOk || !emailOk || !phoneOk) {
      Get.snackbar("Error", "Complete nombre, correo y teléfono");
      return;
    }

    if (!isCodeMode.value) {
      if (passwordController.text.trim().isEmpty) {
        Get.snackbar("Error", "Ingrese una contraseña");
        return;
      }
    }

    nextStep();
  }

  // --------------------------
  // STEP 3 - ADDRESS (styled)
  // --------------------------
  final aliasController = TextEditingController(); // Casa/Trabajo/etc.
  final addressController =
      TextEditingController(); // dirección principal (texto)
  final detailController = TextEditingController(); // detalle
  final referenceController = TextEditingController(); // referencia

  final Rx<LatLng?> selectedLocation = Rx<LatLng?>(null);
  final RxBool isResolvingAddress = false.obs;

  Future<void> openMapAndSelectLocation() async {
    final LatLng initial =
        selectedLocation.value ?? const LatLng(-0.18065, -78.46783);

    final result = await Get.to<MapPointResult>(
      () => MapSelectPage(initialCenter: initial),
    );

    if (result == null) return;

    selectedLocation.value = result.point;

    // Si tu MapSelectPage ya devuelve "name" por reverse allí, úsalo directo:
    if (result.name.trim().isNotEmpty) {
      addressController.text = result.name;
    }
  }

  void validateAddress() {
    final aliasOk = aliasController.text.trim().isNotEmpty;
    final addressOk = addressController.text.trim().isNotEmpty;
    final gpsOk = selectedLocation.value != null;

    if (!aliasOk || !addressOk || !gpsOk) {
      Get.snackbar(
        "Error",
        "Alias, dirección y ubicación (GPS) son obligatorios",
      );
      return;
    }
    nextStep();
  }

  // --------------------------
  // STEP 4 - COMPLETE
  // --------------------------
  Future<void> completeRegister() async {
    try {
      isLoading.value = true;

      if (isCodeMode.value) {
        // ✅ Actualizar usuario + generar clave
        final id = userId.value;
        final code = codigoCliente.value ?? _tryInt(clientCodeController.text);
        final base = baseId.value;

        if (id == null || code == null) {
          throw Exception(
            "No se pudo identificar el usuario/código para actualizar",
          );
        }

        final p = selectedLocation.value!;
        final payload = <String, dynamic>{
          "id": id,
          "codigocliente": code,
          "nombres": fullNameController.text.trim(),
          "apellidopaterno": lastNameFatherController.text.trim(),
          "apellidomaterno": lastNameMotherController.text.trim(),
          "baseid": base ?? 0, // si es requerido, luego lo amarramos bien
          "telefonocelular": phoneController.text.trim(),
          "telefonofijo": "",
          "direccion": addressController.text.trim(),
          "ubicacionexacta": detailController.text.trim(),
          "observacionpersona": referenceController.text.trim(),
          "estado": true,
          "coordenadaspersona": {
            "lat": p.latitude.toString(),
            "lng": p.longitude.toString(),
          },
          "rolid": 5,
        };

        await _authService.updateUser(payload);
        await _authService.generatePassword(email: emailController.text.trim());

        Get.snackbar("Listo", "Datos actualizados y clave enviada al correo");
        // aquí puedes mandarlo a login
        // Get.offAllNamed(AppRoutes.LOGIN);
        return;
      }

      // 🟡 Sin código: crear usuario (pendiente, simulado)
      await _authService.register(
        fullName:
            "${fullNameController.text.trim()} ${lastNameFatherController.text.trim()} ${lastNameMotherController.text.trim()}"
                .trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        password: passwordController.text.trim(),
      );

      Get.snackbar("Listo", "Registro simulado (crear usuario pendiente)");
    } catch (e) {
      Get.snackbar("Error", e.toString().replaceFirst("Exception: ", ""));
    } finally {
      isLoading.value = false;
    }
  }

  // --------------------------
  // Utils
  // --------------------------
  int? _tryInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    final s = v.toString().trim();
    return int.tryParse(s);
  }

  double? _tryDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    final s = v.toString().trim();
    return double.tryParse(s);
  }

  @override
  void onClose() {
    clientCodeController.dispose();
    fullNameController.dispose();
    lastNameFatherController.dispose();
    lastNameMotherController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();

    aliasController.dispose();
    addressController.dispose();
    detailController.dispose();
    referenceController.dispose();
    super.onClose();
  }
}

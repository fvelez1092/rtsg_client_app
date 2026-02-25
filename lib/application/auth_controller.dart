import 'package:app_rtsg_client/data/models/request/login_request.dart';
import 'package:app_rtsg_client/data/models/response/login_response.dart';
import 'package:app_rtsg_client/data/services/local_storage_service.dart';
import 'package:app_rtsg_client/global_memory.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  final LocalStorage localStorage;
  AuthController({required this.localStorage});

  RxBool isLoading = false.obs;
  RxBool isVisible = false.obs;
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final error = ''.obs;
  late LoginResponse loginResponse;

  void login() async {
    Get.focusScope!.unfocus();
    isLoading.value = true;

    if (await validate()) {
      // Muestra el mensaje de bienvenida
      Get.snackbar(
        "Bienvenido",
        GlobalMemory.to.user!.nombresUsuario.split(' ')[2],
        snackPosition: SnackPosition.BOTTOM,
        colorText: Colors.black,
        icon: const Icon(Icons.time_to_leave_outlined, color: Colors.green),
      );
      // Redirigir al Splash
      Get.offAndToNamed(Routes.SPLASH);
    } else {
      // Mostrar el mensaje de error
      isLoading.value = false;
      Get.snackbar(
        "Error",
        error.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color.fromARGB(255, 32, 32, 32),
        colorText: Colors.white,
        borderRadius: 10,
        margin: const EdgeInsets.all(10),
        borderWidth: 1,
        icon: const Icon(Icons.error, color: Colors.white),
      );
    }
  }

  Future<bool> validate() async {
    if (userNameController.text.isEmpty || passwordController.text.isEmpty) {
      error.value = 'Ingrese sus credenciales';
      isLoading.value = false;
      return false;
    }
    return await _toLogin();
  }

  Future<bool> _toLogin() async {
    try {
      LoginRequest loginRequest = LoginRequest(
        userNameController.text.trim(),
        passwordController.text.trim(),
      );
      loginResponse = await AuthenticationService.login(loginRequest);

      if (loginResponse.estado == true) {
        if (_isValidRole(loginResponse.datos!.rolid)) {
          if (loginResponse.datos!.unidad == null) {
            error.value =
                "Al parecer no tienes una unidad asignada, contactate con el administrador";
            return false;
          }
          // Almacena el token y datos del usuario
          await _storeUserData(loginResponse);
          return true;
        } else {
          error.value =
              "Al parecer no eres conductor o socio, contactate con el administrador";
          return false;
        }
      } else {
        error.value = loginResponse.observacion!;
        return false;
      }
    } catch (e) {
      error.value = "Error: $e";
      return false;
    }
  }

  bool _isValidRole(int rolid) {
    return rolid == 1 || rolid == 3 || rolid == 4;
  }

  Future<void> _storeUserData(LoginResponse response) async {
    await GlobalMemory.to.box.write("token", response.token);
    await GlobalMemory.to.box.write("user", response.datos);
    await GlobalMemory.to.box.write("unity", response.datos!.unidad![0]);
    GlobalMemory.to.user = response.datos;
    GlobalMemory.to.unity = response.datos!.unidad![0];
  }

  void logout() async {
    await GlobalMemory.to.box.erase();
    Get.offAndToNamed(Routes.LOGIN);
  }
}

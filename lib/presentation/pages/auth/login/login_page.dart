import 'package:app_rtsg_client/application/auth_controller.dart';
import 'package:app_rtsg_client/core/theme/light_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginPage extends GetView<AuthController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: width * 0.1),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image(
                  image: const AssetImage('assets/images/logo_rtsg.png'),
                  height: height * 0.15,
                  width: width * 0.4,
                ),
                Center(
                  child: Text(
                    'RadioTaxi "San Gregorio"',
                    style: TextStyle(fontSize: 25),
                  ),
                ),

                //   width: width * 0.2,),
                // Image(
                //   image: const AssetImage('assets/images/nombre.png'),
                //   height: height * 0.15,
                //   width: width * 0.2,
                // ),
                SizedBox(height: height * 0.015),
                const Center(
                  child: Text(
                    "Inicia Sesión con tu correo electrónico",
                    style: TextStyle(fontSize: 15),
                  ),
                ),
                SizedBox(height: height * 0.03),
                TextFormField(
                  controller: controller.userNameController,
                  decoration: InputDecoration(
                    labelText: 'Correo Electrónico',
                    prefixIcon: const Icon(Icons.person, color: Colors.grey),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    labelStyle: const TextStyle(color: Colors.grey),
                  ),
                  style: const TextStyle(fontSize: 15),
                  cursorColor: Colors.grey,
                ),
                SizedBox(height: height * 0.03),
                Obx(
                  () => TextFormField(
                    controller: controller.passwordController,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      prefixIcon: IconButton(
                        icon: Icon(
                          controller.isVisible.value
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          controller.isVisible.value =
                              !controller.isVisible.value;
                        },
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      labelStyle: const TextStyle(color: Colors.grey),
                    ),
                    obscureText: !controller.isVisible.value,
                    style: const TextStyle(fontSize: 15),
                    cursorColor: Colors.grey,
                  ),
                ),
                SizedBox(height: height * 0.06),
                Obx(() {
                  return ElevatedButton(
                    onPressed: () => {controller.login()},
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    child: controller.isLoading.value
                        ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              ColorsApp.secondary,
                            ),
                          )
                        : const Text(
                            'Iniciar Sesión',
                            style: TextStyle(
                              fontSize: 18,
                              color: ColorsApp.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  );
                }),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Desarrollado por CeiboCode. All rights Reserved ${DateTime.now().year} ",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

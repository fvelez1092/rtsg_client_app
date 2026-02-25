import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:app_taxis/src/routes/app_pages.dart';

class UserScreen extends StatelessWidget {
  const UserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  margin: EdgeInsets.all(width * 0.05),
                  decoration: const BoxDecoration(
                    //color: ColorsApp.lightGreen, // Cambia a tu color deseado
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  height: height * 0.05,
                  width: height * 0.05,
                  child: IconButton(
                    onPressed: () {
                      Get.toNamed(Routes.DASHBOARD);
                    },
                    icon: const Icon(
                      Icons.navigate_before_outlined,
                      color: Colors.white,
                    ),
                  ),
                ),
                const Center(
                  child: Text(
                    "Editar mi Perfil",
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ],
            ),
            Stack(
              children: [
                CircleAvatar(
                  backgroundImage:
                      const AssetImage("assets/images/avatar_driver.png"),
                  radius: height * 0.1, // Tamaño del círculo
                  // Aquí puedes establecer la imagen del perfil si es necesario
                  // backgroundImage: AssetImage('ruta_de_la_imagen.jpg'),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: FloatingActionButton(
                    //backgroundColor: ColorsApp.lightGreen,
                    child: const Icon(
                      Icons.camera_alt_outlined,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      // Acción al hacer clic en el botón de la cámara
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(
                height:
                    20), // Espacio entre la imagen de perfil y los campos de texto
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  _buildTextField("Cédula", Icons.person),
                  const SizedBox(height: 10),
                  _buildTextField("Nombres", Icons.person),
                  const SizedBox(height: 10),
                  _buildTextField("Apellidos", Icons.person),
                  const SizedBox(height: 10),
                  _buildTextField("example@mail.com", Icons.email_outlined),
                  const SizedBox(height: 10),
                  _buildTextField("Telefono", Icons.call),
                ],
              ),
            ),

            Container(
              width: width,
              margin: EdgeInsets.all(width * 0.05),
              child: ElevatedButton(
                onPressed: () => {}, //controller.login()},
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                // child: controller.isLoading.value
                //     ? const CircularProgressIndicator(
                //         valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                //       )
                //     :
                child: const Text(
                  'Actualizar',
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, [IconData? icon]) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        prefixIcon: icon != null ? Icon(icon) : null,
      ),
    );
  }
}

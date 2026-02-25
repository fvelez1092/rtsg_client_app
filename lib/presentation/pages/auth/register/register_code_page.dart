import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app_rtsg_client/application/register_controller.dart';

class RegisterCodePage extends GetView<RegisterController> {
  const RegisterCodePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Validar Código Cliente")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: controller.clientCodeController,
              decoration: const InputDecoration(labelText: "Código Cliente"),
            ),
            const SizedBox(height: 20),
            Obx(() {
              return ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : controller.fetchClientByCode,
                child: controller.isLoading.value
                    ? const CircularProgressIndicator()
                    : const Text("Buscar"),
              );
            }),

            const SizedBox(height: 20),

            // Mostrar datos cargados
            Obx(() {
              if (controller.clientData.isEmpty) {
                return const SizedBox();
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Nombre: ${controller.clientData['nombre'] ?? ''}"),
                  Text("Email: ${controller.clientData['email'] ?? ''}"),
                  Text("Teléfono: ${controller.clientData['telefono'] ?? ''}"),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

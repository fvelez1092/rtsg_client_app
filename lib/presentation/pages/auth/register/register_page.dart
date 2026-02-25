import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app_rtsg_client/core/theme/app_colors.dart';
import 'package:app_rtsg_client/application/register_controller.dart';

class RegisterPage extends GetView<RegisterController> {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _StepIndicator(),
            Expanded(
              child: Obx(() {
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _buildStep(controller.step.value),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(int step) {
    switch (step) {
      case 0:
        return _StepCode();
      case 1:
        return _StepBasicData();
      case 2:
        return _StepAddress();
      case 3:
        return _StepConfirm();
      default:
        return const SizedBox();
    }
  }
}

class _StepIndicator extends GetView<RegisterController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: List.generate(4, (index) {
            final active = controller.step.value >= index;
            return Expanded(
              child: Container(
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: active ? AppColors.taxiYellow : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          }),
        ),
      );
    });
  }
}

class _StepCode extends GetView<RegisterController> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text(
            "¿Tienes código de cliente?",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
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
                  : const Text("Validar Código"),
            );
          }),
          TextButton(
            onPressed: controller.nextStep,
            child: const Text("Continuar sin código"),
          ),
        ],
      ),
    );
  }
}

class _StepBasicData extends GetView<RegisterController> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          TextField(
            controller: controller.fullNameController,
            decoration: const InputDecoration(labelText: "Nombre completo"),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: controller.emailController,
            decoration: const InputDecoration(labelText: "Email"),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: controller.phoneController,
            decoration: const InputDecoration(labelText: "Teléfono"),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: controller.passwordController,
            decoration: const InputDecoration(labelText: "Contraseña"),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: controller.validateBasicData,
            child: const Text("Continuar"),
          ),
        ],
      ),
    );
  }
}

class _StepAddress extends GetView<RegisterController> {
  const _StepAddress();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Main address",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Add an alias and confirm your exact location on the map.",
            style: TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          _Card(
            child: Column(
              children: [
                _Field(
                  label: "Alias *",
                  hint: "Home, Work, Family...",
                  controller: controller.aliasController,
                  icon: Icons.bookmark_outline,
                ),
                const SizedBox(height: 12),

                // Dirección (puede ser editable si quieres)
                _Field(
                  label: "Address *",
                  hint: "Select on map to fill automatically",
                  controller: controller.addressController,
                  icon: Icons.location_on_outlined,
                ),
                const SizedBox(height: 12),

                _Field(
                  label: "Details",
                  hint: "Apartment, floor, block, gate color...",
                  controller: controller.detailController,
                  icon: Icons.notes_outlined,
                  maxLines: 2,
                ),
                const SizedBox(height: 12),

                _Field(
                  label: "Reference",
                  hint: "Near pharmacy, in front of the park...",
                  controller: controller.referenceController,
                  icon: Icons.map_outlined,
                  maxLines: 2,
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          Obx(() {
            final point = controller.selectedLocation.value;
            return _Card(
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.inputFill,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.gps_fixed,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      point == null
                          ? "No location selected"
                          : "Lat ${point.latitude.toStringAsFixed(6)} • Lng ${point.longitude.toStringAsFixed(6)}",
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: controller.openMapAndSelectLocation,
              icon: const Icon(Icons.map_outlined),
              label: const Text("Select on map"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.taxiYellow,
                foregroundColor: AppColors.textPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: controller.previousStep,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.borderSoft),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: const Text("Back"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: controller.validateAddress,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.textPrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: const Text("Continue"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSoft),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final IconData icon;
  final int maxLines;

  const _Field({
    required this.label,
    required this.hint,
    required this.controller,
    required this.icon,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textSecondary),
            prefixIcon: Icon(icon, color: AppColors.textSecondary),
            filled: true,
            fillColor: AppColors.inputFill,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.borderSoft),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: AppColors.textPrimary,
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _StepConfirm extends GetView<RegisterController> {
  const _StepConfirm();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Obx(() {
        final loading = controller.isLoading.value;
        final point = controller.selectedLocation.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Confirmación",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Revisa que la información esté correcta antes de finalizar.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 18),

            _SectionCard(
              title: "Datos personales",
              children: [
                _RowItem(
                  label: "Nombre",
                  value: controller.fullNameController.text.trim(),
                ),
                _RowItem(
                  label: "Correo",
                  value: controller.emailController.text.trim(),
                ),
                _RowItem(
                  label: "Teléfono",
                  value: controller.phoneController.text.trim(),
                ),
              ],
            ),

            const SizedBox(height: 12),

            _SectionCard(
              title: "Dirección principal",
              children: [
                _RowItem(
                  label: "Alias",
                  value: controller.aliasController.text.trim(),
                ),
                _RowItem(
                  label: "Dirección",
                  value: controller.addressController.text.trim(),
                ),
                _RowItem(
                  label: "Detalle",
                  value: controller.detailController.text.trim().isEmpty
                      ? "-"
                      : controller.detailController.text.trim(),
                ),
                _RowItem(
                  label: "Referencia",
                  value: controller.referenceController.text.trim().isEmpty
                      ? "-"
                      : controller.referenceController.text.trim(),
                ),
              ],
            ),

            const SizedBox(height: 12),

            _SectionCard(
              title: "Ubicación (GPS)",
              children: [
                _RowItem(
                  label: "Lat",
                  value: point == null
                      ? "-"
                      : point.latitude.toStringAsFixed(6),
                ),
                _RowItem(
                  label: "Lng",
                  value: point == null
                      ? "-"
                      : point.longitude.toStringAsFixed(6),
                ),
              ],
            ),

            const SizedBox(height: 18),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: loading ? null : controller.previousStep,
                    child: const Text("Atrás"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: loading ? null : controller.completeRegister,
                    child: loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text("Finalizar"),
                  ),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

class _RowItem extends StatelessWidget {
  final String label;
  final String value;

  const _RowItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? "-" : value,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

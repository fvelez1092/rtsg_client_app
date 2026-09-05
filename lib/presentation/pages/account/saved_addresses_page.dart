import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import 'package:app_rtsg_client/core/theme/app_colors.dart';
import 'package:app_rtsg_client/data/models/saved_address_model.dart';
import 'package:app_rtsg_client/data/services/gps_service.dart';
import 'package:app_rtsg_client/data/services/saved_address_service.dart';
import 'package:app_rtsg_client/presentation/pages/trip/components/trip_location_picker.dart';

class SavedAddressesPage extends StatefulWidget {
  const SavedAddressesPage({super.key});

  @override
  State<SavedAddressesPage> createState() => _SavedAddressesPageState();
}

class _SavedAddressesPageState extends State<SavedAddressesPage> {
  final SavedAddressService _service = SavedAddressService();
  List<SavedAddress> _addresses = const [];

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    setState(() => _addresses = _service.getAll());
  }

  Future<void> _addAddress() async {
    final gps = Get.find<GpsService>().currentPosition.value;
    final initial = gps ?? const LatLng(-0.18065, -78.46783);

    final result = await Get.to(
      () => TripLocationPickerPage(
        initialCenter: initial,
        title: 'Guardar una dirección',
        confirmText: 'Guardar dirección',
        saveAsUserAddress: true,
      ),
    );

    if (result != null && mounted) {
      _reload();
    }
  }

  Future<void> _remove(SavedAddress address) async {
    await _service.remove(address.id);
    if (mounted) _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Direcciones guardadas'),
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addAddress,
        backgroundColor: AppColors.brandGreen,
        foregroundColor: AppColors.surface,
        icon: const Icon(Icons.add_location_alt_rounded),
        label: const Text('Agregar'),
      ),
      body: SafeArea(
        child: _addresses.isEmpty
            ? _EmptyAddresses(onAdd: _addAddress)
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                itemCount: _addresses.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final address = _addresses[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.borderSoft),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
                      leading: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.brandGreen.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: Icon(
                          address.label.toLowerCase().contains('casa')
                              ? Icons.home_rounded
                              : address.label.toLowerCase().contains('trabajo')
                                  ? Icons.work_rounded
                                  : Icons.place_rounded,
                          color: AppColors.brandGreen,
                        ),
                      ),
                      title: Text(
                        address.label,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Text(
                          address.address,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      trailing: IconButton(
                        tooltip: 'Eliminar',
                        onPressed: () => _remove(address),
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          color: AppColors.brandRed,
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _EmptyAddresses extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyAddresses({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                color: AppColors.brandGreen.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.bookmark_add_outlined,
                size: 38,
                color: AppColors.brandGreen,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Guarda tus lugares frecuentes',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Agrega Casa, Trabajo u otro lugar y úsalo con un toque al pedir un viaje.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_location_alt_rounded),
              label: const Text('Agregar dirección'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.brandGreen,
                foregroundColor: AppColors.surface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import 'package:app_rtsg_client/application/trip_controller.dart';
import 'package:app_rtsg_client/core/theme/app_colors.dart';
import 'package:app_rtsg_client/data/models/map_point_result_model.dart';
import 'package:app_rtsg_client/data/models/saved_address_model.dart';
import 'package:app_rtsg_client/data/services/saved_address_service.dart';
import 'package:app_rtsg_client/presentation/pages/trip/components/trip_location_picker.dart';

enum RouteSelectMode { origin, destination }

class RouteInputSheet extends GetView<TripController> {
  final VoidCallback onClose;
  final RouteSelectMode mode;

  const RouteInputSheet({super.key, required this.onClose, required this.mode});

  Future<void> _useSavedAddress(SavedAddress address) async {
    if (mode == RouteSelectMode.origin) {
      controller.setOriginFromExternal(
        point: address.point,
        address: address.address,
      );
      onClose();
      return;
    }

    await controller.setDestination(
      point: address.point,
      address: address.address,
    );
    onClose();
  }

  Future<void> _selectOnMap(BuildContext context) async {
    FocusScope.of(context).unfocus();

    final LatLng initial = mode == RouteSelectMode.destination
        ? (controller.destinationLatLng.value ??
              controller.originLatLng.value ??
              controller.lastCenter)
        : (controller.originLatLng.value ?? controller.lastCenter);

    onClose();
    await Future<void>.delayed(const Duration(milliseconds: 180));

    final result = await Get.to<MapPointResult>(
      () => TripLocationPickerPage(
        initialCenter: initial,
        title: mode == RouteSelectMode.origin
            ? 'Ubica el punto de partida'
            : 'Ubica tu destino',
      ),
      transition: Transition.cupertino,
    );

    if (result == null) return;

    if (mode == RouteSelectMode.destination) {
      await controller.setDestination(
        point: result.point,
        address: result.name,
      );
      return;
    }

    controller.setOriginFromExternal(
      point: result.point,
      address: result.name,
    );
  }

  @override
  Widget build(BuildContext context) {
    final savedAddresses = SavedAddressService().getAll();
    final isOrigin = mode == RouteSelectMode.origin;

    return SafeArea(
      top: false,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.82,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(26),
            topRight: Radius.circular(26),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.borderSoft,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isOrigin ? 'Punto de partida' : '¿A dónde vas?',
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        isOrigin
                            ? 'Busca una dirección o selecciónala en el mapa.'
                            : 'Busca tu destino o usa uno de tus lugares guardados.',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                _CloseButton(onTap: onClose),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller.searchCtrl,
              autofocus: !isOrigin,
              onChanged: controller.onQueryChanged,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.inputFill,
                hintText: isOrigin
                    ? 'Busca el punto de partida'
                    : 'Busca un destino',
                hintStyle: const TextStyle(color: AppColors.textSecondary),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.textPrimary,
                ),
                suffixIcon: IconButton(
                  tooltip: 'Seleccionar en el mapa',
                  onPressed: () => _selectOnMap(context),
                  icon: const Icon(
                    Icons.map_outlined,
                    color: AppColors.brandGreen,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 15,
                ),
              ),
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            Obx(() {
              if (!controller.isSearching.value) {
                return const SizedBox.shrink();
              }

              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.brandGreen,
                      ),
                    ),
                    SizedBox(width: 9),
                    Text(
                      'Buscando lugares cerca de ti…',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }),
            Obx(() {
              final list = controller.results;
              if (list.isEmpty) return const SizedBox.shrink();

              return Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(top: 6),
                  itemCount: list.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, color: AppColors.borderSoft),
                  itemBuilder: (context, index) {
                    final item = list[index];
                    final name = (item['display_name'] ?? 'Sin nombre')
                        .toString();
                    final lat = (item['lat'] as num?)?.toDouble();
                    final lon = (item['lon'] as num?)?.toDouble();

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppColors.inputFill,
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: const Icon(
                          Icons.location_on_outlined,
                          color: AppColors.brandGreen,
                        ),
                      ),
                      title: Text(
                        name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      onTap: () async {
                        if (lat == null || lon == null) return;
                        final point = LatLng(lat, lon);

                        if (mode == RouteSelectMode.destination) {
                          await controller.selectDestination(item);
                          onClose();
                          return;
                        }

                        controller.setOriginFromExternal(
                          point: point,
                          address: name,
                        );
                        onClose();
                      },
                    );
                  },
                ),
              );
            }),
            Obx(() {
              if (controller.results.isNotEmpty ||
                  controller.searchCtrl.text.trim().isNotEmpty) {
                return const SizedBox.shrink();
              }

              return Flexible(
                child: ListView(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  children: [
                    if (isOrigin)
                      Obx(
                        () => _ActionTile(
                          icon: Icons.my_location_rounded,
                          title: 'Mi ubicación actual',
                          subtitle: controller.originAddress.value.isEmpty
                              ? 'Usar ubicación del GPS'
                              : controller.originAddress.value,
                          onTap: () async {
                            final ok = await controller.useCurrentLocation();
                            if (ok) {
                              onClose();
                              return;
                            }

                            Get.snackbar(
                              'Ubicación no disponible',
                              'No pudimos obtener tu ubicación actual.',
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          },
                        ),
                      ),
                    _ActionTile(
                      icon: Icons.map_outlined,
                      title: 'Seleccionar en el mapa',
                      subtitle: 'Mueve el mapa para precisar la dirección',
                      onTap: () => _selectOnMap(context),
                    ),
                    if (savedAddresses.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.only(top: 14, bottom: 7),
                        child: Text(
                          'Tus lugares',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      ...savedAddresses.map(
                        (address) => _ActionTile(
                          icon: address.label.toLowerCase().contains('casa')
                              ? Icons.home_rounded
                              : address.label.toLowerCase().contains('trabajo')
                                  ? Icons.work_rounded
                                  : Icons.bookmark_rounded,
                          title: address.label,
                          subtitle: address.address,
                          onTap: () => _useSavedAddress(address),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  final VoidCallback onTap;

  const _CloseButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.inputFill,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const Padding(
          padding: EdgeInsets.all(10),
          child: Icon(Icons.close, size: 20, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 43,
        height: 43,
        decoration: BoxDecoration(
          color: AppColors.brandGreen.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Icon(icon, color: AppColors.brandGreen),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w800,
        ),
      ),
      subtitle: Text(
        subtitle,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppColors.textSecondary,
      ),
    );
  }
}

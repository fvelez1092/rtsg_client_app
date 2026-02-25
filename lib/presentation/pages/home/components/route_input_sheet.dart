import 'package:app_rtsg_client/application/home_controller.dart';
import 'package:app_rtsg_client/application/trip_controller.dart';
import 'package:app_rtsg_client/data/models/map_point_result_model.dart';
import 'package:app_rtsg_client/presentation/pages/map/map_select_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import 'package:app_rtsg_client/core/theme/app_colors.dart';

enum RouteSelectMode { origin, destination }

class RouteInputSheet extends GetView<TripController> {
  final VoidCallback onClose;
  final RouteSelectMode mode;

  const RouteInputSheet({super.key, required this.onClose, required this.mode});

  @override
  Widget build(BuildContext context) {
    final home = Get.find<HomeController>();

    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(22),
            topRight: Radius.circular(22),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
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
            const SizedBox(height: 10),

            Row(
              children: [
                const SizedBox(width: 40),
                Expanded(
                  child: Text(
                    mode == RouteSelectMode.origin
                        ? 'Selecciona tu origen'
                        : 'Introduce tu ruta',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                _CloseButton(onTap: onClose),
              ],
            ),
            const SizedBox(height: 18),

            // Origen actual del mapa (siempre visible)
            Obx(
              () => _CurrentPlaceTile(
                text: controller.originAddress.value.isEmpty
                    ? 'Mi ubicación'
                    : controller.originAddress.value,
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: controller.searchCtrl,
              onChanged: controller.onQueryChanged,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.surface,
                hintText: mode == RouteSelectMode.origin ? 'Origen' : 'Destino',
                hintStyle: const TextStyle(color: AppColors.textSecondary),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.textPrimary,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: AppColors.textPrimary,
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: AppColors.textPrimary,
                    width: 1.5,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
              ),
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 10),

            Obx(() {
              final loading = controller.isSearching.value;
              return AnimatedOpacity(
                duration: const Duration(milliseconds: 150),
                opacity: loading ? 1 : 0,
                child: loading
                    ? const Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 6),
                          child: Text(
                            'Buscando cerca de ti…',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              );
            }),

            Obx(() {
              final list = controller.results;
              if (list.isEmpty) return const SizedBox(height: 6);

              return ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 260),
                child: ListView.separated(
                  shrinkWrap: true,
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
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                      leading: const Icon(
                        Icons.location_on_outlined,
                        color: AppColors.textSecondary,
                      ),
                      title: Text(
                        name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
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

                        // ORIGEN: actualiza mapa principal + trip origin
                        home.setOriginFromExternal(point: point, address: name);
                        onClose();
                      },
                    );
                  },
                ),
              );
            }),

            const SizedBox(height: 10),

            _SelectOnMap(
              onTap: () async {
                FocusScope.of(context).unfocus();

                final LatLng initial = (mode == RouteSelectMode.destination)
                    ? (controller.destinationLatLng.value ??
                          controller.originLatLng.value ??
                          const LatLng(-0.18065, -78.46783))
                    : (controller.originLatLng.value ??
                          const LatLng(-0.18065, -78.46783));

                final result = await Get.to<MapPointResult>(
                  () => MapSelectPage(initialCenter: initial),
                );

                if (result == null) return;

                if (mode == RouteSelectMode.destination) {
                  controller.destinationLatLng.value = result.point;
                  controller.destinationAddress.value = result.name;
                  await controller.recalculateIfPossible();
                  onClose();
                  return;
                }

                // ORIGEN desde mapa select
                home.setOriginFromExternal(
                  point: result.point,
                  address: result.name,
                );
                onClose();
              },
            ),
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

class _CurrentPlaceTile extends StatelessWidget {
  final String text;
  const _CurrentPlaceTile({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.brandGreen, width: 3),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectOnMap extends StatelessWidget {
  final VoidCallback onTap;
  const _SelectOnMap({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Icon(
                Icons.person_pin_circle_outlined,
                color: Colors.blue,
                size: 22,
              ),
              SizedBox(width: 10),
              Text(
                'Seleccionar en el mapa',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

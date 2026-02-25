import 'package:app_manporcar_client/core/theme/light_theme.dart';
import 'package:app_manporcar_client/data/models/trips/trip_route_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RoutePickerSheet extends StatelessWidget {
  const RoutePickerSheet({
    super.key,
    required this.routes,
    required this.onSelect,
    this.initiallySelectedId,
  });

  final List<TripRoute> routes;
  final void Function(TripRoute) onSelect;
  final int? initiallySelectedId;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle superior
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Selecciona una ruta',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),

            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: routes.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final r = routes[i];
                  final selected = r.idRoute == initiallySelectedId;

                  return ListTile(
                    leading: const Icon(
                      Icons.route_outlined,
                      color: ColorsApp.orange,
                    ),
                    title: Text(
                      ' ${r.originCity} - ${r.destinationCity}',
                      style: const TextStyle(
                        color: ColorsApp.cyanPurple,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      '${r.distanceKm} Km  ·  Tiempo estimado: '
                      '${r.estimatedTime.inHours}h '
                      '${r.estimatedTime.inMinutes.remainder(60)}m',
                      style: const TextStyle(color: ColorsApp.cyanPurple),
                    ),
                    trailing: Icon(
                      selected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: selected ? ColorsApp.orange : ColorsApp.cyanPurple,
                    ),
                    onTap: () {
                      onSelect(r);
                      Get.back(closeOverlays: false);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

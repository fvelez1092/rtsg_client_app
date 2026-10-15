import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app_rtsg_client/data/services/active_trip_session.dart';
import 'package:app_rtsg_client/routes/rtsg_routes.dart';

class ActiveTripBanner extends StatelessWidget {
  const ActiveTripBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final session = ActiveTripSession.instance;
    return Obx(() {
      final trip = session.trip.value;
      if (trip == null) return const SizedBox.shrink();
      return SafeArea(
        bottom: false,
        child: Card(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: ListTile(
            leading: const Icon(Icons.directions_car_rounded),
            title: const Text('Volver al mapa'),
            subtitle: const Text('Tu viaje sigue activo'),
            trailing: const Icon(Icons.map_outlined),
            onTap: () => Get.toNamed(
              AppRoutes.TRIP,
              arguments: {'assignedTripId': int.tryParse(trip.id)},
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          ),
        ),
      );
    });
  }
}

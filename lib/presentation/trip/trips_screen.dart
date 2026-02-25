import 'package:app_rtsg_client/application/trips_controller.dart';
import 'package:app_rtsg_client/data/models/trip_status.dart';
import 'package:app_rtsg_client/data/models/trips/trip_model.dart';
import 'package:app_rtsg_client/presentation/trip/components/trip_card.dart';
import 'package:app_rtsg_client/routes/rtsg_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TripsScreen extends GetView<TripsController> {
  const TripsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Column(
        children: [
          _Header(),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Obx(() {
                final list = controller.trips;
                if (controller.loading.value) {
                  // ✅ Skeleton shimmer placeholder
                  return ListView.separated(
                    padding: const EdgeInsets.only(bottom: 100),
                    itemCount: 4,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, __) => _TripSkeleton(),
                  );
                }

                if (controller.error.isNotEmpty) {
                  return Center(child: Text('Error: ${controller.error}'));
                }
                if (list.isEmpty) return const _EmptyState();

                return ListView.separated(
                  padding: const EdgeInsets.only(bottom: 100),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final trip = list[index];
                    return TripCard(
                      trip: trip,
                      onTap: () =>
                          Get.snackbar('Detalle', 'Abriendo ${trip.tripId}'),
                      onContact:
                          controller.showActive.value &&
                              (trip.status == TripStatus.verified ||
                                  trip.status == TripStatus.inProgress)
                          ? () => Get.snackbar(
                              'Contacto',
                              'Contactando conductor…',
                            )
                          : null,
                      onMap:
                          controller.showActive.value &&
                              trip.status == TripStatus.inProgress
                          ? () => Get.snackbar('Mapa', 'Abriendo ruta…')
                          : null,
                      onCancel:
                          controller.showActive.value &&
                              trip.status == TripStatus.pending
                          ? () => _confirmCancel(trip)
                          : null,

                      onRate:
                          !controller.showActive.value &&
                              trip.status == TripStatus.completed
                          ? () =>
                                Get.snackbar('Calificar', 'Abrir calificación…')
                          : null,
                      onReceipt:
                          !controller.showActive.value &&
                              trip.status == TripStatus.completed
                          ? () => Get.snackbar('Recibo', 'Ver recibo…')
                          : null,
                      onRebook:
                          !controller.showActive.value &&
                              trip.status == TripStatus.cancelled
                          ? () => Get.snackbar('Reservar', 'Reservar de nuevo…')
                          : null,
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFec6206),
        // onPressed: () => Get.toNamed(AppRoutes.NEW_TRIP, id: 1),
        onPressed: () {
          final tripBooking = Get.find<TripBookingController>();
          tripBooking.clearData();
          // Get.toNamed(AppRoutes.NEW_TRIP, id: 1);
          Get.key.currentState?.pushNamed(AppRoutes.NEW_TRIP);
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _confirmCancel(Trip trip) async {
    final ok = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Confirmación'),
        content: const Text('¿Cancelar este viaje?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('No'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => Get.back(result: true),
            label: const Text('Cancelar'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
          ),
        ],
      ),
    );
    if (ok == true) Get.snackbar('Cancelado', 'Viaje cancelado');
  }
}

/// --- Skeleton de carga de viajes ---
class _TripSkeleton extends StatelessWidget {
  const _TripSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 14,
                  width: double.infinity,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 8),
                Container(height: 12, width: 120, color: Colors.grey.shade300),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends GetView<TripsController> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [ColorsApp.cyanPurple, ColorsApp.purple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 52, 16, 16),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Row(
              children: [
                _roundBtn(
                  icon: Icons.arrow_back,
                  onTap: () => Get.toNamed(AppRoutes.HOME, id: 1),
                ),

                const Spacer(),
                const Text(
                  'Mis Viajes',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                _roundBtn(
                  icon: Icons.filter_list_rounded,
                  onTap: () => Get.snackbar('Filtros', 'Abrir filtros…'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _Tabs(),
          ],
        ),
      ),
    );
  }

  Widget _roundBtn({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}

class _Tabs extends GetView<TripsController> {
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            Expanded(
              child: _pill(
                'Activos',
                controller.showActive.value,
                () => controller.showActive.value = true,
              ),
            ),
            Expanded(
              child: _pill(
                'Historial',
                !controller.showActive.value,
                () => controller.showActive.value = false,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pill(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected ? const Color(0xFF1b0130) : Colors.white,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFFF3F4F6),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.directions_car_rounded,
                color: Colors.grey,
                size: 32,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'No hay viajes',
              style: TextStyle(
                color: Color(0xFF1b0130),
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Aún no tienes viajes programados',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFec6206),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
              ),
              onPressed: () => Get.toNamed('/pick'),
              child: const Text(
                'Agendar primer viaje',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:app_manporcar_client/application/controllers/trip_booking_controller.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PassengerPickerSheet extends StatelessWidget {
  const PassengerPickerSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TripBookingController>();

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Seleccionar número de pasajeros',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 24),

            // contador visual
            GetBuilder<TripBookingController>(
              id: 'passenger_count',
              builder: (c) => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Botón menos
                  IconButton(
                    iconSize: 36,
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: c.decreasePassengers,
                  ),

                  Container(
                    width: 70,
                    height: 70,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E8),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFFF7A00),
                        width: 2,
                      ),
                    ),
                    child: Text(
                      '${c.passengerCount.value}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3E2C6D),
                      ),
                    ),
                  ),

                  // Botón más
                  IconButton(
                    iconSize: 36,
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: c.increasePassengers,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3E2C6D),
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.check, color: Colors.white),
              label: const Text(
                'Confirmar',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () => Get.back(closeOverlays: false),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:app_rtsg_client/data/models/trips/trip_model.dart' as history;
import 'package:flutter/material.dart';
import 'package:app_rtsg_client/data/services/active_trip_session.dart';
import 'package:app_rtsg_client/presentation/widgets/active_trip_banner.dart';
import 'package:app_rtsg_client/routes/rtsg_routes.dart';
import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:app_rtsg_client/application/trip_controller.dart';
import 'package:app_rtsg_client/data/services/gps_service.dart';
import 'package:app_rtsg_client/data/services/trip_service.dart';
import 'package:app_rtsg_client/data/services/trip_socket_service.dart';

class FakeTrips implements TripService {
  @override
  Future<history.Trip?> getTripDetails(String id) async => null;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeSocket extends TripSocketService {
  final assignmentEvents = StreamController<Map<String, dynamic>>.broadcast(
    sync: true,
  );
  final locationEvents = StreamController<Map<String, dynamic>>.broadcast(
    sync: true,
  );
  @override
  Stream<Map<String, dynamic>> get assignments => assignmentEvents.stream;
  @override
  Stream<Map<String, dynamic>> get locations => locationEvents.stream;
  @override
  Future<void> connect() async {}
  @override
  void listenForTrip(String id) {}
  @override
  Future<void> dispose() async {
    await assignmentEvents.close();
    await locationEvents.close();
    await super.dispose();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  tearDown(() => Get.reset());

  test('Restores the same trip and driver after leaving tracking', () async {
    Get.testMode = true;
    Get.put(GpsService());
    Get.put<TripService>(FakeTrips());
    final socket = FakeSocket();
    Get.put<TripSocketService>(socket);
    final controller = Get.put(TripController());
    controller.recoverAssignedTrip(42);
    socket.assignmentEvents.add({
      'carrera_id': 42,
      'direccionpartida': 'Mi recogida',
      'coordenadaspartida': {'lat': -0.1, 'lng': -78.1},
      'conductor': {
        'nombre': 'Juan',
        'ubicacion': {'lat': -0.2, 'lng': -78.5},
      },
    });
    await Get.delete<TripController>();
    await Get.delete<TripSocketService>();
    Get.put<TripSocketService>(FakeSocket());
    final restored = Get.put(TripController());
    expect(restored.activeTrip.value!.id, '42');
    expect(restored.originAddress.value, 'Mi recogida');
    expect(restored.originLatLng.value, const LatLng(-0.1, -78.1));
    expect(restored.driverPosition.value, const LatLng(-0.2, -78.5));
    expect(
      restored.activeTrip.value!.assignment!['conductor']['nombre'],
      'Juan',
    );
    restored.cancelTrip();
    expect(ActiveTripSession.instance.trip.value, isNull);
  });

  testWidgets('Return to map opens the saved trip and hides when cleared', (
    tester,
  ) async {
    Get.testMode = true;
    final session = ActiveTripSession.instance;
    Get.put(GpsService());
    Get.put<TripService>(FakeTrips());
    final socket = FakeSocket();
    Get.put<TripSocketService>(socket);
    Get.put(TripController()).recoverAssignedTrip(42);
    socket.assignmentEvents.add({'carrera_id': 42, 'estado_codigo': 'E'});
    await Get.delete<TripController>();
    await tester.pumpWidget(
      GetMaterialApp(
        home: const Scaffold(body: ActiveTripBanner()),
        getPages: [
          GetPage(
            name: AppRoutes.TRIP,
            page: () => Scaffold(
              body: Text('Carrera ${Get.arguments['assignedTripId']}'),
            ),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Volver al mapa'), findsOneWidget);
    await tester.tap(find.text('Volver al mapa'));
    await tester.pumpAndSettle();
    expect(find.text('Carrera 42'), findsOneWidget);
    Get.back();
    await tester.pumpAndSettle();
    expect(find.text('Volver al mapa'), findsOneWidget);
    session.clear();
    await tester.pumpAndSettle();
    expect(find.text('Volver al mapa'), findsNothing);
  });
}

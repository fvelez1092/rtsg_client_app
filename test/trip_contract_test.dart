import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:app_rtsg_client/application/trip_controller.dart';
import 'package:app_rtsg_client/data/models/trip_status.dart';
import 'package:app_rtsg_client/data/models/trip_state_contract.dart';
import 'package:app_rtsg_client/data/models/trips/trip_model.dart' as history;
import 'package:app_rtsg_client/data/models/request/trip_request.dart';
import 'package:app_rtsg_client/data/services/active_trip_session.dart';
import 'package:app_rtsg_client/data/services/gps_service.dart';
import 'package:app_rtsg_client/data/services/trip_service.dart';
import 'package:app_rtsg_client/data/services/trip_socket_service.dart';
import 'package:app_rtsg_client/presentation/pages/trip/driver_tracking_page.dart';
import 'active_trip_return_test.dart' show FakeSocket, FakeTrips;

class ContractSocket extends FakeSocket {
  final states = StreamController<Map<String, dynamic>>.broadcast(sync: true);
  @override
  Stream<Map<String, dynamic>> get statusUpdates => states.stream;
  @override
  Future<void> dispose() async {
    await states.close();
    await super.dispose();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late ContractSocket socket;
  late TripController controller;
  setUp(() {
    Get.testMode = true;
    Get.put(GpsService());
    Get.put<TripService>(FakeTrips());
    socket = ContractSocket();
    Get.put<TripSocketService>(socket);
    controller = Get.put(TripController());
    controller.recoverAssignedTrip(42);
  });
  tearDown(() => Get.reset());

  test('Mobile request keeps origin M', () {
    const request = TripRequest(
      telefonoCliente: '0999999999',
      clienteId: 1,
      direccionPartida: 'Origen',
      ubicacionExactaCliente: '',
      latitudPartida: 0,
      longitudPartida: 0,
      estadoCarrera: 'O',
      unidadId: '0',
      usuarioId: 1,
      direccionDestino: 'Destino',
      latitudDestino: 1,
      longitudDestino: 1,
      distancia: 1,
      costo: 1,
    );
    expect(request.toJson()['origen'], 'M');
  });
  test('Code takes precedence and history understands E L I F', () {
    final mapping = {
      'E': TripStatus.accepted,
      'L': TripStatus.arrived,
      'I': TripStatus.started,
      'F': TripStatus.completed,
    };
    for (final entry in mapping.entries) {
      expect(
        tripStatusFromBackend({
          'estado_codigo': entry.key,
          'estado': 'EN_CAMINO',
        }),
        entry.value,
      );
    }
    expect(
      tripStatusFromBackend({
        'estado': 'L',
        'estado_nombre': 'CLIENTE_NOTIFICADO_LLEGADA',
      }),
      TripStatus.arrived,
    );
    expect(
      history.Trip.fromJson({'estado_codigo': 'F', 'status': 'pending'}).status,
      history.TripStatus.completed,
    );
    expect(
      history.Trip.fromJson({'estado': 'I'}).status,
      history.TripStatus.inProgress,
    );
  });
  test(
    'Live status preserves assignment, ignores other trips and clears finished trip',
    () {
      socket.assignmentEvents.add({
        'carrera_id': 42,
        'estado_codigo': 'E',
        'estado': 'EN_CAMINO',
        'conductor': {'nombre': 'Juan'},
        'unidad': {'placa': 'ABC123'},
      });
      socket.states.add({
        'carrera': {'carrera_id': 99, 'estado': 'F'},
      });
      expect(controller.status.value, TripStatus.accepted);
      socket.states.add({
        'carrera': {
          'carrera_id': 42,
          'estado': 'L',
          'estado_nombre': 'CLIENTE_NOTIFICADO_LLEGADA',
        },
      });
      expect(controller.status.value, TripStatus.arrived);
      socket.assignmentEvents.add({
        'carrera_id': 42,
        'estado_codigo': 'E',
        'estado': 'EN_CAMINO',
      });
      expect(controller.status.value, TripStatus.arrived);
      socket.states.add({
        'carrera_id': 42,
        'estado_codigo': 'I',
        'estado': 'EN_CAMINO',
      });
      expect(controller.status.value, TripStatus.started);
      expect(
        controller.activeTrip.value!.assignment!['conductor']['nombre'],
        'Juan',
      );
      expect(ActiveTripSession.instance.trip.value!.status, TripStatus.started);
      socket.states.add({'carrera_id': 42, 'estado_codigo': 'F'});
      expect(controller.status.value, TripStatus.completed);
      expect(ActiveTripSession.instance.trip.value, isNull);
      socket.assignmentEvents.add({'carrera_id': 42, 'estado_codigo': 'E'});
      expect(controller.status.value, TripStatus.completed);
    },
  );
  test(
    'Recovery can return an already started or completed trip without driver',
    () {
      socket.assignmentEvents.add({
        'carrera': {'carrera_id': 42, 'estado_codigo': 'I'},
      });
      expect(controller.status.value, TripStatus.started);
      socket.assignmentEvents.add({
        'carrera': {'carrera_id': 42, 'estado': 'F'},
      });
      expect(controller.status.value, TripStatus.completed);
      expect(ActiveTripSession.instance.trip.value, isNull);
    },
  );
  testWidgets('Completed tracking displays final state and return action', (
    tester,
  ) async {
    socket.states.add({'carrera_id': 42, 'estado_codigo': 'F'});
    await tester.pumpWidget(
      GetMaterialApp(home: DriverTrackingPage(controller: controller)),
    );
    await tester.pumpAndSettle();
    expect(find.text('Viaje finalizado'), findsOneWidget);
    expect(find.text('Volver al inicio'), findsOneWidget);
  });
}

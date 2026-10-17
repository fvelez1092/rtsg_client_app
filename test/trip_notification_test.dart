import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:app_rtsg_client/data/models/trip_notification_event.dart';
import 'package:app_rtsg_client/data/models/trip_state_contract.dart';
import 'package:app_rtsg_client/data/models/trip_status.dart';
import 'package:app_rtsg_client/data/services/trip_notification_ledger.dart';
import 'package:app_rtsg_client/application/trip_controller.dart';
import 'package:app_rtsg_client/data/services/trip_service.dart';
import 'package:app_rtsg_client/data/services/trip_socket_service.dart';
import 'package:app_rtsg_client/data/services/gps_service.dart';
import 'package:app_rtsg_client/presentation/pages/trip/trip_page.dart';
import 'package:app_rtsg_client/data/models/trips/trip_model.dart' as history;
import 'active_trip_return_test.dart' show FakeTrips;
import 'trip_contract_test.dart' show ContractSocket;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  tearDown(() => Get.reset());
  test(
    'Parses client FCM types, nested socket payloads and old local taps',
    () {
      for (final type in [
        'CONDUCTOR_ASIGNADO',
        'CARRERA_ASIGNADA',
        'ESTADO_CARRERA',
        'ACTUALIZACION_CARRERA',
      ]) {
        final event = TripNotificationEvent.fromData({
          'tipo': type,
          'data': '{"carrera_id":"42","evento_id":"33","estado_codigo":"F"}',
        });
        expect(event!.tripId, 42);
        expect(event.eventId, '33');
        expect(event.title, 'Tu viaje ha finalizado');
        expect(TripNotificationEvent.fromPayload(event.payload)!.eventId, '33');
      }
      expect(
        TripNotificationEvent.fromData({
          'tipo': 'NUEVA_CARRERA',
          'carrera_id': '42',
        }),
        isNull,
      );
      expect(TripNotificationEvent.fromPayload('42')!.tripId, 42);
      expect(TripNotificationEvent.fromPayload('invalid'), isNull);
    },
  );
  test(
    'Concurrent socket and push produce one alert; persistent ledger retains 100 IDs',
    () async {
      List<String> saved = [];
      final ledger = TripNotificationLedger(
        read: () => saved,
        write: (ids) async => saved = List.of(ids),
      );
      var alerts = 0;
      Future<void> show() async {
        alerts++;
        await Future<void>.delayed(Duration.zero);
      }

      final results = await Future.wait([
        ledger.runOnce('30', show),
        ledger.runOnce('30', show),
      ]);
      expect(alerts, 1);
      expect(results, [true, false]);
      final reloaded = TripNotificationLedger(
        read: () => saved,
        write: (ids) async => saved = List.of(ids),
      );
      expect(await reloaded.runOnce('30', show), isFalse);
      for (var i = 0; i < 120; i++) {
        await reloaded.runOnce('new-$i', () async {});
      }
      expect(saved.length, 100);
      expect(saved.last, 'new-119');
      expect(saved.first, 'new-20');
      // Explicitly opening a previously processed ID still parses for navigation.
      expect(
        TripNotificationEvent.fromData({
          'tipo': 'ESTADO_CARRERA',
          'carrera_id': '42',
          'evento_id': 'new-119',
          'estado_codigo': 'F',
        })!.tripId,
        42,
      );
    },
  );
  test(
    'Failed presentation can retry and does not poison the dedup queue',
    () async {
      List<String> saved = [];
      final ledger = TripNotificationLedger(
        read: () => saved,
        write: (ids) async => saved = ids,
      );
      await expectLater(
        ledger.runOnce('1', () async => throw Exception('platform')),
        throwsException,
      );
      expect(saved, isEmpty);
      expect(await ledger.runOnce('1', () async {}), isTrue);
    },
  );
  test('All documented states resolve and C/P are cancelled in history', () {
    for (final code in ['S', 'B', 'R']) {
      expect(
        tripStatusFromBackend({'estado_codigo': code}),
        TripStatus.searching,
      );
    }
    for (final code in ['C', 'P']) {
      expect(
        tripStatusFromBackend({'estado_codigo': code}),
        TripStatus.cancelled,
      );
      expect(
        history.Trip.fromJson({'estado_codigo': code}).status,
        history.TripStatus.cancelled,
      );
    }
  });
  testWidgets(
    'Stale assignment tap waits for current query and displays cancellation',
    (tester) async {
      Get.testMode = true;
      Get.put(GpsService());
      Get.put<TripService>(FakeTrips());
      final socket = ContractSocket();
      Get.put<TripSocketService>(socket);
      final controller = Get.put(TripController());
      controller.recoverAssignedTrip(42);
      await tester.pumpWidget(const GetMaterialApp(home: TripPage()));
      await tester.pump();
      expect(find.text('Consultando tu viaje'), findsOneWidget);
      expect(find.text('Tu conductor viene en camino'), findsNothing);
      socket.assignmentEvents.add({
        '_recovered': true,
        'carrera': {'carrera_id': 42, 'estado_codigo': 'C'},
      });
      await tester.pumpAndSettle();
      expect(find.text('Viaje cancelado'), findsOneWidget);
      expect(controller.isRecoveringTrip.value, isFalse);
      expect(tester.takeException(), isNull);
    },
  );
  test('Authoritative recovery accepts waiting after an outdated assignment', () {
    Get.testMode = true;
    Get.put(GpsService());
    Get.put<TripService>(FakeTrips());
    final socket = ContractSocket();
    Get.put<TripSocketService>(socket);
    final controller = Get.put(TripController());
    controller.recoverAssignedTrip(42);
    // Avoid displaying a modal in this unit test; use recovered F then B parser above.
    socket.assignmentEvents.add({
      '_recovered': true,
      'carrera': {'carrera_id': 42, 'estado_codigo': 'F'},
    });
    expect(controller.status.value, TripStatus.completed);
    controller.recoverAssignedTrip(42);
    expect(controller.isRecoveringTrip.value, isTrue);
    socket.assignmentEvents.add({
      '_recovered': true,
      'carrera': {'carrera_id': 42, 'estado_codigo': 'L'},
    });
    expect(controller.status.value, TripStatus.arrived);
    expect(controller.isRecoveringTrip.value, isFalse);
  });
}

import 'tariff_configuration_test.dart' show configuration;
import 'package:app_rtsg_client/data/models/tariff_configuration.dart';
import 'package:app_rtsg_client/data/services/tariff_configuration_service.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:app_rtsg_client/data/services/gps_service.dart';
import 'package:app_rtsg_client/data/services/mapbox_service.dart';
import 'package:app_rtsg_client/data/services/trip_service.dart';
import 'package:app_rtsg_client/data/services/trip_socket_service.dart';
import 'package:app_rtsg_client/data/services/partners_service.dart';
import 'package:app_rtsg_client/data/services/publicidad_service.dart';
import 'package:app_rtsg_client/data/models/saved_address_model.dart';
import 'package:app_rtsg_client/data/models/partnert_model.dart';
import 'package:app_rtsg_client/application/trip_controller.dart';
import 'package:app_rtsg_client/application/trips_controller.dart';
import 'package:app_rtsg_client/application/home_controller.dart';
import 'package:app_rtsg_client/application/home_content_controller.dart';
import 'package:app_rtsg_client/presentation/pages/home/home_page.dart';
import 'package:app_rtsg_client/presentation/widgets/location_access_card.dart';
import 'package:app_rtsg_client/presentation/pages/trip/components/trip_panel.dart';
import 'package:app_rtsg_client/presentation/widgets/map_widget.dart';
import 'active_trip_return_test.dart' show FakeTrips, FakeSocket;

class FakeGeo extends GeolocatorPlatform {
  bool enabled = true;
  LocationPermission permission = LocationPermission.whileInUse;
  int positionCalls = 0,
      requestCalls = 0,
      appSettingsCalls = 0,
      locationSettingsCalls = 0;
  bool failFirst = false;
  LocationSettings? lastSettings;
  @override
  Future<bool> isLocationServiceEnabled() async => enabled;
  @override
  Future<LocationPermission> checkPermission() async => permission;
  @override
  Future<LocationPermission> requestPermission() async {
    requestCalls++;
    return permission;
  }

  @override
  Future<bool> openAppSettings() async {
    appSettingsCalls++;
    return true;
  }

  @override
  Future<bool> openLocationSettings() async {
    locationSettingsCalls++;
    return true;
  }

  @override
  Future<Position> getCurrentPosition({
    LocationSettings? locationSettings,
  }) async {
    positionCalls++;
    lastSettings = locationSettings;
    if (failFirst && positionCalls == 1) throw TimeoutException('no fix');
    return Position(
      latitude: -0.2,
      longitude: -78.5,
      timestamp: DateTime(2026),
      accuracy: 5,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    );
  }
}

class EmptyPartnersService extends PartnersService {
  @override
  Future<List<PartnerModel>> getPartners() async => const [];
}

class EmptyPublicidadService extends PublicidadService {
  @override
  Future<List<PartnerAdModel>> getPublicidades() async => const [];
}

class RouteGeocoder extends MapboxGeocoder {
  final Completer<String?> reverseResult = Completer<String?>();
  @override
  Future<String?> reverse({required double lat, required double lon}) =>
      reverseResult.future;
  @override
  Future<Map<String, dynamic>?> route({
    required LatLng origin,
    required LatLng destination,
    String profile = 'driving',
  }) async => {
    'distance_m': 100.0,
    'duration_s': 10.0,
    'points': [origin, destination],
  };
}

class FailedRouteGeocoder extends MapboxGeocoder {
  @override
  Future<Map<String, dynamic>?> route({
    required LatLng origin,
    required LatLng destination,
    String profile = 'driving',
  }) async => null;
}

class RacingRouteGeocoder extends MapboxGeocoder {
  final requests = <Completer<Map<String, dynamic>?>>[];
  @override
  Future<Map<String, dynamic>?> route({
    required LatLng origin,
    required LatLng destination,
    String profile = 'driving',
  }) {
    final request = Completer<Map<String, dynamic>?>();
    requests.add(request);
    return request.future;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  tearDown(() {
    Get.reset();
    debugDefaultTargetPlatformOverride = null;
  });
  test(
    'Denied GPS never queries a position and opens app permissions',
    () async {
      final platform = FakeGeo()..permission = LocationPermission.deniedForever;
      final gps = GpsService(platform: platform);
      await gps.getCurrentLocation();
      expect(platform.positionCalls, 0);
      expect(platform.requestCalls, 0);
      expect(gps.access.value, LocationAccess.deniedForever);
      await gps.openLocationConfiguration();
      expect(platform.appSettingsCalls, 1);
    },
  );
  test(
    'Disabled GPS clears previous position and opens location settings',
    () async {
      final platform = FakeGeo();
      final gps = GpsService(platform: platform);
      await gps.getCurrentLocation();
      expect(gps.hasUsableLocation, isTrue);
      platform.enabled = false;
      await gps.getCurrentLocation();
      expect(gps.currentPosition.value, isNull);
      expect(platform.positionCalls, 1);
      await gps.openLocationConfiguration();
      expect(platform.locationSettingsCalls, 1);
    },
  );
  test(
    'Android retries with LocationManager and restores access after permission changes',
    () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      final platform = FakeGeo()..failFirst = true;
      final gps = GpsService(platform: platform);
      await gps.getCurrentLocation();
      expect(platform.positionCalls, 2);
      expect(
        (platform.lastSettings as AndroidSettings).forceLocationManager,
        isTrue,
      );
      expect(gps.hasUsableLocation, isTrue);
      platform.permission = LocationPermission.denied;
      await gps.getCurrentLocation(requestPermission: false);
      expect(gps.hasUsableLocation, isFalse);
      expect(platform.requestCalls, 0);
      platform.permission = LocationPermission.whileInUse;
      await gps.getCurrentLocation(requestPermission: false);
      expect(gps.hasUsableLocation, isTrue);
    },
  );
  test('Missing tariffs block a quote and retry uses backend values', () async {
    Get.testMode = true;
    Get.put(GpsService(platform: FakeGeo()));
    Get.put<TripService>(FakeTrips());
    Get.put<TripSocketService>(FakeSocket());
    final tariffs = LocationTariffs()..fail = true;
    final controller = Get.put(
      TripController(
        geocoder: RouteGeocoder(),
        tariffService: tariffs,
        now: () => DateTime.parse('2026-10-17T17:00:00Z'),
      ),
    );
    controller.setOriginFromSavedAddress(
      const SavedAddress(
        id: 7,
        label: 'Casa',
        address: 'Mi casa',
        latitude: -0.2,
        longitude: -78.5,
      ),
    );
    await controller.setDestination(
      address: 'Destino',
      point: const LatLng(-0.21, -78.51),
    );
    expect(controller.canCreateTrip, isFalse);
    expect(controller.routeError.value, contains('tarifa'));
    expect(controller.estimatedFare.value, 0);
    tariffs.fail = false;
    await controller.recalculateIfPossible();
    expect(controller.canCreateTrip, isTrue);
    expect(controller.estimatedFare.value, 1.25);
    expect(controller.routeError.value, isEmpty);
  });
  testWidgets(
    'Saved Casa enables the trip without GPS and ignores stale origin lookup',
    (tester) async {
      Get.testMode = true;
      Get.put(
        GpsService(platform: FakeGeo()..permission = LocationPermission.denied),
      );
      Get.put<TripService>(FakeTrips());
      Get.put<TripSocketService>(FakeSocket());
      final geocoder = RouteGeocoder();
      final controller = Get.put(
        TripController(geocoder: geocoder, tariffService: LocationTariffs()),
      );
      controller.onMapChanged(const LatLng(-0.3, -78.6), 16, isFinal: true);
      controller.setOriginFromSavedAddress(
        SavedAddress.fromJson({
          'id': 7,
          'alias': 'Casa',
          'direccion': 'Mi casa',
          'coordenadas': '{"latitud":-0.2,"lng":-78.5}',
        }),
      );
      await controller.setDestination(
        address: 'Destino',
        point: const LatLng(-0.21, -78.51),
      );
      expect(controller.durationMin.value, 1);
      expect(controller.canCreateTrip, isTrue);
      expect(controller.selectedOriginAddressId, 7);
      geocoder.reverseResult.complete('Dirección antigua');
      await tester.pump();
      expect(controller.originAddress.value, 'Mi casa');
      controller.isResolvingOrigin.value = true;
      await tester.pumpWidget(
        const GetMaterialApp(home: Scaffold(body: TripPanel())),
      );
      await tester.pump();
      final button = find.widgetWithText(
        FilledButton,
        'Solicitar  •  \$${controller.finalFare.toStringAsFixed(2)}',
      );
      expect(tester.widget<FilledButton>(button).onPressed, isNull);
      controller.isResolvingOrigin.value = false;
      await tester.pump();
      expect(tester.widget<FilledButton>(button).onPressed, isNotNull);
    },
  );
  testWidgets(
    'Home hides recommendations without location and opens correct settings',
    (tester) async {
      Get.testMode = true;
      final platform = FakeGeo()..permission = LocationPermission.deniedForever;
      final gps = Get.put(GpsService(platform: platform));
      await gps.getCurrentLocation();
      final content = HomeContentController(
        partnersService: PartnersService(),
        publicidadService: PublicidadService(),
      );
      content.publicidades.add(
        const PartnerAdModel(
          id: 1,
          title: 'Oferta',
          description: '',
          imageUrl: '',
          partnerName: 'Local',
        ),
      );
      content.partners.add(
        const PartnerModel(
          id: 1,
          name: 'Local',
          category: 'Comida',
          logoUrl: '',
          rating: 5,
        ),
      );
      Get.put(HomeController(content, TripsController(FakeTrips())));
      await tester.pumpWidget(const GetMaterialApp(home: HomePage()));
      await tester.pumpAndSettle();
      expect(find.text('Permiso de ubicación bloqueado'), findsOneWidget);
      expect(find.text('Beneficios para ti'), findsNothing);
      expect(find.text('Partners RTSG'), findsNothing);
      await tester.tap(find.text('Abrir ajustes'));
      await tester.pumpAndSettle();
      expect(platform.appSettingsCalls, 1);
      platform.permission = LocationPermission.whileInUse;
      await gps.getCurrentLocation(requestPermission: false);
      await tester.pumpAndSettle();
      expect(find.text('Permiso de ubicación bloqueado'), findsNothing);
      expect(find.text('Beneficios para ti'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Partners RTSG'),
        250,
        scrollable: find
            .descendant(
              of: find.byType(CustomScrollView),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.pumpAndSettle();
      expect(find.text('Partners RTSG'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('Denied GPS shows a button that requests location permission', (
    tester,
  ) async {
    Get.testMode = true;
    final platform = FakeGeo()..permission = LocationPermission.denied;
    final gps = GpsService(platform: platform);
    await gps.getCurrentLocation(requestPermission: false);

    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(body: LocationAccessCard(gps: gps)),
      ),
    );
    expect(find.text('Falta permiso de ubicación'), findsOneWidget);
    expect(find.text('Permitir ubicación'), findsOneWidget);

    await tester.tap(find.text('Permitir ubicación'));
    await tester.pumpAndSettle();
    expect(platform.requestCalls, 1);
    expect(tester.takeException(), isNull);
  });
  testWidgets('Home explains when nearby content has no results', (
    tester,
  ) async {
    Get.testMode = true;
    final gps = Get.put(GpsService(platform: FakeGeo()));
    gps.currentPosition.value = const LatLng(-0.2, -78.5);
    gps.access.value = LocationAccess.available;
    final content = HomeContentController(
      partnersService: EmptyPartnersService(),
      publicidadService: EmptyPublicidadService(),
    );
    Get.put(HomeController(content, TripsController(FakeTrips())));

    await tester.pumpWidget(const GetMaterialApp(home: HomePage()));
    await tester.pumpAndSettle();

    expect(find.text('Recomendaciones para ti'), findsOneWidget);
    expect(
      find.text('Todavía no hay recomendaciones disponibles.'),
      findsOneWidget,
    );
    await tester.scrollUntilVisible(
      find.text('Partners RTSG'),
      250,
      scrollable: find
          .descendant(
            of: find.byType(CustomScrollView),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.pumpAndSettle();
    expect(find.text('Partners RTSG'), findsOneWidget);
    expect(
      find.text('Aún no hay partners disponibles cerca de ti.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
  testWidgets('Programmatic map centering never changes a saved origin', (
    tester,
  ) async {
    var changes = 0;
    Widget map(LatLng center) => MaterialApp(
      home: Scaffold(
        body: MapPicker(
          initialCenter: center,
          initialZoom: 16,
          onChanged: (center, zoom, {required isFinal}) {
            changes++;
          },
        ),
      ),
    );
    await tester.pumpWidget(map(const LatLng(-0.2, -78.5)));
    await tester.pumpAndSettle();
    changes = 0;
    await tester.pumpWidget(map(const LatLng(-0.3, -78.6)));
    await tester.pumpAndSettle();
    expect(changes, 0);
    await tester.drag(find.byType(MapPicker), const Offset(90, 30));
    await tester.pumpAndSettle();
    expect(changes, greaterThan(0));
    expect(tester.takeException(), isNull);
  });
  testWidgets('Failed route offers retry without an endless spinner', (
    tester,
  ) async {
    Get.testMode = true;
    Get.put(GpsService(platform: FakeGeo()));
    Get.put<TripService>(FakeTrips());
    Get.put<TripSocketService>(FakeSocket());
    final controller = Get.put(TripController(geocoder: FailedRouteGeocoder()));
    controller.setOriginFromSavedAddress(
      const SavedAddress(
        id: 7,
        label: 'Casa',
        address: 'Mi casa',
        latitude: -0.2,
        longitude: -78.5,
      ),
    );
    await controller.setDestination(
      address: 'Destino',
      point: const LatLng(-0.21, -78.51),
    );
    await tester.pumpWidget(
      const GetMaterialApp(home: Scaffold(body: TripPanel())),
    );
    await tester.pumpAndSettle();
    expect(find.text('Reintentar cálculo'), findsOneWidget);
    expect(find.text('Calculando la mejor ruta…'), findsNothing);
    expect(controller.canCreateTrip, isFalse);
  });
  test(
    'An older route never overwrites a newly selected saved origin route',
    () async {
      Get.testMode = true;
      Get.put(GpsService(platform: FakeGeo()));
      Get.put<TripService>(FakeTrips());
      Get.put<TripSocketService>(FakeSocket());
      final geocoder = RacingRouteGeocoder();
      final controller = Get.put(
        TripController(geocoder: geocoder, tariffService: LocationTariffs()),
      );
      controller.setOriginFromSavedAddress(
        const SavedAddress(
          id: 7,
          label: 'Casa',
          address: 'Mi casa',
          latitude: -0.2,
          longitude: -78.5,
        ),
      );
      final oldRequest = controller.setDestination(
        address: 'Destino',
        point: const LatLng(-0.21, -78.51),
      );
      controller.setOriginFromSavedAddress(
        const SavedAddress(
          id: 8,
          label: 'Trabajo',
          address: 'Mi trabajo',
          latitude: -0.3,
          longitude: -78.6,
        ),
      );
      geocoder.requests[1].complete({
        'distance_m': 3000.0,
        'duration_s': 180.0,
        'points': <LatLng>[],
      });
      await Future<void>.delayed(Duration.zero);
      geocoder.requests[0].complete({
        'distance_m': 100.0,
        'duration_s': 10.0,
        'points': <LatLng>[],
      });
      await oldRequest;
      expect(controller.distanceKm.value, 3);
      expect(controller.durationMin.value, 3);
      expect(controller.selectedOriginAddressId, 8);
      expect(controller.canCreateTrip, isTrue);
    },
  );
}

class LocationTariffs extends TariffConfigurationService {
  bool fail = false;
  @override
  Future<TariffConfiguration> getConfiguration() async {
    if (fail) throw Exception('Sin conexión');
    return TariffConfiguration.fromJson(configuration());
  }
}

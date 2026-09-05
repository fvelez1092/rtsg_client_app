import 'dart:async';

import 'package:app_rtsg_client/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

typedef MapCenterChanged =
    void Function(LatLng center, double zoom, {required bool isFinal});

class MapPicker extends StatefulWidget {
  final LatLng initialCenter;
  final double initialZoom;
  final MapCenterChanged onChanged;

  // OSM
  final String tileUrlTemplate;
  final List<String> subdomains;
  final String userAgentPackageName;
  final Duration moveThrottle;
  final bool showCrosshair;
  final bool showAttribution;

  // Tracking (optional)
  final LatLng? driverPosition;
  final List<LatLng> path;
  final bool showDriverMarker;
  final bool showPath;
  final bool followDriver;

  // User / trip points (optional)
  final LatLng? userPosition;
  final bool showUserMarker;
  final LatLng? destinationPosition;
  final bool showDestinationMarker;

  // Dynamic camera fitting
  final bool autoFit;
  final List<LatLng> fitPoints;
  final EdgeInsets fitPadding;
  final double fitMinZoom;
  final double? fitMaxZoom;

  // Styling
  final Color polylineColor;

  const MapPicker({
    super.key,
    required this.initialCenter,
    required this.initialZoom,
    required this.onChanged,
    this.tileUrlTemplate = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    this.subdomains = const <String>[],
    this.userAgentPackageName = 'com.example.app_rtsg_client',
    this.moveThrottle = const Duration(milliseconds: 80),
    this.showCrosshair = true,
    this.showAttribution = true,
    this.driverPosition,
    this.path = const <LatLng>[],
    this.showDriverMarker = false,
    this.showPath = false,
    this.followDriver = false,
    this.userPosition,
    this.showUserMarker = false,
    this.destinationPosition,
    this.showDestinationMarker = false,
    this.autoFit = false,
    this.fitPoints = const <LatLng>[],
    this.fitPadding = const EdgeInsets.all(32),
    this.fitMinZoom = 11.5,
    this.fitMaxZoom = 16.2,
    this.polylineColor = AppColors.brandGreen,
  });

  @override
  State<MapPicker> createState() => _MapPickerState();
}

class _MapPickerState extends State<MapPicker> {
  final MapController _mapController = MapController();
  StreamSubscription<MapEvent>? _sub;
  Timer? _fitTrailingTimer;

  bool _isMoving = false;
  bool _userInteracting = false;
  DateTime _lastTick = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime _lastFitTick = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void initState() {
    super.initState();

    _sub = _mapController.mapEventStream.listen((event) {
      if (event is MapEventMoveStart) {
        _isMoving = true;
        _userInteracting = true;
      }

      if (event is MapEventMove) {
        final now = DateTime.now();
        if (now.difference(_lastTick) >= widget.moveThrottle) {
          widget.onChanged(
            event.camera.center,
            event.camera.zoom,
            isFinal: false,
          );
          _lastTick = now;
        }
      }

      if (event is MapEventMoveEnd) {
        _isMoving = false;
        _userInteracting = false;
        widget.onChanged(event.camera.center, event.camera.zoom, isFinal: true);
      }

      if (mounted) setState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _scheduleFit(force: true),
    );
  }

  @override
  void didUpdateWidget(covariant MapPicker oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.followDriver &&
        !_userInteracting &&
        widget.driverPosition != null &&
        widget.driverPosition != oldWidget.driverPosition) {
      final currentZoom = _mapController.camera.zoom;
      _mapController.move(widget.driverPosition!, currentZoom);
      return;
    }

    final fitChanged =
        widget.autoFit != oldWidget.autoFit ||
        widget.fitPadding != oldWidget.fitPadding ||
        widget.fitMinZoom != oldWidget.fitMinZoom ||
        widget.fitMaxZoom != oldWidget.fitMaxZoom ||
        !_samePoints(widget.fitPoints, oldWidget.fitPoints);

    if (widget.autoFit && fitChanged) {
      _scheduleFit();
      return;
    }

    if (!widget.autoFit &&
        (widget.initialCenter != oldWidget.initialCenter ||
            widget.initialZoom != oldWidget.initialZoom)) {
      _mapController.move(widget.initialCenter, widget.initialZoom);
    }
  }

  bool _samePoints(List<LatLng> a, List<LatLng> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void _scheduleFit({bool force = false}) {
    if (!mounted || !widget.autoFit || widget.fitPoints.length < 2) return;
    if (_userInteracting) return;

    const throttle = Duration(milliseconds: 70);
    final now = DateTime.now();
    final elapsed = now.difference(_lastFitTick);

    if (force || elapsed >= throttle) {
      _fitTrailingTimer?.cancel();
      WidgetsBinding.instance.addPostFrameCallback((_) => _fitRoute());
      return;
    }

    _fitTrailingTimer?.cancel();
    _fitTrailingTimer = Timer(throttle - elapsed, () {
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) => _fitRoute());
    });
  }

  void _fitRoute() {
    if (!mounted || !widget.autoFit || widget.fitPoints.length < 2) return;
    if (_userInteracting) return;

    _lastFitTick = DateTime.now();

    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: LatLngBounds.fromPoints(widget.fitPoints),
        padding: widget.fitPadding,
        minZoom: widget.fitMinZoom,
        maxZoom: widget.fitMaxZoom,
      ),
    );
  }

  @override
  void dispose() {
    _fitTrailingTimer?.cancel();
    _sub?.cancel();
    super.dispose();
  }

  Widget _userDot() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: widget.polylineColor.withValues(alpha: 0.20),
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: widget.polylineColor,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.surface, width: 2),
          ),
        ),
      ],
    );
  }

  Widget _destinationMarker() {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.brandRed, width: 3),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(
        Icons.flag_rounded,
        color: AppColors.brandRed,
        size: 21,
      ),
    );
  }

  Widget _selectionMarker() {
    return SizedBox(
      width: 56,
      height: 56,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          const Positioned(
            top: 3,
            child: Icon(
              Icons.location_on_rounded,
              size: 52,
              color: AppColors.shadow,
            ),
          ),
          Icon(
            Icons.location_on_rounded,
            size: 52,
            color: widget.polylineColor,
          ),
          Positioned(
            top: 10,
            child: Container(
              width: 19,
              height: 19,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: widget.polylineColor.withValues(alpha: 0.18),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.my_location_rounded,
                size: 12,
                color: widget.polylineColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final driver = widget.driverPosition;
    final user = widget.userPosition;
    final destination = widget.destinationPosition;

    return SizedBox.expand(
      child: Stack(
        fit: StackFit.expand,
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: widget.initialCenter,
              initialZoom: widget.initialZoom,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: widget.tileUrlTemplate,
                subdomains: widget.subdomains,
                userAgentPackageName: widget.userAgentPackageName,
              ),
              if (widget.showPath && widget.path.length >= 2)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: widget.path,
                      strokeWidth: 10,
                      color: widget.polylineColor.withValues(alpha: 0.35),
                    ),
                    Polyline(
                      points: widget.path,
                      strokeWidth: 6,
                      color: widget.polylineColor,
                    ),
                  ],
                ),
              if (widget.showUserMarker && user != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: user,
                      width: 44,
                      height: 44,
                      child: _userDot(),
                    ),
                  ],
                ),
              if (widget.showDestinationMarker && destination != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: destination,
                      width: 44,
                      height: 44,
                      child: _destinationMarker(),
                    ),
                  ],
                ),
              if (widget.showDriverMarker && driver != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: driver,
                      width: 48,
                      height: 48,
                      child: const Icon(
                        Icons.directions_car_rounded,
                        size: 36,
                        color: AppColors.brandRed,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          if (widget.showCrosshair)
            IgnorePointer(
              child: Center(
                child: Transform.translate(
                  offset: const Offset(0, -26),
                  child: _selectionMarker(),
                ),
              ),
            ),
          if (_isMoving)
            Positioned(
              top: 12,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.textPrimary.withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'Moviendo mapa…',
                    style: TextStyle(color: AppColors.surface, fontSize: 12),
                  ),
                ),
              ),
            ),
          if (widget.showAttribution)
            Positioned(
              right: 8,
              bottom: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                color: AppColors.surface.withValues(alpha: 0.85),
                child: const Text(
                  '© OpenStreetMap contributors',
                  style: TextStyle(fontSize: 11, color: AppColors.textPrimary),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

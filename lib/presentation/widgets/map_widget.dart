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

  // User (optional)
  final LatLng? userPosition;
  final bool showUserMarker;

  // Styling
  final Color polylineColor;

  const MapPicker({
    super.key,
    required this.initialCenter,
    required this.initialZoom,
    required this.onChanged,
    this.tileUrlTemplate = 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
    this.subdomains = const ['a', 'b', 'c'],
    this.userAgentPackageName = 'com.example.app_rtsg_client',
    this.moveThrottle = const Duration(milliseconds: 80),
    this.showCrosshair = true,
    this.showAttribution = true,

    // tracking defaults
    this.driverPosition,
    this.path = const <LatLng>[],
    this.showDriverMarker = false,
    this.showPath = false,
    this.followDriver = false,

    // user defaults
    this.userPosition,
    this.showUserMarker = false,

    // styling
    this.polylineColor = AppColors.brandGreen,
  });

  @override
  State<MapPicker> createState() => _MapPickerState();
}

class _MapPickerState extends State<MapPicker> {
  final MapController _mapController = MapController();
  StreamSubscription<MapEvent>? _sub;

  bool _isMoving = false;
  bool _userInteracting = false;
  DateTime _lastTick = DateTime.fromMillisecondsSinceEpoch(0);

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
  }

  @override
  void didUpdateWidget(covariant MapPicker oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Follow driver (only when enabled & user isn't moving the map)
    if (widget.followDriver &&
        !_userInteracting &&
        widget.driverPosition != null &&
        widget.driverPosition != oldWidget.driverPosition) {
      final currentZoom = _mapController.camera.zoom;
      _mapController.move(widget.driverPosition!, currentZoom);
      return;
    }

    // Picker behavior (manual center updates)
    if (widget.initialCenter != oldWidget.initialCenter) {
      final currentZoom = _mapController.camera.zoom;
      _mapController.move(widget.initialCenter, currentZoom);
    }
  }

  @override
  void dispose() {
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

  @override
  Widget build(BuildContext context) {
    final driver = widget.driverPosition;
    final user = widget.userPosition;

    return Stack(
      alignment: Alignment.center,
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
                  Marker(point: user, width: 44, height: 44, child: _userDot()),
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
          const IgnorePointer(
            child: Icon(
              Icons.add_location_alt_outlined,
              size: 30,
              color: AppColors.textPrimary,
            ),
          ),

        Positioned(
          top: 12,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 120),
            opacity: _isMoving ? 1 : 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
    );
  }
}

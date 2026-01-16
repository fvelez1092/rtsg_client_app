import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

typedef MapCenterChanged =
    void Function(LatLng center, double zoom, {required bool isFinal});

typedef MapOverlayBuilder = Widget Function(BuildContext context);

typedef CenterLabelBuilder =
    Widget Function(BuildContext context, String label, bool isMoving);

class MapPicker extends StatefulWidget {
  final LatLng initialCenter;
  final double initialZoom;
  final MapCenterChanged onChanged;

  // Tile config
  final String tileUrlTemplate;
  final List<String> subdomains;
  final String userAgentPackageName;

  // Performance
  final Duration moveThrottle;

  // UI (reutilizable)
  final Widget? crosshair;
  final bool showMovingIndicator;
  final Widget Function(BuildContext context)? movingIndicatorBuilder;
  final bool showAttribution;
  final Widget Function(BuildContext context)? attributionBuilder;

  /// Label estilo inDrive sobre el marcador (texto ya resuelto por el caller)
  final String centerLabel;
  final bool showCenterLabel;
  final CenterLabelBuilder? centerLabelBuilder;

  /// Overlays extra sobre el mapa (ej. botones, cards, etc.)
  final List<MapOverlayBuilder> overlayBuilders;

  const MapPicker({
    super.key,
    required this.initialCenter,
    required this.initialZoom,
    required this.onChanged,
    this.tileUrlTemplate = 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
    this.subdomains = const ['a', 'b', 'c'],
    this.userAgentPackageName = 'com.rtsg_client.app',
    this.moveThrottle = const Duration(milliseconds: 120),
    this.crosshair,
    this.showMovingIndicator = true,
    this.movingIndicatorBuilder,
    this.showAttribution = true,
    this.attributionBuilder,
    this.centerLabel = '',
    this.showCenterLabel = true,
    this.centerLabelBuilder,
    this.overlayBuilders = const [],
  });

  @override
  State<MapPicker> createState() => _MapPickerState();
}

class _MapPickerState extends State<MapPicker> {
  final MapController _mapController = MapController();

  StreamSubscription<MapEvent>? _sub;
  Timer? _throttleTimer;

  final ValueNotifier<bool> _isMoving = ValueNotifier<bool>(false);

  LatLng? _pendingCenter;
  double? _pendingZoom;

  @override
  void initState() {
    super.initState();
    _sub = _mapController.mapEventStream.listen(_handleMapEvent);
  }

  void _handleMapEvent(MapEvent event) {
    if (event is MapEventMoveStart) {
      if (!_isMoving.value) _isMoving.value = true;
      return;
    }

    if (event is MapEventMove) {
      _pendingCenter = event.camera.center;
      _pendingZoom = event.camera.zoom;

      _throttleTimer ??= Timer(widget.moveThrottle, () {
        _throttleTimer = null;

        final c = _pendingCenter;
        final z = _pendingZoom;
        if (c != null && z != null) {
          widget.onChanged(c, z, isFinal: false);
        }
      });
      return;
    }

    if (event is MapEventMoveEnd) {
      if (_isMoving.value) _isMoving.value = false;

      _throttleTimer?.cancel();
      _throttleTimer = null;

      widget.onChanged(event.camera.center, event.camera.zoom, isFinal: true);
      return;
    }
  }

  @override
  void didUpdateWidget(covariant MapPicker oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.initialCenter != oldWidget.initialCenter) {
      final currentZoom = _mapController.camera.zoom;
      _mapController.move(widget.initialCenter, currentZoom);
    }
  }

  @override
  void dispose() {
    _throttleTimer?.cancel();
    _sub?.cancel();
    _isMoving.dispose();
    super.dispose();
  }

  Widget _defaultCrosshair() {
    return const IgnorePointer(
      child: Icon(Icons.person_pin_circle, size: 30, color: Colors.black),
    );
  }

  Widget _defaultMovingIndicator(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Text(
        'Moviendo mapa…',
        style: TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }

  Widget _defaultAttribution(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      color: Colors.white.withValues(alpha: 0.85),
      child: const Text(
        '© OpenStreetMap contributors',
        style: TextStyle(fontSize: 11),
      ),
    );
  }

  Widget _defaultCenterLabel(
    BuildContext context,
    String label,
    bool isMoving,
  ) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 120),
      opacity: label.trim().isEmpty ? 0 : 1,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              blurRadius: 12,
              spreadRadius: 0,
              color: Colors.black.withValues(alpha: 0.12),
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.place_outlined,
              size: 16,
              color: isMoving ? Colors.black54 : Colors.black87,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.5,
                  color: isMoving ? Colors.black54 : Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Widget crosshair = widget.crosshair ?? _defaultCrosshair();

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
          ],
        ),

        // Label sobre el “marcador”
        if (widget.showCenterLabel)
          Positioned(
            // lo subimos un poco para que quede sobre el icono del marcador
            child: Transform.translate(
              offset: const Offset(0, -46),
              child: ValueListenableBuilder<bool>(
                valueListenable: _isMoving,
                builder: (context, moving, _) {
                  final builder =
                      widget.centerLabelBuilder ?? _defaultCenterLabel;
                  return builder(context, widget.centerLabel, moving);
                },
              ),
            ),
          ),

        // Crosshair
        crosshair,

        // Indicador "Moviendo..."
        if (widget.showMovingIndicator)
          Positioned(
            top: 12,
            child: ValueListenableBuilder<bool>(
              valueListenable: _isMoving,
              builder: (context, moving, _) {
                return AnimatedOpacity(
                  duration: const Duration(milliseconds: 120),
                  opacity: moving ? 1 : 0,
                  child:
                      (widget.movingIndicatorBuilder ??
                      _defaultMovingIndicator)(context),
                );
              },
            ),
          ),

        // Atribución
        if (widget.showAttribution)
          Positioned(
            right: 8,
            bottom: 8,
            child: (widget.attributionBuilder ?? _defaultAttribution)(context),
          ),

        // Overlays extra
        ...widget.overlayBuilders.map<Widget>((builder) => builder(context)),
      ],
    );
  }
}

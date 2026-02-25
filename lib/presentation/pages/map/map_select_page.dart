import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import 'package:app_rtsg_client/core/theme/app_colors.dart';
import 'package:app_rtsg_client/presentation/widgets/map_widget.dart';
import 'package:app_rtsg_client/data/services/mapbox_service.dart';
import 'package:app_rtsg_client/data/models/map_point_result_model.dart';

class MapSelectPage extends StatefulWidget {
  final LatLng initialCenter;
  final double initialZoom;

  const MapSelectPage({
    super.key,
    required this.initialCenter,
    this.initialZoom = 16,
  });

  @override
  State<MapSelectPage> createState() => _MapSelectPageState();
}

class _MapSelectPageState extends State<MapSelectPage> {
  final _geocoder = MapboxGeocoder();

  LatLng _center = const LatLng(0, 0);
  String _label = 'Buscando dirección…';
  bool _resolving = false;

  int _reqId = 0;

  @override
  void initState() {
    super.initState();
    _center = widget.initialCenter;
    _resolve(_center);
  }

  @override
  void dispose() {
    _geocoder.dispose();
    super.dispose();
  }

  Future<void> _resolve(LatLng c) async {
    final current = ++_reqId;

    setState(() {
      _resolving = true;
      _label = 'Buscando dirección…';
    });

    final name = await _geocoder.reverse(lat: c.latitude, lon: c.longitude);

    if (!mounted) return;
    if (current != _reqId) return;

    setState(() {
      _resolving = false;
      _label = name ?? 'Dirección no disponible';
    });
  }

  void _onDone() {
    if (_resolving) return;
    Get.back(
      result: MapPointResult(point: _center, name: _label),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          MapPicker(
            initialCenter: _center,
            initialZoom: widget.initialZoom,
            centerLabel: _label,
            onChanged: (center, zoom, {required isFinal}) {
              _center = center;

              if (!isFinal) {
                if (!_resolving) {
                  setState(() => _label = 'Buscando dirección…');
                }
                return;
              }

              _resolve(center);
            },
          ),

          Positioned(
            top: 12,
            left: 12,
            child: SafeArea(
              child: Material(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                elevation: 2,
                shadowColor: AppColors.shadow,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => Get.back(),
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(Icons.arrow_back, color: AppColors.textPrimary),
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: SafeArea(
              child: SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _resolving ? null : _onDone,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.taxiYellow,
                    foregroundColor: AppColors.textPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  child: const Text('Hecho'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import 'package:app_rtsg_client/core/theme/app_colors.dart';
import 'package:app_rtsg_client/data/models/map_point_result_model.dart';
import 'package:app_rtsg_client/data/models/saved_address_model.dart';
import 'package:app_rtsg_client/data/services/mapbox_service.dart';
import 'package:app_rtsg_client/data/services/saved_address_service.dart';
import 'package:app_rtsg_client/presentation/widgets/map_widget.dart';

class TripLocationPickerPage extends StatefulWidget {
  final LatLng initialCenter;
  final double initialZoom;
  final String title;
  final String confirmText;
  final bool saveAsUserAddress;

  const TripLocationPickerPage({
    super.key,
    required this.initialCenter,
    this.initialZoom = 16,
    this.title = 'Selecciona una ubicación',
    this.confirmText = 'Confirmar ubicación',
    this.saveAsUserAddress = false,
  });

  @override
  State<TripLocationPickerPage> createState() =>
      _TripLocationPickerPageState();
}

class _TripLocationPickerPageState extends State<TripLocationPickerPage> {
  final MapboxGeocoder _geocoder = MapboxGeocoder();
  final SavedAddressService _savedAddressService = SavedAddressService();
  final TextEditingController _labelController = TextEditingController();

  late LatLng _center;
  String _address = 'Buscando dirección…';
  bool _resolving = false;
  int _requestId = 0;

  @override
  void initState() {
    super.initState();
    _center = widget.initialCenter;
    _resolve(_center);
  }

  @override
  void dispose() {
    _geocoder.dispose();
    _labelController.dispose();
    super.dispose();
  }

  Future<void> _resolve(LatLng point) async {
    final currentRequest = ++_requestId;

    setState(() {
      _resolving = true;
      _address = 'Buscando dirección…';
    });

    final result = await _geocoder.reverse(
      lat: point.latitude,
      lon: point.longitude,
    );

    if (!mounted || currentRequest != _requestId) return;

    setState(() {
      _resolving = false;
      _address = result ?? 'Dirección no disponible';
    });
  }

  Future<void> _confirm() async {
    if (_resolving || _address.trim().isEmpty) return;

    if (widget.saveAsUserAddress) {
      final label = _labelController.text.trim();
      if (label.isEmpty) {
        Get.snackbar(
          'Nombre de la dirección',
          'Escribe un nombre como Casa, Trabajo o Gimnasio.',
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
        return;
      }

      await _savedAddressService.save(
        SavedAddress(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          label: label,
          address: _address,
          latitude: _center.latitude,
          longitude: _center.longitude,
        ),
      );
    }

    if (!mounted) return;
    Get.back(result: MapPointResult(point: _center, name: _address));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: MapPicker(
              initialCenter: _center,
              initialZoom: widget.initialZoom,
              polylineColor: AppColors.brandGreen,
              onChanged: (center, zoom, {required isFinal}) {
                _center = center;
                if (isFinal) {
                  _resolve(center);
                } else if (!_resolving && mounted) {
                  setState(() => _address = 'Buscando dirección…');
                }
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  _RoundButton(
                    icon: Icons.arrow_back_rounded,
                    onTap: () => Get.back(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.shadow,
                            blurRadius: 12,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Text(
                        widget.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 18,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: AppColors.borderSoft,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                    const Text(
                      'Punto seleccionado',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Icon(
                            Icons.location_on_rounded,
                            color: AppColors.brandGreen,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _address,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (widget.saveAsUserAddress) ...[
                      const SizedBox(height: 14),
                      TextField(
                        controller: _labelController,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          hintText: 'Nombre: Casa, Trabajo…',
                          prefixIcon: const Icon(Icons.bookmark_outline_rounded),
                          filled: true,
                          fillColor: AppColors.inputFill,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: FilledButton(
                        onPressed: _resolving ? null : _confirm,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.brandGreen,
                          foregroundColor: AppColors.surface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _resolving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.surface,
                                ),
                              )
                            : Text(
                                widget.confirmText,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _RoundButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: const CircleBorder(),
      elevation: 3,
      shadowColor: AppColors.shadow,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(icon, color: AppColors.textPrimary, size: 22),
        ),
      ),
    );
  }
}

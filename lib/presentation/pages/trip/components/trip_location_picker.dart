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
  bool _isMapMoving = false;
  int _requestId = 0;

  bool get _canConfirm {
    final address = _address.trim();
    return !_resolving &&
        !_isMapMoving &&
        address.isNotEmpty &&
        address != 'Dirección no disponible';
  }

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

    if (mounted) {
      setState(() {
        _resolving = true;
        _address = 'Buscando dirección…';
      });
    }

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
    if (!_canConfirm) return;

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
    final mediaQuery = MediaQuery.of(context);
    final keyboardInset = mediaQuery.viewInsets.bottom;
    final safeBottom = mediaQuery.padding.bottom;
    final bottomInset = keyboardInset > 0
        ? keyboardInset + 12
        : safeBottom + 12;
    final maxCardHeight = mediaQuery.size.height *
        (widget.saveAsUserAddress ? 0.50 : 0.38);

    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                  if (mounted) {
                    setState(() => _isMapMoving = false);
                  }
                  _resolve(center);
                  return;
                }

                if (mounted) {
                  setState(() {
                    _isMapMoving = true;
                    _address = 'Buscando dirección…';
                  });
                }
              },
            ),
          ),
          SafeArea(
            bottom: false,
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
          AnimatedPositioned(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            left: 12,
            right: 12,
            bottom: bottomInset,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxCardHeight),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 18,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 42,
                          height: 5,
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            color: AppColors.borderSoft,
                            borderRadius: BorderRadius.circular(99),
                          ),
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
                      const SizedBox(height: 7),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.inputFill,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.borderSoft),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: AppColors.brandGreen.withValues(
                                  alpha: 0.10,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.location_on_rounded,
                                color: AppColors.brandGreen,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _address,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      height: 1.3,
                                    ),
                                  ),
                                  if (_isMapMoving || _resolving) ...[
                                    const SizedBox(height: 6),
                                    const Row(
                                      children: [
                                        SizedBox(
                                          width: 13,
                                          height: 13,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: AppColors.brandGreen,
                                          ),
                                        ),
                                        SizedBox(width: 7),
                                        Text(
                                          'Actualizando ubicación',
                                          style: TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (widget.saveAsUserAddress) ...[
                        const SizedBox(height: 12),
                        TextField(
                          controller: _labelController,
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            hintText: 'Nombre: Casa, Trabajo…',
                            prefixIcon: const Icon(
                              Icons.bookmark_outline_rounded,
                              color: AppColors.brandGreen,
                            ),
                            filled: true,
                            fillColor: AppColors.inputFill,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: FilledButton(
                          onPressed: _canConfirm ? _confirm : null,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.brandGreen,
                            foregroundColor: AppColors.surface,
                            disabledBackgroundColor: AppColors.borderSoft,
                            disabledForegroundColor: AppColors.textSecondary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            _isMapMoving || _resolving
                                ? 'Ubicando dirección…'
                                : widget.confirmText,
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

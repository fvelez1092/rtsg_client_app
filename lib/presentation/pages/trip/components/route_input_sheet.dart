import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import 'package:app_rtsg_client/application/trip_controller.dart';
import 'package:app_rtsg_client/core/theme/app_colors.dart';
import 'package:app_rtsg_client/data/models/map_point_result_model.dart';
import 'package:app_rtsg_client/data/models/saved_address_model.dart';
import 'package:app_rtsg_client/data/services/saved_address_service.dart';
import 'package:app_rtsg_client/presentation/pages/trip/components/trip_location_picker.dart';

enum RouteSelectMode { origin, destination }

/// Conserva el nombre anterior para no romper TripPanel, pero ahora funciona
/// como una experiencia de búsqueda de pantalla completa.
class RouteInputSheet extends StatefulWidget {
  final VoidCallback onClose;
  final RouteSelectMode mode;

  const RouteInputSheet({
    super.key,
    required this.onClose,
    required this.mode,
  });

  @override
  State<RouteInputSheet> createState() => _RouteInputSheetState();
}

class _RouteInputSheetState extends State<RouteInputSheet> {
  final TripController controller = Get.find<TripController>();
  final SavedAddressService _savedAddressService = SavedAddressService();
  final FocusNode _searchFocus = FocusNode();

  late RouteSelectMode _mode;

  bool get _isOrigin => _mode == RouteSelectMode.origin;

  @override
  void initState() {
    super.initState();
    _mode = widget.mode;
    controller.openDestinationSheet();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _searchFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchFocus.dispose();
    super.dispose();
  }

  void _switchMode(RouteSelectMode mode) {
    if (_mode == mode) {
      _searchFocus.requestFocus();
      return;
    }

    setState(() => _mode = mode);
    controller.openDestinationSheet();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _searchFocus.requestFocus();
    });
  }

  Future<void> _applyPoint({
    required LatLng point,
    required String address,
  }) async {
    if (_isOrigin) {
      controller.setOriginFromExternal(point: point, address: address);
    } else {
      await controller.setDestination(point: point, address: address);
    }

    if (mounted) widget.onClose();
  }

  Future<void> _selectResult(Map<String, dynamic> item) async {
    final name = (item['display_name'] ?? '').toString().trim();
    final lat = (item['lat'] as num?)?.toDouble();
    final lon = (item['lon'] as num?)?.toDouble();

    if (name.isEmpty || lat == null || lon == null) return;
    await _applyPoint(point: LatLng(lat, lon), address: name);
  }

  Future<void> _useSavedAddress(SavedAddress address) async {
    await _applyPoint(point: address.point, address: address.address);
  }

  Future<void> _useCurrentLocation() async {
    final ok = await controller.useCurrentLocation();
    if (!mounted) return;

    if (ok) {
      widget.onClose();
      return;
    }

    Get.snackbar(
      'Ubicación no disponible',
      'No pudimos obtener tu ubicación actual.',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
    );
  }

  Future<void> _selectOnMap() async {
    FocusScope.of(context).unfocus();

    final initial = _isOrigin
        ? (controller.originLatLng.value ?? controller.lastCenter)
        : (controller.destinationLatLng.value ??
              controller.originLatLng.value ??
              controller.lastCenter);

    final result = await Get.to<MapPointResult>(
      () => TripLocationPickerPage(
        initialCenter: initial,
        title: _isOrigin
            ? 'Ubica el punto de partida'
            : 'Ubica tu destino',
      ),
      transition: Transition.cupertino,
    );

    if (result == null || !mounted) {
      if (mounted) _searchFocus.requestFocus();
      return;
    }

    await _applyPoint(point: result.point, address: result.name);
  }

  IconData _savedIcon(SavedAddress address) {
    final label = address.label.toLowerCase();
    if (label.contains('casa')) return Icons.home_rounded;
    if (label.contains('trabajo')) return Icons.work_rounded;
    return Icons.star_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final savedAddresses = _savedAddressService.getAll();
    final height = MediaQuery.sizeOf(context).height;

    return SizedBox(
      height: height,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
                child: Row(
                  children: [
                    _RoundBackButton(onTap: widget.onClose),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.inputFill,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.person_rounded,
                            size: 19,
                            color: AppColors.brandGreen,
                          ),
                          SizedBox(width: 7),
                          Text(
                            'Para mí',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  children: [
                    Obx(
                      () => _LocationField(
                        active: _isOrigin,
                        dotColor: AppColors.brandGreen,
                        hint: 'Punto de partida',
                        value: controller.originAddress.value,
                        controller: _isOrigin ? controller.searchCtrl : null,
                        focusNode: _isOrigin ? _searchFocus : null,
                        onTap: () => _switchMode(RouteSelectMode.origin),
                        onChanged: (value) {
                          controller.onQueryChanged(value);
                          setState(() {});
                        },
                        onClear: () {
                          controller.searchCtrl.clear();
                          controller.onQueryChanged('');
                          setState(() {});
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    Obx(
                      () => _LocationField(
                        active: !_isOrigin,
                        dotColor: AppColors.brandRed,
                        hint: '¿A dónde vamos?',
                        value: controller.destinationAddress.value,
                        controller: !_isOrigin ? controller.searchCtrl : null,
                        focusNode: !_isOrigin ? _searchFocus : null,
                        onTap: () => _switchMode(RouteSelectMode.destination),
                        onChanged: (value) {
                          controller.onQueryChanged(value);
                          setState(() {});
                        },
                        onClear: () {
                          controller.searchCtrl.clear();
                          controller.onQueryChanged('');
                          setState(() {});
                        },
                      ),
                    ),
                  ],
                ),
              ),
              if (savedAddresses.isNotEmpty) ...[
                const SizedBox(height: 16),
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    scrollDirection: Axis.horizontal,
                    itemCount: savedAddresses.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final address = savedAddresses[index];
                      return ActionChip(
                        avatar: Icon(
                          _savedIcon(address),
                          size: 17,
                          color: AppColors.textSecondary,
                        ),
                        label: Text(address.label),
                        onPressed: () => _useSavedAddress(address),
                        backgroundColor: AppColors.surface,
                        side: const BorderSide(color: AppColors.borderSoft),
                        labelStyle: const TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w700,
                        ),
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Expanded(
                child: Obx(() {
                  final results = controller.results;
                  final searching = controller.isSearching.value;
                  final hasQuery = controller.searchCtrl.text.trim().isNotEmpty;

                  if (searching) {
                    return const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppColors.brandGreen,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Buscando lugares…',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (results.isNotEmpty) {
                    return ListView.separated(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
                      itemCount: results.length,
                      separatorBuilder: (_, __) => const Divider(
                        height: 1,
                        color: AppColors.borderSoft,
                      ),
                      itemBuilder: (context, index) {
                        final item = results[index];
                        return _ResultTile(
                          title: (item['display_name'] ?? 'Sin nombre')
                              .toString(),
                          onTap: () => _selectResult(item),
                        );
                      },
                    );
                  }

                  if (hasQuery) {
                    return const Center(
                      child: Text(
                        'No encontramos resultados para esta búsqueda.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    );
                  }

                  return ListView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
                    children: [
                      if (_isOrigin)
                        _ActionTile(
                          icon: Icons.my_location_rounded,
                          title: 'Mi ubicación actual',
                          subtitle: controller.originAddress.value.isEmpty
                              ? 'Usar la ubicación del GPS'
                              : controller.originAddress.value,
                          onTap: _useCurrentLocation,
                        ),
                      _ActionTile(
                        icon: Icons.location_on_outlined,
                        title: 'Señalar la ubicación en el mapa',
                        subtitle: _isOrigin
                            ? 'Ajusta con precisión el punto de partida'
                            : 'Mueve el mapa hasta el destino exacto',
                        onTap: _selectOnMap,
                      ),
                      if (savedAddresses.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.only(top: 18, bottom: 6),
                          child: Text(
                            'Tus lugares',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        ...savedAddresses.map(
                          (address) => _ActionTile(
                            icon: _savedIcon(address),
                            title: address.label,
                            subtitle: address.address,
                            onTap: () => _useSavedAddress(address),
                          ),
                        ),
                      ],
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LocationField extends StatelessWidget {
  final bool active;
  final Color dotColor;
  final String hint;
  final String value;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final VoidCallback onTap;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _LocationField({
    required this.active,
    required this.dotColor,
    required this.hint,
    required this.value,
    required this.controller,
    required this.focusNode,
    required this.onTap,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? AppColors.inputFill : AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: active ? null : onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          minHeight: 60,
          padding: const EdgeInsets.only(left: 15, right: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderSoft),
          ),
          child: Row(
            children: [
              Container(
                width: 11,
                height: 11,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: dotColor.withValues(alpha: 0.20),
                      blurRadius: 6,
                      spreadRadius: 3,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: active
                    ? TextField(
                        controller: controller,
                        focusNode: focusNode,
                        autofocus: true,
                        textInputAction: TextInputAction.search,
                        onChanged: onChanged,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                        decoration: InputDecoration(
                          hintText: value.trim().isNotEmpty ? value : hint,
                          hintStyle: TextStyle(
                            color: value.trim().isNotEmpty
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                            fontWeight: value.trim().isNotEmpty
                                ? FontWeight.w700
                                : FontWeight.w600,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      )
                    : Text(
                        value.trim().isNotEmpty ? value : hint,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: value.trim().isNotEmpty
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                          fontSize: 17,
                          fontWeight: value.trim().isNotEmpty
                              ? FontWeight.w700
                              : FontWeight.w600,
                        ),
                      ),
              ),
              if (active && (controller?.text.isNotEmpty ?? false))
                IconButton(
                  tooltip: 'Limpiar búsqueda',
                  onPressed: onClear,
                  icon: const Icon(
                    Icons.cancel_rounded,
                    color: AppColors.textSecondary,
                    size: 21,
                  ),
                )
              else
                const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundBackButton extends StatelessWidget {
  final VoidCallback onTap;

  const _RoundBackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: const CircleBorder(),
      elevation: 2,
      shadowColor: AppColors.shadow,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: const SizedBox(
          width: 48,
          height: 48,
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
            size: 21,
          ),
        ),
      ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _ResultTile({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      leading: Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(
          color: AppColors.inputFill,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.location_on_rounded,
          color: AppColors.textSecondary,
        ),
      ),
      title: Text(
        title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      leading: Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(
          color: AppColors.inputFill,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.textSecondary),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w800,
        ),
      ),
      subtitle: Text(
        subtitle,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
        ),
      ),
    );
  }
}

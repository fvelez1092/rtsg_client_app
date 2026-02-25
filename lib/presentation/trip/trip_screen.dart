import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:app_manporcar_client/presentation/widgets/map_widget.dart';
import 'package:app_manporcar_client/core/theme/light_theme.dart';
import 'package:app_manporcar_client/application/controllers/trip_booking_controller.dart';
import 'package:app_manporcar_client/presentation/pages/trip/components/options_trip_card.dart';
import 'package:app_manporcar_client/presentation/utils/utils.dart';

class TripScreen extends GetView<TripBookingController> {
  const TripScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // MAPA ---------------------------------------------------------------
          Expanded(
            flex: 6,
            child: Stack(
              children: [
                Obx(
                  () => MapPicker(
                    initialCenter: controller.mapCenter.value,
                    initialZoom: 15,
                    userAgentPackageName: 'com.manporcar.www',
                    onChanged: (center, zoom, {required isFinal}) {
                      FocusManager.instance.primaryFocus?.unfocus();
                      controller.clearSearchSuggestions();
                      controller.handleMapChange(
                        center,
                        zoom,
                        isFinal: isFinal,
                      );
                    },
                  ),
                ),

                // pill fase ----------------------------------------------------
                Positioned(
                  left: 12,
                  top: 24,
                  child: Row(
                    children: [
                      _roundBtn(
                        icon: Icons.arrow_back,
                        onTap: () => Get.key.currentState?.pop(),
                      ),
                      const SizedBox(width: 12),
                      Obx(() {
                        final phase = controller.phase.value;
                        final label = switch (phase) {
                          TripPhase.pickingOrigin => 'ORIGEN',
                          TripPhase.pickingDestination => 'DESTINO',
                          TripPhase.done => 'Viaje listo',
                        };
                        final point = switch (phase) {
                          TripPhase.pickingOrigin => controller.origin.value,
                          TripPhase.pickingDestination =>
                            controller.destination.value ??
                                controller.origin.value,
                          TripPhase.done =>
                            controller.destination.value ??
                                controller.origin.value,
                        };
                        return Align(
                          alignment: Alignment.topLeft,
                          child: _GlassPill(
                            child: Text(
                              point == null
                                  ? label
                                  : '$label · ${point.latitude.toStringAsFixed(6)}, ${point.longitude.toStringAsFixed(6)}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),

                // costo --------------------------------------------------------
                Positioned(
                  right: 12,
                  top: 24,
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      width: 80,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: ColorsApp.purple, width: 2),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.price_change,
                            size: 25,
                            color: Color(0xFF3E2C6D),
                          ),
                          const SizedBox(height: 8),
                          Obx(
                            () => Text(
                              controller.selectedCost.value != null
                                  ? controller.selectedCost.value!.baseFare
                                        .toString()
                                  : 'N/A',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
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
          ),

          // BOTTOM SHEET -------------------------------------------------------
          Container(
            height: mq.size.height * 0.4,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Color(0x22000000),
                  blurRadius: 12,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _BottomSheetHandle(),
                    const SizedBox(height: 10),

                    // OPCIONES ------------------------------------------------
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Wrap(
                        spacing: 3,
                        children: [
                          Obx(
                            () => OptionCard(
                              icon: Icons.explicit_outlined,
                              title:
                                  controller.selectedCategory.value?.name ??
                                  'Seleccionar Categoria',
                              onTap: controller.openCategoriesSheet,
                            ),
                          ),
                          Obx(
                            () => OptionCard(
                              icon: Icons.route,
                              title: controller.selectedRoute.value != null
                                  ? '${controller.selectedRoute.value!.originCity} - ${controller.selectedRoute.value!.destinationCity}'
                                  : 'Seleccionar ruta',
                              onTap: controller.openRoutesSheet,
                            ),
                          ),
                          Obx(
                            () => OptionCard(
                              icon: Icons.person_2,
                              title: controller.passengerCount.value.toString(),
                              onTap: () {
                                final cat = controller.selectedCategory.value;
                                if (cat == null) {
                                  Utils.showError(
                                    'Selecciona una categoría primero.',
                                  );
                                  return;
                                }
                                if (cat.idTravelCategory == 4) {
                                  controller.openPassengerSheet();
                                }
                              },
                            ),
                          ),
                          Obx(
                            () => OptionCard(
                              icon: Icons.schedule,
                              title: controller.formattedRequestedDate,
                              onTap: () {
                                final cat = controller.selectedCategory.value;
                                if (cat == null) {
                                  Utils.showError(
                                    'Selecciona una categoría primero.',
                                  );
                                  return;
                                }
                                if (cat.idTravelCategory == 4) {
                                  controller.openDateTimePicker();
                                } else {
                                  controller.openDateTimePickerCustom();
                                }
                              },
                            ),
                          ),
                          OptionCard(
                            icon: Icons.luggage_outlined,
                            title: "Equipaje",
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // ORIGEN ---------------------------------------------------
                    Obx(
                      () => _PillField(
                        focusNode: controller.originFocusNode,
                        onFocusChanged: (hasFocus) {
                          if (hasFocus) controller.startPickingOrigin();
                        },
                        suggestions: controller.originSuggestions
                            .map((e) => e['display_name']?.toString() ?? '')
                            .where((name) => name.isNotEmpty)
                            .toList(),
                        onFieldTap: () {
                          controller.startPickingOrigin();
                          controller.destinationFocusNode.unfocus();
                          controller.originFocusNode.requestFocus();
                        },
                        onQueryChanged: controller.onOriginSearchChanged,
                        onSuggestionSelected:
                            controller.onOriginSuggestionSelected,
                        label: 'Origen',
                        controller: controller.originTextController,
                        color: ColorsApp.purple,
                        iconColor: ColorsApp.purple,
                        onPick: () {
                          controller.startPickingOrigin();
                          FocusManager.instance.primaryFocus?.unfocus();
                          controller.clearSearchSuggestions();
                        },
                        showClear:
                            controller.origin.value != null ||
                            controller.originTextController.text
                                .trim()
                                .isNotEmpty,
                        onClear: controller.clearOrigin,
                        pinIcon: Icons.my_location,
                      ),
                    ),

                    // REFERENCIA ORIGEN --------------------------------------
                    Obx(() {
                      if (!controller.canAddOriginReference) {
                        return const SizedBox.shrink();
                      }
                      final hasRef = controller.originReference.value
                          .trim()
                          .isNotEmpty;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 6),
                          TextButton.icon(
                            onPressed: () => controller.openReferenceEditor(
                              TripPhase.pickingOrigin,
                            ),
                            icon: const Icon(Icons.edit_location_alt, size: 18),
                            label: Text(
                              hasRef
                                  ? 'Editar referencia de origen'
                                  : 'Agregar referencia de origen',
                            ),
                          ),
                          if (hasRef)
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 12,
                                bottom: 4,
                              ),
                              child: Text(
                                controller.originReference.value,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                        ],
                      );
                    }),

                    const SizedBox(height: 8),

                    // DESTINO --------------------------------------------------
                    Obx(
                      () => _PillField(
                        focusNode: controller.destinationFocusNode,
                        onFocusChanged: (hasFocus) {
                          if (hasFocus) controller.startPickingDestination();
                        },
                        suggestions: controller.destinationSuggestions
                            .map((e) => e['display_name']?.toString() ?? '')
                            .where((name) => name.isNotEmpty)
                            .toList(),
                        onFieldTap: () {
                          controller.startPickingDestination();
                          controller.originFocusNode.unfocus();
                          controller.destinationFocusNode.requestFocus();
                        },
                        onQueryChanged: controller.onDestinationSearchChanged,
                        onSuggestionSelected:
                            controller.onDestinationSuggestionSelected,
                        label: 'Destino',
                        controller: controller.destinationTextController,
                        color: ColorsApp.orange,
                        iconColor: ColorsApp.orange,
                        onPick: () {
                          controller.startPickingDestination();
                          FocusManager.instance.primaryFocus?.unfocus();
                          controller.clearSearchSuggestions();
                        },
                        showClear:
                            controller.destination.value != null ||
                            controller.destinationTextController.text
                                .trim()
                                .isNotEmpty,
                        onClear: controller.clearDestination,
                        pinIcon: Icons.add_location_alt_outlined,
                      ),
                    ),

                    // REFERENCIA DESTINO -------------------------------------
                    Obx(() {
                      if (!controller.canAddDestinationReference) {
                        return const SizedBox.shrink();
                      }
                      final hasRef = controller.destinationReference.value
                          .trim()
                          .isNotEmpty;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 6),
                          TextButton.icon(
                            onPressed: () => controller.openReferenceEditor(
                              TripPhase.pickingDestination,
                            ),
                            icon: const Icon(Icons.edit_location_alt, size: 18),
                            label: Text(
                              hasRef
                                  ? 'Editar referencia de destino'
                                  : 'Agregar referencia de destino',
                            ),
                          ),
                          if (hasRef)
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 12,
                                bottom: 4,
                              ),
                              child: Text(
                                controller.destinationReference.value,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                        ],
                      );
                    }),

                    const SizedBox(height: 10),

                    // BOTÓN CREAR VIAJE / FRECUENTES -------------------------
                    Obx(() {
                      final phase = controller.phase.value;

                      if (phase == TripPhase.done && controller.isTripReady) {
                        return SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: controller.createTrip,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Crear viaje',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        );
                      }

                      final addresses = controller.memory.addresses;
                      if (addresses.isEmpty) return const SizedBox.shrink();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Destinos frecuentes',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 6),
                          ...addresses.map((address) {
                            final title = address.label.trim();
                            final subtitle = address.reference?.trim();
                            if (title.isEmpty) return const SizedBox.shrink();

                            return _FrequentItem(
                              icon: Icons.location_on,
                              color: Colors.blue,
                              title: title,
                              subtitle: subtitle ?? '',
                              onTap: () => controller.useSavedAddress(address),
                            );
                          }),
                        ],
                      );
                    }),
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

class _GlassPill extends StatelessWidget {
  final Widget child;
  const _GlassPill({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(999),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: DefaultTextStyle(
        style: const TextStyle(color: Colors.white),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.pin_drop, size: 16, color: Colors.white),
            const SizedBox(width: 6),
            child,
          ],
        ),
      ),
    );
  }
}

class _BottomSheetHandle extends StatelessWidget {
  const _BottomSheetHandle();

  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      width: 42,
      height: 5,
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(999),
      ),
    ),
  );
}

class _PillField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final Color color;
  final Color iconColor;
  final VoidCallback onPick;
  final bool showClear;
  final VoidCallback? onClear;
  final IconData pinIcon;
  final List<String> suggestions;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<String> onSuggestionSelected;
  final VoidCallback? onFieldTap;

  final FocusNode focusNode;
  final ValueChanged<bool>? onFocusChanged;

  const _PillField({
    this.onFieldTap,
    required this.label,
    required this.controller,
    required this.color,
    required this.iconColor,
    required this.onPick,
    required this.showClear,
    required this.onClear,
    required this.pinIcon,
    required this.suggestions,
    required this.onQueryChanged,
    required this.onSuggestionSelected,
    required this.focusNode,
    this.onFocusChanged,
  });

  @override
  State<_PillField> createState() => _PillFieldState();
}

class _PillFieldState extends State<_PillField> {
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();

    widget.focusNode.addListener(() {
      final nowFocused = widget.focusNode.hasFocus;
      if (nowFocused == _hasFocus) return;

      setState(() => _hasFocus = nowFocused);
      widget.onFocusChanged?.call(nowFocused);

      if (!nowFocused) {
        FocusScope.of(context).unfocus();
        widget.onQueryChanged(''); // limpia sugerencias al perder foco
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const constraints = BoxConstraints(minWidth: 32, minHeight: 32);
    const padding = EdgeInsets.all(0.0);

    final showSuggestions = _hasFocus && widget.suggestions.isNotEmpty;

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.18),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
            border: Border.all(
              color: widget.color.withValues(alpha: 0.75),
              width: 1,
            ),
            color: Colors.white,
          ),
          child: TextField(
            onTap: widget.onFieldTap,
            controller: widget.controller,
            focusNode: widget.focusNode,
            onChanged: widget.onQueryChanged,
            maxLines: 1,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              isDense: true,
              labelText: widget.label,
              labelStyle: TextStyle(
                fontSize: 11,
                color: widget.iconColor,
                fontWeight: FontWeight.w600,
              ),
              hintText: 'Buscar lugar o toque el pin',
              hintStyle: const TextStyle(fontSize: 12),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Colors.transparent,
                  width: 0,
                ),
                borderRadius: BorderRadius.circular(999),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: widget.color, width: 1.2),
                borderRadius: BorderRadius.circular(999),
              ),
              prefixIcon: Icon(Icons.place, size: 18, color: widget.iconColor),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.showClear)
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      color: widget.iconColor,
                      tooltip: 'Borrar',
                      onPressed: widget.onClear,
                      constraints: constraints,
                      padding: padding,
                    ),
                  IconButton(
                    icon: Icon(widget.pinIcon, size: 18),
                    color: widget.iconColor,
                    tooltip: 'Seleccionar en el mapa',
                    onPressed: widget.onPick,
                    constraints: constraints,
                    padding: padding,
                  ),
                  const SizedBox(width: 6),
                ],
              ),
            ),
          ),
        ),

        if (showSuggestions)
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 180),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x22000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.suggestions.length,
                itemBuilder: (context, index) {
                  final place = widget.suggestions[index];
                  return ListTile(
                    title: Text(
                      place,
                      style: TextStyle(color: ColorsApp.purple),
                    ),
                    onTap: () {
                      widget.controller.text = place;
                      widget.onSuggestionSelected(place);
                      FocusScope.of(context).unfocus();
                      widget.onQueryChanged('');
                    },
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}

Widget _roundBtn({required IconData icon, required VoidCallback onTap}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(999),
    child: Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: ColorsApp.cyanPurple.withValues(alpha: 0.7),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white),
    ),
  );
}

class _FrequentItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _FrequentItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) => ListTile(
    leading: CircleAvatar(
      backgroundColor: color.withValues(alpha: 0.08),
      child: Icon(icon, color: color),
    ),
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
    subtitle: Text(subtitle),
    onTap: onTap,
  );
}

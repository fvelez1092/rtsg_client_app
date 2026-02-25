import 'package:app_manporcar_client/core/theme/light_theme.dart';
import 'package:app_manporcar_client/data/models/trips/trip_category_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CategoryPickerSheet extends StatelessWidget {
  const CategoryPickerSheet({
    super.key,
    required this.categories,
    required this.onSelect,
    this.initiallySelectedId,
  });

  final List<TripCategory> categories;
  final void Function(TripCategory) onSelect;
  final int? initiallySelectedId;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle superior
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Selecciona una categoría',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),

            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: categories.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final c = categories[i];
                  final selected = c.idTravelCategory == initiallySelectedId;

                  return ListTile(
                    leading: const Icon(
                      Icons.explicit_rounded,
                      color: ColorsApp.orange,
                    ),
                    title: Text(
                      c.name ?? "",
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: ColorsApp.cyanPurple,
                      ),
                    ),
                    subtitle: (c.description?.isNotEmpty ?? false)
                        ? Text(
                            c.description!,
                            style: const TextStyle(color: ColorsApp.cyanPurple),
                          )
                        : null,
                    trailing: Icon(
                      selected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: selected ? ColorsApp.orange : ColorsApp.cyanPurple,
                    ),
                    onTap: () {
                      onSelect(c);
                      Get.back(closeOverlays: false);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

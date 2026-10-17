import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app_rtsg_client/data/services/gps_service.dart';

class LocationAccessCard extends StatelessWidget {
  final GpsService gps;
  const LocationAccessCard({super.key, required this.gps});

  @override
  Widget build(BuildContext context) => Obx(() {
    if (gps.hasUsableLocation) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final loading = gps.isLoading.value;
    final access = gps.access.value;
    final title = loading
        ? 'Buscando tu ubicación…'
        : switch (access) {
            LocationAccess.serviceDisabled => 'El GPS está desactivado',
            LocationAccess.denied => 'Falta permiso de ubicación',
            LocationAccess.deniedForever => 'Permiso de ubicación bloqueado',
            LocationAccess.unavailable => 'No se detectó tu ubicación',
            LocationAccess.unknown => 'Activa tu ubicación',
            LocationAccess.available => 'Buscando tu ubicación…',
          };
    final message = loading
        ? 'Estamos intentando detectar tu posición para mostrar partners y recomendaciones cercanas.'
        : gps.error.value.isNotEmpty
        ? gps.error.value
        : 'Comparte tu ubicación para ver partners y recomendaciones cercanas.';
    final needsSettings =
        access == LocationAccess.deniedForever ||
        access == LocationAccess.serviceDisabled;
    final actionLabel = switch (access) {
      LocationAccess.denied => 'Permitir ubicación',
      LocationAccess.deniedForever => 'Abrir ajustes',
      LocationAccess.serviceDisabled => 'Activar GPS',
      LocationAccess.unavailable => 'Reintentar',
      LocationAccess.unknown => 'Activar ubicación',
      LocationAccess.available => 'Reintentar',
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: colors.primary.withValues(alpha: .18)),
          boxShadow: [
            BoxShadow(
              color: colors.shadow.withValues(alpha: .06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: .11),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Center(
                    child: loading
                        ? SizedBox(
                            width: 19,
                            height: 19,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colors.primary,
                            ),
                          )
                        : Icon(
                            Icons.location_off_outlined,
                            color: colors.primary,
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        message,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: loading
                  ? null
                  : () async {
                      if (needsSettings) {
                        final opened = await gps.openLocationConfiguration();
                        if (!opened) {
                          Get.snackbar(
                            'Ubicación',
                            'No pudimos abrir los ajustes del teléfono.',
                          );
                        }
                      } else {
                        await gps.getCurrentLocation();
                      }
                    },
              icon: Icon(
                needsSettings
                    ? Icons.settings_outlined
                    : Icons.my_location_rounded,
                size: 18,
              ),
              label: Text(loading ? 'Buscando…' : actionLabel),
            ),
            if (loading || access == LocationAccess.denied) ...[
              const SizedBox(height: 2),
              TextButton.icon(
                onPressed: () async {
                  final opened = await gps.openLocationConfiguration();
                  if (!opened) {
                    Get.snackbar(
                      'Ubicación',
                      'No pudimos abrir los ajustes del teléfono.',
                    );
                  }
                },
                icon: const Icon(Icons.settings_outlined, size: 17),
                label: const Text('Abrir ajustes'),
              ),
            ],
          ],
        ),
      ),
    );
  });
}

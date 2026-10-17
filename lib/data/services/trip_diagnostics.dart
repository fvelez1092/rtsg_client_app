import 'dart:convert';
import 'package:flutter/foundation.dart';

/// Diagnóstico de carreras solo en desarrollo. Nunca registra el JWT.
void logTripEvent(String event, dynamic payload, {String? activeTripId}) {
  if (!kDebugMode) return;
  final entry = {
    'evento': event,
    'carrera_activa': activeTripId,
    'hora': DateTime.now().toIso8601String(),
    'datos': _safePayload(payload),
  };
  final json = const JsonEncoder.withIndent('  ').convert(entry);
  debugPrint('[RTSG][CARRERA] INICIO $event');
  for (final line in json.split('\n')) {
    debugPrint('[RTSG][CARRERA] $line');
  }
  debugPrint('[RTSG][CARRERA] FIN $event');
}

dynamic _safePayload(dynamic value) {
  if (value is String) {
    try {
      final decoded = jsonDecode(value);
      return decoded is Map || decoded is List ? _safePayload(decoded) : value;
    } catch (_) {
      return value;
    }
  }
  if (value is Map) {
    return value.map((key, item) {
      final name = key.toString();
      final normalized = name.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
      final sensitive =
          normalized.contains('token') ||
          normalized.contains('password') ||
          normalized.contains('secret') ||
          normalized == 'authorization' ||
          normalized == 'clave';
      return MapEntry(name, sensitive ? '[OCULTO]' : _safePayload(item));
    });
  }
  if (value is List) return value.map(_safePayload).toList();
  if (value == null || value is num || value is bool) return value;
  return '<${value.runtimeType}>';
}

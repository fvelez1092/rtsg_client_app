class TariffConfiguration {
  const TariffConfiguration({
    required this.companyId,
    required this.currency,
    required this.isDefault,
    required this.updatedAt,
    required this.dayStartMinute,
    required this.nightStartMinute,
    required this.dayStartFare,
    required this.nightStartFare,
    required this.dayCostPerKm,
    required this.nightCostPerKm,
    required this.dayMinimumFare,
    required this.nightMinimumFare,
    required this.minimumDistanceKm,
    required this.waitCostPerMinute,
  });

  final int companyId;
  final String currency;
  final bool isDefault;
  final DateTime? updatedAt;
  final int dayStartMinute, nightStartMinute;
  final double dayStartFare, nightStartFare, dayCostPerKm, nightCostPerKm;
  final double dayMinimumFare,
      nightMinimumFare,
      minimumDistanceKm,
      waitCostPerMinute;

  factory TariffConfiguration.fromJson(Map<String, dynamic> json) {
    double number(String key) {
      final raw = json[key];
      final value = raw is num ? raw.toDouble() : double.tryParse('$raw');
      if (value == null || !value.isFinite || value < 0) {
        throw FormatException('Tarifa inválida: $key');
      }
      return value;
    }

    int time(String key) {
      final match = RegExp(r'^(\d{2}):(\d{2})$').firstMatch('${json[key]}');
      if (match == null) throw FormatException('Horario inválido: $key');
      final hour = int.parse(match[1]!), minute = int.parse(match[2]!);
      if (hour > 23 || minute > 59) {
        throw FormatException('Horario inválido: $key');
      }
      return hour * 60 + minute;
    }

    final company = int.tryParse('${json['company_id']}');
    final currency = '${json['moneda'] ?? ''}'.trim();
    final day = time('hora_inicio_diurno'),
        night = time('hora_inicio_nocturno');
    if (company == null ||
        company <= 0 ||
        !RegExp(r'^[A-Z]{3}$').hasMatch(currency) ||
        day == night) {
      throw const FormatException('Configuración de tarifas inválida');
    }
    return TariffConfiguration(
      companyId: company,
      currency: currency,
      isDefault: json['configuracion_predeterminada'] == true,
      updatedAt: DateTime.tryParse('${json['actualizado_en']}'),
      dayStartMinute: day,
      nightStartMinute: night,
      dayStartFare: number('arranque_diurno'),
      nightStartFare: number('arranque_nocturno'),
      dayCostPerKm: number('costo_km_diurno'),
      nightCostPerKm: number('costo_km_nocturno'),
      dayMinimumFare: number('carrera_minima_diurna'),
      nightMinimumFare: number('carrera_minima_nocturna'),
      minimumDistanceKm: number('distancia_minima_km'),
      waitCostPerMinute: number('costo_minuto_espera'),
    );
  }

  /// The minimum includes the start fare and the first minimumDistanceKm.
  /// Travel duration is not waiting time and must not be charged as such.
  double estimate({
    required double distanceKm,
    required DateTime at,
    double waitingMinutes = 0,
  }) {
    if (!distanceKm.isFinite ||
        distanceKm < 0 ||
        !waitingMinutes.isFinite ||
        waitingMinutes < 0) {
      throw ArgumentError('Distancia o espera inválida');
    }
    final night = isNightAt(at);
    final minimum = night ? nightMinimumFare : dayMinimumFare;
    final perKm = night ? nightCostPerKm : dayCostPerKm;
    final extraKm = distanceKm > minimumDistanceKm
        ? distanceKm - minimumDistanceKm
        : 0.0;
    final amount =
        minimum + extraKm * perKm + waitingMinutes * waitCostPerMinute;
    return (amount * 100).roundToDouble() / 100;
  }

  // The API currently supplies company schedules for Ecuador (UTC-5).
  bool isNightAt(DateTime instant) {
    final local = instant.toUtc().subtract(const Duration(hours: 5));
    final minute = local.hour * 60 + local.minute;
    final isDay = dayStartMinute < nightStartMinute
        ? minute >= dayStartMinute && minute < nightStartMinute
        : minute >= dayStartMinute || minute < nightStartMinute;
    return !isDay;
  }
}

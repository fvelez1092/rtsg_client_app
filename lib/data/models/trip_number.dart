/// Acepta números y decimales del API sin convertir datos ausentes en cero.
double? tripNumber(dynamic value) {
  final number = value is num
      ? value.toDouble()
      : double.tryParse(value?.toString().trim().replaceAll(',', '.') ?? '');
  return number != null && number.isFinite && number >= 0 ? number : null;
}

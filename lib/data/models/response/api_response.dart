class ApiResponse<T> {
  final bool ok;
  final int status;
  final String message;
  final T data;

  ApiResponse({
    required this.ok,
    required this.status,
    required this.message,
    required this.data,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic raw) convert,
  ) {
    final successRaw = json.containsKey('estado') ? json['estado'] : json['ok'];
    final ok = _asBool(successRaw);

    return ApiResponse<T>(
      ok: ok,
      status: _asInt(json['status'], fallback: ok ? 200 : 400),
      message: (json['observacion'] ?? json['message'] ?? '').toString(),
      data: convert(json.containsKey('datos') ? json['datos'] : json['data']),
    );
  }

  static bool _asBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    final normalized = value?.toString().trim().toLowerCase();
    return normalized == 'true' || normalized == '1';
  }

  static int _asInt(dynamic value, {required int fallback}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }
}

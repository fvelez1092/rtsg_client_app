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
    return ApiResponse<T>(
      ok: json['ok'] as bool,
      status: json['status'] as int,
      message: (json['message'] ?? '') as String,
      data: convert(json['data']),
    );
  }
}

import 'package:app_rtsg_client/data/services/local_storage_service.dart';
import 'package:app_rtsg_client/routes/rtsg_routes.dart';

import 'package:dio/dio.dart';
import 'package:get/get.dart';

class ApiInterceptor extends Interceptor {
  final _storage = LocalStorage();

  static const List<String> _publicPaths = ['/acceder'];

  bool _isPublic(RequestOptions options) {
    final p = options.path.toLowerCase();
    return _publicPaths.any((pub) => p.startsWith(pub));
  }

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    options.headers['Accept'] ??= 'application/json';

    options.headers['Content-Type'] ??= 'application/json';

    if (_isPublic(options)) {
      return handler.next(options);
    }

    final token = await _storage.getToken();
    if (token == null || token.isEmpty) {
      Get.offAllNamed(AppRoutes.LOGIN);
      return handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.cancel,
          error: 'Token ausente',
        ),
      );
    }

    //options.headers['Authorization'] = 'Bearer $token';
    options.headers['x-access-token'] = token;
    handler.next(options);
  }

  bool _isDeviceRegistration(RequestOptions options) {
    return options.path.toLowerCase().contains('/register/device');
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // FCM es opcional: un rechazo en este endpoint no debe cerrar la sesión
    // que ya fue validada con /user.by.token.
    if (err.response?.statusCode == 401 &&
        !_isDeviceRegistration(err.requestOptions)) {
      LocalStorage().clearData();
      Get.offAllNamed(AppRoutes.LOGIN);
    }
    handler.next(err);
  }
}

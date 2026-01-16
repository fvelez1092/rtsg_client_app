import 'package:app_rtsg_client/core/constants/api_constants.dart';
import 'package:app_rtsg_client/data/network/api_interceptor.dart';
import 'package:dio/dio.dart';

class ApiClient {
  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        // Concatenamos base + versión UNA sola vez
        baseUrl: '${ApiConstants.baseUrl}${ApiConstants.versionAPI}',
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
      ),
    );
    _dio.interceptors.add(ApiInterceptor());

    // Útil en desarrollo (comenta en producción):
    // _dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
  }

  static final ApiClient _instance = ApiClient._internal();
  static Dio get dio => _instance._dio;

  late final Dio _dio;
}

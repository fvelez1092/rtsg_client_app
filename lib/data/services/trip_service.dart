import 'package:app_rtsg_client/data/models/request/trip_request.dart';
import 'package:app_rtsg_client/data/models/response/api_response.dart';
import 'package:app_rtsg_client/data/models/trips/trip_category_model.dart';
import 'package:app_rtsg_client/data/models/trips/trip_cost_model.dart';
import 'package:app_rtsg_client/data/models/trips/trip_model.dart';
import 'package:app_rtsg_client/data/models/trips/trip_route_model.dart';
import 'package:app_rtsg_client/data/network/dio_client.dart';
import 'package:dio/dio.dart';

class TripService {
  final Dio _dio = ApiClient.dio;

  /// POST /transport/request
  /// Crea un viaje y devuelve el Trip creado (tomando el primer item de data).
  Future<Trip> createTrip(TripRequest input) async {
    try {
      final res = await _dio.post('/transport/request', data: input.toJson());

      if (res.data is! Map<String, dynamic>) {
        throw DioException(
          requestOptions: res.requestOptions,
          response: res,
          type: DioExceptionType.badResponse,
          error: 'Respuesta no válida del servidor',
        );
      }

      final map = res.data as Map<String, dynamic>;

      // La API devuelve { ok, status, message, data: [ {...} ] }
      final api = ApiResponse<List<Trip>>.fromJson(map, (raw) {
        final list = (raw as List).cast<Map<String, dynamic>>();
        return list.map(Trip.fromJson).toList();
      });

      if (!api.ok || api.data.isEmpty) {
        throw DioException(
          requestOptions: res.requestOptions,
          response: res,
          type: DioExceptionType.badResponse,
          error: api.message.isNotEmpty
              ? api.message
              : 'No se pudo crear el viaje',
        );
      }

      return api.data.first;
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception('Error al crear el viaje: $e');
    }
  }

  /// Obtiene los viajes del usuario autenticado.
  /// Endpoint: GET /transport/request/user
  Future<List<Trip>> getUserTrips() async {
    try {
      final res = await _dio.get('/transport/request/user');

      // Esperamos { ok, status, message, data: [ ... ] }
      if (res.data is! Map<String, dynamic>) {
        throw DioException(
          requestOptions: res.requestOptions,
          response: res,
          type: DioExceptionType.badResponse,
          error: 'Respuesta no válida del servidor',
        );
      }

      final map = res.data as Map<String, dynamic>;

      final api = ApiResponse<List<Trip>>.fromJson(map, (raw) {
        final list = (raw as List).cast<Map<String, dynamic>>();
        return list.map(Trip.fromJson).toList();
      });

      if (!api.ok) {
        // El backend dice ok=false; lanzar con el message
        throw DioException(
          requestOptions: res.requestOptions,
          response: res,
          type: DioExceptionType.badResponse,
          error: api.message,
        );
      }

      return api.data;
    } on DioException catch (e) {
      // Puedes mapear códigos específicos aquí si deseas
      rethrow;
    } catch (e) {
      // Errores no-Dio
      throw Exception('Error al obtener viajes: $e');
    }
  }

  /// GET /transport/cost  → Costos por ruta/categoría
  Future<List<TripCost>> getCompanyCosts() async {
    try {
      final res = await _dio.get('/transport/cost');

      if (res.data is! Map<String, dynamic>) {
        throw DioException(
          requestOptions: res.requestOptions,
          response: res,
          type: DioExceptionType.badResponse,
          error: 'Respuesta no válida del servidor',
        );
      }

      final map = res.data as Map<String, dynamic>;

      final api = ApiResponse<List<TripCost>>.fromJson(map, (raw) {
        final list = (raw as List).cast<Map<String, dynamic>>();
        return list.map(TripCost.fromJson).toList();
      });

      if (!api.ok) {
        throw DioException(
          requestOptions: res.requestOptions,
          response: res,
          type: DioExceptionType.badResponse,
          error: api.message,
        );
      }
      return api.data;
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception('Error al obtener costos: $e');
    }
  }

  /// GET /transport/route → Rutas preestablecidas
  Future<List<TripRoute>> getPresetRoutes() async {
    try {
      final res = await _dio.get('/transport/route');

      if (res.data is! Map<String, dynamic>) {
        throw DioException(
          requestOptions: res.requestOptions,
          response: res,
          type: DioExceptionType.badResponse,
          error: 'Respuesta no válida del servidor',
        );
      }

      final map = res.data as Map<String, dynamic>;

      final api = ApiResponse<List<TripRoute>>.fromJson(map, (raw) {
        final list = (raw as List).cast<Map<String, dynamic>>();
        return list.map(TripRoute.fromJson).toList();
      });

      if (!api.ok) {
        throw DioException(
          requestOptions: res.requestOptions,
          response: res,
          type: DioExceptionType.badResponse,
          error: api.message,
        );
      }
      return api.data;
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception('Error al obtener rutas: $e');
    }
  }

  /// GET /transport/category → Categorias de los viajes
  Future<List<TripCategory>> getCategories() async {
    try {
      final res = await _dio.get('/transport/category');

      if (res.data is! Map<String, dynamic>) {
        throw DioException(
          requestOptions: res.requestOptions,
          response: res,
          type: DioExceptionType.badResponse,
          error: 'Respuesta no válida del servidor',
        );
      }

      final map = res.data as Map<String, dynamic>;

      final api = ApiResponse<List<TripCategory>>.fromJson(map, (raw) {
        final list = (raw as List).cast<Map<String, dynamic>>();
        return list.map(TripCategory.fromJson).toList();
      });

      if (!api.ok) {
        throw DioException(
          requestOptions: res.requestOptions,
          response: res,
          type: DioExceptionType.badResponse,
          error: api.message,
        );
      }
      return api.data;
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception('Error al obtener categorias: $e');
    }
  }
}

import 'dart:convert';

import 'package:app_rtsg_client/data/models/request/trip_request.dart';
import 'package:app_rtsg_client/data/models/response/api_response.dart';
import 'package:app_rtsg_client/data/models/trips/trip_model.dart';
import 'package:app_rtsg_client/data/network/dio_client.dart';
import 'package:dio/dio.dart';

class TripService {
  final Dio _dio = ApiClient.dio;

  Future<Trip> createTrip(TripRequest input, {String? audioPath}) async {
    try {
      // 1. Envolvemos el objeto entero en la llave 'data' y lo convertimos a String
      final Map<String, dynamic> mapData = {
        'data': jsonEncode({'data': input.toJson()}),
      };

      // 2. Condicionamos el audio
      if (audioPath != null && audioPath.isNotEmpty) {
        // Si hay ruta, enviamos el archivo
        mapData['audio'] = await MultipartFile.fromFile(
          audioPath,
          filename: audioPath.split('/').last,
        );
      } else {
        // Si NO hay ruta, forzamos el envío de la variable 'audio' para que el backend
        // detecte que llegó, pero vacía/nula.
        // (Dio enviará el texto "null", que el backend lee como nulo)
        mapData['audio'] = 'null';
      }

      // 3. Generamos el form data
      final formData = FormData.fromMap(mapData);

      final response = await _dio.post(
        '/crear.carrera',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      final body = _asMap(response.data, response.requestOptions);
      final api = ApiResponse<List<Trip>>.fromJson(body, _parseTrips);

      if (!api.ok || api.data.isEmpty) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
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

  /// Obtiene las carreras del usuario autenticado con la respuesta real del API.
  /// Soporta tanto {estado, observacion, datos} como el contrato legado
  /// {ok, status, message, data}.
  Future<List<Trip>> getUserTrips() async {
    try {
      final response = await _dio.get('/mostrar.carreras.cliente');
      final body = _asMap(response.data, response.requestOptions);

      final api = ApiResponse<List<Trip>>.fromJson(body, _parseTrips);

      if (!api.ok) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: api.message.isNotEmpty
              ? api.message
              : 'No se pudieron obtener los viajes',
        );
      }

      return api.data;
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception('Error al obtener viajes: $e');
    }
  }

  List<Trip> _parseTrips(dynamic raw) {
    if (raw == null) return const <Trip>[];

    if (raw is Map) {
      return [Trip.fromJson(Map<String, dynamic>.from(raw))];
    }

    if (raw is! List) return const <Trip>[];

    return raw
        .whereType<Map>()
        .map((item) => Trip.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Map<String, dynamic> _asMap(dynamic data, RequestOptions requestOptions) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);

    throw DioException(
      requestOptions: requestOptions,
      type: DioExceptionType.badResponse,
      error: 'Respuesta no válida del servidor',
    );
  }
}

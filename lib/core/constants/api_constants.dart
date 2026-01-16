abstract class ApiConstants {
  static const String baseUrl = 'https://api.manporcar26.com.ec/api/';
  static const String mapboxBaseUrl = 'api.mapbox.com';
  static const String mapboxGeocodingPath = '/geocoding/v5/mapbox.places';

  /// Idioma de la respuesta de direcciones
  static const String mapboxLanguage = 'es';

  /// Tipos priorizados (puedes ajustar según tu caso)
  static const String mapboxTypes = 'address,place,locality,neighborhood,poi';
  static const String mapboxAccessToken =
      "pk.eyJ1IjoiY2VpYm9jb2RldGVjaCIsImEiOiJjbWd3ZWZxcGowNmd1MmpwaTg2a2pmZjd2In0.SgfP15MbuYqeXASKr2NIDg";
  static const String versionAPI = "v1";
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
}

abstract class ApiConstants {
  //static const String baseUrl = 'https://api.manporcar26.com.ec/api/';
  //static const String baseUrl = 'http://192.168.100.29:3001/api/';
  static const String baseUrl = 'https://ztfd48x3-3001.use2.devtunnels.ms/api/';
  static const String mapboxBaseUrl = 'api.mapbox.com';
  static const String mapboxGeocodingPath = '/geocoding/v5/mapbox.places';

  /// Idioma de la respuesta de direcciones
  static const String mapboxLanguage = 'es';
  static const String mapboxDirectionsPath = '/directions/v5/mapbox';

  /// Tipos priorizados (puedes ajustar según tu caso)
  static const String mapboxTypes = 'address,place,locality,neighborhood,poi';
  static const String mapboxAccessToken =
      "sk.eyJ1IjoiY2FjaWN1c3RlY2giLCJhIjoiY210dWlzZ2oxMGM4MjJ4cHhvM2ppZXpyaSJ9.DGM2_q-eT0uuKerJxLGkPQ";

  static const String versionAPI = "v3";
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;

  //geoapify configuration
  static const String geoapifyBaseUrl = 'https://api.geoapify.com/v1/geocode';
  static const String geoapifyApiKey = '3f337e3394114460bb83443d5906ece8';
}

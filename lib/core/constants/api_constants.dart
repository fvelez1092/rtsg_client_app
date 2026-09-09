abstract class ApiConstants {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://apiv2.rtsg.ceibocode.com/api/',
  );

  static const String versionAPI = String.fromEnvironment(
    'API_VERSION',
    defaultValue: 'v3',
  );

  static const String mapboxBaseUrl = String.fromEnvironment(
    'MAPBOX_BASE_URL',
    defaultValue: 'api.mapbox.com',
  );

  static const String mapboxGeocodingPath = String.fromEnvironment(
    'MAPBOX_GEOCODING_PATH',
    defaultValue: '/geocoding/v5/mapbox.places',
  );

  static const String mapboxDirectionsPath = String.fromEnvironment(
    'MAPBOX_DIRECTIONS_PATH',
    defaultValue: '/directions/v5/mapbox',
  );

  static const String mapboxLanguage = String.fromEnvironment(
    'MAPBOX_LANGUAGE',
    defaultValue: 'es',
  );

  static const String mapboxTypes = String.fromEnvironment(
    'MAPBOX_TYPES',
    defaultValue: 'address,place,locality,neighborhood,poi',
  );

  static const String mapboxAccessToken = String.fromEnvironment(
    'MAPBOX_ACCESS_TOKEN',
  );

  static const int connectTimeout = int.fromEnvironment(
    'API_CONNECT_TIMEOUT_MS',
    defaultValue: 30000,
  );

  static const int receiveTimeout = int.fromEnvironment(
    'API_RECEIVE_TIMEOUT_MS',
    defaultValue: 30000,
  );
}

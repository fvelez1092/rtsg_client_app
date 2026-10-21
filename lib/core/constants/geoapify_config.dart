import 'package:app_rtsg_client/core/constants/api_constants.dart';

enum LocationProvider { mapbox, geoapify }

abstract class GeoapifyConfig {
  // Temporary provider selection for the current evaluation.
  static const activeProvider = LocationProvider.geoapify;
  static const apiKey = ApiConstants.geoapifyApiKey;
  static const geocodingUrl = ApiConstants.geoapifyBaseUrl;
  static const routingUrl = 'https://api.geoapify.com/v1/routing';
  static const language = 'es';
  static const timeout = Duration(seconds: 10);
}

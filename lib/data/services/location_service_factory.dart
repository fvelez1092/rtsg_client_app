import 'package:app_rtsg_client/core/constants/geoapify_config.dart';
import 'package:app_rtsg_client/data/services/geoapify_service.dart';
import 'package:app_rtsg_client/data/services/mapbox_service.dart';

MapboxGeocoder createLocationService() =>
    GeoapifyConfig.activeProvider == LocationProvider.geoapify
    ? GeoapifyGeocoder()
    : MapboxGeocoder();

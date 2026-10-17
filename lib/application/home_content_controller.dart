import 'package:app_rtsg_client/data/services/gps_service.dart';
import 'package:app_rtsg_client/data/models/partnert_model.dart';
import 'package:app_rtsg_client/data/services/partners_service.dart';
import 'package:app_rtsg_client/data/services/publicidad_service.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class HomeContentController extends GetxController {
  HomeContentController({
    required PartnersService partnersService,
    required PublicidadService publicidadService,
  }) : _partnersService = partnersService,
       _publicidadService = publicidadService;

  final PartnersService _partnersService;
  final PublicidadService _publicidadService;

  Worker? _locationWorker;
  GpsService get _gps => Get.find<GpsService>();

  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  final RxList<PartnerModel> partners = <PartnerModel>[].obs;
  final RxList<PartnerAdModel> publicidades = <PartnerAdModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _locationWorker = everAll([_gps.access, _gps.currentPosition], (_) {
      if (_gps.hasUsableLocation) {
        loadContent();
      } else {
        partners.clear();
        publicidades.clear();
      }
    });
    loadContent();
  }

  Future<void> loadContent() async {
    if (!_gps.hasUsableLocation) {
      if (kDebugMode) {
        debugPrint(
          '[RTSG][HOME][CONTENT] consulta omitida: '
          'ubicación=${_gps.access.value} error=${_gps.error.value}',
        );
      }
      return;
    }
    if (isLoading.value) {
      if (kDebugMode) {
        debugPrint('[RTSG][HOME][CONTENT] consulta omitida: ya está cargando');
      }
      return;
    }
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';
      if (kDebugMode) {
        final position = _gps.currentPosition.value!;
        debugPrint(
          '[RTSG][HOME][CONTENT] consultando /partners y /publicidades '
          'lat=${position.latitude} lng=${position.longitude}',
        );
      }

      final results = await Future.wait([
        _partnersService.getPartners(),
        _publicidadService.getPublicidades(),
      ]);

      if (isClosed || !_gps.hasUsableLocation) return;
      partners.assignAll(results[0] as List<PartnerModel>);
      publicidades.assignAll(results[1] as List<PartnerAdModel>);
      if (kDebugMode) {
        debugPrint(
          '[RTSG][HOME][CONTENT] respuesta correcta '
          'partners=${partners.length} publicidades=${publicidades.length}',
        );
      }
    } catch (e, stackTrace) {
      hasError.value = true;
      errorMessage.value = e.toString();
      if (kDebugMode) {
        debugPrint('[RTSG][HOME][CONTENT] error consultando contenido: $e');
        debugPrintStack(stackTrace: stackTrace);
      }
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    _locationWorker?.dispose();
    super.onClose();
  }
}

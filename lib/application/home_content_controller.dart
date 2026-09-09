import 'package:app_rtsg_client/data/models/partnert_model.dart';
import 'package:app_rtsg_client/data/services/partners_service.dart';
import 'package:app_rtsg_client/data/services/publicidad_service.dart';
import 'package:get/get.dart';

class HomeContentController extends GetxController {
  HomeContentController({
    required PartnersService partnersService,
    required PublicidadService publicidadService,
  })  : _partnersService = partnersService,
        _publicidadService = publicidadService;

  final PartnersService _partnersService;
  final PublicidadService _publicidadService;

  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  final RxList<PartnerModel> partners = <PartnerModel>[].obs;
  final RxList<PartnerAdModel> publicidades = <PartnerAdModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadContent();
  }

  Future<void> loadContent() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final results = await Future.wait([
        _partnersService.getPartners(),
        _publicidadService.getPublicidades(),
      ]);

      partners.assignAll(results[0] as List<PartnerModel>);
      publicidades.assignAll(results[1] as List<PartnerAdModel>);
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}

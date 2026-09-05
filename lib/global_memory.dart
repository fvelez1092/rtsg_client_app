import 'package:app_rtsg_client/data/models/user_model.dart';
import 'package:app_rtsg_client/data/services/local_storage_service.dart';
import 'package:get/get.dart';

class GlobalMemory extends GetxController {
  final LocalStorage _localStorage = Get.find<LocalStorage>();

  static GlobalMemory get to => Get.find<GlobalMemory>();

  // Usuario autenticado.
  final Rxn<User> userRx = Rxn<User>();

  // Contexto principal entregado por el login.
  final Rxn<int> companyIdRx = Rxn<int>();
  final Rxn<int> unitIdRx = Rxn<int>();
  final Rxn<int> unitNumberRx = Rxn<int>();

  // Otros estados globales.
  final RxList bases = [].obs;
  final RxBool hasActiveTrip = false.obs;

  Future<void> logout() async {
    await _localStorage.clearData();
    _syncUserContext(null);
    bases.clear();
    hasActiveTrip.value = false;
  }

  Future<User?> getUser({bool forceRefresh = false}) async {
    if (!forceRefresh && userRx.value != null) return userRx.value;

    final user = await _localStorage.getUser();
    _syncUserContext(user);
    return user;
  }

  Future<void> setUser(User user) async {
    _syncUserContext(user);
    await _localStorage.saveUser(user);
  }

  Future<String?> getToken() async => _localStorage.getToken();

  Future<void> setToken(String token) async => _localStorage.saveToken(token);

  void _syncUserContext(User? user) {
    userRx.value = user;
    companyIdRx.value = user?.primaryCompany?.idCompany;
    unitIdRx.value = user?.primaryUnit?.id;
    unitNumberRx.value = user?.primaryUnit?.unitNumber;
  }

  User? get user => userRx.value;
  int? get companyId => companyIdRx.value;
  int? get unitId => unitIdRx.value;
  int? get unitNumber => unitNumberRx.value;
}

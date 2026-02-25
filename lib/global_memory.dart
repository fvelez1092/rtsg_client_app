import 'package:app_rtsg_client/data/models/user_model.dart';
import 'package:app_rtsg_client/data/services/local_storage_service.dart';
import 'package:get/get.dart';

class GlobalMemory extends GetxController {
  final LocalStorage _localStorage = Get.find<LocalStorage>();

  static GlobalMemory get to => Get.find<GlobalMemory>();

  // Usuario básico (del login)
  final Rxn<User> userRx = Rxn<User>();

  // Empresa (si la necesitas en UI)
  final Rxn<int> companyIdRx = Rxn<int>();

  // Otros estados globales (si los usas)
  final RxList bases = [].obs;
  final RxBool hasActiveTrip = false.obs;

  /// Cerrar sesión: limpia storage y memoria
  Future<void> logout() async {
    await _localStorage.clearData();
    userRx.value = null;
    companyIdRx.value = null;
    bases.clear();
    hasActiveTrip.value = false;
  }

  Future<User?> getUser({bool forceRefresh = false}) async {
    if (!forceRefresh && userRx.value != null) return userRx.value;

    final u = await _localStorage.getUser();
    userRx.value = u;
    return u;
  }

  Future<void> setUser(User user) async {
    userRx.value = user;
    await _localStorage.saveUser(user);
  }

  Future<String?> getToken() async => _localStorage.getToken();

  Future<void> setToken(String token) async => _localStorage.saveToken(token);

  // Handy getter
  User? get user => userRx.value;
}

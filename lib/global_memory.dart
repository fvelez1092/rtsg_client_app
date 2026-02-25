import 'package:app_rtsg_client/data/models/client_model.dart';
import 'package:app_rtsg_client/data/models/user_model.dart';
import 'package:app_rtsg_client/data/services/local_storage_service.dart';
import 'package:get/get.dart';

class GlobalMemory extends GetxController {
  late final LocalStorage _localStorage;

  GlobalMemory() {
    _localStorage = Get.find<LocalStorage>();
  }

  static GlobalMemory get to => Get.find<GlobalMemory>();

  // Usuario básico (del login)
  User? _user;

  // Driver completo (del endpoint /user/driver)
  Client? _driverData;

  // Versión reactiva para escuchar cambios del driver
  final Rxn<Client> driverRx = Rxn<Client>();

  // Otros estados globales que ya tenías
  RxList bases = [].obs;
  RxBool ifCarrera = false.obs;

  /// Cerrar sesión: limpia storage y memoria
  Future<void> logout() async {
    await _localStorage.clearData();
    _user = null;
    _driverData = null;
    driverRx.value = null;
    bases.clear();
    ifCarrera.value = false;
  }

  /// USER BÁSICO (el que guardas en el login)
  Future<User?> getUser({bool forceRefresh = false}) async {
    if (!forceRefresh && _user != null) return _user;

    _user = await _localStorage.getUser();
    return _user;
  }

  Future<void> setUser(User user) async {
    _user = user;
    await _localStorage.saveUser(user);
  }

  /// DRIVER COMPLETO (del /user/driver)
  void setDriverData(Client driverData) {
    _driverData = driverData;
    driverRx.value = driverData;
  }

  Client? get driverData => _driverData;

  /// Token (por si lo necesitas desde aquí)
  Future<String?> getToken() async {
    return _localStorage.getToken();
  }

  Future<Client?> getDriverData() async {
    return _driverData;
  }

  Map<String, int> rango = {"1M": 1, "3M": 3, "6M": 6, "1A": 12};
}

import 'package:app_rtsg_client/data/models/user_model.dart';

import 'package:get_storage/get_storage.dart';

class LocalStorage {
  final String _token = 'TOKEN';
  final String _userKey = 'USER';
  final GetStorage _localStorage = GetStorage();

  Future<void> saveToken(String token) async {
    await _localStorage.write(_token, token);
  }

  Future<String?> getToken() async {
    // SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return _localStorage.read(_token); //sharedPreferences.getString(_token)!;
  }

  Future<void> clearData() async {
    await _localStorage.remove(_token);
    await _localStorage.remove(_userKey);
  }

  Future<User?> getUser() async {
    final Map<String, dynamic>? userMap = _localStorage.read(_userKey);
    if (userMap == null) return null;
    return User.fromJson(userMap);
  }

  Future<bool> saveUser(User user) async {
    try {
      await _localStorage.write(_userKey, user.toJson());
      return true;
    } catch (e) {
      return false;
    }
  }
}

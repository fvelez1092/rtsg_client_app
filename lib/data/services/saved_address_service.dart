import 'package:get_storage/get_storage.dart';

import 'package:app_rtsg_client/data/models/saved_address_model.dart';

class SavedAddressService {
  final GetStorage _storage = GetStorage();

  String get _key {
    final rawUser = _storage.read('USER');

    if (rawUser is Map) {
      final user = Map<String, dynamic>.from(rawUser);
      final owner =
          user['id_user'] ??
          user['id_person'] ??
          user['username'] ??
          user['user'];

      if (owner != null && owner.toString().trim().isNotEmpty) {
        return 'SAVED_ADDRESSES_${owner.toString()}';
      }
    }

    return 'SAVED_ADDRESSES_GUEST';
  }

  List<SavedAddress> getAll() {
    final raw = _storage.read<List>(_key) ?? const [];

    return raw
        .whereType<Map>()
        .map((item) => SavedAddress.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<void> save(SavedAddress address) async {
    final current = getAll();
    final index = current.indexWhere((item) => item.id == address.id);

    if (index >= 0) {
      current[index] = address;
    } else {
      current.add(address);
    }

    await _storage.write(
      _key,
      current.map((item) => item.toJson()).toList(),
    );
  }

  Future<void> remove(String id) async {
    final current = getAll()..removeWhere((item) => item.id == id);
    await _storage.write(
      _key,
      current.map((item) => item.toJson()).toList(),
    );
  }
}

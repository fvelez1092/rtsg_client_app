import 'package:flutter_test/flutter_test.dart';
import 'package:app_rtsg_client/data/models/user_model.dart';

void main() {
  test('foto_perfil is preferred and survives persisted user round trip', () {
    final user = User.fromJson({
      'foto_perfil': '/uploads/avatar.jpg',
      'photo': 'old.jpg',
    });
    expect(user.photo, '/uploads/avatar.jpg');
    expect(user.toJson()['foto_perfil'], '/uploads/avatar.jpg');
    expect(User.fromJson(user.toJson()).photo, user.photo);
  });
  test(
    'Old cached photos remain supported and explicit null clears the photo',
    () {
      expect(User.fromJson({'photo': 'old.jpg'}).photo, 'old.jpg');
      expect(User.fromJson({'foto': 'legacy.jpg'}).photo, 'legacy.jpg');
      expect(
        User.fromJson({'foto_perfil': null, 'photo': 'old.jpg'}).photo,
        isNull,
      );
    },
  );
}

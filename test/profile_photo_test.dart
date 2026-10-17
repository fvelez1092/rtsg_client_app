import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:image_picker/image_picker.dart';
import 'package:app_rtsg_client/data/models/user_model.dart';
import 'package:app_rtsg_client/data/models/saved_address_model.dart';
import 'package:app_rtsg_client/data/services/user_service.dart';
import 'package:app_rtsg_client/data/services/local_storage_service.dart';
import 'package:app_rtsg_client/data/services/saved_address_service.dart';
import 'package:app_rtsg_client/application/profile_controller.dart';
import 'package:app_rtsg_client/global_memory.dart';

class PhotoAdapter implements HttpClientAdapter {
  RequestOptions? request;
  String wireBody = '';
  int status = 200;
  Map<String, dynamic> responseBody = {'estado': true};
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? stream,
    Future<void>? cancelFuture,
  ) async {
    request = options;
    if (stream != null) {
      final bytes = await stream.fold<List<int>>(
        [],
        (all, next) => all..addAll(next),
      );
      wireBody = utf8.decode(bytes, allowMalformed: true);
    }
    return ResponseBody.fromString(
      jsonEncode(responseBody),
      status,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class PhotoPicker extends ImagePicker {
  XFile? image;
  int calls = 0;
  @override
  Future<XFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    bool requestFullMetadata = true,
  }) async {
    calls++;
    return image;
  }
}

class PhotoUsers extends UserService {
  int uploads = 0, reads = 0;
  bool failUpload = false, failRead = false;
  Completer<void>? pending;
  @override
  Future<void> updateProfilePhoto({
    required List<int> bytes,
    required String filename,
    String? mimeType,
  }) async {
    uploads++;
    if (failUpload) throw Exception('Formato rechazado');
    if (pending != null) await pending!.future;
  }

  @override
  Future<User> getUserByToken() async {
    reads++;
    if (failRead) {
      failRead = false;
      throw Exception('offline');
    }
    return const User(
      idUser: 1,
      photo: 'https://example.test/new.jpg',
      email: 'user@example.test',
    );
  }
}

class PhotoAddresses implements SavedAddressService {
  @override
  Future<List<SavedAddress>> getAll() async => [];
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class PhotoStorage implements LocalStorage {
  User? saved;
  @override
  Future<bool> saveUser(User user) async {
    saved = user;
    return true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  tearDown(() => Get.reset());
  test(
    'PUT sends the photo file with multipart field fotoPerfil and existing JWT header',
    () async {
      final adapter = PhotoAdapter();
      final dio = Dio(
        BaseOptions(
          baseUrl: 'https://example.test/api/v3',
          headers: {'x-access-token': 'test-jwt'},
        ),
      )..httpClientAdapter = adapter;
      await UserService(
        dio: dio,
      ).updateProfilePhoto(bytes: [1, 2, 3], filename: 'foto.jpg');
      expect(adapter.request!.method, 'PUT');
      expect(adapter.request!.uri.path, '/api/v3/perfil/foto');
      expect(adapter.request!.headers['x-access-token'], 'test-jwt');
      expect(adapter.request!.contentType, startsWith('multipart/form-data'));
      final form = adapter.request!.data as FormData;
      expect(form.fields, isEmpty);
      expect(form.files.single.key, 'fotoPerfil');
      expect(form.files.single.value.filename, 'foto.jpg');
      expect(form.files.single.value.contentType.toString(), 'image/jpeg');
      expect(
        adapter.wireBody,
        contains('name="fotoPerfil"; filename="foto.jpg"'),
      );
    },
  );
  test(
    'Rejects server-declared failure and explains oversized photos',
    () async {
      final adapter = PhotoAdapter()
        ..responseBody = {'estado': false, 'observacion': 'Formato inválido'};
      final dio = Dio(BaseOptions(baseUrl: 'https://example.test/api/v3'))
        ..httpClientAdapter = adapter;
      final service = UserService(dio: dio);
      await expectLater(
        service.updateProfilePhoto(bytes: [1], filename: 'foto.png'),
        throwsException,
      );
      adapter.status = 413;
      adapter.responseBody = {};
      await expectLater(
        service.updateProfilePhoto(bytes: [1], filename: 'foto.png'),
        throwsA(predicate((e) => e.toString().contains('demasiado grande'))),
      );
    },
  );
  testWidgets(
    'Uploading blocks duplicate requests and persists the refreshed avatar',
    (tester) async {
      Get.testMode = true;
      final storage = PhotoStorage();
      Get.put<LocalStorage>(storage);
      final memory = Get.put(GlobalMemory());
      await memory.setUser(
        const User(idUser: 1, photo: 'https://example.test/old.jpg'),
      );
      final users = PhotoUsers()..pending = Completer<void>();
      final picker = PhotoPicker()
        ..image = XFile.fromData(
          Uint8List.fromList([1, 2, 3]),
          name: 'foto.jpg',
          mimeType: 'image/jpeg',
        );
      final controller = Get.put(
        ProfileController(PhotoAddresses(), userService: users, picker: picker),
      );
      await tester.pumpWidget(
        GetMaterialApp(home: Scaffold(body: Container())),
      );
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
      final uploading = controller.pickPhoto(ProfilePhotoSource.gallery);
      await tester.pump();
      expect(controller.isUploadingPhoto.value, isTrue);
      await controller.pickPhoto(ProfilePhotoSource.camera);
      expect(picker.calls, 1);
      expect(users.uploads, 1);
      users.pending!.complete();
      await uploading;
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
      expect(controller.isUploadingPhoto.value, isFalse);
      expect(controller.localPhotoPath.value, isNull);
      expect(memory.user!.photo, 'https://example.test/new.jpg');
      expect(storage.saved!.photo, memory.user!.photo);
      expect(controller.photoError.value, isEmpty);
    },
  );
  testWidgets(
    'Cancelled selection never uploads and failed refresh retries without uploading twice',
    (tester) async {
      Get.testMode = true;
      Get.put<LocalStorage>(PhotoStorage());
      final memory = Get.put(GlobalMemory());
      await memory.setUser(
        const User(idUser: 1, photo: 'https://example.test/old.jpg'),
      );
      final users = PhotoUsers()..failRead = true;
      final picker = PhotoPicker();
      final controller = Get.put(
        ProfileController(PhotoAddresses(), userService: users, picker: picker),
      );
      await tester.pumpWidget(
        GetMaterialApp(home: Scaffold(body: Container())),
      );
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
      await controller.pickPhoto(ProfilePhotoSource.gallery);
      expect(users.uploads, 0);
      picker.image = XFile.fromData(
        Uint8List.fromList([1, 2]),
        name: 'foto.jpg',
      );
      await controller.pickPhoto(ProfilePhotoSource.gallery);
      expect(users.uploads, 1);
      expect(controller.photoError.value, contains('La foto se guardó'));
      expect(controller.canRetryPhoto, isTrue);
      await controller.retryPhotoUpload();
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
      expect(users.uploads, 1);
      expect(users.reads, 2);
      expect(controller.photoError.value, isEmpty);
    },
  );
  testWidgets('Rejected upload restores previous avatar and offers retry', (
    tester,
  ) async {
    Get.testMode = true;
    Get.put<LocalStorage>(PhotoStorage());
    final memory = Get.put(GlobalMemory());
    await memory.setUser(
      const User(idUser: 1, photo: 'https://example.test/old.jpg'),
    );
    final users = PhotoUsers()..failUpload = true;
    final picker = PhotoPicker()
      ..image = XFile.fromData(Uint8List.fromList([1, 2]), name: 'foto.jpg');
    final controller = Get.put(
      ProfileController(PhotoAddresses(), userService: users, picker: picker),
    );
    await tester.pumpWidget(GetMaterialApp(home: Scaffold(body: Container())));
    await tester.pumpAndSettle();
    await controller.pickPhoto(ProfilePhotoSource.gallery);
    expect(controller.localPhotoPath.value, isNull);
    expect(memory.user!.photo, 'https://example.test/old.jpg');
    expect(controller.photoError.value, 'Formato rechazado');
    expect(controller.canRetryPhoto, isTrue);
    expect(users.reads, 0);
  });
}

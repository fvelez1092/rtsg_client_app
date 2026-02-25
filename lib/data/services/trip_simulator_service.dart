import 'package:app_rtsg_client/data/models/trip_model.dart';
import 'package:app_rtsg_client/data/models/trip_status.dart';

import 'dart:async';
import 'dart:math';
import 'package:get/get.dart';

class TripSimulatorService extends GetxService {
  final _rng = Random();

  final StreamController<TripModel> _controller =
      StreamController<TripModel>.broadcast();

  Stream<TripModel> get stream => _controller.stream;

  Timer? _timer;
  TripModel? _active;

  /// Crea una carrera y empieza a emitir estados.
  Future<TripModel> createTrip(TripModel trip) async {
    // Simula tiempo de creación
    await Future.delayed(const Duration(milliseconds: 700));

    // Estado inicial: searching
    _active = trip.copyWith(status: TripStatus.searching);
    _controller.add(_active!);

    // Simula que un conductor acepta en un tiempo aleatorio (2-8s)
    _scheduleAcceptance();

    return _active!;
  }

  void _scheduleAcceptance() {
    _timer?.cancel();

    final seconds = 2 + _rng.nextInt(7); // 2..8
    _timer = Timer(Duration(seconds: seconds), () {
      if (_active == null) return;

      // 85% probabilidad de aceptación (ajusta)
      final accepted = _rng.nextDouble() < 0.85;
      if (!accepted) {
        // sigue buscando otros 3-6s
        _active = _active!.copyWith(status: TripStatus.searching);
        _controller.add(_active!);
        _timer = Timer(Duration(seconds: 3 + _rng.nextInt(4)), () {
          if (_active == null) return;
          _active = _active!.copyWith(status: TripStatus.accepted);
          _controller.add(_active!);
          _scheduleRideProgress();
        });
        return;
      }

      _active = _active!.copyWith(status: TripStatus.accepted);
      _controller.add(_active!);

      _scheduleRideProgress();
    });
  }

  void _scheduleRideProgress() {
    // Opcional: simular llegada e inicio automáticamente
    _timer = Timer(const Duration(seconds: 5), () {
      if (_active == null) return;
      _active = _active!.copyWith(status: TripStatus.arrived);
      _controller.add(_active!);

      _timer = Timer(const Duration(seconds: 4), () {
        if (_active == null) return;
        _active = _active!.copyWith(status: TripStatus.started);
        _controller.add(_active!);

        _timer = Timer(const Duration(seconds: 8), () {
          if (_active == null) return;
          _active = _active!.copyWith(status: TripStatus.completed);
          _controller.add(_active!);
        });
      });
    });
  }

  void cancelActive() {
    _timer?.cancel();
    if (_active == null) return;

    _active = _active!.copyWith(status: TripStatus.cancelled);
    _controller.add(_active!);

    _active = null;
  }

  void reset() {
    _timer?.cancel();
    _active = null;
  }

  @override
  void onClose() {
    _timer?.cancel();
    _controller.close();
    super.onClose();
  }
}

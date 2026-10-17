/// Serializa Socket.IO y FCM para no presentar dos veces el mismo evento.
class TripNotificationLedger {
  final List<String> Function() read;
  final Future<void> Function(List<String>) write;
  Future<void> _pending = Future<void>.value();
  TripNotificationLedger({required this.read, required this.write});

  Future<bool> runOnce(String eventId, Future<void> Function() action) {
    final result = _pending.then((_) async {
      final ids = read();
      if (ids.contains(eventId)) return false;
      await action();
      final updated = [...ids, eventId];
      await write(
        updated.length > 100 ? updated.sublist(updated.length - 100) : updated,
      );
      return true;
    });
    _pending = result.then<void>(
      (_) {},
      onError: (Object error, StackTrace stack) {},
    );
    return result;
  }
}

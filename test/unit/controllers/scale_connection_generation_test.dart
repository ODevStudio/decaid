import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:reaprime/src/controllers/scale_controller.dart';
import 'package:reaprime/src/models/device/device.dart';
import 'package:reaprime/src/models/device/device_implementation.dart';
import 'package:reaprime/src/models/device/scale.dart';
import 'package:reaprime/src/models/device/transport/data_transport.dart';
import 'package:rxdart/subjects.dart';

class _BlockingScale implements Scale {
  @override
  final String deviceId;

  _BlockingScale(this.deviceId);

  final Completer<void> connectCompleter = Completer<void>();
  final BehaviorSubject<ConnectionState> _connectionState =
      BehaviorSubject.seeded(ConnectionState.discovered);
  final BehaviorSubject<ScaleSnapshot> _snapshots = BehaviorSubject();
  int connectCalls = 0;

  void completeConnect() {
    if (!connectCompleter.isCompleted) connectCompleter.complete();
  }

  void emitWeight(double weight) {
    _snapshots.add(
      ScaleSnapshot(
        timestamp: DateTime.utc(2026, 9, 15),
        weight: weight,
        batteryLevel: 50,
      ),
    );
  }

  Future<void> close() async {
    await _connectionState.close();
    await _snapshots.close();
  }

  @override
  String get name => deviceId;

  @override
  DeviceType get type => DeviceType.scale;

  @override
  DeviceImplementation get implementation => DeviceImplementation.unifiedDe1;

  @override
  TransportType get transportType => TransportType.unknown;

  @override
  Stream<ConnectionState> get connectionState => _connectionState.stream;

  @override
  Stream<ScaleSnapshot> get currentSnapshot => _snapshots.stream;

  @override
  Future<void> onConnect() async {
    connectCalls++;
    await connectCompleter.future;
    _connectionState.add(ConnectionState.connected);
  }

  @override
  Future<void> disconnect() async {
    _connectionState.add(ConnectionState.disconnected);
  }

  @override
  Future<void> tare() async {}

  @override
  Future<void> sleepDisplay() async {}

  @override
  Future<void> wakeDisplay() async {}

  @override
  Future<void> startTimer() async {}

  @override
  Future<void> stopTimer() async {}

  @override
  Future<void> resetTimer() async {}
}

class _BlockingHandoffScale extends _BlockingScale
    implements TransportHandoffScale {
  _BlockingHandoffScale(super.deviceId);

  final Completer<void> handoffCompleter = Completer<void>();

  void completeHandoff() {
    if (!handoffCompleter.isCompleted) handoffCompleter.complete();
  }

  @override
  Future<void> disconnectForHandoff() => handoffCompleter.future;
}

void main() {
  test(
    'invalidated pending scale cannot adopt after late completion',
    () async {
      final controller = ScaleController();
      final pending = _BlockingScale('scale-old');
      final frames = <WeightSnapshot>[];
      final frameSub = controller.weightSnapshot.listen(frames.add);

      final connect = controller.connectToScale(pending);
      await Future<void>.delayed(Duration.zero);

      controller.invalidatePendingConnectionAttempt();
      pending.completeConnect();
      await connect;

      expect(controller.connectedScaleOrNull, isNull);

      pending.emitWeight(12.3);
      await Future<void>.delayed(Duration.zero);
      expect(
        frames,
        isEmpty,
        reason: 'the stale attempt must release its snapshot subscription',
      );

      await frameSub.cancel();
      controller.dispose();
      await pending.close();
    },
  );

  test(
    'late scale completion cannot replace or detach a newer scale',
    () async {
      final controller = ScaleController();
      final pending = _BlockingScale('scale-old');
      final replacement = _BlockingScale('scale-new');

      final oldConnect = controller.connectToScale(pending);
      await Future<void>.delayed(Duration.zero);

      replacement.completeConnect();
      await replacement.onConnect();
      await controller.adoptScale(replacement);

      pending.completeConnect();
      await oldConnect;

      expect(controller.connectedScaleOrNull, same(replacement));

      final nextFrame = controller.weightSnapshot.first;
      replacement.emitWeight(42.0);
      expect((await nextFrame).weight, 42.0);

      controller.dispose();
      await pending.close();
      await replacement.close();
    },
  );

  test(
    'invalidation during handoff prevents replacement connect from starting',
    () async {
      final controller = ScaleController();
      final previous = _BlockingHandoffScale('scale-old');
      final replacement = _BlockingScale('scale-new');

      previous.completeConnect();
      await previous.onConnect();
      await controller.adoptScale(previous);

      final connect = controller.connectToScale(replacement);
      await Future<void>.delayed(Duration.zero);

      controller.invalidatePendingConnectionAttempt();
      previous.completeHandoff();
      await connect;

      expect(replacement.connectCalls, 0);
      expect(controller.connectedScaleOrNull, isNull);

      controller.dispose();
      await previous.close();
      await replacement.close();
    },
  );
}

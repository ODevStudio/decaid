import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:reaprime/src/controllers/scale_controller.dart';
import 'package:reaprime/src/models/device/device.dart';
import 'package:reaprime/src/models/device/scale.dart';

import '../../helpers/test_scale.dart';

class _BlockingScale extends TestScale {
  final Completer<void> connectCompleter = Completer<void>();

  _BlockingScale(String deviceId)
    : super(deviceId: deviceId, initialState: ConnectionState.discovered);

  void completeConnect() {
    if (!connectCompleter.isCompleted) connectCompleter.complete();
  }

  void emitWeight(double weight) {
    emitSnapshot(
      ScaleSnapshot(
        timestamp: DateTime.utc(2026, 9, 15),
        weight: weight,
        batteryLevel: 50,
      ),
    );
  }

  @override
  Future<void> onConnect() async {
    await connectCompleter.future;
    setConnectionState(ConnectionState.connected);
  }
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
      pending.dispose();
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
      pending.dispose();
      replacement.dispose();
    },
  );
}

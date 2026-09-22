import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:reaprime/src/services/serial/utils.dart';

void main() {
  const frame = [0x03, 0xCE, 0xFF, 0xFD, 0x00, 0x00, 0xCF];

  test('detects HDS frames split at every byte boundary', () {
    for (var split = 1; split < frame.length; split++) {
      expect(
        isDecentScale([], [
          Uint8List.fromList(frame.sublist(0, split)),
          Uint8List.fromList(frame.sublist(split)),
        ]),
        isTrue,
        reason: 'split=$split',
      );
    }
  });

  test('detects HDS after a partial previous frame and text', () {
    expect(
      isDecentScale([], [
        Uint8List.fromList([0xCF, 13, 10, ...frame]),
      ]),
      isTrue,
    );
  });

  test('rejects incomplete signatures and other serial data', () {
    for (var length = 0; length < 6; length++) {
      expect(
        isDecentScale([], [Uint8List.fromList(frame.take(length).toList())]),
        isFalse,
      );
    }
    expect(
      isDecentScale([], [
        Uint8List.fromList([3, 206, 0, 1, 2, 3]),
      ]),
      isFalse,
    );
  });

  test('keeps ASCII HDS discovery', () {
    expect(isDecentScale(['1234 Weight: 0.00'], []), isTrue);
    expect(isDecentScale(['unrelated device'], []), isFalse);
  });
}

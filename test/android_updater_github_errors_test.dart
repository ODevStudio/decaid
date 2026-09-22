import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:reaprime/src/services/android_updater.dart';

void main() {
  AndroidUpdater updater(http.Response response) => AndroidUpdater(
    owner: 'decentespresso',
    repo: 'decaid',
    httpClient: MockClient((_) async => response),
  );

  test(
    'release requests explicitly identify Decaid and accept GitHub JSON',
    () async {
      final client = AndroidUpdater(
        owner: 'decentespresso',
        repo: 'decaid',
        httpClient: MockClient((request) async {
          expect(request.headers['User-Agent'], 'Decaid');
          expect(request.headers['Accept'], 'application/vnd.github.v3+json');
          return http.Response('[]', 200);
        }),
      );
      expect(await client.checkForUpdate('0.8.6'), isNull);
    },
  );

  test('rate limit includes a UTC reset time', () async {
    final reset = DateTime.utc(2026, 9, 22, 12);
    final client = updater(
      http.Response(
        jsonEncode({'message': 'API rate limit exceeded'}),
        403,
        headers: {
          'x-ratelimit-remaining': '0',
          'x-ratelimit-reset': '${reset.millisecondsSinceEpoch ~/ 1000}',
        },
      ),
    );
    await expectLater(
      client.checkForUpdate('0.8.6'),
      throwsA(
        isA<UpdateCheckException>().having(
          (error) => error.message,
          'message',
          allOf(
            contains('403'),
            contains('rate limit'),
            contains('2026-09-22T12:00:00.000Z'),
          ),
        ),
      ),
    );
  });

  test('administrative 403 retains the User-Agent explanation', () async {
    final client = updater(
      http.Response(
        'Request forbidden by administrative rules. Please make sure your request has a User-Agent header',
        403,
      ),
    );
    await expectLater(
      client.checkForUpdate('0.8.6'),
      throwsA(
        isA<UpdateCheckException>().having(
          (error) => error.message,
          'message',
          allOf(
            contains('403'),
            contains('User-Agent'),
            isNot(contains('rate limit')),
          ),
        ),
      ),
    );
  });

  for (final reset in ['invalid', '-1', '999999999999999999999']) {
    test('invalid reset $reset does not hide the HTTP failure', () async {
      final client = updater(
        http.Response(
          '{invalid json',
          403,
          headers: {'x-ratelimit-remaining': '0', 'x-ratelimit-reset': reset},
        ),
      );
      await expectLater(
        client.checkForUpdate('0.8.6'),
        throwsA(
          isA<UpdateCheckException>().having(
            (error) => error.message,
            'message',
            allOf(contains('403'), contains('rate limit')),
          ),
        ),
      );
    });
  }

  test('JSON failure messages are bounded and flattened', () async {
    final client = updater(
      http.Response(jsonEncode({'message': 'Unavailable\n${'x' * 1000}'}), 503),
    );
    await expectLater(
      client.checkForUpdate('0.8.6'),
      throwsA(
        isA<UpdateCheckException>().having(
          (error) => error.message,
          'message',
          allOf(
            contains('Unavailable'),
            isNot(contains('\n')),
            hasLength(lessThan(400)),
          ),
        ),
      ),
    );
  });
}

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:reaprime/src/services/account/decent_account_service.dart';
import 'package:reaprime/src/services/account/decent_proxy_service.dart';

import 'decent_proxy_service_test.dart' as helpers;

class _DelayedCredentialStore extends helpers.FakeCredentialStore {
  final Future<void> Function(String) onRead;
  final Future<void> Function(String) onWrite;

  _DelayedCredentialStore({required this.onRead, required this.onWrite});

  @override
  Future<String?> read({required String key}) async {
    final value = await super.read(key: key);
    await onRead(key);
    return value;
  }

  @override
  Future<void> write({required String key, required String value}) async {
    await onWrite(key);
    await super.write(key: key, value: value);
  }
}

void main() {
  late helpers.FakeCredentialStore store;
  late DecentAccountService account;
  Future<void> Function(String)? readHook;
  Future<void> Function(String)? writeHook;

  setUp(() async {
    readHook = null;
    writeHook = null;
    store = _DelayedCredentialStore(
      onRead: (key) async => await readHook?.call(key),
      onWrite: (key) async => await writeHook?.call(key),
    );
    await store.write(key: 'email', value: 'user@example.com');
    await store.write(key: 'password', value: 'stable-token');
    final client = MockClient((request) async {
      return switch (request.url.path) {
        '/support/api/login_test' => http.Response('stable-token', 200),
        '/support/api/sn' => http.Response('6262 DE-DE1PRO', 200),
        _ => throw StateError('Unexpected request: ${request.url}'),
      };
    });
    addTearDown(client.close);
    account = DecentAccountService(httpClient: client, credentialStore: store);
    expect(await account.login('user@example.com', 'password'), isTrue);
  });

  DecentProxyService proxy(
    MockClientHandler handler, {
    Future<bool> Function(String)? requireConsent,
    bool trackGeneration = true,
  }) {
    final client = MockClient(handler);
    addTearDown(client.close);
    return DecentProxyService(
      httpClient: client,
      credentialStore: store,
      requireConsent: requireConsent ?? (_) async => true,
      onAuthFailure: account.reportAuthenticationFailure,
      isAuthKnownInvalid: account.isAuthKnownInvalid,
      authenticationGeneration: trackGeneration
          ? () => account.authenticationGeneration
          : null,
    );
  }

  test(
    'changed credentials suppress old 401 without a generation provider',
    () async {
      final started = Completer<void>();
      final response = Completer<http.Response>();
      final service = proxy((_) async {
        started.complete();
        return response.future;
      }, trackGeneration: false);
      final pending = service.proxyGet(
        callerId: 'plugin:shot-upload',
        path: 'support/api/sn',
      );
      await started.future;
      expect(await account.login('new@example.com', 'password'), isTrue);
      response.complete(http.Response('unauthorized', 401));
      expect((await pending).statusCode, 401);
      expect(await account.isAuthKnownInvalid(), isFalse);
    },
  );

  test('generation is checked after rereading credentials for a 401', () async {
    final started = Completer<void>();
    final response = Completer<http.Response>();
    final readStarted = Completer<void>();
    final finishRead = Completer<void>();
    final service = proxy((_) async {
      started.complete();
      return response.future;
    });
    final pending = service.proxyGet(
      callerId: 'plugin:shot-upload',
      path: 'support/api/sn',
    );
    await started.future;
    readHook = (key) async {
      if (key != 'password') return;
      readHook = null;
      readStarted.complete();
      await finishRead.future;
    };
    response.complete(http.Response('unauthorized', 401));
    await readStarted.future;
    expect(await account.login('user@example.com', 'password'), isTrue);
    finishRead.complete();
    expect((await pending).statusCode, 401);
    expect(await account.isAuthKnownInvalid(), isFalse);
  });

  test(
    'generation is captured before consent and an overlapping login',
    () async {
      final consentStarted = Completer<void>();
      final grantConsent = Completer<bool>();
      final writeStarted = Completer<void>();
      final finishWrite = Completer<void>();
      final requestStarted = Completer<void>();
      final response = Completer<http.Response>();
      final service = proxy(
        (_) async {
          requestStarted.complete();
          return response.future;
        },
        requireConsent: (_) {
          consentStarted.complete();
          return grantConsent.future;
        },
      );
      final pending = service.proxyGet(
        callerId: 'plugin:shot-upload',
        path: 'support/api/sn',
      );
      await consentStarted.future;
      writeHook = (key) async {
        if (key != 'password') return;
        writeHook = null;
        writeStarted.complete();
        await finishWrite.future;
      };
      final login = account.login('user@example.com', 'password');
      await writeStarted.future;
      grantConsent.complete(true);
      await requestStarted.future;
      finishWrite.complete();
      expect(await login, isTrue);
      response.complete(http.Response('unauthorized', 401));
      expect((await pending).statusCode, 401);
      expect(await account.isAuthKnownInvalid(), isFalse);
    },
  );

  for (final email in ['new@example.com', 'user@example.com']) {
    test('old 401 cannot invalidate a later login as $email', () async {
      final started = Completer<void>();
      final response = Completer<http.Response>();
      final service = proxy((request) async {
        if (!started.isCompleted) {
          started.complete();
          return response.future;
        }
        return http.Response('ok', 200);
      });
      final pending = service.proxyGet(
        callerId: 'plugin:shot-upload',
        path: 'support/api/sn',
      );
      await started.future;
      expect(await account.login(email, 'password'), isTrue);
      response.complete(http.Response('unauthorized', 401));

      expect((await pending).statusCode, 401);
      expect(await account.isAuthKnownInvalid(), isFalse);
      expect(await account.isLoggedIn(), isTrue);
      expect(
        (await service.proxyGet(
          callerId: 'plugin:shot-upload',
          path: 'support/api/sn',
        )).statusCode,
        200,
      );
    });
  }

  test(
    'current 401 invalidates authentication and blocks the next call',
    () async {
      final service = proxy((_) async => http.Response('unauthorized', 401));
      expect(
        (await service.proxyGet(
          callerId: 'plugin:shot-upload',
          path: 'support/api/sn',
        )).statusCode,
        401,
      );
      expect(await account.isAuthKnownInvalid(), isTrue);
      await expectLater(
        service.proxyGet(
          callerId: 'plugin:shot-upload',
          path: 'support/api/sn',
        ),
        throwsA(isA<DecentAccountAuthInvalidException>()),
      );
    },
  );
}

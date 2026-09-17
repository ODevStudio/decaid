from pathlib import Path


def replace(path, old, new, count=1):
    p = Path(path)
    text = p.read_text()
    if old not in text:
        raise SystemExit(f"anchor not found in {path}: {old[:120]!r}")
    p.write_text(text.replace(old, new, count))


replace(
    "lib/src/models/device/transport/ble_connect_exception.dart",
    "  BleConnectException({this.code, this.description, this.function, this.cause});\n\n  @override\n",
    "  BleConnectException({this.code, this.description, this.function, this.cause});\n\n  bool get recoveryBlocked =>\n      description?.startsWith('RECOVERY_BLOCKED:') ?? false;\n\n  @override\n",
)

replace(
    "lib/src/controllers/connection/connection_attempt_owner.dart",
    "  bool owns(String deviceId, {ConnectionAttemptRole? role}) {\n",
    "  ConnectionAttemptLease? activeFor(String deviceId) =>\n      _active[_normalize(deviceId)];\n\n  bool owns(String deviceId, {ConnectionAttemptRole? role}) {\n",
)

replace(
    "lib/src/services/universal_ble_discovery_service.dart",
    "    } on BleConnectException catch (e) {\n      log.info('Quick-connect GATT error ($e), retrying once after 1s');\n",
    "    } on BleConnectException catch (e) {\n      if (e.recoveryBlocked) rethrow;\n      log.info('Quick-connect GATT error ($e), retrying once after 1s');\n",
)
replace(
    "lib/src/services/universal_ble_discovery_service.dart",
    "    } catch (e, st) {\n      log.warning('Quick-connect failed for $deviceId', e, st);\n      try {\n        await device.disconnect();\n      } catch (_) {}\n      try {\n        await transport.dispose();\n      } catch (_) {}\n      return null;\n    }\n  }\n\n  Future<BleDevice?> _findSystemDevice",
    "    } on BleConnectException catch (e, st) {\n      if (e.recoveryBlocked) {\n        log.warning('Quick-connect recovery blocked for $deviceId', e, st);\n        try {\n          await transport.dispose();\n        } catch (_) {}\n        rethrow;\n      }\n      log.warning('Quick-connect failed for $deviceId', e, st);\n      try {\n        await device.disconnect();\n      } catch (_) {}\n      try {\n        await transport.dispose();\n      } catch (_) {}\n      return null;\n    } catch (e, st) {\n      log.warning('Quick-connect failed for $deviceId', e, st);\n      try {\n        await device.disconnect();\n      } catch (_) {}\n      try {\n        await transport.dispose();\n      } catch (_) {}\n      return null;\n    }\n  }\n\n  Future<BleDevice?> _findSystemDevice",
)

replace(
    "lib/src/controllers/connection_manager.dart",
    """  Future<bool> _retireAttempt(
    ConnectionAttemptLease attempt,
    Future<void> source,
    bool Function() adopted,
    Future<void> Function() cleanup,
  ) async {
    final adapterResetEpoch = _adapterResetEpoch;
    Object? sourceError;
    StackTrace? sourceStack;
    try {
      await source;
    } catch (error, stackTrace) {
      sourceError = error;
      sourceStack = stackTrace;
    }
    var cleanupSucceeded = true;
    try {
      final mayAdopt = attempt.mayAdopt;
      if (!mayAdopt || sourceError != null || !adopted()) {
        try {
          await cleanup();
        } catch (error, stackTrace) {
          cleanupSucceeded = false;
          if (attempt.ble && adapterResetEpoch != _adapterResetEpoch) {
            attempt.settle();
          } else {
            attempt.markCleanupFailed();
          }
          _log.warning(
            'Connection attempt cleanup failed for ${attempt.deviceId}',
            error,
            stackTrace,
          );
          Error.throwWithStackTrace(error, stackTrace);
        }
        if (mayAdopt && sourceError != null) {
          Error.throwWithStackTrace(sourceError, sourceStack!);
        }
        return false;
      }
      return true;
    } finally {
      if (cleanupSucceeded) attempt.settle();
    }
  }
""",
    """  Future<bool> _retireAttempt(
    ConnectionAttemptLease attempt,
    Future<void> source,
    bool Function() adopted,
    Future<void> Function() cleanup,
  ) async {
    final adapterResetEpoch = _adapterResetEpoch;
    Object? sourceError;
    StackTrace? sourceStack;
    try {
      await source;
    } catch (error, stackTrace) {
      sourceError = error;
      sourceStack = stackTrace;
    }
    final recoveryBlocked =
        attempt.ble &&
        sourceError is BleConnectException &&
        sourceError.recoveryBlocked;
    var cleanupSucceeded = true;
    try {
      final mayAdopt = attempt.mayAdopt;
      if (!mayAdopt || sourceError != null || !adopted()) {
        try {
          await cleanup();
        } catch (error, stackTrace) {
          cleanupSucceeded = false;
          if (attempt.ble && adapterResetEpoch != _adapterResetEpoch) {
            attempt.settle();
          } else {
            attempt.markCleanupFailed();
          }
          _log.warning(
            'Connection attempt cleanup failed for ${attempt.deviceId}',
            error,
            stackTrace,
          );
          Error.throwWithStackTrace(error, stackTrace);
        }
        if (recoveryBlocked && adapterResetEpoch == _adapterResetEpoch) {
          attempt.markCleanupFailed();
        }
        if (mayAdopt && sourceError != null) {
          Error.throwWithStackTrace(sourceError, sourceStack!);
        }
        return false;
      }
      return true;
    } finally {
      if (cleanupSucceeded && !attempt.cleanupFailed) attempt.settle();
    }
  }
""",
)

replace(
    "lib/src/controllers/connection_manager.dart",
    """    final attempt = _connectionAttempts.acquire(
      machineId,
      role: ConnectionAttemptRole.machine,
      automatic: true,
      controllerOwned: false,
      ble: remembered.transportType == TransportType.ble,
    );
    if (attempt == null) return null;
    try {
      final device = await deviceScanner.tryQuickConnect(remembered);
      if (device is De1Interface) {
        if (!attempt.mayAdopt) {
          await device.disconnect();
          return null;
        }
        de1Controller.adoptDevice(device);
        await _disconnectSupervisor.waitForMachine(device.deviceId);
        if (!attempt.mayAdopt) {
          await device.disconnect();
          return null;
        }
        await _migrateQuickConnectAlias(remembered.id, device.deviceId);
        _log.info('Quick-connect: machine adopted (${device.deviceId})');
        return device;
      }
    } catch (e, st) {
      _log.warning('Quick-connect: machine attempt failed', e, st);
    } finally {
      attempt.settle();
    }
    return null;
  }

  Future<void> _migrateQuickConnectAlias""",
    """    final existing = _connectionAttempts.activeFor(machineId);
    if (existing != null) {
      if (existing.ble && existing.cleanupFailed) {
        throw BleConnectException(
          code: 'connectionFailed',
          description:
              'RECOVERY_BLOCKED: retained quick-connect ownership for $machineId',
          function: 'connect',
        );
      }
      return null;
    }
    final attempt = _connectionAttempts.acquire(
      machineId,
      role: ConnectionAttemptRole.machine,
      automatic: true,
      controllerOwned: false,
      ble: remembered.transportType == TransportType.ble,
    );
    if (attempt == null) return null;
    final adapterResetEpoch = _adapterResetEpoch;
    try {
      final device = await deviceScanner.tryQuickConnect(remembered);
      if (device is De1Interface) {
        if (!attempt.mayAdopt) {
          await _cleanupQuickConnectMachine(
            attempt,
            device,
            adapterResetEpoch: adapterResetEpoch,
            expected: false,
          );
          return null;
        }
        de1Controller.adoptDevice(device);
        await _disconnectSupervisor.waitForMachine(device.deviceId);
        if (!attempt.mayAdopt) {
          await _cleanupQuickConnectMachine(
            attempt,
            device,
            adapterResetEpoch: adapterResetEpoch,
            expected: true,
          );
          return null;
        }
        await _migrateQuickConnectAlias(remembered.id, device.deviceId);
        _log.info('Quick-connect: machine adopted (${device.deviceId})');
        return device;
      }
    } on BleConnectException catch (e, st) {
      if (e.recoveryBlocked && attempt.ble) {
        if (adapterResetEpoch != _adapterResetEpoch) {
          _log.info(
            'Quick-connect recovery block cleared by adapter reset for $machineId',
          );
          return null;
        }
        attempt.markCleanupFailed();
        _log.warning('Quick-connect recovery blocked for $machineId', e, st);
        rethrow;
      }
      _log.warning('Quick-connect: machine attempt failed', e, st);
    } catch (e, st) {
      _log.warning('Quick-connect: machine attempt failed', e, st);
    } finally {
      if (!attempt.cleanupFailed) attempt.settle();
    }
    return null;
  }

  Future<void> _cleanupQuickConnectMachine(
    ConnectionAttemptLease attempt,
    De1Interface device, {
    required int adapterResetEpoch,
    required bool expected,
  }) async {
    if (expected) markExpectingDisconnect(device.deviceId);
    try {
      await device.disconnect();
    } catch (error, stackTrace) {
      _log.warning(
        'Quick-connect cleanup failed for ${device.deviceId}',
        error,
        stackTrace,
      );
      if (!attempt.ble || adapterResetEpoch != _adapterResetEpoch) return;
      attempt.markCleanupFailed();
      throw BleConnectException(
        code: 'connectionFailed',
        description:
            'RECOVERY_BLOCKED: quick-connect cleanup failed for ${device.deviceId}',
        function: 'disconnect',
        cause: error,
      );
    }
  }

  Future<void> _migrateQuickConnectAlias""",
)

replace(
    "lib/src/controllers/connection_manager.dart",
    "      final qcMachine = await _tryQuickConnectMachine();\n      if (qcMachine != null) {\n",
    """      De1Interface? qcMachine;
      try {
        qcMachine = await _tryQuickConnectMachine();
      } on BleConnectException catch (error) {
        if (!error.recoveryBlocked) rethrow;
        final machineId = settingsController.preferredMachineId;
        _publishStatus(
          currentStatus.copyWith(
            phase: ConnectionPhase.idle,
            pendingAmbiguity: () => null,
            activeTargetTransport: () => null,
          ),
        );
        _emit(
          ConnectionError(
            kind: ConnectionErrorKind.machineConnectFailed,
            severity: ConnectionErrorSeverity.error,
            timestamp: DateTime.now().toUtc(),
            deviceId: machineId,
            message:
                'Bluetooth recovery is blocked by unfinished connection cleanup.',
            suggestion: 'Toggle Bluetooth off and on, then retry.',
            details: {
              if (error.code != null) 'ble_code': error.code,
              if (error.description != null)
                'ble_description': error.description,
              if (error.function != null) 'ble_function': error.function,
            },
          ),
        );
        return;
      }
      if (qcMachine != null) {
""",
)

replace(
    "test/helpers/mock_device_scanner.dart",
    "    quickConnectResult = null;\n    quickConnectCallCount = 0;\n",
    "    quickConnectResult = null;\n    quickConnectError = null;\n    quickConnectCallCount = 0;\n",
)
replace(
    "test/helpers/mock_device_scanner.dart",
    """  Device? quickConnectResult;

  int quickConnectCallCount = 0;

  @override
  Future<Device?> tryQuickConnect(RememberedDevice remembered) async {
    quickConnectCallCount++;
    return quickConnectResult;
  }
""",
    """  Device? quickConnectResult;
  Object? quickConnectError;

  int quickConnectCallCount = 0;

  @override
  Future<Device?> tryQuickConnect(RememberedDevice remembered) async {
    quickConnectCallCount++;
    final error = quickConnectError;
    quickConnectError = null;
    if (error != null) throw error;
    return quickConnectResult;
  }
""",
)

replace(
    "test/controllers/connection_attempt_owner_test.dart",
    "    test('repeated cancel is idempotent', () {\n",
    """    test('activeFor normalizes device ids', () {
      final owner = ConnectionAttemptOwner();
      final attempt = owner.acquire('AA:BB')!;

      expect(owner.activeFor('aa:bb'), same(attempt));
    });

    test('repeated cancel is idempotent', () {
""",
)

replace(
    "test/services/universal_ble_discovery_service_test.dart",
    "import 'package:reaprime/src/models/device/remembered_device.dart';\n",
    "import 'package:reaprime/src/models/device/remembered_device.dart';\nimport 'package:reaprime/src/models/device/transport/ble_connect_exception.dart';\n",
)
replace(
    "test/services/universal_ble_discovery_service_test.dart",
    "  group('quick-connect identity policy', () {\n",
    """  group('quick-connect identity policy', () {
    test('quick-connect does not retry recovery-blocked admission', () async {
      const deviceId = 'AA:BB:CC:DD:EE:21';
      var connectCalls = 0;
      final transport = _TrackingFakeBleTransport(
        deviceId: deviceId,
        onConnect: () async {
          connectCalls++;
          throw BleConnectException(
            code: 'connectionFailed',
            description: 'RECOVERY_BLOCKED: unresolved native GATT teardown',
            function: 'connect',
          );
        },
      );
      final sut = UniversalBleDiscoveryService(
        requiresSystemDevice: () => false,
        transportFactory:
            ({
              required device,
              required stopScan,
              required requestLargeMtuNonAndroid,
              required lifecycleGate,
            }) => transport,
      );
      addTearDown(sut.dispose);
      await sut.initialize();

      await expectLater(
        sut.tryQuickConnect(
          const RememberedDevice(
            id: deviceId,
            name: 'DE1',
            type: domain.DeviceType.machine,
            implementation: DeviceImplementation.unifiedDe1,
            transportType: TransportType.ble,
          ),
        ),
        throwsA(
          isA<BleConnectException>().having(
            (error) => error.recoveryBlocked,
            'recoveryBlocked',
            isTrue,
          ),
        ),
      );

      expect(connectCalls, 1);
      expect(transport.disconnectCalls, 0);
      expect(transport.disposeCalls, 1);
    });
""",
)

replace(
    "test/controllers/connection_manager_test.dart",
    "      test('already-connected machine is not quick-connected again', () async {\n",
    """      test(
        'quick-connect recovery block retains ownership and skips scan fallback',
        () async {
          await connectionManager.dispose();
          await settingsController.setPreferredMachineId('blocked-de1');
          mockSettingsService.setRememberedDevices(
            RememberedDevice.encodeList([
              const RememberedDevice(
                id: 'blocked-de1',
                name: 'DE1',
                type: DeviceType.machine,
                implementation: DeviceImplementation.unifiedDe1,
                transportType: TransportType.ble,
              ),
            ]),
          );
          final remembered = RememberedDevicesController(
            machineConnections: const Stream.empty(),
            scaleConnections: const Stream.empty(),
            settings: mockSettingsService,
          );
          await remembered.initialize();
          mockScanner.quickConnectError = BleConnectException(
            code: 'connectionFailed',
            description: 'RECOVERY_BLOCKED: unresolved native GATT teardown',
            function: 'connect',
          );
          connectionManager = ConnectionManager(
            deviceScanner: mockScanner,
            de1Controller: mockDe1Controller,
            scaleController: mockScaleController,
            settingsController: settingsController,
            rememberedDevices: remembered,
          );

          await connectionManager.connect();

          expect(mockScanner.quickConnectCallCount, 1);
          expect(mockScanner.scanCallCount, 0);
          expect(
            connectionManager.currentStatus.error?.kind,
            ConnectionErrorKind.machineConnectFailed,
          );
          expect(
            connectionManager.currentStatus.error?.details?['ble_description'],
            contains('RECOVERY_BLOCKED:'),
          );

          await connectionManager.connect();
          expect(mockScanner.quickConnectCallCount, 1);
          expect(mockScanner.scanCallCount, 0);
          expect(
            (await connectionManager.connectMachine(
              _FakeDe1(
                deviceId: 'BLOCKED-DE1',
                transportType: TransportType.ble,
              ),
            )).outcome,
            ConnectionOutcome.conflict,
          );

          mockScanner.mockAdapterState(AdapterState.poweredOff);
          await Future<void>.delayed(Duration.zero);
          expect(
            (await connectionManager.connectMachine(
              _FakeDe1(
                deviceId: 'blocked-de1',
                transportType: TransportType.ble,
              ),
            )).outcome,
            ConnectionOutcome.connected,
          );
          await remembered.dispose();
        },
      );

      test('cancelled adopted quick-connect marks cleanup as expected', () async {
        await connectionManager.dispose();
        await settingsController.setPreferredMachineId('pref-de1');
        mockSettingsService.setRememberedDevices(
          RememberedDevice.encodeList([
            const RememberedDevice(
              id: 'pref-de1',
              name: 'DE1',
              type: DeviceType.machine,
              implementation: DeviceImplementation.unifiedDe1,
              transportType: TransportType.ble,
            ),
          ]),
        );
        final remembered = RememberedDevicesController(
          machineConnections: const Stream.empty(),
          scaleConnections: const Stream.empty(),
          settings: mockSettingsService,
        );
        await remembered.initialize();
        final disconnectStarted = Completer<void>();
        final device = _FakeDe1(
          deviceId: 'pref-de1',
          transportType: TransportType.ble,
          disconnectStarted: disconnectStarted,
        );
        mockScanner.quickConnectResult = device;
        connectionManager = ConnectionManager(
          deviceScanner: mockScanner,
          de1Controller: mockDe1Controller,
          scaleController: mockScaleController,
          settingsController: settingsController,
          rememberedDevices: remembered,
        );

        final connecting = connectionManager.connect();
        await Future<void>.delayed(Duration.zero);
        mockScanner.mockAdapterState(AdapterState.unauthorized);
        await Future<void>.delayed(Duration.zero);
        mockDe1Controller.de1Subject.add(device);
        await disconnectStarted.future;
        await connecting;

        expect(
          connectionManager.currentStatus.error?.kind,
          ConnectionErrorKind.bluetoothPermissionDenied,
        );
        connectionManager.debugNotifyMachineDisconnected(device.deviceId);
        expect(
          connectionManager.currentStatus.error?.kind,
          ConnectionErrorKind.bluetoothPermissionDenied,
        );
        await remembered.dispose();
      });

      test('already-connected machine is not quick-connected again', () async {
""",
)

replace(
    "test/controllers/connection_manager_test.dart",
    "      test('adapter reset releases a failed BLE cleanup lease', () async {\n",
    """      test(
        'recovery-blocked BLE source retains its lease until adapter reset',
        () async {
          mockDe1Controller.failNextConnectWith = BleConnectException(
            code: 'connectionFailed',
            description: 'RECOVERY_BLOCKED: unresolved native GATT teardown',
            function: 'connect',
          );
          final machine = _FakeDe1(
            deviceId: 'blocked-source-machine',
            transportType: TransportType.ble,
          );

          expect(
            (await connectionManager.connectMachine(machine)).outcome,
            ConnectionOutcome.failed,
          );
          expect(
            (await connectionManager.connectMachine(
              _FakeDe1(
                deviceId: 'BLOCKED-SOURCE-MACHINE',
                transportType: TransportType.ble,
              ),
            )).outcome,
            ConnectionOutcome.conflict,
          );

          mockScanner.mockAdapterState(AdapterState.poweredOff);
          await Future<void>.delayed(Duration.zero);

          expect(
            (await connectionManager.connectMachine(
              _FakeDe1(
                deviceId: 'blocked-source-machine',
                transportType: TransportType.ble,
              ),
            )).outcome,
            ConnectionOutcome.connected,
          );
        },
      );

      test('adapter reset releases a failed BLE cleanup lease', () async {
""",
)

replace(
    "doc/plans/archive/871-ble-recovery/part-4-decaid-integration.md",
    "- repeated cancellation is idempotent and preserves the first owner/reason;\n",
    "- repeated cancellation is idempotent;\n",
)

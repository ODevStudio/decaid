import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:reaprime/src/controllers/connection_manager.dart';
import 'package:reaprime/src/controllers/device_controller.dart';
import 'package:reaprime/src/controllers/remembered_devices_controller.dart';
import 'package:reaprime/src/models/device/device.dart';
import 'package:reaprime/src/models/device/impl/mock_de1/mock_de1.dart';
import 'package:reaprime/src/models/device/remembered_device.dart';
import 'package:reaprime/src/models/device/transport/data_transport.dart';
import 'package:reaprime/src/settings/settings_controller.dart';

import '../helpers/mock_de1_controller.dart';
import '../helpers/mock_device_discovery_service.dart';
import '../helpers/mock_device_scanner.dart';
import '../helpers/mock_scale_controller.dart';
import '../helpers/mock_settings_service.dart';
import '../helpers/test_scale.dart';

class _TransportScale extends TestScale {
  @override
  final TransportType transportType;

  _TransportScale(this.transportType) : super(deviceId: 'preferred-scale');
}

void main() {
  for (final transport in [
    TransportType.serial,
    TransportType.wifi,
    TransportType.ble,
  ]) {
    for (final rememberedOnly in [
      if (transport != TransportType.ble) false,
      true,
    ]) {
      test(
        '${transport.name} recovery chooses the correct scan with '
        '${rememberedOnly ? "remembered" : "discovered"} transport',
        () async {
          final service = MockSettingsService();
          final settings = SettingsController(service);
          await settings.loadSettings();
          await settings.setPreferredScaleId('preferred-scale');
          await service.setRememberedDevices(
            RememberedDevice.encodeList([
              RememberedDevice(
                id: 'preferred-scale',
                name: 'Half Decent Scale',
                type: DeviceType.scale,
                transportType: transport,
              ),
            ]),
          );
          final remembered = RememberedDevicesController(
            machineConnections: const Stream.empty(),
            scaleConnections: const Stream.empty(),
            settings: service,
          );
          await remembered.initialize();
          final scanner = MockDeviceScanner()..supportsWatch = true;
          final scales = MockScaleController();
          final machines = MockDe1Controller(
            controller: DeviceController([MockDeviceDiscoveryService()]),
          );
          final machine = MockDe1();
          final scale = _TransportScale(transport);
          if (!rememberedOnly) scanner.addDevice(scale);
          final manager = ConnectionManager(
            deviceScanner: scanner,
            de1Controller: machines,
            scaleController: scales,
            settingsController: settings,
            rememberedDevices: rememberedOnly ? remembered : null,
          )..scaleReconnectBaseDelay = const Duration(milliseconds: 10);
          addTearDown(() async {
            await manager.dispose();
            await machine.disconnect();
            await remembered.dispose();
            scanner.dispose();
            scales.dispose();
            scale.dispose();
          });
          scales.debugSetLastConnectedId(scale.deviceId);
          scales.mockEmitConnectionState(ConnectionState.connected);
          machines.de1Subject.add(machine);
          await Future<void>.delayed(Duration.zero);
          expect(scanner.startWatchCallCount, 0);

          scales.mockEmitConnectionState(ConnectionState.disconnected);
          await Future<void>.delayed(Duration.zero);
          if (transport == TransportType.ble) {
            expect(scanner.startWatchCallCount, 1);
            expect(manager.scaleReconnectScheduled, isFalse);
            expect(scanner.scanCallCount, 0);
            return;
          }
          expect(scanner.startWatchCallCount, 0);
          expect(manager.scaleReconnectScheduled, isTrue);
          final scanning = scanner.scanningStream.firstWhere((value) => value);
          await scanning.timeout(const Duration(seconds: 2));
          expect(scanner.scanCallCount, 1);
          expect(scanner.startWatchCallCount, 0);
        },
      );
    }
  }
}

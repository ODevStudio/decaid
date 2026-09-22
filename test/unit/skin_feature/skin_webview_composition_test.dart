import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reaprime/src/settings/feature_flags.dart';
import 'package:reaprime/src/settings/advanced_page.dart';
import 'package:reaprime/src/settings/settings_controller.dart';
import 'package:reaprime/src/skin_feature/skin_webview_composition.dart';
import 'package:reaprime/src/skin_feature/skin_webview_diagnostics.dart';
import 'package:yaml/yaml.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../helpers/mock_settings_service.dart';

class _MountCounter extends StatefulWidget {
  final VoidCallback onMount;
  const _MountCounter({required this.onMount});

  @override
  State<_MountCounter> createState() => _MountCounterState();
}

class _MountCounterState extends State<_MountCounter> {
  @override
  void initState() {
    super.initState();
    widget.onMount();
  }

  @override
  Widget build(BuildContext context) => const SizedBox();
}

void main() {
  test('composition remains hybrid until explicitly enabled', () async {
    final service = MockSettingsService();
    final settings = SettingsController(service);
    await settings.loadSettings();
    expect(
      settings.isFeatureFlagEnabled(FeatureFlag.androidTextureLayerComposition),
      isFalse,
    );
    await settings.setFeatureFlag(
      FeatureFlag.androidTextureLayerComposition,
      true,
    );
    final reloaded = SettingsController(service);
    await reloaded.loadSettings();
    expect(
      reloaded.isFeatureFlagEnabled(FeatureFlag.androidTextureLayerComposition),
      isTrue,
    );
  });

  test('only Android switches creation settings', () {
    for (final platform in TargetPlatform.values) {
      for (final texture in [false, true]) {
        final settings = createSkinWebViewSettings(
          platform: platform,
          textureComposition: texture,
        );
        expect(
          settings.useHybridComposition,
          platform == TargetPlatform.android ? !texture : true,
        );
        expect(settings.allowUniversalAccessFromFileURLs, isFalse);
        expect(settings.allowFileAccessFromFileURLs, isFalse);
        expect(settings.useOnRenderProcessGone, isTrue);
      }
    }
  });

  for (final platform in [TargetPlatform.android, TargetPlatform.windows]) {
    testWidgets('mode changes recreate only Android views: $platform', (
      tester,
    ) async {
      final settings = SettingsController(MockSettingsService());
      var mounts = 0;
      await tester.pumpWidget(
        SkinWebViewComposition(
          settings: settings,
          platform: platform,
          builder: (context, texture) => _MountCounter(onMount: () => mounts++),
        ),
      );
      expect(mounts, 1);
      await settings.setFeatureFlag(
        FeatureFlag.androidTextureLayerComposition,
        true,
      );
      await tester.pump();
      expect(mounts, platform == TargetPlatform.android ? 2 : 1);
      await settings.setShowSkinExitInstructions(false);
      await tester.pump();
      expect(mounts, platform == TargetPlatform.android ? 2 : 1);
      await settings.setFeatureFlag(
        FeatureFlag.androidTextureLayerComposition,
        false,
      );
      await tester.pump();
      expect(mounts, platform == TargetPlatform.android ? 3 : 1);
    });
  }

  test(
    'diagnostics preserve provider and distinguish settings from actual mode',
    () async {
      final report = await readSkinRenderingDiagnostics(
        textureComposition: true,
        readProvider: () async => WebViewPackageInfo(
          packageName: 'com.android.webview',
          versionName: '91.0',
        ),
        readSdk: () async => 31,
        readSettings: () async =>
            InAppWebViewSettings(useHybridComposition: false),
      );
      expect(report['requestedMode'], 'tlhc-with-hc-fallback');
      expect(report['actualComposition'], 'not-exposed-by-plugin');
      expect(report['provider'], {
        'packageName': 'com.android.webview',
        'versionName': '91.0',
      });
      expect(report['sdk'], 31);
      expect(
        (report['effectiveSettings'] as Map)['useHybridComposition'],
        isFalse,
      );
      expect(report.containsKey('flutterVersion'), isTrue);
    },
  );

  test('failed probes do not discard remaining diagnostics', () async {
    final report = await readSkinRenderingDiagnostics(
      textureComposition: false,
      readProvider: () async => throw StateError('unavailable'),
      readSdk: () async => 31,
      readSettings: () async => null,
    );
    expect(report['requestedMode'], 'hc');
    expect(report['provider'], isNull);
    expect(report['sdk'], 31);
    expect(report['effectiveSettings'], isNull);
  });

  test('diagnostic plugin version matches the repository lockfile', () {
    final lock = loadYaml(File('pubspec.lock').readAsStringSync()) as YamlMap;
    expect(
      androidWebViewPluginVersion,
      lock['packages']['flutter_inappwebview_android']['version'],
    );
  });

  testWidgets(
    'native diagnostic selector saves an Android mode',
    (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final settings = SettingsController(MockSettingsService());
      await tester.pumpWidget(
        ShadApp(home: AdvancedPage(controller: settings)),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('HC (default)'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('TLHC (HC fallback)').last);
      await tester.pumpAndSettle();
      expect(
        settings.isFeatureFlagEnabled(
          FeatureFlag.androidTextureLayerComposition,
        ),
        isTrue,
      );
      expect(tester.takeException(), isNull);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.android),
  );
}

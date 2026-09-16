# #871 part 5/5: BLE recovery acceptance package

- Issue: #877
- Parent: #871
- Date: 2026-09-15
- Decision gate: #875 remains open

## Outcome

The narrow Android direct-connect admission and exact-GATT lifecycle design is
the retained candidate. Host and deterministic software evidence supports its
ownership invariants, but does not establish the field root cause or prove
affected-device recovery. The required Android 10/Teclast tablet, DE1, and
original full-height Decent Scale are unavailable. Every physical result below
is `NOT RUN`; #871, #875, and #877 remain open.

The candidate is reproducibly pinned to published `universal_ble` PR #28 head
`895aa687a25c99b17c81e8672cac7de051551ded` in both Decaid dependency files.
Native Android unit tests passed in CI. A candidate Decaid Android app build
and the physical acceptance matrix remain unrun.

## Review result

No known deterministic-test correctness defect remains in the reviewed A
through D software diffs. The Decaid correction reuses controller and `ScaleWatch`
generation fences and adds only one device-id lease owner. Unused diagnostic,
cancellation-reason, and monotonic-generation state was removed. No second
watch pause layer, app-global scheduler, global GATT command queue, or new
dependency was retained.

This result is limited to review, deterministic host tests, and native Android
CI tests. Candidate Decaid Android app compilation and physical acceptance
remain open gates. The Linux app compile, package, and launch smoke passed.

## Immutable revisions

| Component | Baseline or inspected revision | Reviewed candidate |
| --- | --- | --- |
| Decaid main | `f181612dacf47fa58d2eb3dac6f8aab343946f5a` | tested D merge parent |
| Baseline and diagnostics | PR #878 runtime head `2484d04aefdfa6134344571eb7aeb3f71535d73c`; docs-only archive follow-up `b53d4ba650f1dc15d073b7d728f679ae3db3d142` | follow-up CI run `35115385053` |
| Native admission | fork baseline `16bbfbce197eb5913c6b16578363f7dc943e605d` | PR #25 head `a5cc8dd727a2f7da6822eccdc968038839fe0bb9` |
| Native lifecycle | PR #28 head `895aa687a25c99b17c81e8672cac7de051551ded` | tested merge `e3ddd73beab1bfb1447abb65fad44438239936e6`; CI run `35108117215` |
| Decaid integration | PR #881 head `88e5d9b492f837eab4471f8451f917123737068e` | tested merge `9d37d7f379b390fa88538113927690ef2ffd807e`; CI run `35112700192` |
| Combined A+D verification | isolated merge `cb57a614f046949323a570be00034893fe798e2a` with parents D `88e5d9b492f837eab4471f8451f917123737068e` and A `b53d4ba650f1dc15d073b7d728f679ae3db3d142` | tree `ea9d0f3586f462857e013e85c73bb9408a07be1f`; final C pin `895aa687a25c99b17c81e8672cac7de051551ded` |
| `flutter_js` | `d6e8849210c0081d19c78be97628947e6e2976e2` | unchanged |

Host verification used Windows x64, Flutter 3.44.8, Dart 3.12.2, Gradle
8.14.3, Kotlin 2.3.21, compile SDK 36, target SDK 35, and minimum SDK 28.
Earlier pre-final Android startup probes used both Temurin JDK 17.0.17 and
Android Studio's JetBrains JBR 21.0.8. CI uses Flutter 3.44.2; host results are
not substituted for CI or Android hardware results.

## Software evidence

| Block | Result | Limits |
| --- | --- | --- |
| A: Decaid baseline/diagnostics | Docs-only final-head CI run `35115385053` passed format, analysis, the Linux build smoke, and the full Flutter suite with 4,298 visible passes and one skip; runtime code is unchanged from tested parent `2484d04aefdfa6134344571eb7aeb3f71535d73c` | No affected hardware |
| B: native admission | Implemented and host-verified: analyze clean; host Flutter suite 136 passed with 13 platform skips | Inspected-head CI is green; affected hardware is unverified |
| C: native lifecycle | Final head passed analysis and 136 host Flutter tests with 13 platform skips; CI run `35108117215` passed the native Android helper/plugin tests | Host Flutter tests do not validate Kotlin; affected hardware is unverified |
| D: Decaid integration | Final-head CI run `35112700192` passed format, analysis, the Linux app compile/package/launch smoke, and 4,315 visible Flutter tests with one skip; the local Windows run passed 4,314 with one skip | Candidate Decaid Android app build and affected hardware are unverified; CMake 3.28 and private Microsoft-signed NuGet 7.9 compiled an earlier pre-final Windows candidate revision until `universal_ble_plugin.dll` failed to link with unresolved MSVC `std::bad_cast` symbols, so the simulated REST smoke did not run |
| Final A+D combination | Isolated merge passed analysis, 4 focused diagnostic tests, 252 focused connection tests, and the full Windows suite with 4,317 visible passes and one skip | No integration code changes; affected hardware remains unverified |

The combined run used Flutter 3.44.8 and Dart 3.12.2. Its clean committed tree
retains final C in both dependency files. Local `pub get` adjusted five
Flutter-SDK-pinned transitive packages without changing that C ref. The exact
resolved lock is retained as `pubspec.resolved-flutter-3.44.8.lock` (SHA-256
`E53F5E9F49DFD68052DC2CFF5B1FE73D7DE7C6BBE068646DE7E3E1578E5C27A5`) and
the dependency graph as `pub-deps-flutter-3.44.8.json` (SHA-256
`0C5692596C641B0A13212590A85A0CA76BDF3C2F179274B388FE47264CA8305D`). Raw
results are `focused-diagnostics.ndjson`, `focused-connection.ndjson`, and
`full-tests-green.ndjson` in the combined evidence directory.

The local Dart 3.12.2 format check reported ten pre-existing formatter
differences. Both final PR CI heads pass their Flutter 3.44.2 format checks, so
the verification branch leaves those unrelated files unchanged.

The earlier bounded JDK 17 selector probe failed after setting a short
process-scoped `jdk.net.unixdomain.tmpdir`, reaching
`UnixDomainSockets.connect0` with
`Invalid argument: connect`. Android Studio's materially different JetBrains
JBR 21.0.8 also failed in the current environment during both the initial
`gradle help --no-daemon` invocation and an independent `Selector.open()`
probe.

Before final C publication, one follow-up comparison used its predecessor
worktree, cached Gradle 8.14.3, Studio JBR 21, the normal persistent-daemon
path, and only the prior Kotlin settings as per-invocation properties:

```powershell
$env:JAVA_HOME='C:\Program Files\Android\Android Studio\jbr'
$env:ANDROID_HOME='C:\AndroidSDK'
$env:ANDROID_SDK_ROOT='C:\AndroidSDK'
& 'C:\Users\El Fuzzi\.gradle\wrapper\dists\gradle-8.14.3-bin\cv11ve7ro1n3o1j4so8xd9n66\gradle-8.14.3\bin\gradle.bat' `
  :universal_ble:testDebugUnitTest `
  -Pkotlin.incremental=false `
  -Pkotlin.compiler.execution.strategy=in-process `
  --stacktrace --info
```

No Java process was active before the command. Gradle started daemon PID 22264
with a three-hour idle timeout, advertised `localhost/127.0.0.1:55320`, and
accepted the client connection. The client and daemon then failed while
constructing the connection stream because `Selector.open()` could not
establish its internal loopback pipe. The daemon exited, project configuration
was not reached, and the native test task did not execute. Per the bounded stop
condition, that earlier integrated candidate build was not attempted. Raw
client and daemon output is retained in `android-normal-daemon-c-native-tests.txt` and
`android-normal-daemon-22264.log`.

These failures describe only the tested invocations in the current process
environment. They do not show that this host or tablet cannot build or test
Android. Local Decaid builds and ADB tablet runs succeeded in August 2026 with
the same Android Studio JBR 21 and a persistent Gradle daemon, including
`flutter run --profile -d R9TX60JBR5T --dart-define=simulate=replay`. The prior
artifacts use production application ID `net.tadel.reaprime`, do not contain
the final issue #871 candidate, and were not installed. Comparison details
are retained in `android-prior-workflow-comparison.txt`.

## Fixed comparison contract

Baseline and candidate must use identical current scale behavior:
`displayOff` sends shared `0A 00` and preserves a healthy original-scale link.
Explicit disconnect power mode is a separate scenario. The only A/B dependency
variable is published baseline `universal_ble`
`16bbfbce197eb5913c6b16578363f7dc943e605d` versus published candidate
`895aa687a25c99b17c81e8672cac7de051551ded`.

For each recovery episode, record peripheral availability and fresh adverts;
request, admission, native callback, and protocol-ready timestamps; native
status; attempts per device; queue state; healthy-peer notification gaps; and
GATT create/close counts. Report count, median, p95, maximum, and failures.

Pass criteria are fixed before execution:

- Every available peer regains protocol readiness within 120 seconds.
- Each device starts at most three new native attempts after availability.
- Repairing one peer causes zero application-initiated teardown of the healthy
  peer.
- The healthy-peer notification gap stays below the larger of five seconds or
  ten times its baseline p95 valid inter-notification interval.
- Cancelled attempts cause zero late adoption or replacement teardown.
- Client, listener, and pending-task counts show zero progressive growth after
  quiescence.
- No supported scenario requires app restart, adapter reset, bond removal, or
  forgetting a device.

## Physical matrix

| Scenario | Fixed coverage | Required observation | Status |
| --- | --- | --- | --- |
| Long-running dual connection | 8 hours per build | Both protocol streams remain usable; compare dropouts and native clients | `NOT RUN` |
| `displayOff` sleep/wake | 50 cycles per build | Display changes without intentional reconnect; wake and weighing work | `NOT RUN` |
| Explicit disconnect power mode | 20 cycles per build | Disconnect is respected and eligible wake reconnects | `NOT RUN` |
| Scale loss, healthy DE1 | 20 cycles per build | DE1 remains usable and scale recovery meets targets | `NOT RUN` |
| DE1 loss, healthy scale | 20 cycles per build | Scale remains usable and machine recovery meets targets | `NOT RUN` |
| Dual loss, scale first | 10 cycles per build | No overlap storm; both regain protocol readiness | `NOT RUN` |
| Dual loss, DE1 first | 10 cycles per build | No overlap storm; both regain protocol readiness | `NOT RUN` |
| One peripheral unavailable | 20 cycles per device/build | Available peer is not starved; callers remain bounded | `NOT RUN` |
| Real operation/connect GATT 133 | Every observed event | Preserve raw status and apply bounded matching recovery | `NOT RUN` |
| Cancel queued, active, cooldown | 20 cycles per phase/build | No late native connection or adoption | `NOT RUN` |
| Adapter off/on and screen transitions | 20 cycles per transition/build | No stale epoch, dead watch, leak, or healthy-peer teardown | `NOT RUN` |

Injected callbacks and mocked 133 faults remain software evidence and must be
reported separately from a real controller/radio failure.

## Supplemental inventory

| Target | Observation | Coverage |
| --- | --- | --- |
| Samsung `SM-X210` tablet | Read-only ADB inventory: Android 16 / SDK 36, build `BP2A.250605.031.A3`, existing `net.tadel.reaprime` version `1.0.0` build 2735 | Inventory only; the running Decaid app was not stopped, launched, changed, or replaced, and no candidate APK was installed |
| Windows Android toolchain | Android Studio `AI-252.27397.103.2522.14514259`, bundled JetBrains JBR 21.0.8, SDK 36.1.0 at `C:/AndroidSDK` | Toolchain inventory and bounded current-invocation failures only; the normal-daemon comparison did not reach Gradle project configuration, while prior same-JBR local builds and ADB runs succeeded |
| COM5 HDS USB | `USB-SERIAL CH340K`, WCH, VID/PID `1A86:7522`, revision `0264`; one 12-second passive 115200 8N1 capture received 424 bytes, including 12 ASCII `Weight: 0.00` samples and two health lines | `HARDWARE/TRANSPORT BASELINE`, not candidate app or Android BLE acceptance; no bytes were written, firmware was not reported, reconnect was not exercised, and the port was closed and disposed |

The tablet is not the affected Android 10/Teclast target and provides no BLE,
DE1, original-scale, or candidate-build acceptance evidence. COM5 proves only
that the host can open the HDS USB transport and receive passive scale output.
No existing Windows runner could exercise `SerialServiceDesktop` without a
working build of the earlier Windows candidate revision, so the HDS
enable/readiness path and app-owned reconnect remain unverified. Raw serial
evidence is
`com5-hds-passive-baseline.txt` in the evidence directory.

## Capture and support checklist

Use this checklist only for a coordinated test build on a designated test
device. Confirm the test-device serial and an isolated candidate application ID
before capture. Do not target or replace the protected running installation.

1. Record Decaid and fork commits, resolved lockfile refs, tablet model, Android
   build fingerprint, DE1 firmware, scale firmware, power mode, foreground
   state, screen state, and whether both devices reached protocol readiness.
2. Start a read-only live native-log capture before the coordinated run, stop
   it after the bounded run, and do not clear tablet-wide logcat:

   ```powershell
   $serial='<designated-test-serial>'
   $appId='<verified-isolated-candidate-app-id>'
   adb -s $serial logcat -v threadtime -T 1 > native-logcat.txt
   ```

3. Save Decaid logs through the in-app Export logs action or, on a debuggable
   build, with:

   ```powershell
   adb -s $serial shell run-as $appId cat app_flutter/log.txt > decaid-log.txt
   ```

4. Capture `GET /api/v1/diagnostics/ble` before the run, at every failure, and
   after quiescence. Native `UniversalBle` logcat is separate and is not assumed
   to be present in the Dart log or feedback upload.
5. Mark actual peripheral availability separately from cached discovery.
   Correlate device identifiers consistently, then redact account credentials,
   API tokens, unrelated network data, and unrelated device identifiers before
   sharing.
6. Attach the raw logs, matrix row, iteration number, timestamps, and observed
   result. Do not summarize a missing callback, 133, or timeout as the same
   failure class without the native evidence.

## Rollback package

No candidate release should be made while the physical matrix is unrun. If a
later candidate build must be rolled back:

1. Stop rollout and retain the failing build, its exact lockfile, app logs,
   native logcat, and BLE diagnostic snapshots.
2. Restore only the `universal_ble` manifest ref to
   `16bbfbce197eb5913c6b16578363f7dc943e605d`, regenerate the lockfile with the
   repository Flutter toolchain, and verify both `ref` and `resolved-ref`.
3. Revert the Decaid attempt-retirement change only if evidence implicates it.
   Preserve the current original-scale/HDS protocol and `displayOff` fixes.
4. Verify the focused connection tests, analysis, full Flutter suite, and an
   Android build before distributing the rollback.
5. Repeat the failed matrix row on the same affected hardware. A restored pin
   is not proof of restored field behavior without that check.

The candidate deliberately adds no adapter toggle, bond removal, cache refresh,
global GATT command queue, notification heartbeat, or `dart_js` change. Android
force-stop or process death can still skip Dart cleanup. Other apps, other
plugin instances, OS-managed `autoConnect`, and temporary service-discovery
GATT clients remain outside the direct-admission guarantee.

## Sign-off state

- Prerequisite software reviews: final A through D heads are reviewed and their
  recorded CI runs are green.
- Final A+D combination: isolated merge passed focused diagnostics, focused
  connection suites, analysis, and the full Flutter suite without code changes.
- Native Android helper/plugin tests: passed in CI run `35108117215`; host
  Flutter tests do not validate Kotlin.
- Candidate Decaid Android app compilation: unverified; bounded JDK 17 and JBR
  21 invocations against earlier candidate revisions failed at
  `Selector.open()` before Gradle project configuration, while prior same-JBR
  local builds and ADB tablet runs succeeded.
- Exact candidate dependency pin: satisfied at published PR #28 head
  `895aa687a25c99b17c81e8672cac7de051551ded`.
- Affected-device matrix: `NOT RUN`.
- Maintainer hardware sign-off: pending.
- #871, #875, and #877: remain open.

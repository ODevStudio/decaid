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
Native Android unit tests passed in CI. A side-by-side Android APK was built
from the combined source plus a temporary simulation-isolation overlay and was
run on a supplemental Samsung tablet. That modified overlay is not the
published production-source candidate. A subsequent direct verification built
the unmodified published #881 application source as a release APK. Physical
BLE acceptance remains unrun; supplemental HDS USB results are recorded below.

## Review result

No known deterministic-test correctness defect remains in the reviewed A
through D software diffs. The Decaid correction reuses controller and `ScaleWatch`
generation fences and adds only one device-id lease owner. Unused diagnostic,
cancellation-reason, and monotonic-generation state was removed. No second
watch pause layer, app-global scheduler, global GATT command queue, or new
dependency was retained.

This result is limited to review, deterministic host tests, native Android CI
tests, and the explicitly supplemental runtime checks below. Published-source
Android compilation now passes, but physical acceptance
remains an open gate. The Linux app compile, package, and launch smoke passed.

## Immutable revisions

| Component | Baseline or inspected revision | Reviewed candidate |
| --- | --- | --- |
| Decaid main | `f181612dacf47fa58d2eb3dac6f8aab343946f5a` | tested D merge parent |
| Baseline and diagnostics | PR #878 runtime head `2484d04aefdfa6134344571eb7aeb3f71535d73c`; docs-only archive follow-up `b53d4ba650f1dc15d073b7d728f679ae3db3d142` | follow-up CI run `35115385053` |
| Native admission | fork baseline `16bbfbce197eb5913c6b16578363f7dc943e605d` | PR #25 head `a5cc8dd727a2f7da6822eccdc968038839fe0bb9` |
| Native lifecycle | PR #28 head `895aa687a25c99b17c81e8672cac7de051551ded` | tested merge `e3ddd73beab1bfb1447abb65fad44438239936e6`; CI run `35108117215` |
| Decaid integration | PR #881 head `88e5d9b492f837eab4471f8451f917123737068e` | tested merge `9d37d7f379b390fa88538113927690ef2ffd807e`; CI run `35112700192` |
| Combined A+D verification | isolated merge `cb57a614f046949323a570be00034893fe798e2a` with parents D `88e5d9b492f837eab4471f8451f917123737068e` and A `b53d4ba650f1dc15d073b7d728f679ae3db3d142` | tree `ea9d0f3586f462857e013e85c73bb9408a07be1f`; final C pin `895aa687a25c99b17c81e8672cac7de051551ded` |
| Supplemental Android simulation overlay R2 | combined source `cb57a614f046949323a570be00034893fe798e2a`; uncommitted isolation patch SHA-256 `E6DC3962F58FB7F186F31E90FD065A44F48919C909822E27C31863227C798B54` | isolated package `net.tadel.reaprime.issue871candidate`; APK SHA-256 `A80A5C75B41D6AC23D5B5FF6D27B23B1C1E700E7802DF9E4C6C5D6E22F95D2FC`; resolved lock SHA-256 `E53F5E9F49DFD68052DC2CFF5B1FE73D7DE7C6BBE068646DE7E3E1578E5C27A5`; reported build time `2026-09-16T17:50:48Z` |
| Supplemental Android simulation overlay R3 | combined source `cb57a614f046949323a570be00034893fe798e2a`; local unpublished MockScale fix `65b9681427c4dd5eed0f29e61cc1c55c3e9eb574`, pending separate publication permission; uncommitted isolation patch SHA-256 `758EAAB735B7F73A00A32DBCAD4799E8510D7456A794A7981E3C49BF3F2A6016` | isolated package `net.tadel.reaprime.issue871candidate`; APK SHA-256 `58DD087785934E3BF3A1866786B308D73B454224953A69AF4F94A72E8C967111`; resolved lock SHA-256 `E53F5E9F49DFD68052DC2CFF5B1FE73D7DE7C6BBE068646DE7E3E1578E5C27A5`; reported build time `2026-09-16T18:40:41Z` |
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
| D: Decaid integration | Final-head CI run `35112700192` passed format, analysis, the Linux app compile/package/launch smoke, and 4,315 visible Flutter tests with one skip; the local Windows run passed 4,314 with one skip. Direct published-source Android release compilation also passed as recorded below. | Affected hardware remains unverified; CMake 3.28 and private Microsoft-signed NuGet 7.9 compiled an earlier pre-final Windows candidate revision until `universal_ble_plugin.dll` failed to link with unresolved MSVC `std::bad_cast` symbols, so the desktop simulated REST smoke did not run |
| Final A+D combination | Isolated merge passed analysis, 4 focused diagnostic tests, 252 focused connection tests, and the full Windows suite with 4,317 visible passes and one skip | No integration code changes; affected hardware remains unverified |
| Supplemental Android simulation overlay R2 | APK build, signing, manifest inspection, analysis, the foreground-service test, and the targeted initialization test passed. The targeted TLS plugin tests passed when native QuickJS and Git OpenSSL were on process-local `PATH`. On Samsung `SM-X210` / Android 16, the native launcher and candidate API exposed `MockDe1` and `Mock Scale`; the first connection cycle produced usable machine and scale snapshots. | The overlay changes startup, ports, application ID, and hardware-service isolation and will not be published. Its full suite was not green: 4,306 passed, one skipped, and four failed. One TLS setup failure was environmental and passed in the targeted rerun; three assertions retain production ports `4001`/`8080` while the overlay uses `14001`/`18080`. A second same-process mock reconnect restored connected state and machine snapshots but not scale weight frames. |
| Supplemental Android simulation overlay R3 | The focused MockScale regression passed 7 tests, analysis was clean, and the rebuilt APK passed signing and package-identity inspection. On the same Samsung tablet, two same-process MockDe1 and MockScale connect/readiness cycles each produced connected inventory, an idle machine snapshot, connected scale status, and a newly received weight frame. | The R3 overlay adds the local unpublished mock-only reconnect fix to R2, pending separate publication permission. It changes startup isolation and provides no physical BLE, DE1, original-scale, HDS, or affected-device evidence. |

## Supplemental Android simulation overlay

R2 and R3 used `simulate=1` and skipped physical BLE, serial/USB, Wi-Fi-scale
discovery, multicast lock, and Android foreground-service startup. Production
package `net.tadel.reaprime` stayed running as PID `10742`; the isolated
candidate used a separate package and API forward. No skin or plugin UI was
opened. The overlay's missing `ACCESS_NETWORK_STATE` produced nonfatal
network-info exceptions with localhost fallback, and its unused WebUI tried to
bind the production-owned port `3000`. Those are overlay limitations and were
not chased with permission or production changes.

The first bounded cycle connected `MockDe1`; preferred `MockScale` connected in
the same scan. `GET /api/v1/devices` reported both connected,
`GET /api/v1/machine/state` returned an idle machine snapshot, and
`ws/v1/scale/snapshot` returned `{"status":"connected"}` followed by a weight
frame with weight `0.0`, flow `0.0`, and battery `100`. Native UI showed
`MockDe1 · idle` and `Mock Scale`. Candidate-only disconnect then reported both
devices disconnected, the machine-state endpoint returned 500 as documented,
and the scale socket returned `{"status":"disconnected"}`.

In R2, the second connection cycle did not satisfy the two-success threshold.
`MockDe1` returned `connected`; `MockScale` returned `alreadyConnected`; the
device API and native UI showed both connected; and the machine endpoint again
returned a usable idle snapshot. The scale socket returned only
`{"status":"connected"}` and no weight frame within eight seconds. Source
inspection explains the simulation-only result: `MockScale.simulateDisconnect`
cancels its emission timer and sets `_stalled`, while `onConnect` only publishes
connected state. No runtime fix was added to the acceptance branch. This is a
mock reconnect defect, not evidence about physical BLE recovery or HDS
hardware.

The focused main-based fix at
`65b9681427c4dd5eed0f29e61cc1c55c3e9eb574` restarts MockScale emission only
when reconnecting without an active timer. It is local and unpublished pending
separate publication permission. Its regression failed before the fix, passed
afterward, and the full main-based suite passed 4,295 tests with one skip. R3
applied that reviewed diff to the uncommitted isolation overlay. Both
bounded same-process cycles then reported `MockDe1` and `MockScale` connected,
returned usable idle machine state, and produced `{"status":"connected"}` plus
a newly received weight frame. Between cycles both devices reported
disconnected, machine state returned the documented 500, and the scale socket
reported `{"status":"disconnected"}`. The candidate was stopped, its `18080`
ADB forward was removed, and production remained PID `10742`.

Retained runtime evidence includes `candidate-r2-reconnect-app-log.txt`
(SHA-256 `FD5D6C1E9011524F6D7ABC0708FD3CBA7721AF4468725576DE4057030C2ABABC`),
`candidate-r2-reconnect-logcat.txt` (SHA-256
`1C32EC87E4C27FC368C32DEED427AC1710310A9C5FC300899157BD63DA2A7B05`), and
the connected native screenshots `candidate-r2-cycle1-connected.png` and
`candidate-r2-cycle2-connected.png` (SHA-256
`F086686D9A62490B5D5A7D7E2B63052EE0A00CFE0B338E1C4AA8ED75A51E6AF5` and
`98EF759823B4AD92C614FFFC1BE08E7228E708794E2EED630F2EF9814FBC0389`).
R3's raw API/WebSocket exchange is retained verbatim from command-output chunks
`998c12`, `1ddcb3`, `355f6f`, `9100c4`, `89e165`, and `b23845` as
`candidate-r3-two-cycle-api-ws-transcript.txt` (SHA-256
`C2EE7C738223318E626AAE2D99AF30F33B95C49EB66809447F5F74EFB154E864`).
Additional R3 evidence includes `candidate-r3-reconnect-app-log.txt` (SHA-256
`A3A3CD21A9CA53D22F18978F25222CA6F32AFCFAEF51BF00FB7797B296DF1272`),
`candidate-r3-reconnect-logcat.txt` (SHA-256
`1F68379BCEDBE5790014CA0D4DFB317C6725201E67696EFE27FD69CC0742D3A4`), and
`candidate-r3-cycle2-connected.png` (SHA-256
`1BDA80FB3DB51F627ADA75DF88801433795664A807FBE8ECD46407C01613C40B`).

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

## Direct verification follow-up, 2026-09-16

These checks extend the earlier compilation and USB evidence without changing
the fixed BLE acceptance criteria.

### Published-source Android compilation

Unmodified tracked application source at #881 head
`88e5d9b492f837eab4471f8451f917123737068e` compiled successfully using
`flutter build apk --release --no-pub`, without a `simulate` define or startup,
foreground-service, permission, package-ID, or transport changes. The final
native dependency resolved to the clean cached checkout
`895aa687a25c99b17c81e8672cac7de051551ded`. Gradle completed in 321.6 seconds.
APK SHA-256:
`868E9FED89DA884226719231FAEBB294C446985675C4C8C21E9994FF37944153`.
APK signature verification passed; package inspection confirmed
`net.tadel.reaprime`, minimum SDK 28, target SDK 35, and BLE permissions.
This APK was not installed, protecting the existing application.

This is compilation evidence, not a distributable release or runtime test.
It uses local debug signing and the existing CI-style bundled-skin stub;
no skin was exercised. Flutter 3.44.8/Dart 3.12.2 used SDK-compatible resolved
versions intl 0.20.2, matcher 0.12.19, meta 1.18.0, test_api 0.7.11, and
vector_math 2.2.0, rather than the five versions in the committed lockfile.
The actual package configuration and dependency graph were retained. Flutter
selected Android Studio JBR 21 for Gradle, despite the command environment's
JDK 17 `JAVA_HOME`. The process-local selector fallback was
`-Djdk.net.unixdomain.tmpdir=Z:\issue871-nonexistent`.

Raw evidence: `production-d-android-build.txt` (SHA-256
`6922C8D19C599FAA5DE971F4FAAF512C698955A584C9DBAF75014542956D6E6F`),
`production-d-package-config.json`, `production-d-deps.json`,
`production-d-badging.txt`, and `production-d-88e5d9b.apk` in the evidence
directory. Earlier Android environment failures are historical observations,
not the status of the final candidate compilation.

### Powered HDS USB connection cycles

After the user confirmed HDS power, the existing hash-verified native Windows
harness ran against the same COM5 PnP identity. It calls the candidate
`HDSSerial.onConnect`, not a simulated scale. Two connect/read/disconnect cycles
passed, each writing only the documented `03 20 01 01` readiness request.
The production parser reported 32 and 38 valid weight frames respectively,
zero invalid frames, and zero checksum failures. Both cycles reached connected
state, received weights, then disconnected; the harness exited successfully
and released the port. All observed weights were 0.0, so changing-load response
and measurement accuracy were not tested. Frames arrived in batches; 20
callback samples are not 20 independently timed USB arrivals.

Raw evidence: `hds-direct-confirmed-power.txt`, SHA-256
`AB6BD76A706AD67E88EA683A8CAB3BD6FCB64B59F558771785C6432A2F0438DD`.
The executable hash matched the previously retained harness provenance.
This supersedes the previous power-confirmation gate, not the earlier timeout
observations. It is a real USB/protocol smoke test, not Android BLE recovery,
an app-owned desktop discovery test, or a completed physical matrix row.

The user also made the Samsung tablet and Bengle available. Bengle normal
application connection applies defaults and uploads the selected workflow
profile. That connection remains pending explicit approval of these effects;
the protected Decaid installation has not been changed.

### Separate hardware candidate startup

A new local-only candidate based on combined A+D `cb57a614` built, installed,
and cold-launched successfully on the Samsung. Unlike R2/R3, it retains the
original main/startup, foreground-service, Bluetooth permission, discovery,
and transport code, and does not include the unpublished MockScale fix.
Its isolation changes are the application ID/label and matching Google
package configuration, plus API/docs/WebUI ports 18081/14002/13001. It uses
the existing `simulate=0` real-hardware debug mode, which creates no simulated
devices and disables Dart Firebase/telemetry initialization. This is still a
modified debug candidate, not the unmodified release APK above.

Analysis passed after staging the existing plugin bundles and CI-style skin
stub. The initial analysis and first build reported missing bundle directories;
the final build completed without those errors. Candidate API devices and BLE
diagnostics returned HTTP 200. Inventory was empty and diagnostics showed no
active scan/watch or connection. Onboarding and peripheral connection were
not advanced, so foreground-service operation and BLE readiness are not yet
validated. No skin was opened. The candidate was stopped and its sole ADB
forward removed. Production was already not running at preflight; it was not
started or stopped. Its installed code path, version 2735, and update time
were unchanged afterward.

Package: `net.tadel.reaprime.issue871hardware`. APK SHA-256:
`0E9A74192410B7876C13426372A1D1ADBAAF76AD6AC4B237A5BB514D25CAAC87`.
Unpublished isolation patch including resolved-lock changes SHA-256:
`4053A064EDB7A5BD23FAB9660D73E8FF2CCE4C6857C58A87AD562CAB8F2625CA`.
Raw evidence uses the `hardware-direct-*` prefix in the same evidence
directory. The app remains installed separately for the approved hardware run.

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
| Samsung `SM-X210` tablet | Android 16 / SDK 36, build `BP2A.250605.031.A3`; isolated R2 and R3 packages installed and run beside existing `net.tadel.reaprime` version `1.0.0` build 2735 | Supplemental simulation only. R2 exposed the mock-scale reconnect defect; R3 passed two same-process mock machine/scale readiness cycles after the reviewed fix. Production remained PID `10742` and was not stopped, launched, changed, or replaced. No physical BLE was started. |
| Windows Android toolchain | Android Studio `AI-252.27397.103.2522.14514259`, bundled JetBrains JBR 21.0.8, Temurin JDK 17.0.17, SDK 36.1.0 at `C:/AndroidSDK` | R2 and R3 isolation-overlay APK builds succeeded with Flutter 3.44.8, JDK 17, Gradle 8.14.3, and the recorded process-local selector fallback. Earlier bounded JDK 17 and JBR 21 startup failures at `Selector.open()` remain retained as historical environment provenance. |
| COM5 HDS USB | `USB-SERIAL CH340K`, WCH, VID/PID `1A86:7522`, revision `0264`; passive 115200 8N1 capture received ASCII `Weight:` and `[health]` output. Two later bounded readiness attempts wrote complete `03 20 01 01` requests after subscribing, drained synchronously, received zero bytes, timed out after two seconds, and released the port. | Harness and desktop transport match on endpoint, 115200 8N1, flow control off, DTR/RTS off, subscription-before-write, and raw-byte routing. The passive stream contained no framed `03 CE` HDS packets. Local scale power/responding state was not independently confirmed during the active attempts, so this is not a hardware-silence conclusion and no further serial retry is authorized without that confirmation. Harness SHA-256: `18414C5E7CDBA809C0231E6F6D82F9948966893196302D82A77919459CDA385C`; provenance SHA-256: `CB3971D116D5F500F504C183A1460E223E24AAEE3A019AFEC4CB4056D7D2A7D6`. |

The tablet is not the affected Android 10/Teclast target and provides no BLE,
DE1, or original-scale acceptance evidence. The later direct COM5 run above
adds two powered HDSSerial connection cycles to the passive observations.
No existing Windows runner could exercise `SerialServiceDesktop` without a
working build of the earlier Windows candidate revision, so app-owned HDS
reconnect remains unverified. Raw serial evidence includes
`com5-hds-passive-baseline.txt`, `hds-hardware-smoke.dart`, and
`hds-hardware-smoke-provenance.txt` in the evidence directory.

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
- Candidate Decaid Android app compilation: direct release compilation of
  unmodified #881 application source passed, with the toolchain, resolved
  dependencies, signing, and bundled-skin qualifications recorded above.
  The production-ID APK was not installed. R2/R3 remain separate simulation
  overlay results, not production-source runtime evidence.
- Supplemental runtime: R2 exposed missing mock-scale emission after reconnect.
  R3 passed the requested two same-process mock machine/scale readiness cycles
  after the focused fix. This does not close a physical acceptance row.
- Exact candidate dependency pin: satisfied at published PR #28 head
  `895aa687a25c99b17c81e8672cac7de051551ded`.
- Affected-device matrix: `NOT RUN`.
- Maintainer hardware sign-off: pending.
- #871, #875, and #877: remain open.

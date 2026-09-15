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

The candidate cannot yet be built reproducibly from the Decaid dependency pin.
The corrected fork tree exists only as local commit
`546d55bbaef7f750c570b88d8c797299fc01335a`. Decaid therefore remains pinned to
published baseline `16bbfbce197eb5913c6b16578363f7dc943e605d` rather than a
non-fetchable commit or the uncorrected PR #28 head.

## Review result

No unresolved correctness defect remains in the locally reviewed A through D
software diffs. The Decaid correction reuses controller and `ScaleWatch`
generation fences and adds only one device-id lease owner. Unused diagnostic,
cancellation-reason, and monotonic-generation state was removed. No second
watch pause layer, app-global scheduler, global GATT command queue, or new
dependency was retained.

This result is limited to review and deterministic host tests. Dependency
publication, Android compilation, and physical acceptance remain open gates.

## Immutable revisions

| Component | Baseline or inspected revision | Reviewed candidate |
| --- | --- | --- |
| Decaid main | `4d522443aaa4dc6470dcf56e9df61c4426fbeaf6` | same base |
| Baseline and diagnostics | PR #878 `dae28ac16a30a221f65e7a9216317e15f57d7f86` | local correction `4540b730d20a23f4c80321337a1c28bac072420c` |
| Native admission | fork baseline `16bbfbce197eb5913c6b16578363f7dc943e605d` | PR #25 `f61b5666e8b3542a043b2f0da8056b70d97da0df` |
| Native lifecycle | PR #28 `1dca59494a684dbb6007e3b2819e7e11ee0ae987` | local correction `546d55bbaef7f750c570b88d8c797299fc01335a` |
| Decaid integration | PR #881 `c9a22221dd08f9f42f261d9b628fa7d782ed3f23` | local correction `bd437c99a9bbfd5a011687d55e4e193060f3770c` |
| `flutter_js` | `d6e8849210c0081d19c78be97628947e6e2976e2` | unchanged |

Host verification used Windows x64, Flutter 3.44.8, Dart 3.12.2, Temurin JDK
17.0.17, Gradle 8.14.3, Kotlin 2.3.21, compile SDK 36, target SDK 35, and minimum
SDK 28. CI uses Flutter 3.44.2; host results are not substituted for CI or
Android hardware results.

## Software evidence

| Block | Result | Limits |
| --- | --- | --- |
| A: Decaid baseline/diagnostics | Analyze clean; focused tests 5/5 and 4/4; full Flutter suite 4,255 passed with one skip | No affected hardware |
| B: native admission | Analyze clean; host Flutter suite 136 passed with 13 platform skips | Android Gradle failed before configuration with loopback error; inspected-head CI is green |
| C: native lifecycle | Analyze clean; host Flutter suite 136 passed with 13 platform skips | Android Gradle failed before configuration; CI covers the uncorrected PR head, not local correction |
| D: Decaid integration | Analyze clean; focused suites 212 and 59 passed; full Flutter suite 4,268 passed with one skip | Android debug build failed before configuration with loopback error |

The repeated Android build error was
`java.io.IOException: Unable to establish loopback connection`. It was not
retried in the unchanged environment and is not reported as Android
compilation evidence.

## Fixed comparison contract

Baseline and candidate must use identical current scale behavior:
`displayOff` sends shared `0A 00` and preserves a healthy original-scale link.
Explicit disconnect power mode is a separate scenario. The only A/B dependency
variable is published baseline `universal_ble`
`16bbfbce197eb5913c6b16578363f7dc943e605d` versus the final published form of
candidate `546d55bbaef7f750c570b88d8c797299fc01335a`.

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

## Capture and support checklist

1. Record Decaid and fork commits, resolved lockfile refs, tablet model, Android
   build fingerprint, DE1 firmware, scale firmware, power mode, foreground
   state, screen state, and whether both devices reached protocol readiness.
2. Clear logcat immediately before a bounded run, then retain native and Dart
   logs with monotonic ordering where available:

   ```powershell
   adb logcat -c
   adb logcat -v threadtime > native-logcat.txt
   ```

3. Save Decaid logs through the in-app Export logs action or, on a debuggable
   build, with:

   ```powershell
   adb shell run-as net.tadel.reaprime cat app_flutter/log.txt > decaid-log.txt
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

No candidate release should be made while the corrected fork revision is
unpublished and the physical matrix is unrun. If a later candidate build must
be rolled back:

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

- Prerequisite software reviews: complete locally, with dependency publication
  and Android build limits recorded.
- Exact candidate dependency pin: blocked by unpublished corrected fork commit.
- Affected-device matrix: `NOT RUN`.
- Maintainer hardware sign-off: pending.
- #871, #875, and #877: remain open.

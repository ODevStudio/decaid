## Summary

- Bind Decaid machine and scale connects to normalized device-id leases that
  remain owned until source completion and stale-candidate cleanup.
- Fence timeout, scan cancellation, USB attach, adapter loss, explicit
  disconnect, and shutdown without adding an app-global BLE scheduler.
- Remove the shorter quick-connect wrapper timeout and disarm the existing
  scale watch before direct controller connects.
- Archive the final ownership decision and dependency publication gate.

## Linked Issue

Refs #876. Parent #871 remains open until #877 completes affected-device
acceptance.

## Verification

- `dart format` completed for the changed Dart files.
- `flutter analyze --no-pub`: no issues.
- Connection manager, USB attach, and attempt-owner suites: 215 passed.
- Discovery and controller generation suites: 59 passed.
- Integrated Block A and D candidate full `flutter test --no-pub`: 4,274
  passed, one existing skip. Candidate resolution used local corrected fork
  `546d55bbaef7f750c570b88d8c797299fc01335a`; committed dependency files remain
  publishable on the baseline pin.
- JDK 17 `Selector.open()` still failed with a short process-scoped
  `jdk.net.unixdomain.tmpdir`; corrected-fork Android compilation and the
  candidate Android app build remain not run because Gradle cannot start.
- Simulated Windows REST smoke did not start because the host CMake is 3.20
  and the current Firebase SDK requires 3.22 or newer.
- Android 10/Teclast, DE1, and original full-height scale: `NOT RUN` because
  the required hardware is unavailable.

## Impact

- Timed-out or cancelled connects cannot adopt later, and same-device
  replacements wait for retirement cleanup.
- No API, schema, storage, migration, plugin-session, or scale-power behavior
  changes.
- The reviewed fork correction is not published, so the reproducible
  `universal_ble` pin remains at
  `16bbfbce197eb5913c6b16578363f7dc943e605d` pending publication of
  `546d55bbaef7f750c570b88d8c797299fc01335a`.

## Contributor Responsibility

- [x] I have reviewed and understand all changes in this PR and take
  responsibility for their correctness, security, behavior, licensing, and
  provenance, including any AI-assisted or AI-generated work.

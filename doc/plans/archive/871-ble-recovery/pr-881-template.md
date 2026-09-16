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
- Post-merge focused connection ownership, auxiliary-scale, USB attach,
  discovery, and controller suites: 325 passed.
- Post-merge full `flutter test --no-pub`: 4,772 passed, one existing skip.
- `universal_ble` PR #28 run `35108117215`: all jobs passed on merge
  `e3ddd73beab1bfb1447abb65fad44438239936e6`, including
  `gradle :universal_ble:testDebugUnitTest` for exact head
  `895aa687a25c99b17c81e8672cac7de051551ded`.
- Local Android compilation was not rerun because the documented Windows
  Gradle/JBR loopback failure occurs before configuration; the exact native
  dependency tests ran in the upstream Linux job instead.
- Android 10/Teclast, DE1, and original full-height scale: `NOT RUN` because
  the required hardware is unavailable.

## Impact

- Timed-out or cancelled connects cannot adopt later, and same-device
  replacements wait for retirement cleanup.
- No API, schema, storage, migration, plugin-session, or scale-power behavior
  changes.
- `universal_ble` is reproducibly pinned in both dependency files to reviewed,
  native-tested head `895aa687a25c99b17c81e8672cac7de051551ded`.

## Contributor Responsibility

- [x] I have reviewed and understand all changes in this PR and take
  responsibility for their correctness, security, behavior, licensing, and
  provenance, including any AI-assisted or AI-generated work.

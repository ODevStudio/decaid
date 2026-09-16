## Summary

- Record the immutable BLE recovery candidate revisions and software evidence.
- Freeze the baseline/candidate matrix, numerical pass criteria, support log
  capture, operational limits, and rollback procedure.
- Keep every affected Android hardware result explicitly `NOT RUN`.

## Linked Issue

Refs #877 and #871. Neither issue is closed because the corrected fork revision
is unpublished and affected-device acceptance has not run.

## Verification

- Block A: analyze clean; focused suites 5/5 and 4/4; full suite 4,255 passed
  with one skip.
- Block B: analyze clean; 136 host tests passed with 13 platform skips.
- Block C local correction: analyze clean; 136 host tests passed with 13
  platform skips.
- Block D against local corrected C: analyze clean; focused suites 215 and 59
  passed; final integrated suite passed 4,274 tests with one skip.
- Corrected-fork and candidate-app Android compilation: `NOT RUN`; one bounded
  corrected-fork native-test command used cached Gradle 8.14.3, Android
  Studio's JBR 21, the normal persistent-daemon path, and the prior Kotlin
  settings as invocation properties. The daemon started and accepted the
  client socket, but the connection stream failed at `Selector.open()` before
  project configuration, so the task did not execute and the gated integrated
  build was not attempted. This is limited to the tested current environment;
  prior same-JBR local builds and ADB tablet runs succeeded.
- Simulated REST smoke: `NOT RUN`; CMake 3.28 and private Microsoft-signed
  NuGet 7.9 configured and compiled the Windows candidate until
  `universal_ble_plugin.dll` failed to link with unresolved MSVC
  `std::bad_cast` symbols.
- Supplemental Samsung `SM-X210` / Android 16 inventory: read-only only; the
  existing Decaid installation was untouched and no candidate APK was built or
  installed.
- Supplemental COM5 HDS USB capture: passive 115200 8N1 transport baseline
  received 12 weight samples and two health lines with no writes; the port was
  closed and disposed. Candidate HDS readiness/reconnect and Android BLE
  acceptance remain `NOT RUN`.
- Android 10/Teclast, DE1, and original full-height scale: `NOT RUN` because the
  required hardware is unavailable.

## Impact

- Documentation and acceptance evidence only; no additional runtime, API,
  schema, storage, migration, plugin, or scale-protocol change.
- Candidate publication and hardware acceptance remain release gates.

## Contributor Responsibility

- [x] I have reviewed and understand all changes in this PR and take
  responsibility for their correctness, security, behavior, licensing, and
  provenance, including any AI-assisted or AI-generated work.

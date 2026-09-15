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
- Corrected-fork and candidate-app Android compilation: `NOT RUN` after the JDK
  17 selector probe failed even with a short process-scoped Unix-domain temp
  directory. Earlier baseline attempts failed before Gradle configuration.
- Simulated REST smoke: `NOT RUN`; CMake 3.28 and private Microsoft-signed
  NuGet 7.9 configured and compiled the Windows candidate until
  `universal_ble_plugin.dll` failed to link with unresolved MSVC
  `std::bad_cast` symbols.
- Supplemental Samsung `SM-X210` / Android 16 inventory: read-only only; the
  existing Decaid installation was untouched and no candidate APK was built or
  installed.
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

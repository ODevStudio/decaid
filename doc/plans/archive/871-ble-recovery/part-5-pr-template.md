## Summary

- Record the immutable BLE recovery candidate revisions and software evidence.
- Freeze the baseline/candidate matrix, numerical pass criteria, support log
  capture, operational limits, and rollback procedure.
- Keep every affected Android hardware result explicitly `NOT RUN`.

## Linked Issue

Refs #877 and #871. Neither issue is closed because affected-device acceptance
has not run.

## Verification

- Block A docs-only final head `b53d4ba650f1dc15d073b7d728f679ae3db3d142`:
  CI run `35115385053` passed format, analysis, the Linux build smoke, and the
  full Flutter suite with 4,298 visible passes and one skip. Runtime code is
  unchanged from tested parent `2484d04aefdfa6134344571eb7aeb3f71535d73c`.
- Block B: analyze clean; 136 host tests passed with 13 platform skips.
- Block C final head `895aa687a25c99b17c81e8672cac7de051551ded`:
  analyze clean; 136 host Flutter tests passed with 13 platform skips; CI run
  `35108117215` passed the native Android helper/plugin tests on merge
  `e3ddd73beab1bfb1447abb65fad44438239936e6`. Host Flutter tests do not validate
  Kotlin.
- Block D final head `88e5d9b492f837eab4471f8451f917123737068e`:
  CI run `35112700192` passed format, analysis, the Linux app
  compile/package/launch smoke, and 4,315 visible Flutter tests with one skip on merge
  `9d37d7f379b390fa88538113927690ef2ffd807e`; the local Windows run passed 4,314
  with one skip.
- Final A+D isolated merge `cb57a614f046949323a570be00034893fe798e2a`
  (tree `ea9d0f3586f462857e013e85c73bb9408a07be1f`) passed analysis, 4 focused
  diagnostic tests, 252 focused connection tests, and the full Windows suite
  with 4,317 visible passes and one skip. Both dependency files retain final C
  head `895aa687a25c99b17c81e8672cac7de051551ded`.
- Candidate Decaid Android app compilation: `NOT RUN`; one bounded
  pre-publication native-test command against an earlier candidate revision
  used cached Gradle 8.14.3, Android
  Studio's JBR 21, the normal persistent-daemon path, and the prior Kotlin
  settings as invocation properties. The daemon started and accepted the
  client socket, but the connection stream failed at `Selector.open()` before
  project configuration, so the task did not execute and the gated integrated
  build was not attempted. This records only that earlier candidate invocation
  in the tested environment; prior same-JBR local builds and ADB tablet runs
  succeeded.
- Simulated REST smoke: `NOT RUN`; CMake 3.28 and private Microsoft-signed
  NuGet 7.9 configured and compiled an earlier pre-final Windows candidate until
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
- Candidate Decaid Android app compilation and hardware acceptance remain
  release gates. The Linux app compile/package/launch smoke passed.

## Contributor Responsibility

- [x] I have reviewed and understand all changes in this PR and take
  responsibility for their correctness, security, behavior, licensing, and
  provenance, including any AI-assisted or AI-generated work.

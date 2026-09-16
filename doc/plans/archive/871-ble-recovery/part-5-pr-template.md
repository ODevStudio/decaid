## Summary

- Record the immutable BLE recovery candidate revisions and software evidence.
- Freeze the baseline/candidate matrix, numerical pass criteria, support log
  capture, operational limits, and rollback procedure.
- Keep every affected Android hardware result explicitly `NOT RUN`.

## Linked Issue

Refs #877 and #871. Neither issue is closed because affected-device acceptance
has not run.

## Verification

- Direct follow-up: unmodified published #881 application source compiled as
  an Android release APK without simulation or startup-isolation changes.
  Native pin `895aa687a25c99b17c81e8672cac7de051551ded` was verified clean.
  APK SHA-256 `868E9FED89DA884226719231FAEBB294C446985675C4C8C21E9994FF37944153`;
  signature and package inspection passed. The APK was not installed.
  This build uses Flutter 3.44.8 SDK-resolved dependencies, local debug signing,
  and the CI-style skin stub, not release-distribution or runtime acceptance.
- Direct HDS follow-up after user power confirmation: two real COM5
  connect/read/disconnect cycles passed through candidate HDSSerial, with 32
  and 38 valid frames, zero invalid/checksum frames, and successful port release.
  All weights were zero; changing-load accuracy was not tested. This is USB
  protocol evidence, not affected-device BLE acceptance. Raw transcript hash:
  `AB6BD76A706AD67E88EA683A8CAB3BD6FCB64B59F558771785C6432A2F0438DD`.

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
- Isolated Android simulation overlay R2 built, installed, and launched from
  combined source `cb57a614f046949323a570be00034893fe798e2a`. The uncommitted
  isolation patch SHA-256 is
  `E6DC3962F58FB7F186F31E90FD065A44F48919C909822E27C31863227C798B54`, the
  APK SHA-256 is
  `A80A5C75B41D6AC23D5B5FF6D27B23B1C1E700E7802DF9E4C6C5D6E22F95D2FC`,
  and the resolved lock SHA-256 is
  `E53F5E9F49DFD68052DC2CFF5B1FE73D7DE7C6BBE068646DE7E3E1578E5C27A5`.
  This modified overlay is not the production-source candidate and will not be
  published.
- On Samsung `SM-X210` / Android 16, the first R2 candidate-only MockDe1 plus Mock
  Scale cycle produced usable machine and scale snapshots, then disconnected
  cleanly. The second same-process reconnect restored connected inventory,
  native UI state, and machine snapshots, but the scale socket emitted only
  connected status and no weight frame within eight seconds. Source inspection
  identified the existing mock-only cause: disconnect cancels MockScale's
  emission timer and reconnect does not restart it. The requested two-success
  threshold was not met; this is not physical BLE evidence.
- A focused main-based fix at
  `65b9681427c4dd5eed0f29e61cc1c55c3e9eb574` restarts MockScale emission only
  when reconnecting without an active timer. It is local and unpublished
  pending separate publication permission. Its regression passed, analysis was
  clean, and the full main-based suite passed 4,295 tests with one skip.
- R3 applied that reviewed local fix to the unpublished isolation overlay. Its
  patch SHA-256 is
  `758EAAB735B7F73A00A32DBCAD4799E8510D7456A794A7981E3C49BF3F2A6016`,
  APK SHA-256 is
  `58DD087785934E3BF3A1866786B308D73B454224953A69AF4F94A72E8C967111`,
  resolved lock SHA-256 remains
  `E53F5E9F49DFD68052DC2CFF5B1FE73D7DE7C6BBE068646DE7E3E1578E5C27A5`,
  and reported build time is `2026-09-16T18:40:41Z`.
- Both R3 same-process cycles produced connected MockDe1 and MockScale
  inventory, usable idle machine state, connected scale status, and a newly
  received weight frame. Between cycles both devices reported disconnected,
  machine state returned the documented 500, and the scale socket reported
  disconnected. The candidate was stopped and its `18080` ADB forward removed.
  Production remained PID `10742`. This remains supplemental simulation, not
  physical BLE evidence.
- The verbatim retained API/WebSocket exchange is
  `candidate-r3-two-cycle-api-ws-transcript.txt`, SHA-256
  `C2EE7C738223318E626AAE2D99AF30F33B95C49EB66809447F5F74EFB154E864`,
  sourced from command-output chunks `998c12`, `1ddcb3`, `355f6f`, `9100c4`,
  `89e165`, and `b23845` without replaying the tablet run.
- R2 analysis, targeted initialization and foreground-service tests, targeted
  TLS tests with process-local QuickJS/OpenSSL, APK signing, and manifest
  inspection passed. Its temporary-overlay full-suite result was 4,306 passes,
  one skip, and four failures: one environment-only TLS setup failure passed on
  targeted rerun, while three assertions retain production ports `4001`/`8080`
  instead of overlay ports `14001`/`18080`.
- Desktop simulated REST smoke remains `NOT RUN`; CMake 3.28 and private
  Microsoft-signed NuGet 7.9 compiled an earlier pre-final Windows candidate
  until `universal_ble_plugin.dll` failed to link with unresolved MSVC
  `std::bad_cast` symbols. The Android R2/R3 simulation runs are supplemental and
  do not replace that result.
- Production `net.tadel.reaprime` stayed PID `10742` throughout the Samsung run.
  The candidate used isolated package `net.tadel.reaprime.issue871candidate`;
  no skin/plugin UI, physical BLE, or production endpoint was driven. Missing
  `ACCESS_NETWORK_STATE` and the unused WebUI's failed bind to production-owned
  port `3000` are explicit overlay limitations.
- Supplemental COM5 HDS capture: passive 115200 8N1 output contained ASCII
  `Weight:` and `[health]` data but no framed `03 CE` packets. Two bounded
  readiness attempts used the same COM5 endpoint and production transport
  settings, completed and drained the four-byte `03 20 01 01` write, received
  zero bytes, timed out after two seconds, and released the port. Local scale
  power/responding state was not independently confirmed, so hardware silence
  was not established. The later powered direct test above supersedes that
  confirmation gate, while retaining these unsuccessful observations.
- Android 10/Teclast, DE1, and original full-height scale: `NOT RUN` because the
  required hardware is unavailable.

## Impact

- Documentation and acceptance evidence only; no additional runtime, API,
  schema, storage, migration, plugin, or scale-protocol change.
- Published-source Android compilation now passes under the recorded local
  toolchain. Physical BLE acceptance remains a release gate; neither USB smoke
  tests nor the R2/R3 simulation overlays close it. The Linux app
  compile/package/launch smoke passed.

## Contributor Responsibility

- [x] I have reviewed and understand all changes in this PR and take
  responsibility for their correctness, security, behavior, licensing, and
  provenance, including any AI-assisted or AI-generated work. <!-- contributor-responsibility -->

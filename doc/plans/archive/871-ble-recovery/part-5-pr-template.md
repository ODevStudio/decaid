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
- Blocks B and C: analyze clean; 136 host tests passed with 13 platform skips at
  each reviewed tree.
- Block D: analyze clean; focused suites 212 and 59 passed; full suite 4,268
  passed with one skip.
- Android builds: attempted but failed before Gradle project configuration with
  `java.io.IOException: Unable to establish loopback connection`.
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

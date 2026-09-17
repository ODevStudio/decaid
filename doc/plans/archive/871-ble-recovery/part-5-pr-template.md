## Summary

- Record the immutable BLE recovery candidate revisions and software evidence.
- Freeze the baseline/candidate matrix, numerical pass criteria, support log
  capture, operational limits, and rollback procedure.
- Keep every affected Android hardware result explicitly `NOT RUN`.
- Finalize this session's handoff without merging, closing #871, or claiming
  affected-device sign-off. Further hardware work requires the missing matrix
  setup; no additional worker or periodic follow-up is scheduled.

## Linked Issue

Refs #877 and #871. Neither issue is closed because affected-device acceptance
has not run.

## Verification

| Check | Result |
| --- | --- |
| Combined diagnostics + integration | Analysis passed; **4,317 tests passed, 1 skipped** |
| Native Android tests | **Passed** in fork #28 CI |
| Published-source Android build | **Passed**; not installed; local SDK, debug signing and skin-stub qualifications |
| Samsung/Bengle BLE | **2 normal reconnects + 78-second screen-off passed**; supplemental, single BLE peer |
| HDS USB | **2 protocol cycles passed**; not BLE acceptance |
| Affected Teclast + DE1 + original scale | **NOT RUN**; remains the release gate |

**Open finding:** direct REST connection can omit Bengle's integrated scale; this also exists in the baseline. Simulation-only fixes, unsuccessful runs and other limitations are retained in the evidence, not counted as production acceptance.

[Full evidence, revisions, hashes and limitations](https://github.com/decentespresso/decaid/blob/odev/issue-871-publish-e/doc/plans/archive/871-ble-recovery/part-5-acceptance-package.md) | [Remaining acceptance matrix](https://github.com/decentespresso/decaid/blob/odev/issue-871-publish-e/doc/plans/archive/871-ble-recovery/part-5-acceptance-package.md#physical-matrix)

## Impact

- Documentation and acceptance evidence only; no additional runtime, API,
  schema, storage, migration, plugin, or scale-protocol change.
- Published-source Android compilation now passes under the recorded local
  toolchain. Affected-device BLE acceptance remains a release gate; neither USB
  smoke, Samsung/Bengle supplemental tests, nor R2/R3 simulation close it.
  The Linux app compile/package/launch smoke passed.

## Contributor Responsibility

- [x] I have reviewed and understand all changes in this PR and take
  responsibility for their correctness, security, behavior, licensing, and
  provenance, including any AI-assisted or AI-generated work. <!-- contributor-responsibility -->

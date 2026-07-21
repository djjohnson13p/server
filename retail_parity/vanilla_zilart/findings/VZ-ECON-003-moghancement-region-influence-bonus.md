# VZ-ECON-003 — Moghancement: Region Awards No Conquest Influence Bonus

## Identification

- **ID:** `VZ-ECON-003`
- **Expansion scope:** Vanilla shared system
- **Area:** Conquest / Mog House / regional influence
- **Baseline status:** `INACCURATE`
- **Severity:** `MODERATE`
- **Confidence:** `HIGH`
- **Implementation state:** Implemented on `retail-parity/codex-vanilla-zilart`
- **Implementation commit:** `556ad21ccda664e012003e5898fa7b4e2936c208`

## Expected behavior

Moghancement: Region is represented by `CONQUEST_REGION_BONUS = 10` and must increase the base regional influence award as a percentage.

## Baseline behavior

`GainInfluencePoints` divided the modifier by 100, converted the result to an integer, and added it as a flat amount. The configured value 10 became 0.1 and truncated to zero; even value 100 added only one point instead of scaling the award.

## Correction

`GainInfluencePoints` now reads the modifier, applies positive values to the base point award, and converts the calculated percentage contribution after multiplication.

Files changed:

- `src/map/conquest_system.cpp`

The pre-existing UTF-8 byte-order marker was restored in follow-up commit `0702a5be6421efd52be6ed17a4fa36347f1c69cf`; no unrelated encoding change remains.

## Validation completed

- The one-time fork workflow required exactly one matching baseline arithmetic expression before editing.
- Static post-edit assertions confirmed percentage multiplication is present and the broken expression is absent.
- `git diff --check` passed.
- Both temporary workflows removed themselves after committing.
- A native Ubuntu GCC Debug build was launched separately and is recorded in `CODEX_VALIDATION.md` when complete.

## Remaining validation

Add a deterministic conquest/IPC test for zero, 10%, 100%, and small point awards. The implemented conversion floors fractional bonus points; retail observation may still refine rounding behavior.

## Completion criteria

- [x] A modifier value of 10 is applied as a percentage of the base award.
- [x] Zero/nonpositive values do not add a bonus.
- [x] Source assertion and diff validation pass.
- [x] Original source encoding is preserved.
- [ ] Native build passes.
- [ ] Conquest/IPC regression tests are added.

# VZ-ECON-003 — Moghancement: Region Awards No Conquest Influence Bonus

## Identification

- **ID:** `VZ-ECON-003`
- **Expansion scope:** Vanilla shared system
- **Area:** Conquest / Mog House / regional influence
- **Baseline status:** `INACCURATE`
- **Severity:** `MODERATE`
- **Confidence:** `HIGH`
- **Implementation state:** `IMPLEMENTED_AND_TEST_BACKED`
- **Implementation commit:** `556ad21ccda664e012003e5898fa7b4e2936c208`
- **Validation commit:** `58c30fd5ecaa6eb1b1c85f76c55c5b384fe21a27`

## Expected behavior

Moghancement: Region is represented by `CONQUEST_REGION_BONUS = 10` and must increase the base regional influence award as a percentage.

## Baseline behavior

`GainInfluencePoints` divided the modifier by 100, converted the result to an integer, and added it as a flat amount. The configured value 10 became 0.1 and truncated to zero; even value 100 added only one point instead of scaling the award.

## Correction

`GainInfluencePoints` now reads the modifier, applies positive values to the base point award, and converts the calculated percentage contribution after multiplication.

Files changed:

- `src/map/conquest_system.cpp`

The pre-existing UTF-8 byte-order marker was restored in follow-up commit `0702a5be6421efd52be6ed17a4fa36347f1c69cf`; no unrelated encoding change remains.

## Automated validation completed

`GainInfluencePoints` now delegates only the point arithmetic to
`ApplyRegionInfluenceBonus` and passes the result to the existing
`AddInfluencePoints(points, nation, region)` path. Nation selection, region
selection, IPC message construction, and world aggregation are unchanged.

`src/test/tests/conquest_system_tests.cpp` calls the production arithmetic and
proves:

- 0%: 100 remains 100;
- 10%: 100 becomes 110;
- 100%: 100 becomes 200;
- a small 3-point award at 10% remains 3;
- 10 points at 15% becomes 11;
- zero points remain zero;
- a negative modifier leaves the award unchanged.

The two fractional cases explicitly lock down truncation toward zero after
percentage multiplication. The Catch2 test passed during `xi_test`, and the
full MSVC/Ninja Debug build passed.

## Remaining validation

The implementation and existing truncation behavior are test-backed. Reliable
retail evidence may still refine fractional rounding, but this pass does not
change it without evidence.

## Completion criteria

- [x] A modifier value of 10 is applied as a percentage of the base award.
- [x] Zero/nonpositive values do not add a bonus.
- [x] Original source encoding is preserved.
- [x] Fractional truncation behavior is explicit and deterministic.
- [x] Nation/region selection and IPC/world aggregation remain on the existing
  path.
- [x] Native MSVC/Ninja Debug build passes.
- [x] Conquest arithmetic regression tests are added.

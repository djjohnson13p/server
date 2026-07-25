# VZ-ECON-001 — Fishing New-Moon Catch Pattern Uses the Full-Moon Formula

## Identification

- **ID:** `VZ-ECON-001`
- **Expansion scope:** Shared Vanilla-era fishing system
- **Area:** Fishing / catch probability / economy
- **Baseline status:** `INACCURATE`
- **Severity:** `MODERATE`
- **Confidence:** `HIGH`
- **Implementation state:** `IMPLEMENTED_AND_TEST_BACKED`
- **Implementation commit:** `556ad21ccda664e012003e5898fa7b4e2936c208`
- **Validation commit:** `58c30fd5ecaa6eb1b1c85f76c55c5b384fe21a27`

## Expected behavior

Fishing pattern 4 is the full-moon preference and pattern 5 is the new-moon preference. Their separately defined formulas must be dispatched independently.

## Baseline behavior

At pinned baseline `242ab0d055dfb80396e7398b0dd7361b750c74e2`, `GetMoonModifier` dispatched both case 4 and case 5 to `MOONPATTERN_4`, even though `fishingutils.h` defines a distinct `MOONPATTERN_5` and active catch data assigns pattern 5 to fish.

## Correction

Case 5 now calls `MOONPATTERN_5(moonPhase)`.

Files changed:

- `src/map/utils/fishingutils.cpp`

## Automated validation completed

The production dispatch now has a narrow overload,
`GetMoonModifier(moonPattern, moonPhase)`, while the live `fish_t` path calls
that overload with the current moon phase.

`src/test/tests/fishingutils_tests.cpp` calls the real implementation and
checks patterns 4 and 5 for every defined phase from new moon through waning
crescent. Each result is compared with its independently configured macro,
including the production `+0.25` adjustment. A separate assertion proves the
two dispatches diverge where their curves differ.

The Catch2 test passed during `xi_test`, and the full MSVC/Ninja Debug build
passed.

## Remaining validation

The dispatch defect is fully test-backed. Broader retail validation of the
underlying curve coefficients remains separate and requires reliable
retail/client evidence; it does not block this correction.

## Completion criteria

- [x] Case 5 calls `MOONPATTERN_5`.
- [x] Pattern 4 calls its independently configured curve.
- [x] Every defined moon phase is covered deterministically.
- [x] Native MSVC/Ninja Debug build passes.
- [x] Deterministic unit test covers the independent curves.

# VZ-ECON-001 — Fishing New-Moon Catch Pattern Uses the Full-Moon Formula

## Identification

- **ID:** `VZ-ECON-001`
- **Expansion scope:** Shared Vanilla-era fishing system
- **Area:** Fishing / catch probability / economy
- **Baseline status:** `INACCURATE`
- **Severity:** `MODERATE`
- **Confidence:** `HIGH`
- **Implementation state:** Implemented on `retail-parity/codex-vanilla-zilart`
- **Implementation commit:** `556ad21ccda664e012003e5898fa7b4e2936c208`

## Expected behavior

Fishing pattern 4 is the full-moon preference and pattern 5 is the new-moon preference. Their separately defined formulas must be dispatched independently.

## Baseline behavior

At pinned baseline `242ab0d055dfb80396e7398b0dd7361b750c74e2`, `GetMoonModifier` dispatched both case 4 and case 5 to `MOONPATTERN_4`, even though `fishingutils.h` defines a distinct `MOONPATTERN_5` and active catch data assigns pattern 5 to fish.

## Correction

Case 5 now calls `MOONPATTERN_5(moonPhase)`.

Files changed:

- `src/map/utils/fishingutils.cpp`

## Validation completed

- The one-time fork workflow required exactly one matching baseline expression before editing.
- Static post-edit assertion confirmed case 5 calls `MOONPATTERN_5`.
- `git diff --check` passed.
- The temporary workflow removed itself after committing.
- A native Ubuntu GCC Debug build was launched separately and is recorded in `CODEX_VALIDATION.md` when complete.

## Remaining validation

A dedicated unit test should expose `GetMoonModifier` or an appropriate test seam and verify patterns 4 and 5 across all phase indices. Broader retail validation of the curve coefficients remains separate from this dispatch correction.

## Completion criteria

- [x] Case 5 calls `MOONPATTERN_5`.
- [x] Source assertion and diff validation pass.
- [ ] Native build passes.
- [ ] Deterministic unit test covers the independent curves.

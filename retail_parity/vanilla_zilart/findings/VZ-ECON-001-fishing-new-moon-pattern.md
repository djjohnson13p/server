# VZ-ECON-001 — Fishing New-Moon Catch Pattern Uses the Full-Moon Formula

## Identification

- **ID:** `VZ-ECON-001`
- **Title:** Fishing moon-pattern value 5 dispatches to the wrong catch-weight formula
- **Expansion scope:** Shared Vanilla-era fishing system
- **Area:** Fishing / catch probability / economy
- **Status:** `INACCURATE`
- **Severity:** `MODERATE`
- **Confidence:** `HIGH`
- **Disposition:** `CODEX` for the one-line correction and automated test because the assistant connector cannot safely replace the full 3,290-line source file

## Expected retail behavior

Fishing catch data distinguishes multiple moon-preference patterns. In particular:

- Pattern 4 is the `MOONPATTERN_FULL` preference.
- Pattern 5 is the `MOONPATTERN_NEW` preference.

The two patterns have separate formulas with opposite phase offsets. Fish assigned new-moon preference must use the new-moon formula rather than the full-moon formula.

## Current LandSandBoat behavior

At pinned baseline `242ab0d055dfb80396e7398b0dd7361b750c74e2`:

- `src/map/utils/fishingutils.h` defines:
  - pattern 4 as `MOONPATTERN_FULL` and macro `MOONPATTERN_4`;
  - pattern 5 as `MOONPATTERN_NEW` and macro `MOONPATTERN_5`.
- The two macros are distinct cosine curves with phase offsets of approximately pi radians.
- `src/map/utils/fishingutils.cpp`, `GetMoonModifier`, dispatches:
  - case 4 to `MOONPATTERN_4`;
  - case 5 incorrectly to `MOONPATTERN_4` again.
- The fishing catch data actively assigns moon-pattern value 5 to fish, including entries visible in `scripts/globals/hobbies/fishing/data.lua` such as Brass Loach, Giant Donko, and others.

## Difference

Every fish configured with the new-moon preference receives the full-moon catch-weight curve. This reverses or substantially distorts its intended moon-phase availability and affects catch distribution and the fishing economy.

## Evidence

- **Current source:**
  - `src/map/utils/fishingutils.h`
  - `src/map/utils/fishingutils.cpp`
  - `scripts/globals/hobbies/fishing/data.lua`
- **Internal consistency evidence:** The enum, macro names, distinct formula definitions, and switch cases establish the intended one-to-one dispatch without requiring an inferred retail coefficient.
- **Retail observation/test:** Useful for validating the underlying curve values, but not required to establish that case 5 calling the case-4 macro is internally incorrect.
- **Uncertainty:** The wider accuracy of all fishing moon curves is outside this bounded finding.

## Reproduction

### Deterministic code test

1. Create representative `fish_t` inputs with `moonPattern` 4 and 5.
2. Evaluate `GetMoonModifier` for all eight moon-phase indices.
3. Confirm that the baseline returns identical values for patterns 4 and 5.
4. Confirm after correction that pattern 4 matches `MOONPATTERN_4` and pattern 5 matches `MOONPATTERN_5`.

### Gameplay test

1. Select a catch-data fish assigned moon pattern 5.
2. Hold zone, bait, rod, skill, weather, time, month, and pool state constant.
3. Compare catch weighting across new and full moon phases before and after correction.

## Dependencies and regression risk

- Core fishing catch-weight calculation.
- All fish assigned `moonPattern = 5`.
- Fishing pool distributions and economy availability.
- Existing moon-pattern tests, if any.

Regression risk is low: the intended macro and enum already exist and the change is a one-line dispatch correction.

## Proposed correction

In `GetMoonModifier`, change case 5 from `MOONPATTERN_4(moonPhase)` to `MOONPATTERN_5(moonPhase)`.

## Implementation plan

- **Assistant work completed:** Traced enum, macro definitions, switch dispatch, and active catch-data use.
- **Assistant implementation limitation:** The GitHub connector requires complete replacement content for updates; safely reconstructing a 3,290-line C++ file for a one-line edit is unjustified.
- **Codex work:** Make the one-line correction, add a deterministic unit test covering all moon-pattern cases, run formatting and relevant fishing tests, and commit on the Codex implementation branch.
- **Human validation required:** None for the dispatch correction. Broader retail validation of curve coefficients remains separate.

## Completion criteria

- Case 5 calls `MOONPATTERN_5`.
- A test fails on the baseline and passes after the correction.
- Patterns 4 and 5 produce their independently defined curves.
- Existing fishing tests and required C++ checks pass.

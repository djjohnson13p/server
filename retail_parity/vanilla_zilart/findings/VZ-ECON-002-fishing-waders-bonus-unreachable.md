# VZ-ECON-002 — Waders Fishing Bonus Is Unreachable

## Identification

- **ID:** `VZ-ECON-002`
- **Title:** The fishing lucky-timing bonus for Waders can never activate
- **Expansion scope:** Shared Vanilla-era fishing system
- **Area:** Fishing / equipment effects / hook minigame
- **Status:** `INACCURATE`
- **Severity:** `MINOR`
- **Confidence:** `HIGH`
- **Disposition:** `CODEX` for the bounded correction and regression test because the assistant connector cannot safely replace the full 3,290-line source file

## Expected retail behavior

When the fishing system deliberately defines a Waders-specific equipment bonus, equipping Waders in the feet slot must make that bonus reachable during the lucky-timing calculation.

This finding is based on internal code consistency. It does not independently certify the exact `+2` retail magnitude; it establishes that the currently coded Waders branch is dead.

## Current LandSandBoat behavior

At pinned baseline `242ab0d055dfb80396e7398b0dd7361b750c74e2`:

- `src/map/utils/fishingutils.h` defines `WADERS = 14195` as fishing feet equipment.
- `GetFishingGear` reads the equipped feet item but retains it only when it is `FISHERMANS_BOOTS` or `ANGLERS_BOOTS`; any Waders item is converted to `0`.
- Later in `CalculateLuckyTiming`, the feet switch contains an explicit `case WADERS:` that adds a bonus of `2`.
- Because `gear.feet` can never equal `WADERS`, the Waders case is unreachable.

## Difference

The implementation advertises and calculates a Waders fishing bonus but filters the item out before calculation. A player wearing Waders receives no intended lucky-timing contribution from this path.

## Evidence

- **Current source:**
  - `src/map/utils/fishingutils.h`
  - `src/map/utils/fishingutils.cpp`
- **Internal consistency evidence:** The same subsystem defines the item constant and a Waders-specific switch case, while the equipment filter prevents that case from executing.
- **Retail observation/test:** Needed only to validate the exact magnitude and whether other gear interactions modify it. It is not needed to prove the branch is unreachable.

## Reproduction

### Deterministic test

1. Create a character fixture with Waders equipped in the feet slot.
2. Call `GetFishingGear`.
3. Confirm the baseline returns `gear.feet == 0` instead of the Waders item ID.
4. Evaluate lucky timing with all random and environmental factors fixed.
5. Confirm the Waders bonus is absent at baseline and present after correction.

## Dependencies and regression risk

- `GetFishingGear` feet-slot filtering.
- `CalculateLuckyTiming` equipment bonuses.
- Waders item ID and any associated item modifiers.

Regression risk is very low. The correction should only permit an already-defined feet item to reach an already-defined switch case.

## Proposed correction

Include `WADERS` in the accepted feet-item expression in `GetFishingGear`.

## Implementation plan

- **Assistant work completed:** Traced the item constant, feet filter, and unreachable bonus branch.
- **Assistant implementation limitation:** Safe connector updates require replacing the complete large C++ file.
- **Codex work:** Add Waders to the feet filter, add a deterministic equipment/lucky-timing test, run formatting and relevant fishing checks.
- **Human validation required:** None for reachability; optional retail validation for the exact bonus magnitude.

## Completion criteria

- `GetFishingGear` retains Waders in `gear.feet`.
- The Waders branch in `CalculateLuckyTiming` executes in a deterministic test.
- Other fishing feet equipment behavior remains unchanged.
- Relevant C++ and fishing tests pass.

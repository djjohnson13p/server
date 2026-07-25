# VZ-ECON-002 — Waders Fishing Bonus Is Unreachable

## Identification

- **ID:** `VZ-ECON-002`
- **Expansion scope:** Shared Vanilla-era fishing system
- **Area:** Fishing / equipment effects / hook minigame
- **Baseline status:** `INACCURATE`
- **Severity:** `MINOR`
- **Confidence:** `HIGH`
- **Implementation state:** `IMPLEMENTED_AND_TEST_BACKED`
- **Implementation commit:** `556ad21ccda664e012003e5898fa7b4e2936c208`
- **Validation commit:** `58c30fd5ecaa6eb1b1c85f76c55c5b384fe21a27`

## Expected behavior

The fishing system defines Waders as fishing equipment and contains a Waders-specific lucky-timing bonus. Equipping Waders must allow that branch to execute.

## Baseline behavior

`GetFishingGear` retained only Fisherman's Boots or Angler's Boots in the feet field. It converted Waders to zero before `CalculateLuckyTiming` reached its explicit `case WADERS`, making the coded bonus unreachable.

## Correction

`GetFishingGear` now retains Waders alongside the two existing fishing boots.

Files changed:

- `src/map/utils/fishingutils.cpp`

## Automated validation completed

The production feet filter and gear-only lucky-timing contribution now have
narrow deterministic seams:

- `GetFishingFeetGear` is used by `GetFishingGear`.
- `GetLuckyTimingGearBonus` is used by `CalculateLuckyTiming`.

`src/test/tests/fishingutils_tests.cpp` proves that:

- Fisherman's Boots survive filtering and retain their existing `+0.5` branch.
- Angler's Boots survive filtering and retain their existing `+1.0` branch.
- Waders survive filtering and reach the existing `+2.0` branch.
- unrelated feet equipment is converted to zero and contributes no bonus.

The Catch2 test passed during `xi_test`, and the full MSVC/Ninja Debug build
passed.

## Remaining validation

The reachability defect is fully test-backed. A live-retail observation may
still refine the exact magnitude, but is unnecessary to prove that the
baseline branch was dead and that the configured branch now executes.

## Completion criteria

- [x] `GetFishingGear` retains Waders.
- [x] Fisherman's Boots and Angler's Boots remain unchanged.
- [x] Unrelated feet equipment remains filtered.
- [x] The configured Waders lucky-timing branch is reachable.
- [x] Native MSVC/Ninja Debug build passes.
- [x] Equipment/lucky-timing regression test is added.

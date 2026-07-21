# VZ-ECON-002 — Waders Fishing Bonus Is Unreachable

## Identification

- **ID:** `VZ-ECON-002`
- **Expansion scope:** Shared Vanilla-era fishing system
- **Area:** Fishing / equipment effects / hook minigame
- **Baseline status:** `INACCURATE`
- **Severity:** `MINOR`
- **Confidence:** `HIGH`
- **Implementation state:** Implemented on `retail-parity/codex-vanilla-zilart`
- **Implementation commit:** `556ad21ccda664e012003e5898fa7b4e2936c208`

## Expected behavior

The fishing system defines Waders as fishing equipment and contains a Waders-specific lucky-timing bonus. Equipping Waders must allow that branch to execute.

## Baseline behavior

`GetFishingGear` retained only Fisherman's Boots or Angler's Boots in the feet field. It converted Waders to zero before `CalculateLuckyTiming` reached its explicit `case WADERS`, making the coded bonus unreachable.

## Correction

`GetFishingGear` now retains Waders alongside the two existing fishing boots.

Files changed:

- `src/map/utils/fishingutils.cpp`

## Validation completed

- The one-time fork workflow required exactly one matching baseline feet-filter expression before editing.
- Static post-edit assertion confirmed Waders is accepted by the feet filter.
- `git diff --check` passed.
- The temporary workflow removed itself after committing.
- A native Ubuntu GCC Debug build was launched separately and is recorded in `CODEX_VALIDATION.md` when complete.

## Remaining validation

Add a deterministic test with Waders equipped that proves `GetFishingGear().feet` retains the item and the Waders branch contributes to lucky timing. Retail observation is optional for confirming the exact `+2` magnitude; it is unnecessary to prove the baseline branch was dead.

## Completion criteria

- [x] `GetFishingGear` retains Waders.
- [x] Source assertion and diff validation pass.
- [ ] Native build passes.
- [ ] Equipment/lucky-timing regression test is added.

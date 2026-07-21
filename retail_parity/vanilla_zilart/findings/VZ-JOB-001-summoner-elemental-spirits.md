# VZ-JOB-001 — Summoner Elemental Spirit Behavior and Scaling

## Identification

- **ID:** `VZ-JOB-001`
- **Title:** Elemental Spirits use guessed AI and knowingly incorrect HP/MP/stat scaling
- **Expansion scope:** Rise of the Zilart
- **Area:** Summoner / Elemental Spirits / pet AI and statistics
- **Status:** `INACCURATE`
- **Severity:** `MAJOR`
- **Confidence:** `HIGH` that the current framework is inaccurate; exact replacement values remain partly unresolved
- **Disposition:** `CODEX` with deferred final retail validation

## Expected retail behavior

Elemental Spirits are autonomous Summoner pets. Retail behavior includes:

- Spirit-specific spell lists based on pet level.
- Autonomous spell choice based on combat state and available targets.
- Light Spirit healing and enhancing behavior.
- Spell-use timing affected by Summoning Magic skill, elemental day, elemental weather, equipment, and applicable job effects.
- Spirit HP, MP, attributes, magic accuracy, and magic damage derived from retail pet progression rather than a blanket emergency percentage modifier.

Square Enix's March 27, 2012 update notes also confirm that Summoner had a dedicated “Summoning Magic Cast Time” merit adjustment and provide official spirit perpetuation changes, demonstrating that spirit timing and progression are intentional game systems rather than generic elemental-monster defaults.

## Current LandSandBoat behavior

At pinned baseline `242ab0d055dfb80396e7398b0dd7361b750c74e2`, `scripts/globals/pets/avatar.lua` explicitly admits several approximations:

- File-level TODOs request more accurate Light Spirit logic, accurate Spirit HP/MP/stat scaling, and investigation of possible positional behavior.
- Curaga selection chance is marked “Guessed.”
- Avatar weapon damage uses `pet:getMainLvl() + 2` with `TODO: Verify retail base damage`.
- Spirits are assigned `MPP +300` with the comment that the value is wrong and exists only to prevent extremely low MP.
- The Light Spirit implementation returns no explicit offensive-spell choice when engaged, relying on generic downstream behavior rather than a fully documented retail decision model.

The cast-cooldown helper does account for Summoning Magic skill, day, weather, Astral Flow, and a spirit-cast-reduction modifier, but that does not resolve the incorrect stat model or guessed spell-selection logic.

## Difference

The system is present and usable, but it cannot be considered retail-equivalent:

1. Spirit resource scaling is knowingly artificial.
2. Base damage is unverified.
3. Light Spirit group-heal selection is guessed.
4. The overall spell-selection model is incomplete and not backed by a complete current-retail test matrix.

These defects affect the core identity and usefulness of a Zilart job.

## Evidence

- **Current source:** `scripts/globals/pets/avatar.lua`
- **Official Square Enix update evidence:**
  - https://forum.square-enix.com/ffxi/threads/22099
- **Square Enix forum retail observations and test discussion:**
  - https://forum.square-enix.com/ffxi/archive/index.php/t-48186.html
  - https://forum.square-enix.com/ffxi/archive/index.php/t-20950.html
  - https://forum.square-enix.com/ffxi/threads/41685-Summoning-Skill-and-conversion-How-does-it-work-exactely
- **Uncertainty:** Forum observations establish several timing relationships but do not provide a complete authoritative table for every Spirit's current HP, MP, attributes, spell priorities, and all caps.

## Reproduction

### Fork/server analysis

1. Summon each Spirit at representative levels.
2. Record max HP/MP and verify the universal `MPP +300` adjustment.
3. Test Light Spirit with one and multiple injured allies, at different pet levels and skill-over-cap values.
4. Record spell choices, cast intervals, idle-versus-engaged behavior, day/weather adjustments, and equipment modifiers.
5. Compare non-Light Spirit spell selection and resource use against the configured spell lists and generic mob AI.

### Retail comparison

1. Repeat controlled tests with each Spirit at matched level and Summoning Magic skill.
2. Capture max HP/MP where observable, spell choice, spell tier, cast interval, target selection, and day/weather changes.
3. Use enough trials to distinguish deterministic priority from random weighting.

## Dependencies and regression risk

- Pet stat generation and `pet_list`/mob-family data.
- Summoning Magic skill and skill-cap tables.
- Mob spell-list selection.
- Day/weather elemental relationships.
- Equipment and merit modifiers.
- Avatar and Spirit weapon damage.
- Later-expansion Spirit changes must not be accidentally applied to historical modules unless deliberately configured.

Risk is moderate to high because changes can affect all Spirit levels and both modern and era-module behavior.

## Proposed correction

Replace emergency universal scaling and guessed branching with a data-driven Spirit profile:

- Explicit level/stat progression or verified family/stat calculation.
- Verified MP pools and regeneration behavior.
- Spirit-specific spell tables with documented priority/weight rules.
- A single tested cast-timer calculation with named modifiers and caps.
- Separate current-retail data from optional historical-era overrides.

## Implementation plan

- **Assistant work:** Trace and document the existing code path, gather public evidence, create this finding, and review bounded corrections when exact data is available.
- **Codex work:** Build an automated Spirit behavior matrix, trace C++/Lua/SQL pet stat construction, replace the `MPP +300` workaround with supported data, formalize spell-selection logic, and add regression tests.
- **Tests:** Cast cooldown, day/weather modifiers, skill under/over cap, Light Spirit cure/buff selection, spell tiers, resource pools, and idle/engaged transitions.
- **Deferred final validation:** Current-retail Spirit stats and spell-selection captures where public evidence is insufficient.

## Completion criteria

- No active Spirit code retains comments admitting guessed or knowingly wrong core behavior.
- HP/MP/stat scaling is supported by data or clearly documented retail-derived formulas.
- Light Spirit cure, Curaga, buff, and offensive selection are reproducible and tested.
- Cast timing modifiers and caps are covered by automated tests.
- Remaining uncertainty is isolated to specific measured values rather than the entire subsystem.

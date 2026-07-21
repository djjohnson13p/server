# VZ-COMBAT-001 — Item Additional-Effect Framework Is Inaccurate and Incomplete

## Identification

- **ID:** `VZ-COMBAT-001`
- **Title:** Era item additional effects use admitted approximations, missing resistance paths, and incomplete handlers
- **Expansion scope:** Shared core
- **Area:** Combat / equipment / ammunition / additional effects
- **Status:** `INACCURATE`
- **Severity:** `MAJOR`
- **Confidence:** `HIGH` for framework defects; exact retail formulas remain partly unverified
- **Disposition:** `AI_PLUS_HUMAN_TESTING`

## Expected retail behavior

Weapons and ammunition with additional effects must apply the correct effect type, proc condition, accuracy/resistance calculation, element, potency, duration, target immunity, damage interaction, and combat message for that specific item. Vanilla and Rise of the Zilart items include elemental damage, status ammunition, drains, dispels, self-effects, and special NM interactions.

Retail parity requires item-specific parameters where retail does not use one universal formula. Status ammunition such as Sleep Bolt and Acid Bolt must not inherit an unrelated generic spell formula merely because both produce a status effect.

## Current LandSandBoat behavior

At pinned baseline `242ab0d055dfb80396e7398b0dd7361b750c74e2`, `scripts/globals/additional_effects.lua` contains multiple explicit limitations:

- Magical additional-effect damage still uses an element-oriented path with a TODO to support damage type correctly.
- Magic Attack Bonus inclusion is marked as requiring further testing.
- Several handlers are marked TODO for resistance checks, including damage/drain/dispel paths.
- The generic debuff handler calls `calculateResistRate` with a fixed `xi.skillRank.A` and `xi.mod.INT`, rather than data that clearly identifies each item's actual retail accuracy/stat model.
- MP, TP, and related drain handlers hardcode Dark element behavior.
- HP/MP and HP/MP/TP combined drains randomly select a drain type, accompanied by an explicit comment that this is wrong and needs retail verification.
- Self-buff handling supports only selected effects and prints an error for unhandled types; Haste power/duration/tier behavior remains a TODO.
- Death resistance uses a special local check because the standard resistance system does not support it.
- `xi.additionalEffect.spikes` is an empty TODO stub.

Upstream issue `#7899`, still open during this audit, provides retail test-data claims for status ammunition and states that the existing implementation is inaccurate or insufficient.

## Difference

The framework is functional for some configured items, but it cannot be considered retail-equivalent across Vanilla and Zilart equipment. Some paths are knowingly wrong, some omit resistance handling, some use universal assumptions where retail evidence indicates item-native behavior, and one advertised source category—auto-spikes—has no implementation.

This finding does not yet assert one final universal replacement formula. The code defects are confirmed; exact item-by-item retail parameters require a separate evidence table.

## Evidence

- **Current source:** `scripts/globals/additional_effects.lua`
- **Upstream tracking:** https://github.com/LandSandBoat/server/issues/7899
- **Retail observation/test:** The issue references a larger status-ammunition dataset, but that dataset must be preserved in an accessible audit artifact or independently reproduced before exact formulas are treated as high-confidence.
- **Independent corroboration:** Item descriptions and community observations can identify expected effect types, but controlled resist-rate tests are required for accuracy formulas.
- **Contradictory evidence or uncertainty:** Different item families may use different rules. Evidence for Sleep/Acid ammunition must not automatically be generalized to every additional effect.

## Reproduction

### Fork/server test

1. Build a table of every Vanilla/Zilart item configured with `ITEM_ADDEFFECT_*` modifiers.
2. Group items by effect family and handler.
3. Run deterministic tests against targets with controlled level, stats, resistances, immunities, and damage reductions.
4. Confirm the admitted wrong or missing paths: combined-drain selection, omitted resistance, unhandled self-buffs, and the empty spikes handler.

### Retail comparison

1. Select representative era items from each effect family.
2. Collect sufficient trials across controlled target levels/resistances.
3. Record proc rate separately from resist rate, potency, duration, partial-resist behavior, and combat messages.
4. Repeat for ranged distance bands when ammunition is involved.

## Dependencies and regression risk

- Magic hit rate and resistance tiers.
- Status-effect immunity and overwrite rules.
- Damage type, elemental absorption/nullification, Phalanx, Stoneskin, and severe-damage handling.
- Ranged-attack distance correction.
- Item modifier SQL/data and level-sync behavior.
- NM-specific item mechanics, including Zilart sky NMs.

Risk is high because a framework change can alter many items across later expansions. Changes must be data-driven and gated by broad regression tests.

## Proposed correction

Replace universal assumptions with an explicit item/effect profile model. Separate proc chance from effect accuracy and resistance. Permit each item or family to define skill basis, governing stat or no dSTAT, element, resistance mode, potency, duration, damage type, valid targets, and special behavior. Preserve specialized NM logic behind clearly tested hooks.

## Implementation plan

- **Assistant-direct work:** Produce the era-item inventory, map each item to its active code path, identify obvious dead/unreachable handlers, add narrow tests, and implement small corrections with strong evidence.
- **Codex work:** Refactor the framework and item data across Lua/SQL, migrate existing configurations, add parameter validation, and build broad automated regression coverage.
- **Files likely affected:** `scripts/globals/additional_effects.lua`, item/equipment SQL, item scripts, magic-hit/resistance helpers, and combat tests.
- **Tests to add or extend:** Proc-vs-resist separation, status ammunition, elemental damage, drains, dispel, self-effects, level sync, nullification/absorption, and NM-specific effects.
- **Human validation required:** Retail trial datasets for effect accuracy, dSTAT, durations, and unusual items.
- **Beyond reliable AI:** Inferring undocumented formulas from small or inaccessible datasets without controlled retail captures.

## Completion criteria

- Every Vanilla/Zilart additional-effect item is inventoried and mapped to a tested handler.
- No active era path retains a comment admitting known-wrong behavior.
- Proc chance, resistance, potency, duration, and messages are independently testable.
- Item-specific evidence is recorded; unsupported generalization is avoided.
- Automated regression tests cover representative items from each effect family.
- Human retail comparison validates formulas or explicitly marks unresolved item families `VERIFY_LIVE`.

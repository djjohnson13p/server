# VZ-COMBAT-001 — Item Additional-Effect Framework

## Identification

- **ID:** `VZ-COMBAT-001`
- **Expansion scope:** Shared core, inventoried for Vanilla/Rise of the Zilart
- **Area:** Combat / equipment / ammunition / additional effects
- **Baseline status:** `INACCURATE`
- **Current status:** `PARTIALLY_CORRECTED_PHASE_A`
- **Severity:** `MAJOR`
- **Confidence:** `HIGH` for the Phase A inventory, call paths, and corrected deterministic defects; item-specific retail numerics remain mixed
- **Disposition:** `PHASE_B_AND_CONTROLLED_RETAIL_EVIDENCE_REQUIRED`

Phase A is complete. It does not classify the full finding as corrected.

## Phase A inventory

The generated inventory is the repository record:

- `retail_parity/vanilla_zilart/artifacts/VZ-COMBAT-001-item-inventory.csv`
- `retail_parity/vanilla_zilart/artifacts/VZ-COMBAT-001-item-inventory.md`
- `tools/retail_parity/generate_item_additional_effect_inventory.py`

It inspects active `ITEM_ADDEFFECT_*`, `ITEM_SUBEFFECT`, latent, per-item Lua,
and equipment-spikes sources. It also retains the two issue-#7899 ammunition
entries that have no active selector, rather than silently omitting them.
Stable regeneration currently produces:

- 420 total rows: 18 maintained `VANILLA_OR_ZILART`, 402 `ERA_UNRESOLVED`;
- 183 damage, 124 debuff, 46 equipment-spikes, 27 scripted, 13 HP-drain,
  five Dispel, six NM-specific, four TP-drain, two MP-drain, two Death, two
  HP/MP/TP-drain, and the smaller remaining families recorded in the artifact;
- 387 SQL-only, 25 SQL-plus-item-script, five SQL-plus-latent, one
  script-only, and two issue-evidence-only rows;
- 122 configuration-error, 185 era-unresolved, 98 `VERIFY_LIVE`, ten
  framework-correct/legacy-numerics, and five special-case-test-backed rows.

The 341 repository-wide configuration findings are individual diagnostics,
not 341 maintained-era failures. All 18 maintained Vanilla/Zilart entries
have reachable handlers and non-error classifications. The unresolved rows
are intentionally retained because active repository tables have no reliable
item-introduction expansion field; numeric item-ID ranges were not used as
era evidence.

## Active lifecycle and ownership

### Melee

`attack round -> battleutils::HandleEnspell -> scaled item selector ->
luautils::additionalEffectAttack or OnItemAdditionalEffect -> Lua profile/
item script -> action_result_t additional-effect fields -> 0x028 serializer`

### Ranged

`range state -> physical hit/distance presentation -> TakePhysicalDamage ->
ammo-first additional-effect selector -> Lua profile/item script -> ammo
removal -> action_result_t -> 0x028 serializer`

### Equipment spikes

`melee reaction -> battleutils::HandleSpikesDamage -> equipped sub/body/
legs/head/hands/feet scan -> HandleSpikesEquip -> reaction fields -> 0x028`

The empty Lua `xi.additionalEffect.spikes` stub is not the active equipment
spikes path. Its formulas remain unimplemented and are not guessed in Phase A.

### Global profile path

1. The C++ attack path establishes a successful melee/ranged hit and selects
   the equipped weapon or ammo.
2. Lua rejects an item above the attacker's effective main level.
3. The profile layer resolves proc, accuracy/resistance, outcome, and
   presentation policy from the authoritative item modifiers plus narrow
   item/family policy.
4. Profile validation rejects unsupported/malformed combinations, reporting
   each invalid item at most once. The repository sanity tool reports the
   complete static set.
5. Level correction and the proc roll run before effect resistance.
6. Damage/status resistance and immunity/nullification guards resolve.
7. Calculators return a result without mutating combat state.
8. One application layer mutates HP/MP/TP/status exactly once.
9. The handler returns subeffect, message, and the actual applied amount or
   effect ID.
10. C++ stores one additional-effect result and the 0x028 serializer writes
    proc kind, info, parameter, and message.

## Profile architecture

`scripts/globals/additional_effect_profiles.lua` keeps SQL modifiers as the
numeric source of truth and separates:

- proc chance, level correction, triggering attack, distance inheritance,
  and target restriction;
- item-native/legacy accuracy mode, skill rank, governing-stat evidence,
  element, resistance, immunity, nullification, absorption, and
  partial-resist policy;
- family, damage type, potency, status, duration, tick, resource, selection,
  undead, and exactly-once application policy;
- subeffect, success/no-effect/absorption message policy and parameter shape.

Item overrides do not duplicate SQL potency/chance/duration. Unsupported
families resolve to named `VERIFY_LIVE` compatibility policy. The combined
drain branches explicitly preserve `LEGACY_RANDOM_VERIFY_LIVE` selection
instead of presenting that selection as retail-correct.

## Deterministic defects reproduced and corrected

Behavioral tests were added before the correction and reproduced:

- target HP changed by more than the returned magical additional-effect
  packet amount;
- elemental absorption was evaluated twice;
- magical nullification was evaluated twice;
- `NULL_BREATH_DAMAGE` did not work because the helper populated
  `isBreath` but read `isBREATH`.

The correction makes magical calculation pure, performs absorption and
nullification once, and applies the result once through a common operation.
The message amount is the actual HP delta/heal. The same ownership correction
removes unintended HP mutation from MP/TP drain calculation and preserves one
mutation for HP drain, physical-profile damage, and NM-specific damage.

The new status regression also exposed an inherited no-effect presentation
defect: if `addStatusEffect` rejected a non-overwriting effect, the handler
still returned a success subeffect/message. It now returns no presentation
when application fails.

## Maintained Vanilla/Zilart profiles

### Framework-correct with legacy numerics

Kabura Arrow, Patriarch Protector's Arrow, Acid Bolt, Sleep Bolt, Blind Bolt,
Venom Bolt, Poison Arrow, Sleep Arrow, Demon Arrow, and Spartan Bullet use
the validated generic status framework. Their configured proc/power/duration
values remain compatibility numerics unless item-specific evidence is
recorded.

### `VERIFY_LIVE`

Fire Arrow, Ice Arrow, and Lightning Arrow remain in their existing per-item
Lua damage paths. The scripts are reachable and inventoried, but their exact
item-specific damage/accuracy formulas are not promoted to retail-correct.

HP/MP/TP drains, combined drains, Dispel, absorb-status, self-buff, Death,
equipment spikes, and other unsupported families are isolated by explicit
policy/inventory classification. Phase A corrected shared double mutation
where independently justified but did not invent their retail ordering,
accuracy, scaling, tier, or formulas.

### Special-case test-backed

The following existing hooks are behaviorally preserved:

- Buccaneer's Knife against Brigandish Blade;
- Zephyr against Seiryu;
- Antarctic Wind against Genbu;
- Arctic Wind against Suzaku;
- East Wind against Byakko.

Wrong items and unrelated targets do not invoke a special action.

## Sleep Bolt and Acid Bolt evidence boundary

[LandSandBoat issue #7899](https://github.com/LandSandBoat/server/issues/7899)
and its reported dataset support an item-native A-rank magic-accuracy basis
for Sleep Bolt and Acid Bolt. The profile represents A rank explicitly only
for those two items.

The issue does not conclusively establish dSTAT. The inherited INT argument
is therefore retained as `LEGACY_UNVERIFIED`, and the generated rows say
`UNRESOLVED; LEGACY_INT_COMPATIBILITY`. No no-dSTAT or dINT conclusion is
claimed. The result was not generalized to Blind/Venom bolts, arrows,
Spartan Bullet, or later Gashing/Abrasion/Oxidant ammunition.

Real ranged-state tests prove ammo consumption, distance-penalty path,
profile selection, status power/duration, subeffect/message, action-packet
serialization, and supported A-rank transport while controlling the
unresolved resistance seam.

## Automated evidence

Focused production-path coverage includes:

- pure versus applying damage ownership, actual packet amount, absorption,
  elemental/general nullification, and healing;
- a real Sirocco Kukri melee action with one 0x028 additional result for each
  applied effect;
- physical/ranged/breath nullification, physical absorption, and damage-type
  SDT;
- proc failure before resistance, full resist, partial duration, full status,
  immunity, resistant trait, effect nullification, opposing-boost removal,
  and non-overwrite failure;
- Sleep, Defense Down, Poison, and Blind status parameters;
- above-level and latent-derived level eligibility;
- real Acid/Sleep ranged states, ammo removal, distance handling, status,
  and 0x028 presentation;
- all five maintained NM interactions plus wrong-item/unrelated-target cases;
- explicit `VERIFY_LIVE` family resolution and unsupported-family rejection.

The profile sanity tool proves stable artifacts, unique rows, issue-#7899
coverage, reachable/non-error maintained handlers, classification validity,
and the precise Acid/Sleep evidence boundary.

## SQL and compatibility

Phase A changes no SQL schema or item numeric data. The isolated database was
created from the current SQL through the supported database tooling. Existing
databases need no migration for this phase.

The shared deterministic corrections necessarily affect later-expansion
items using the same global handlers. Their numeric profiles are not
reclassified as retail-correct. Malformed later configurations are now
visible in the generated report and rejected explicitly rather than accepted
as a misleading zero-filled profile.

## Remaining Phase B work

- Establish item-specific introduction-era evidence for the 402 unresolved
  rows where useful; do not infer it from numeric ranges.
- Resolve the 122 configured-but-invalid/unreachable rows, prioritizing
  actual runtime relevance and avoiding speculative activation.
- Collect evidence and migrate damage type, damage resistance, MAB/dSTAT,
  drain accuracy/scaling/resource order, Dispel, self-buff tier/duration,
  Death, and spikes formulas.
- Determine per-item/family accuracy and partial-resist rules beyond the
  supported Acid/Sleep A-rank boundary.
- Expand real-path coverage as supported formulas are adopted.

Controlled live-retail captures remain necessary for unsupported formulas,
proc-versus-resist datasets, exact client presentation, and the named
unverified item families. Phase A intentionally preserves those questions
instead of replacing them with a new guess.

## Completion assessment

`VZ-COMBAT-001` is **partially corrected**. Phase A's complete conservative
inventory, testable profile seam, deterministic shared corrections, maintained
profile classifications, and regression coverage are complete. Retail parity
for every item and unsupported family is not complete and belongs to bounded
Phase B work plus controlled retail evidence.

# VZ-COMBAT-001 — Item Additional-Effect Framework

## Identification

- **ID:** `VZ-COMBAT-001`
- **Expansion scope:** Shared core, inventoried for Vanilla/Rise of the Zilart
- **Area:** Combat / equipment / ammunition / additional effects
- **Baseline status:** `INACCURATE`
- **Current status:** `PARTIALLY_CORRECTED_PHASE_B1`
- **Severity:** `MAJOR`
- **Confidence:** `HIGH` for the Phase A inventory, call paths, and corrected deterministic defects; item-specific retail numerics remain mixed
- **Disposition:** `PHASE_B2_AND_CONTROLLED_RETAIL_EVIDENCE_REQUIRED`

Phase A and the bounded Fire/Ice/Lightning Arrow Phase B1 implementation are
complete. The three arrows are hardened and explicitly profiled, not declared
retail-correct. The full finding remains partial.

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
numeric source for modifier-driven families and owns explicit policy for
scripted families. It separates:

- proc chance, level correction, triggering attack, distance inheritance,
  and target restriction;
- item-native/legacy accuracy mode, skill rank, governing-stat evidence,
  element, resistance, immunity, nullification, absorption, and
  partial-resist policy;
- family, damage type, potency, status, duration, tick, resource, selection,
  undead, and exactly-once application policy;
- subeffect, success/no-effect/absorption message policy and parameter shape.

Modifier-driven item overrides do not duplicate SQL potency/chance/duration.
Scripted profiles keep their numerics in one registry rather than three
anonymous item tables. Unsupported families resolve to named `VERIFY_LIVE`
compatibility policy. The combined drain branches explicitly preserve
`LEGACY_RANDOM_VERIFY_LIVE` selection instead of presenting that selection as
retail-correct.

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

Fire Arrow, Ice Arrow, and Lightning Arrow use the Phase B1 scripted profile
path described below. Their exact proc, damage, stat, accuracy, resistance,
and multiplier formulas remain `VERIFY_LIVE`.

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

## Phase A completion assessment

`VZ-COMBAT-001` is **partially corrected**. Phase A's complete conservative
inventory, testable profile seam, deterministic shared corrections, maintained
profile classifications, and regression coverage are complete. Retail parity
for every item and unsupported family is not complete and belongs to bounded
Phase B work plus controlled retail evidence.

## Phase B1 — Fire, Ice, and Lightning Arrow

### Retail evidence and conflict

The item-specific ledger is:

- `retail_parity/vanilla_zilart/artifacts/VZ-COMBAT-001-elemental-arrows-evidence.md`

The strongest accessible era evidence is a January 2004 Ranger guide listing
all three level-45 arrows and their Fire, Ice, and Lightning additional
damage. Modern Japanese references independently preserve the three elements
and describe them as original elemental arrows.

No controlled packet log, damage dataset, or official formula was found. A
March 2004 player report says elemental arrows dealt roughly 5-10 effect
damage and did not activate every hit. That conflicts with the inherited
uniform 7-10 roll and implicit 100% chance. A modern uncited Fire Arrow page
calls the damage INT-based, while a 2013 player report says high INT plus some
MAB still left Ice Arrow weak. Neither isolates actor INT, target INT/dINT,
magic accuracy, MAB, or another multiplier.

Those claims remain low-confidence hypotheses. Phase B1 does not change
numeric behavior from them.

### Authoritative scripted profile

The three item scripts now contain only their normal
`onItemAdditionalEffect` bridge to `executeScriptedDamageProfile`. A single
registry owns exactly these identities:

| Item | ID | Element | Subeffect |
|---|---:|---|---|
| Fire Arrow | 17322 | Fire | Fire damage |
| Ice Arrow | 17323 | Ice | Ice damage |
| Lightning Arrow | 17324 | Thunder | Lightning damage |

Registry construction validates every profile and rejects duplicate IDs.
Runtime resolution validates again before application and raises a visible
configuration error for a missing or malformed profile. The repository sanity
tool proves that each item has one `ITEM_ADDEFFECT_SCRIPTED` marker, one
wrapper call, one registry entry, the correct element/subeffect, and both real
test references. Earth, Water, Wind, Grand Knight's, and Temple Knight's
arrows are explicitly checked as unmigrated.

### Effective production policy

| Parameter | Effective policy | Evidence classification |
|---|---|---|
| Proc | One fixed 100% compatibility roll after a successful physical ranged hit | `VERIFY_LIVE` |
| Level | Existing item-required-level gate; no extra correction | Gate framework-correct; formula `VERIFY_LIVE` |
| Base power | One uniform integer roll from 7 through 10 | `VERIFY_LIVE` |
| Skill/stat/macc | Legacy A+; actor stat 0; target stat 0; explicit macc 0 | `VERIFY_LIVE` |
| MAB | Disabled | `VERIFY_LIVE` |
| Element | Fire, Ice, or Thunder by item | `EVIDENCE_BACKED` |
| Attack/damage type | Magical; elemental damage type by item | `FRAMEWORK_CORRECT_LEGACY_NUMERICS` |
| Resistance | Existing magical tiers through 1/8 | `VERIFY_LIVE` |
| Multipliers | General magic adjustment, elemental SDT, staff, affinity, and day/weather enabled | `VERIFY_LIVE` |
| Defenses | Phalanx, One for All, and Stoneskin retained once | `VERIFY_LIVE` |
| Null/absorb | One existing elemental nullification and absorption resolution | `FRAMEWORK_CORRECT_LEGACY_NUMERICS` |
| Distance | Inherit the successful physical ranged action; no second magical distance pass | `FRAMEWORK_CORRECT_LEGACY_NUMERICS` |
| Presentation | Matching elemental subeffect and normal damage/heal message | `FRAMEWORK_CORRECT_LEGACY_NUMERICS` |

The executor passes a lazy power resolver into the existing damage helper.
After profile validation, the helper performs its one proc roll and the
existing nullification, resistance, and absorption checks. It resolves power
exactly once only when the effect reaches damage calculation. A failed proc,
full nullification, or resistance below the configured floor therefore does
not advance power RNG. The path performs no second proc, resistance,
nullification, absorption, or HP mutation. The ordinary ranged subsystem
continues to own physical hit validation, range, item-level eligibility, ammo
priority, consumption, Recycle, and Unlimited Shot.

### Deterministic packet-amount correction

The Phase B1 pre-correction test reproduced an inherited scripted-path defect:
the helper returned planned damage or healing even when remaining HP/max HP
clamped the amount actually applied. This could make the 0x028 additional
effect value disagree with the target's HP delta.

`executeScriptedDamageProfile` now snapshots the target HP and returns the
actual damage or healing delta for these three profiles. It does not alter the
shared legacy helper or unrelated scripted items.

### Proc-before-power RNG correction

A bounded follow-up reproduced an ordering defect in the initial Phase B1
executor. It eagerly called `math.random(7, 10)` while constructing helper
parameters, before the helper evaluated the configured proc chance. Failed
procs therefore consumed a power roll that had no effect and perturbed later
random outcomes. The same eager evaluation also occurred before full
nullification and below-floor resistance rejection.

The shared helper now accepts either the existing numeric `basePower` value or
a zero-argument resolver. Parameter validation preserves that value without
invoking it. Fire/Ice/Lightning Arrow profiles pass the existing 7-10 roll as
the resolver; direct numeric callers remain unchanged. The resolver runs after
proc success, nullification, resistance-floor rejection, and absorption
classification, immediately before the existing damage formula.

The pre-correction 51-case run exited `1`: 48 cases passed and exactly the
failed-proc, full-nullification, and below-floor-resistance lazy-power cases
failed. The corrected and final post-build runs both passed 51/51.

### Behavioral coverage

Real ranged-state tests for all three arrows prove:

- successful physical hit, correct elemental subeffect/message/value, one
  ranged-finish action, matching total HP delta, and one consumed arrow;
- ordinary physical miss, target leaving range mid-shot, initial out-of-range
  rejection, target despawn, and below-item-level suppression;
- a longer valid physical range with no additional magical distance pass;
- Recycle and Unlimited Shot ammo preservation through the ordinary ranged
  subsystem;
- one arrow result when an Enspell is also active;
- no script/global double handling and no element cross-wiring.

Direct production-executor tests prove:

- registry validity, exact three-item scope, malformed-policy rejection, and
  duplicate rejection;
- failed proc with one proc roll, zero power/nullification/resistance/
  absorption/application work, and no HP change;
- successful synthetic 50% proc with exactly one proc, power, nullification,
  resistance, absorption, and HP-application event;
- zero power rolls after full nullification or below-floor resistance;
- unchanged direct numeric-base callers with no resolver or power-RNG call;
- one 7-10 power roll on successful resolution, including both boundaries;
- no actor-INT, target-INT, or MAB contribution as compatibility behavior,
  without calling that behavior retail-correct;
- full, half, quarter, eighth, and below-floor resistance outcomes;
- A+ rank, per-item element, no-stat, and zero-macc transport;
- general magic adjustment, elemental SDT, staff, affinity, day/weather,
  Phalanx, One for All, and Stoneskin compatibility behavior;
- one nullification and absorption resolution for each element;
- actual damage/healing amount at HP caps.

Existing Phase A tests remain the regression authority for Acid/Sleep Bolt,
generic item additional effects, NM hooks, and ordinary 0x028 behavior.

### Phase B1 validation

- Fresh MSVC 19.44/Ninja Debug configure: exit `0`.
- Fresh `xi_test` target build: exit `0` (`906/906`).
- Complete all-target Debug build: exit `0` (`148/148` remaining steps);
  `xi_connect`, `xi_map`, `xi_search`, `xi_world`, and `xi_test` linked.
- Pre-correction elemental-arrow/profile run: expected exit `1` (48/51);
  exactly the three lazy-power ordering cases failed.
- Corrected and final post-build elemental-arrow/profile runs: exit `0`
  (51/51 each).
- Final Phase A framework, Acid/Sleep Bolt ranged, and NM regression group:
  exit `0` (39/39).
- Final battle-action packet regression: exit `0` (65/65 `0x028` cases).
- Inventory generation twice produced identical CSV and Markdown SHA-256
  hashes; write, `--check`, and exact-profile sanity all exited `0`.
- Changed Lua passed the repository `luacheck`, style, binding-usage, and
  mob-skill-purity wrapper. Changed Python passed Black and pylint.
- Changed C++ was formatted, and `git diff --check` passed.
- The isolated current-SQL database, its two grants, the disposable build,
  staged executables/PDBs, and temporary logs were removed. The owner's
  working `xidb` was not modified.

### Phase B1 assessment

The bounded Phase B1 engineering pass is complete. Fire, Ice, and Lightning
Arrow are **hardened and profiled but not retail-formula-corrected**. Element
identity and deterministic framework ownership are supported; proc chance,
7-10 power, stat/accuracy model, resist floor, MAB, staff/affinity/day-weather,
and defensive interactions remain compatibility behavior or `VERIFY_LIVE`.

Phase B2 must select another bounded family or obtain a controlled retail
dataset for these parameters. It must not generalize this profile to later
elemental arrows without separate evidence.

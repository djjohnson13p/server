# VZ-COMBAT-001 — Item Additional-Effect Framework

## Identification

- **ID:** `VZ-COMBAT-001`
- **Expansion scope:** Shared core, inventoried for Vanilla/Rise of the Zilart
- **Area:** Combat / equipment / ammunition / additional effects
- **Baseline status:** `INACCURATE`
- **Current status:** `PARTIALLY_CORRECTED_PHASE_B4`
- **Severity:** `MAJOR`
- **Confidence:** `HIGH` for the Phase A inventory, call paths, and corrected deterministic defects; item-specific retail numerics remain mixed
- **Disposition:** `PHASE_B5_AND_CONTROLLED_RETAIL_EVIDENCE_REQUIRED`

Phase A and the bounded Phase B1 through B4 implementations are complete
engineering passes. The item families are hardened and explicitly profiled,
not declared retail-formula-correct. The full finding remains partial.

## Phase A inventory

The generated inventory is the repository record:

- `retail_parity/vanilla_zilart/artifacts/VZ-COMBAT-001-item-inventory.csv`
- `retail_parity/vanilla_zilart/artifacts/VZ-COMBAT-001-item-inventory.md`
- `tools/retail_parity/generate_item_additional_effect_inventory.py`

It inspects active `ITEM_ADDEFFECT_*`, `ITEM_SUBEFFECT`, latent, per-item Lua,
and equipment-spikes sources. It also retains the two issue-#7899 ammunition
entries that have no active selector, rather than silently omitting them.
Stable regeneration currently produces:

- 420 total rows: 18 maintained `VANILLA_OR_ZILART`, one `VANILLA`, one
  `ZILART`, three `LATER_EXPANSION`, and 397 `ERA_UNRESOLVED`;
- 183 damage, 124 debuff, 46 equipment-spikes, 27 scripted, 13 HP-drain,
  five Dispel, six NM-specific, four TP-drain, two MP-drain, two Death, two
  HP/MP/TP-drain, and the smaller remaining families recorded in the artifact;
- 373 SQL-only, 22 SQL-plus-item-script, eight SQL-plus-status-profile, three
  SQL-plus-single-drain-profile, three SQL-plus-combined-drain-profile, five
  SQL-plus-latent, three SQL-plus-scripted-profile, one script-only, and two
  issue-evidence-only rows;
- 122 configuration-error, 185 era-unresolved, 106 `VERIFY_LIVE`, two
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

Acid Bolt and Sleep Bolt use the validated generic status framework with the
item-native A-rank evidence boundary recorded below. Their governing stat and
configured proc/power/duration remain compatibility numerics.

### `VERIFY_LIVE`

Fire Arrow, Ice Arrow, and Lightning Arrow use the Phase B1 scripted profile
path described below. Kabura Arrow, Patriarch Protector's Arrow, Blind Bolt,
Venom Bolt, Poison Arrow, Sleep Arrow, Demon Arrow, and Spartan Bullet use the
Phase B2 status-ammunition profile described below. Their exact proc, level,
stat, accuracy, element, power/duration, resistance, and presentation formulas
remain compatibility behavior or `VERIFY_LIVE`.

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

Phase B2 selected the bounded maintained status-ammunition family below. It
does not generalize the Phase B1 profile to later elemental arrows.

## Phase B2 — Maintained status ammunition

### Evidence and bounded scope

The item-specific ledger is:

- `retail_parity/vanilla_zilart/artifacts/VZ-COMBAT-001-status-ammunition-evidence.md`

It records every required field separately for Kabura Arrow 17325, Patriarch
Protector's Arrow 17329, Blind Bolt 18150, Venom Bolt 18152, Poison Arrow
18157, Sleep Arrow 18158, Demon Arrow 18159, and Spartan Bullet 18160.
Effect identities are supported by historical/community item references.
No controlled eight-item retail dataset was found for proc, level correction,
rank/stat, action element, power, duration, or resistance distribution.

Issue #7899 and all public attachments were reviewed. Its controlled A-rank
dataset belongs to Acid/Sleep Bolt and was not generalized. Its Spartan logs
support a cooldown and roughly four-to-five-second visible Stun but do not
resolve a safe complete model. Japanese summaries describe an approximately
30-second target-wide Spartan-only lockout; dated FFXIAH comments conflict
between a 55/132 count and a first-eligible-shot/10-20-second model. The
active 10%/five-second/no-cooldown behavior is therefore recorded as known
incomplete compatibility, not silently presented as retail.

### Authoritative status-ammunition profile

A validated `VZ_STATUS_AMMUNITION` registry owns exactly the eight item
identities and machine-readable field classifications. SQL remains the sole
numeric source. Runtime resolution exposes and validates:

- successful-ranged-hit trigger and inherited distance;
- compatibility proc chance and level correction;
- legacy A-rank/INT accuracy input, with dSTAT explicitly unused by status
  application;
- configured and effective action element;
- status, power, duration, resist floor, guard, overwrite, and application
  policy;
- subeffect/message presentation and unresolved-evidence fields;
- explicit `NOT_IMPLEMENTED_VERIFY_LIVE` Spartan cooldown policy.

Validation rejects malformed or duplicate profiles, SQL/profile drift, later
Gashing/Abrasion/Oxidant ammunition, and accidental Acid/Sleep migration.
The inventory generator emits exact profile source, profile family, field
classifications, effective policy, both test references, and precise
subeffect names for the eight scoped items while retaining a shared label for
other subeffect-18 statuses.

### Deterministic status-application correction

The inherited status helper selected and removed Defense/Evasion/Attack Boost
before the authoritative `addStatusEffect` call. A late status-container
rejection could therefore mutate an unrelated boost while returning no
effect. A valid regression models the authoritative rejection after every
earlier guard and proves the pre-correction caller removes the boost.

The status helper is now pure policy lookup. The DEBUFF handler:

1. runs the existing immunity, trait, nullification, and one resist check;
2. computes tick and prospective opposing boost;
3. calls the authoritative status container exactly once;
4. returns no presentation and removes nothing on rejection;
5. removes the opposing boost exactly once only after successful application;
6. returns one ordinary status additional-effect result.

No status overwrite rule, SQL numeric, resist tier, proc rate, element, or
Spartan cooldown was changed.

### Effective compatibility policies

| Item | Proc / level | Effective element | Status power / duration | Classification |
|---|---|---|---|---|
| Kabura Arrow | 95%, adjustment 5 | Wind-associated | Silence 1 / 60 s | `VERIFY_LIVE` |
| Patriarch Protector's Arrow | 95%, adjustment 5 | Ice-associated | Paralysis 30 / 30 s | `VERIFY_LIVE` |
| Blind Bolt | 100%, adjustment 5 | Explicit Dark | Blind 10 / 30 s | `VERIFY_LIVE` |
| Venom Bolt | 100%, adjustment 5 | Explicit Water | Poison 4, 3 s tick / 30 s | `VERIFY_LIVE` |
| Poison Arrow | 95%, adjustment 5 | Water-associated | Poison 4, 3 s tick / 30 s | `VERIFY_LIVE` |
| Sleep Arrow | 95%, adjustment 5 | `NONE` compatibility | Sleep 0 / 25 s | `VERIFY_LIVE` |
| Demon Arrow | 95%, adjustment 5 | Water-associated | Attack Down 12 / 60 s | `VERIFY_LIVE` |
| Spartan Bullet | 10%, adjustment 5 | Thunder-associated | Stun 10 / 5 s, no cooldown | `VERIFY_LIVE`, known incomplete |

All use legacy A-rank/INT status accuracy, full or half duration only, status
guards, and the status container. Those values are test-backed current
contracts, not retail conclusions.

### Behavioral coverage

Real ranged-action cases prove, for all eight items:

- one successful physical hit reaches exactly one validated item profile;
- one matching status subeffect/message/effect ID is serialized in one
  `RANGED_FINISH` action;
- one status application and one normal ammunition consumption occur;
- each physical miss consumes the ordinary shot but performs no status work.

Representative real-state cases additionally cover initial out-of-range
rejection, target despawn, level restriction, longer valid range, Recycle,
and Unlimited Shot. Direct profile cases cover exact scope, duplicate/
malformed/later-item rejection, Acid/Sleep separation, one proc roll, zero
downstream work on failure, every per-item proc boundary, every item's
full/half/below-floor outcome, every immunity/trait/nullification guard, all
active resist tiers and the half-duration floor, rank/stat/element/effect
transport, all eight power/duration/tick values, application rejection, and
post-success opposing-boost removal.

Existing Acid/Sleep, Phase B1, NM, and complete 0x028 packet groups remain
regression authorities. Ranged weapon-skill effect behavior and exact Spartan
cooldown ownership are not claimed test-backed by this pass.

### Phase B2 assessment

Phase B2 is `PARTIAL`: the eight maintained items now have explicit validated
policy, real ranged coverage, deterministic application ownership, generated
inventory fields, and a ranked evidence ledger. They are not
retail-formula-correct. Controlled captures must resolve proc versus resist,
rank/stat/element, power/duration/overwrite, exact presentation, ranged
weapon-skill behavior, and the Spartan target/source cooldown contract.

Phase B3 should select one new bounded family, preferably the maintained
drain items, without beginning Dispel, Death, self-buffs, spikes, Elemental
Spirits, or Ballista in the same pass.

## Phase B3 — Single-resource HP, MP, and TP drain weapons

### Scope and evidence

Phase B3 covers exactly Aspir Knife 16509, Bloody Rapier 16528, and Shinsoku
17823. The ranked evidence ledger is:

- `retail_parity/vanilla_zilart/artifacts/VZ-COMBAT-001-single-resource-drains-evidence.md`

Contemporary evidence establishes Bloody Rapier as Vanilla and identifies
its HP-drain effect. A dated pre-Chains-of-Promathia update record establishes
Shinsoku as Zilart-era and community references identify TP absorption.
Contemporary 2003 mission discussion establishes Aspir Knife's Zilart-era
presence and MP-drain identity, but does not distinguish original-release
from Zilart introduction, so its era remains `ERA_UNRESOLVED`.

No controlled retail packet dataset establishes proc rate, level correction,
fixed/random amount, accuracy/skill, governing stat/dSTAT, Dark element,
resistance, SDT, staff/affinity/day/weather, nullification/absorption,
HP-oriented defenses, undead behavior, resource-cap presentation,
main/off-hand priority, or exact 0x028 bytes. These fields remain
`VERIFY_LIVE`; current SQL numerics and inherited multiplier behavior are
explicit compatibility, not retail conclusions.

### Reproduced deterministic defect

The pre-change Shinsoku SQL row had type 7 and amount/chance data but no
`ITEM_SUBEFFECT` or explicit element. A direct real handler regression
reproduced TP removal and amount 10 with subeffect 0 instead of `TP_DRAIN`.
The generic handler happened to force Dark at runtime, concealing the missing
data ownership. Phase B3 adds `TP_DRAIN`, explicit Dark compatibility, and
corrects only the stale chance comment from 5% to the existing value 8%. It
does not change Shinsoku's active 8%/10 numeric behavior.

### Authoritative profile and transfer ownership

`additional_effect_profiles.lua` now owns one validated
`VZ_SINGLE_RESOURCE_DRAIN` registry with exactly:

| Item | Resource | Proc / level | Base | Equip | Effective element | Classification |
|---|---|---|---|---|---|---|
| Aspir Knife | MP | 10%, adjustment 0 | fixed 3 | main or off hand | Dark compatibility | `VERIFY_LIVE`; era unresolved |
| Bloody Rapier | HP | 5%, adjustment 0 | fixed 10 | main or off hand | Dark compatibility | `VERIFY_LIVE`; Vanilla identity/era supported |
| Shinsoku | TP | 8%, adjustment 0 | fixed 10 | main only | Dark compatibility | `VERIFY_LIVE`; Zilart identity/era supported |

Every profile exposes item/resource identity, proc and level policy,
trigger/equip policy, skill/stat/dSTAT/MAB policy, element and resistance
policy, nullification/absorption/undead policy, target and attacker caps,
base/scaling/defense policy, application ownership, presentation, per-field
classification, and unresolved evidence. Validation rejects unsupported,
malformed, duplicate, cross-resource, presentation, element, and SQL/profile
drift. Combined drains, Bloody Bolt and other scripted drains, and later
items remain outside the registry.

`executeSingleResourceDrain` is the exact-scope mutation owner. After ordinary
item/profile/level/target validation and one proc roll, it:

1. rejects dead and undead targets before calculation;
2. performs the preserved legacy calculation once;
3. clamps negative compatibility results to zero;
4. caps removal to the target's actual HP, MP, or TP;
5. mutates the target once and credits the attacker once;
6. returns the resource-specific subeffect/message with actual target
   resource removed.

HP uses the authoritative magical-Dark damage application once; MP and TP
mutate only their own resource containers. Attacker resource caps do not
change the packet amount, which remains actual target removal. This is a
test-backed compatibility contract, not proof of retail cap presentation.

### Behavioral coverage

The focused Phase B3 suite contains 58 cases:

- exact three-item registration, required fields, SQL consistency,
  malformed/duplicate/resource/presentation rejection, and explicit
  combined/scripted/later exclusions;
- one proc roll and no downstream work on failure for every item;
- every configured proc boundary and the existing item-level gate;
- one calculation and one transfer for HP, MP, and TP;
- below/equal/above target-resource caps, attacker near/full caps, and
  zero-resource compatibility presentation;
- full, half, quarter, eighth, and below-floor outcomes with rounding;
- the inherited resistance/SDT/environment/defense stack once;
- nullification once and negative absorption clamped to no transfer;
- actual undead rejection for all three and dead-target rejection before
  proc/calculation;
- MP/TP isolation from HP and from the other resources;
- real main-hand attacks for all three and real off-hand attacks for Aspir
  Knife and Bloody Rapier;
- real physical miss, below-level, target-despawn, Enspell-priority,
  item-priority, multi-attack, and ordinary-melee paths;
- one normal 0x028 additional-effect result per eligible swing with
  resource-specific subeffect, message, and actual removed amount.

An executor observer records resource values immediately around the real
production call so unrelated world regeneration cannot falsify the packet/
mutation comparison. It preserves all three production return values and
does not bypass the real melee state, item selection, handler, mutation, or
0x028 serialization.

The direct HP case proves available-HP capping and already-dead rejection.
The real-melee fixture does not model a deterministic final lethal physical
swing without additional unrelated combat setup, so exact lethal packet
ordering remains unclaimed. Existing Phase A, elemental-arrow, status-
ammunition, Acid/Sleep, NM, and complete 0x028 suites remain regression
authorities.

### Phase B3 assessment

Phase B3 is `COMPLETE_PHASE_B3` as a bounded evidence/profile/framework pass:
the exact family has authoritative validated policy, one deterministic
transfer owner, Shinsoku's missing presentation data is corrected, real
melee behavior is covered, and unsupported mechanics are explicitly
preserved as compatibility.

The three items are not classified retail-formula-correct. Controlled retail
captures must still resolve every `VERIFY_LIVE` field listed in the ledger,
including proc versus resist, amount/scaling, Dark-element ownership,
resource-cap/zero presentation, undead behavior, and HP lethal ordering.
`VZ-COMBAT-001` therefore remains partially corrected overall.

Phase B4 should be a separate bounded family, preferably the maintained
combined HP/MP and HP/MP/TP drain configuration group. It must not begin
Dispel, Death, self-buffs, spikes, Elemental Spirits, Ballista, or another
audit area in the same pass.

## Phase B4 — Combined-resource HP/MP and HP/MP/TP drains

### Scope, era, and evidence

Phase B4 covers exactly Hofud 17745, Vampirism 20706, and Crepuscular Knife
21585. The ranked field-by-field ledger is:

- `retail_parity/vanilla_zilart/artifacts/VZ-COMBAT-001-combined-resource-drains-evidence.md`

Independent era evidence establishes Hofud as 2007 Einherjar content,
Vampirism as 2015 Sinister Reign content, and Crepuscular Knife as 2021 Wyrm
God content. All three are `LATER_EXPANSION`; none is added to the 18-item
maintained Vanilla/Zilart count. This is consequently a shared-core
framework-hardening pass, not a Vanilla/Zilart item-formula correction.

The public mechanics evidence is insufficient for a numeric correction.
Hofud's Japanese summary reports roughly 20% and unequal HP/MP maxima without
a linked dataset. Vampirism's page claims some effect on every eligible hit
without separating proc, resistance, or branch selection. Contemporary
Crepuscular discussion conflicts between equal branches and roughly
45% HP/45% MP/10% TP, while another summary reports HP/MP around 5 and TP
0–100. No accessible source publishes a controlled counted trial ledger or
packet capture. Existing SQL numerics and selection therefore remain
compatibility and `VERIFY_LIVE`.

### Active configurations and authoritative profiles

| Item | Resource set | Active proc / amount | Subeffect | Era | Profile |
|---|---|---|---|---|---|
| Hofud 17745 | HP or MP | 15%, fixed 15 | Darkness Damage | 2007, later expansion | `VZ_COMBINED_RESOURCE_DRAIN` |
| Vampirism 20706 | HP, MP, or TP | 100%, fixed 20 | MP Drain | 2015, later expansion | `VZ_COMBINED_RESOURCE_DRAIN` |
| Crepuscular Knife 21585 | HP, MP, or TP | 15%, fixed 15 | Darkness Damage | 2021, later expansion | `VZ_COMBINED_RESOURCE_DRAIN` |

SQL remains the sole numeric source. Each independently addressable policy
records resource set, introduction evidence, trigger/equip, proc/level,
selection distribution/timing, retry/empty/resisted/nullified behavior,
skill/stat/dSTAT, configured/effective element, resistance/null/absorb/
undead, amount/scaling/defenses, target/attacker caps, outcome ownership,
subeffect/resource message/packet amount, per-field classifications, and
unresolved evidence.

Registry construction and runtime validation reject unsupported IDs,
duplicates, malformed fields, resource-set/family mismatches, branch/message
mismatches, and SQL/profile drift. The B3 single-resource registry, Bloody
Bolt and other scripts, and every unrelated combined-drain item remain
outside the registry.

### Selection and transfer architecture

The explicit compatibility policy is:

`UNIFORM_SINGLE_BRANCH_NO_RETRY_COMPATIBILITY`

After normal hit, item, level, target, and profile validation:

1. `xi.additionalEffect.attack` owns exactly one configured item-proc roll.
2. Proc failure performs no branch selection or resource work.
3. Success selects once: HPMP maps 1 to HP and 2 to MP; HPMPTP maps 1 to HP,
   2 to MP, and 3 to TP.
4. The selected branch runs through one shared transfer primitive also used
   by B3 after B3 has already selected its fixed resource.
5. Dead/undead guards, one legacy calculation, negative-result clamp, target
   cap, one target mutation, and one attacker credit occur in that order.
6. No other resource is attempted after an empty, resisted, nullified,
   absorbed, or undead-blocked branch.
7. One result retains the item-configured subeffect, uses the selected
   resource message, and reports actual target resource removed.

This refactor does not route combined items through the single-resource item
registry and does not change the B3 external contract.

### Behavioral coverage

The focused B4 suite contains 55 cases across direct profile/transfer and
real melee paths:

- exact three-profile scope, complete required fields, SQL consistency,
  duplicate/malformed/unsupported/resource/message/element drift rejection,
  and separation from B3/scripted items;
- every HP/MP and HP/MP/TP selector, invalid selectors, one proc and one
  selection, Hofud/Crepuscular proc failure, and Vampirism's configured 100%
  boundary;
- below/equal/above/zero resources, attacker near/full caps, lethal direct HP
  boundaries, every configured resistance tier/floor, nullification,
  absorption, dead/invalid/undead targets, no retry, and complete resource
  isolation;
- real main- and off-hand attacks for all three, one ordinary 0x028 result,
  physical misses, level gates, target despawn, Enspell priority,
  multi-attack cardinality, and ordinary melee.

The intentional B3 assertion update recognizes that the three items now
belong to the separate combined registry. Its external resource, packet, and
selection behavior is unchanged and the complete 58-case B3 group remains a
regression requirement.

### Aggregate defect found before B4

The mandatory pre-edit 198-test single-process aggregate reproduced a Windows
access violation only when earlier suites stacked Lua doubles on the same
path. `MockManager::restoreAll()` restored doubles grouped by type and in
installation order, so a Lua global could be left pointing at a freed prior
stub. Loading the NM group changed heap reuse and made the stale pointer
deterministic.

The test framework now records one combined installation sequence and
restores all doubles in strict reverse order before freeing them. Lua
regressions cover stacked stub/stub and stub/spy paths. The corrected
mandatory aggregate passed 198/198 before Phase B4 production edits. This was
an isolation defect, not an item-formula change, and is committed separately.
Post-edit and final post-build aggregate repeats also passed 198/198; the
final repeat completed in 132.916 seconds.

### Phase B4 assessment

Phase B4 is `COMPLETE_PHASE_B4` as a bounded shared-core profile/framework
pass. The exact three items have authoritative validated policy, one
selection owner, one transfer owner, generated inventory/evidence ownership,
and real packet-path coverage. They remain `LATER_EXPANSION`, and no active
numeric, branch distribution, retry policy, resistance formula, or client
presentation is claimed retail-correct.

`VZ-COMBAT-001` remains partially corrected. Controlled captures must still
resolve every `VERIFY_LIVE` field in the ledger, especially proc versus
resist, nonuniform branch hypotheses, retry/order, per-resource amounts,
magic accuracy/stat/element, multi-attack eligibility, empty/full resources,
undead/null/absorb behavior, and exact 0x028 presentation.

Phase B5 should select one new bounded inventory family or configuration
group. It must not combine Dispel, absorb-status, Death, self-buffs, equipment
spikes, Elemental Spirits, Ballista, or another audit area in one pass.

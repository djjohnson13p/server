# VZ-COMBAT-001 Phase B2 Status-Ammunition Evidence

## Scope and conclusion

This ledger covers exactly eight maintained Vanilla/Rise of the Zilart
ammunition items:

| ID | Item | Additional effect |
|---:|---|---|
| 17325 | Kabura Arrow | Silence |
| 17329 | Patriarch Protector's Arrow | Paralysis |
| 18150 | Blind Bolt | Blind |
| 18152 | Venom Bolt | Poison |
| 18157 | Poison Arrow | Poison |
| 18158 | Sleep Arrow | Sleep |
| 18159 | Demon Arrow | Attack Down |
| 18160 | Spartan Bullet | Stun |

The effect identities are well supported. The accessible material does not
provide controlled retail datasets for the eight items' proc, level
correction, magic-accuracy inputs, status power, duration, or resist
distribution. Those values therefore remain explicit SQL compatibility
behavior and `VERIFY_LIVE`, not retail-formula claims.

Spartan Bullet is a known special case. Multiple sources support a
target-scoped lockout after a successful Stun, but they conflict on its
duration and do not fully isolate source ownership, weapon-skill behavior, or
interaction with unrelated Stun sources. This pass does not manufacture that
model. The active 10% chance and five-second Stun remain compatibility
behavior, and the missing cooldown remains an explicit defect/retail-capture
requirement.

## Evidence method and ranking

Evidence was ranked as follows:

1. controlled retail packet logs or test datasets;
2. official documentation or contemporaneous official statements;
3. contemporary reports with repeatable methods and results;
4. community reference summaries;
5. memory, unsourced statements, or emulator implementations.

Current LandSandBoat code and SQL were used only to reproduce and classify
active behavior. They were not treated as retail evidence. No other private
server implementation was used.

## Source register

| Ref | Source | Type / date | Contemporary? | Controlled trials? | Evidentiary use |
|---|---|---|---|---|---|
| S1 | [LandSandBoat issue #7899](https://github.com/LandSandBoat/server/issues/7899) and all public comments | Issue report, 2024-2026 | No | Acid/Sleep Bolt dataset only; partial Spartan logs | Item-native A-rank evidence belongs only to Acid/Sleep Bolt. Spartan logs support a cooldown hypothesis and roughly four-to-five-second visible Stun, but not a complete production model. |
| S2 | Seven issue attachments downloaded from issue #7899 (`ranged1.png`, `ranged2.png`, `ranged3.png`, `spartan-ws.png`, `spartan-resist.png`, `spartan-log1.png`, `spartan-log2.png`) | Retail screenshots/logs | Mixed | Controlled for Acid/Sleep; observational for Spartan | Reviewed locally. The three ranged datasets do not transfer their rank result to the eight scoped items. Spartan images show successful and suppressed shots but do not resolve the exact cooldown contract. Temporary copies are not tracked. |
| S3 | [FF11 term dictionary: additional effects](https://wiki.ffo.jp/html/149.html) | Maintained Japanese community reference | No | No | Says ammunition effects can ride ranged weapon skills; describes an approximately 30-second Spartan target lockout shared across shooters and isolated from unrelated Stun sources. |
| S4 | [FF11 term dictionary: bullets](https://wiki.ffo.jp/html/18656.html) | Maintained Japanese historical summary | No | No | Dates Spartan Bullet to 2003-10-21 and describes a 2004-12-09 change that sharply reduced activation for about 30 seconds after Stun. |
| S5 | [FFXIAH Spartan Bullet](https://www.ffxiah.com/item/18160/spartan-bullet) | Dated community comments, 2009-2010 | Near-contemporary | One 132-shot count; method incomplete | Contains conflicting claims: 55/132 (~42%) in 2009 versus a 2010 first-eligible-shot/10-20-second cooldown model. Useful conflict evidence, not a formula. |
| S6 | [FF11 term dictionary: arrows](https://wiki.ffo.jp/html/1738.html) | Maintained Japanese community reference | No | No | Confirms listed effect identities for Poison/Sleep/Demon and the Patriarch arrow family; not numeric proof. |
| S7 | [FF11 term dictionary: Kabura Arrow](https://wiki.ffo.jp/html/5019.html) | Maintained Japanese item reference | No | No | Confirms Silence identity and records a qualitative claim of extremely low activation; conflicts with active 95% SQL and later general Silence claims. |
| S8 | [FF11 term dictionary: ranged attacks](https://wiki.ffo.jp/html/1734.html) | Maintained Japanese mechanics summary | No | No | Says ammunition effects are generally high-probability and may ride ranged weapon skills. It does not provide item-specific counts. |
| S9 | Modern item references: [Kabura Arrow](https://www.bg-wiki.com/ffxi/Kabura_Arrow), [Blind Bolt](https://www.bg-wiki.com/ffxi/Blind_Bolt), [Venom Bolt](https://www.bg-wiki.com/ffxi/Venom_Bolt), [Poison Arrow](https://www.bg-wiki.com/ffxi/Poison_Arrow), [Sleep Arrow](https://www.bg-wiki.com/ffxi/Sleep_Arrow), [Demon Arrow](https://www.bg-wiki.com/ffxi/Demon_Arrow), [Spartan Bullet](https://www.bg-wiki.com/ffxi/Spartan_Bullet) | Modern community item summaries | No | No | Corroborate effect identity and displayed equipment data only. Uncited numeric statements are hypotheses. |
| S10 | Active repository SQL, profile executor, ranged state, and packet tests | Emulator implementation | No | Deterministic framework tests only | Establishes current behavior and regressions, never retail truth. |

Searches also covered accessible archived discussions, Japanese references,
modern item pages, and the public issue attachments. No official formula,
contemporaneous packet capture, or controlled eight-item dataset was found.
Some older forum hosts were inaccessible or blocked automated access; their
uncorroborated snippets were not used to select production numerics.

## Per-item evidence matrix

### Identity, era, and effect

| Item | Introduction-era evidence | Effect-element evidence | Confidence / conclusion |
|---|---|---|---|
| Kabura Arrow 17325 | Maintained V/Z scope manifest; historical item references establish pre-75-cap use, but no accessible official introduction notice was found. | Silence is Wind-associated in the status system; no controlled item-action-element capture was found. | Effect identity high; exact introduction date and action element unresolved. |
| Patriarch Protector's Arrow 17329 | Rank-7 conquest-reward history and level-60 equipment context support the original-era family; no accessible official introduction notice was found. | Paralysis is Ice-associated; no item-specific resist dataset was found. | Effect identity high; exact date and action element unresolved. |
| Blind Bolt 18150 | Maintained V/Z scope and longstanding pre-cap crossbow references; no official introduction notice found. | Active data explicitly keys Dark; community item identity confirms Blind, not the resist key. | Effect identity high; Dark action element remains compatibility. |
| Venom Bolt 18152 | Maintained V/Z scope and longstanding pre-cap crossbow references; no official introduction notice found. | Active data explicitly keys Water; Poison is Water-associated. | Effect identity high; action element remains compatibility. |
| Poison Arrow 18157 | Maintained V/Z scope and historical arrow lists; no official introduction notice found. | Poison is Water-associated; the item has no explicit SQL element. | Effect identity high; associated-element fallback remains compatibility. |
| Sleep Arrow 18158 | Maintained V/Z scope and historical arrow lists; no official introduction notice found. | Sleep is a special case that uses the supplied action element. The item supplies none, so active behavior resolves `NONE`. | Effect identity high; action element is specifically unresolved. |
| Demon Arrow 18159 | Maintained V/Z scope and historical arrow lists; no official introduction notice found. | Attack Down is Water-associated; the item has no explicit SQL element. | Effect identity high; associated-element fallback remains compatibility. |
| Spartan Bullet 18160 | S4 dates introduction to 2003-10-21 and a cooldown change to 2004-12-09. | Stun is Thunder-associated; no controlled item-specific resist dataset was found. | Era/effect identity medium-high; action element and formula unresolved. |

### Proc, level, rank, stat, resistance, and status values

| Item | Proc / level behavior | Skill, stat, and dSTAT | Resistance / nullification | Power and duration | Classification |
|---|---|---|---|---|---|
| Kabura Arrow | Active 95%, level adjustment 5. S7 qualitatively says activation is extremely rare, conflicting with SQL. | Active A-rank/INT accuracy defaults; no DSTAT is used by the status handler. | Wind-associated status magic; full or half duration only. | Power 1, 60 seconds. No controlled support. | All numeric fields `VERIFY_LIVE`; SQL compatibility retained. |
| Patriarch Protector's Arrow | Active 95%, adjustment 5; no controlled rate. | Active A-rank/INT defaults; dSTAT not used by status application. | Ice-associated status magic; full or half duration only. | Power 30, 30 seconds. No controlled support. | `VERIFY_LIVE`; compatibility retained. |
| Blind Bolt | Active 100%, adjustment 5; issue #7899 did not test this item. | Active A-rank/INT accuracy. SQL has `DSTAT=INT`, but dSTAT only alters the unused damage field for the DEBUFF handler. | Explicit Dark key; full or half duration only. | Power 10, 30 seconds. No controlled support. | `VERIFY_LIVE`; do not transfer Acid/Sleep A-rank evidence. |
| Venom Bolt | Active 100%, adjustment 5; no controlled rate. | Active A-rank/INT accuracy. SQL `DSTAT=INT` does not affect the applied Poison. | Explicit Water key; full or half duration only. | Power 4 per 3-second tick, 30 seconds. Community summaries agree, but no controlled dataset was found. | Identity high; all numerics `VERIFY_LIVE`. |
| Poison Arrow | Active 95%, adjustment 5; no controlled rate. | Active A-rank/INT defaults; dSTAT not used. | Water-associated fallback; full or half duration only. | Power 4 per 3-second tick, 30 seconds. No controlled support. | `VERIFY_LIVE`; compatibility retained. |
| Sleep Arrow | Active 95%, adjustment 5; no controlled rate. | Active A-rank/INT defaults; dSTAT not used. | Effective element `NONE`; full or half duration only. | Power 0, fixed 25-second SQL duration. Modern summaries give broad approximate ranges, not a controlled fixed value. | `VERIFY_LIVE`; element/duration especially require capture. |
| Demon Arrow | Active 95%, adjustment 5; no controlled rate. | Active A-rank/INT defaults; dSTAT not used. | Water-associated fallback; full or half duration only. | Power 12 (displayed as 12.5%/32-of-256 in some summaries), 60 seconds. No controlled support. | `VERIFY_LIVE`; do not convert uncited percentages into SQL. |
| Spartan Bullet | Active 10%, adjustment 5. S3-S5 conflict with this simple chance model and support a missing cooldown. | Active A-rank/INT defaults; dSTAT not used. | Thunder-associated fallback; full or half duration only. Issue images say resistance matters but do not yield a formula. | Power 10, five seconds. Logs visually support roughly four-to-five seconds; exact packet timing is not isolated. | `VERIFY_LIVE`; known incomplete behavior retained pending a safe cooldown contract. |

For all eight items, the active guards run once in this order: effect
immunity, effect-resistance trait, effect nullification, one magic-resist
calculation, then one status-container application. Resist results below
one-half return no additional-effect presentation. A half resist floors the
scaled duration. These are deterministic compatibility contracts, not claims
that retail uses exactly this tier floor or order.

### Trigger, resource, priority, and presentation behavior

| Field | Evidence and conclusion for each of the eight items |
|---|---|
| Trigger and distance | Production C++ invokes the item handler only after a successful physical ranged hit. Miss, invalid/out-of-range start, mid-shot invalidation, and level restriction do not independently trigger the status. The effect inherits the physical shot's range decision. `FRAMEWORK_CORRECT_LEGACY_NUMERICS`. |
| Ammunition consumption | The ordinary ranged subsystem owns consumption, Recycle, and Unlimited Shot. The profile does not consume ammunition. `FRAMEWORK_CORRECT_LEGACY_NUMERICS`. |
| Weapon skills / nonstandard attacks | S3/S8 say ammunition effects may ride ranged weapon skills, but this pass does not change or claim the current nonstandard-attack path. Spartan issue images are not sufficient to define every weapon-skill boundary. `VERIFY_LIVE`. |
| Priority | Existing ranged selection remains ammo first, then ranged weapon; only one active item handler is invoked. Acid/Sleep Bolt and Phase B1 elemental-arrow regressions remain separate. Exact retail priority beyond existing behavior is unresolved. |
| Immunity and trait resistance | Existing status helpers suppress presentation and application. `FRAMEWORK_CORRECT_LEGACY_NUMERICS` for engine consistency; exact retail ordering remains unverified. |
| Nullification and absorption | Status nullification uses the status helper. Elemental damage absorption is not applicable to these statuses. No damage/healing mutation occurs. |
| Overwrite and opposing boost | The authoritative status container decides whether application succeeds. Defense/Evasion/Attack boosts are removed only after the corresponding Down effect applies successfully. Failed application produces neither presentation nor false removal. Framework-correct and behaviorally tested. |
| Subeffect and message | Each item uses its matching status subeffect and `ADD_EFFECT_STATUS_2` with the effect ID in the normal ranged 0x028 additional-result fields. Framework-correct; exact retail client presentation still needs capture. |
| Level sync | The effect is blocked when effective main level is below item level; the physical ranged shot and ordinary ammo consumption continue. Framework-correct compatibility. |

## Spartan Bullet conflict ledger

| Claim | Evidence | Assessment |
|---|---|---|
| Simple 10% chance, five-second Stun, no cooldown | Active SQL/runtime | Current compatibility only; not retail evidence. |
| 55 successes in 132 shots (~42%) | Dated 2009 FFXIAH comment (S5) | A count is given, but target, eligibility intervals, misses, and cooldown handling are not controlled. |
| First eligible shot always Stuns, then 10-20 second lockout | Dated 2010 FFXIAH comment (S5) | Repeatable hypothesis, conflicts with S3/S4 and modern issue estimates. |
| Approximately 30-second target-wide Spartan-only lockout | Japanese mechanics/history summaries (S3/S4) | Strongest accessible architectural description, but not a controlled packet dataset. |
| Random 20-30 second cooldown and about four-second Stun | Issue #7899 comments and attachments (S1/S2) | Modern observations support a cooldown and visible duration, but exact interval/ownership remain incomplete. |
| Works through ranged weapon skills | S3/S8 and issue attachment | Likely, but complete packet/priority semantics are not isolated. |

Required controlled retail follow-up:

1. record physical hit/miss and 0x028 additional fields for every shot;
2. separate shooter-local, target-local, and global cooldown ownership with
   two shooters and two targets;
3. bracket the cooldown at one-second intervals after a confirmed Stun;
4. repeat with ranged weapon skills and ordinary shots;
5. interleave spell Stun and a different Stun additional-effect source;
6. vary Thunder resistance/magic evasion without changing hit rate;
7. record visible effect removal and packet timestamps separately.

Until those trials resolve the conflicts, a guessed cooldown would be less
reliable than the explicitly labeled compatibility behavior.

## Selected Phase B2 production policy

One validated `VZ_STATUS_AMMUNITION` registry owns the eight identities and
their evidence classifications. Numeric proc, level, rank/stat, element,
power, and duration inputs still come from the existing SQL and are checked
against the explicit compatibility profile so drift fails visibly.

The production correction in this phase is architectural and deterministic:
status application occurs once, and any opposing boost is removed only after
the status container accepts the new Down effect. The phase does not change
SQL numerics, add a Spartan cooldown, transfer Acid/Sleep evidence, or migrate
later ammunition.

Overall Phase B2 classification: `PARTIAL`. The framework and inventory are
hardened and the eight items are explicit, but retail numeric correctness and
the Spartan cooldown remain unresolved.

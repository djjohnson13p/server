# VZ-COMBAT-001 Combined-Resource Drains Evidence

## Scope and decision rule

This ledger covers only:

- Hofud (17745), HP or MP drain;
- Vampirism (20706), HP, MP, or TP drain;
- Crepuscular Knife (21585), HP, MP, or TP drain;
- the active HP/MP and HP/MP/TP selection architecture used by those items.

All three items postdate Rise of the Zilart. They are therefore
`LATER_EXPANSION`, not maintained Vanilla/Zilart items. This pass uses them to
harden shared additional-effect ownership and make the active compatibility
policy explicit. It does not claim that their current numbers or branch
selection reproduce retail.

Repository SQL and executable tests establish active server behavior, not
retail behavior. Community summaries and anecdotes can identify hypotheses
but cannot establish a numeric production formula without a controlled,
reviewable dataset.

## Source register

| ID | Source | Type | Source date | Contemporary? | Controlled? | Sample size | Methodology | Evidence rank | What it can support |
|---|---|---|---|---|---|---:|---|---:|---|
| R1 | `sql/item_equipment.sql`, `sql/item_weapon.sql`, `sql/item_mods.sql` at Phase B4 start | Active repository data | 2026-07-29 inspection | No—server configuration | Deterministic configuration inspection | All three rows | Parsed exact item and modifier rows | N/A | Active configuration only |
| R2 | `scripts/globals/additional_effects.lua`, profile resolver, melee C++/Lua integration | Active repository source | 2026-07-29 inspection | No—server implementation | Deterministic source trace | Complete scoped call paths | Traced hit selection, proc, branch, calculation, mutation, and packet return | N/A | Active behavior only |
| R3 | Phase B4 Lua simulation tests | Automated server tests | 2026-07-29 | No—server tests | Yes for server behavior | Every item and every branch | Forced legal boundary rolls through direct and real-melee paths | N/A | Framework properties, not retail formulas |
| H1 | [FF11用語辞典: Hofud](https://wiki.ffo.jp/html_2006/12253.html) | Japanese community reference | Page copyright includes 2011; accessed 2026-07-29 | Partly; item-era page | No controlled dataset linked | Unknown | Summary identifies the 2007-06-06 addition, HP/MP drain, and an uncited report of about 20% with maxima around HP 20/MP 10 | 4 | Identity, effect resource, strong later-era routing; numeric hypothesis only |
| H2 | [BG-Wiki: Hofud](https://www.bg-wiki.com/ffxi/Hofud) | Community reference | Living page; accessed 2026-07-29 | No | No | None reported | Item summary and acquisition route | 4 | Corroborates identity/effect wording, not formula |
| V1 | [Official Aug. 5, 2015 version update](https://forum.square-enix.com/ffxi/threads/47901) | Official update notes | 2015-08-05 | Yes | Not a mechanics trial | N/A | Announces Sinister Reign and its equipment rewards | 2 | Confirms the relevant content release date |
| V2 | [FF11用語辞典: Vampirism](https://wiki.ffo.jp/html/34234.html) | Japanese community reference | Item page tied to 2015 release; accessed 2026-07-29 | Near-contemporary | No | Unknown | Identifies the 2015-08-05 addition, HP/MP/TP drain, and claims some effect occurs on every eligible hit | 4 | Identity/resource and later-era corroboration; 100% is only a hypothesis |
| C1 | [Official July 12, 2021 version update](https://forum.square-enix.com/ffxi/threads/58291) | Official update notes | 2021-07-12 | Yes | Not a mechanics trial | N/A | Adds the Wyrm God battlefield/new items and explicitly names Crepuscular Knife in known-issue text | 2 | Strong 2021 introduction boundary |
| C2 | [FF11用語辞典: Crepuscular Knife](https://wiki.ffo.jp/html/38361.html) | Japanese community reference | Item page tied to 2021 release; accessed 2026-07-29 | Near-contemporary | No | Unknown | Identifies the 2021-07-12 addition; summarizes HP/MP near 5, TP 0–100, and TP branch around 10% | 4 | Identity/resource and numeric hypotheses only |
| C3 | [FFXIAH thief-guide discussion, page 244](https://de.ffxiah.com/forum/topic/36654/for-the-shinies-a-guide-for-thief/244/) | Contemporary community discussion | 2021-07-10 through 2021-07-11 | Yes | Partially observed, not controlled | Not stated | Conflicting claims: 100%/equal branches versus about 45% HP, 45% MP, 10% TP; later posts cite screenshots and magic-accuracy dependence but publish no counted trial ledger | 3–4 | Establishes a conflict and test hypotheses, not a production formula |

No controlled retail packet log, complete counted trial dataset, or official
mechanics formula was found for any scoped item. No other emulator is used as
evidence.

## Hofud (17745)

### Identity and active configuration

R1 establishes a level-75 sword equippable in main or sub, proc family 8
(`HPMP_DRAIN`), configured chance 15, amount 15, level correction 0,
configured element 0/None, and subeffect 8/Darkness Damage. It has one global
handler and no item script.

H1 identifies Hofud as a 2007-06-06 Einherjar-era item and describes its
effect as HP or MP drain. This proves `LATER_EXPANSION`; it does not prove the
active SQL numbers.

| Field | Sources | Confidence | Classification | Conclusion | Unresolved question |
|---|---|---|---|---|---|
| Item ID/name | R1, H1, H2 | High | `EVIDENCE_BACKED` | 17745, Hofud | None |
| Introduction era/date | H1, H2 | High | `EVIDENCE_BACKED`; `LATER_EXPANSION` | Added with 2007-06-06 Einherjar-era content | Exact first obtainability versus update deployment |
| Resource identity | H1, H2 | High | `EVIDENCE_BACKED` | HP or MP drain | Exact client wording/locale |
| Required level/type/slots | R1, H1 | High configuration; medium retail | `VERIFY_LIVE` for effect eligibility | Active row is level-75 sword, main/sub | Whether the effect itself works identically off hand |
| Global/script ownership | R1, R2 | High framework | `FRAMEWORK_CORRECT_LEGACY_NUMERICS` | One global path, no item script | Retail-internal ownership is not observable |
| Overall proc chance | R1, H1 | Low retail | `VERIFY_LIVE` | Preserve configured 15%; H1 reports about 20% without dataset | Proc versus resist denominator and confidence interval |
| Overall versus per-resource proc | R2 only | Low retail | `VERIFY_LIVE` | Preserve one overall roll before selection | Whether retail rolls per branch |
| Branch distribution | R2 only | Low retail | `VERIFY_LIVE` | Preserve uniform selector 1..2 | Retail HP:MP distribution |
| Branch order/mapping | R2 only | Low retail | `VERIFY_LIVE` | 1=HP, 2=MP compatibility | Whether numeric order has retail meaning |
| Retry/fallback | R2 only | Low retail | `VERIFY_LIVE` | Preserve one selected branch, no retry | Whether retail retries another resource |
| Selected empty branch | R2 only | Low retail | `VERIFY_LIVE` | Zero selected result; no fallback | Exact retail message/no-effect behavior |
| Resisted branch | R2 only | Low retail | `VERIFY_LIVE` | Selected branch resolves once; no fallback | Proc versus resist distinction |
| Nullified branch | R2 only | Low retail | `VERIFY_LIVE` | Selected branch resolves once; no fallback | Retail nullification semantics |
| HP amount | R1, H1 | Low retail | `VERIFY_LIVE` | Preserve SQL fixed 15; H1 reports maximum near 20 | Fixed/random range and scaling |
| MP amount | R1, H1 | Low retail | `VERIFY_LIVE` | Preserve SQL fixed 15; H1 reports maximum near 10 | Fixed/random range and scaling |
| Skill/magic accuracy | No retail source | None | `VERIFY_LIVE` | Preserve legacy no-explicit-skill path | Skill rank and magic-accuracy source |
| Governing stat/dSTAT | No retail source | None | `VERIFY_LIVE` | Preserve no configured governing stat/dSTAT | Any stat relationship |
| Element | R1, R2 only | Low retail | `VERIFY_LIVE` | Configured None, effective Dark compatibility | Retail element/action element |
| Resistance tiers/floor | R2 only | Low retail | `VERIFY_LIVE` | Preserve legacy magical tiers/floor | Retail tier distribution and floor |
| Nullification/absorption | R2 only | Low retail | `VERIFY_LIVE` | One calculation; negative absorb clamps to zero | Whether absorption can reverse a drain |
| Undead | R2 only | Low retail | `VERIFY_LIVE` | Preserve selected-branch block, no fallback | Retail message and fallback |
| Target-resource cap | R2, R3 | High framework | `FRAMEWORK_CORRECT_LEGACY_NUMERICS` | Remove no more than selected target resource | Lethal HP client order |
| Attacker-resource cap | R2, R3 | High framework; low retail | `VERIFY_LIVE` | Target removal is reported even when attacker is capped | Retail lost-overflow semantics |
| Main/off-hand | R1, R3 | High framework; low retail | `VERIFY_LIVE` | Active path works from either hand | Retail off-hand eligibility |
| Multi-attack | R2, R3 | High framework; low retail | `VERIFY_LIVE` | One outcome per eligible swing | Retail extra-attack eligibility |
| Enspell/priority | R2, R3 | High framework; low retail | `VERIFY_LIVE` | Existing Enspell priority is preserved | Exact retail priority chain |
| Subeffect/message | R1–R3 | High framework; low retail | `VERIFY_LIVE` | Keep item subeffect; selected HP/MP message | Client animation and no-effect presentation |
| Packet amount/order | R2, R3 | High framework; low retail | `FRAMEWORK_CORRECT_LEGACY_NUMERICS` | One 0x028 proc result reports actual target resource removed | Exact retail packet ordering/rendering |

## Vampirism (20706)

### Identity and active configuration

R1 establishes a level-99/item-level-119 sword equippable in main or sub,
proc family 9 (`HPMPTP_DRAIN`), configured chance 100, amount 20, level
correction 0, configured element None, and subeffect 22/MP Drain. It has one
global handler and no item script.

V1 establishes Sinister Reign as 2015 content. V2 dates Vampirism to the same
2015-08-05 update and identifies HP/MP/TP drain. This proves
`LATER_EXPANSION`. V2's 100% statement has no published trial count and does
not establish whether a missing result is proc failure, resistance, an
ineligible extra swing, or presentation suppression.

| Field | Sources | Confidence | Classification | Conclusion | Unresolved question |
|---|---|---|---|---|---|
| Item ID/name | R1, V2 | High | `EVIDENCE_BACKED` | 20706, Vampirism | None |
| Introduction era/date | V1, V2 | High | `EVIDENCE_BACKED`; `LATER_EXPANSION` | 2015-08-05 Sinister Reign era | Exact first reward availability |
| Resource identity | V2 | High | `EVIDENCE_BACKED` | HP, MP, or TP drain | Exact client wording/locale |
| Required level/type/slots | R1, V2 | High configuration; medium retail | `VERIFY_LIVE` for effect eligibility | Active row is level-99 i119 sword, main/sub | Effect behavior off hand |
| Global/script ownership | R1, R2 | High framework | `FRAMEWORK_CORRECT_LEGACY_NUMERICS` | One global path, no item script | Retail-internal ownership |
| Overall proc chance | R1, V2, C3 | Low retail | `VERIFY_LIVE` | Preserve configured 100%; community claim lacks denominator | Proc versus resistance/eligibility |
| Overall versus per-resource proc | R2, C3 | Low retail | `VERIFY_LIVE` | Preserve one overall roll before selection | C3 discusses magic accuracy but has no controlled dataset |
| Branch distribution | R2, C3 | Low retail | `VERIFY_LIVE` | Preserve uniform 1..3 | C3 says Vampirism has worse TP distribution, without counts |
| Branch order/mapping | R2 only | Low retail | `VERIFY_LIVE` | 1=HP, 2=MP, 3=TP compatibility | Retail internal mapping |
| Retry/fallback | R2 only | None retail | `VERIFY_LIVE` | Preserve no retry/fallback | Sequential retry theory remains unsupported |
| Selected empty branch | R2 only | None retail | `VERIFY_LIVE` | Zero selected result; no fallback | Retail empty MP/TP behavior |
| Resisted branch | R2, C3 | Low retail | `VERIFY_LIVE` | Selected branch resolves once; no fallback | Whether resistance occurs before/after selection |
| Nullified branch | R2 only | None retail | `VERIFY_LIVE` | Selected branch resolves once; no fallback | Retail behavior |
| HP/MP/TP amount | R1 only | None retail | `VERIFY_LIVE` | Preserve fixed SQL 20 for every selected resource | Per-resource ranges/scaling |
| Skill/magic accuracy | C3 | Low | `VERIFY_LIVE` | Preserve no-explicit-skill compatibility | C3 claims magic-accuracy influence without dataset |
| Governing stat/dSTAT | No retail source | None | `VERIFY_LIVE` | Preserve no governing stat/dSTAT | Any stat relationship |
| Element | R1, R2 only | None retail | `VERIFY_LIVE` | Configured None, effective Dark compatibility | Retail element |
| Resistance tiers/floor | R2 only | None retail | `VERIFY_LIVE` | Preserve legacy magical tiers/floor | Retail tiers/floor |
| Nullification/absorption | R2 only | None retail | `VERIFY_LIVE` | One calculation; negative absorb clamps to zero | Retail reverse-transfer behavior |
| Undead | R2 only | None retail | `VERIFY_LIVE` | Block selected branch, no fallback | Message/fallback |
| Target-resource cap | R2, R3 | High framework | `FRAMEWORK_CORRECT_LEGACY_NUMERICS` | Remove no more than selected resource | Lethal HP order |
| Attacker-resource cap | R2, R3 | High framework; low retail | `VERIFY_LIVE` | Report target removal when actor is capped | Lost overflow |
| Main/off-hand | R1, R3 | High framework; low retail | `VERIFY_LIVE` | Active path works from either hand | Retail effect eligibility off hand |
| Multi-attack | R2, R3, C3 | Medium conflict | `VERIFY_LIVE` | Preserve one outcome per eligible swing | C3 claims no effect on extra attacks; no counted trial |
| Enspell/priority | R2, R3 | High framework; low retail | `VERIFY_LIVE` | Preserve existing Enspell priority | Retail priority |
| Subeffect/message | R1–R3 | High framework; low retail | `VERIFY_LIVE` | Keep MP Drain subeffect; selected resource message | Shared animation correctness |
| Packet amount/order | R2, R3 | High framework; low retail | `FRAMEWORK_CORRECT_LEGACY_NUMERICS` | One 0x028 proc result reports actual removed amount | Exact retail rendering/order |

## Crepuscular Knife (21585)

### Identity and active configuration

R1 establishes a level-99/item-level-119 dagger equippable in main or sub,
proc family 9 (`HPMPTP_DRAIN`), configured chance 15, amount 15, level
correction 0, configured element None, and subeffect 8/Darkness Damage. It has
one global handler and no item script.

C1 and C2 establish 2021-07-12 and `LATER_EXPANSION`. C2 and C3 agree that
the item selects HP, MP, or TP, but the accessible mechanics claims conflict
with each other and with active SQL. Neither source supplies a complete
counted dataset.

| Field | Sources | Confidence | Classification | Conclusion | Unresolved question |
|---|---|---|---|---|---|
| Item ID/name | R1, C1, C2 | High | `EVIDENCE_BACKED` | 21585, Crepuscular Knife | None |
| Introduction era/date | C1, C2 | High | `EVIDENCE_BACKED`; `LATER_EXPANSION` | 2021-07-12 | Exact first battlefield drop availability |
| Resource identity | C2, C3 | High | `EVIDENCE_BACKED` | HP, MP, or TP drain | Exact localized wording |
| Required level/type/slots | R1, C2 | High configuration; medium retail | `VERIFY_LIVE` for effect eligibility | Active row is level-99 i119 dagger, main/sub | Effect behavior off hand |
| Global/script ownership | R1, R2 | High framework | `FRAMEWORK_CORRECT_LEGACY_NUMERICS` | One global path, no item script | Retail-internal ownership |
| Overall proc chance | R1, C3 | Conflicting/low | `VERIFY_LIVE` | Preserve configured 15%; C3 alternately claims 100% or magic-accuracy dependence | Controlled denominator by eligible swing |
| Overall versus per-resource proc | R2, C3 | Low | `VERIFY_LIVE` | Preserve one overall roll before selection | Whether "resist" is branch or overall failure |
| Branch distribution | R2, C2, C3 | Conflicting/low | `VERIFY_LIVE` | Preserve uniform 1..3 only as compatibility | C2/C3 claim TP near 10% versus another C3 equal-branch claim |
| Branch order/mapping | R2 only | None retail | `VERIFY_LIVE` | 1=HP, 2=MP, 3=TP compatibility | Retail mapping |
| Retry/fallback | R2 only | None retail | `VERIFY_LIVE` | Preserve no retry/fallback | Sequential fallback remains unsupported |
| Selected empty branch | R2 only | None retail | `VERIFY_LIVE` | Zero selected result; no fallback | Retail empty-resource behavior |
| Resisted branch | R2, C3 | Low | `VERIFY_LIVE` | Selected branch resolves once; no fallback | Selection/resistance ordering |
| Nullified branch | R2 only | None retail | `VERIFY_LIVE` | Selected branch resolves once; no fallback | Retail behavior |
| HP/MP amount | R1, C2 | Conflicting/low | `VERIFY_LIVE` | Preserve fixed SQL 15; C2 says around 5 | Distribution and stat/target dependence |
| TP amount | R1, C2, C3 | Conflicting/low | `VERIFY_LIVE` | Preserve fixed SQL 15; C2 says 0–100 and C3 discusses 30–80 legacy-style values | Scale, units, and distribution |
| Skill/magic accuracy | C3 | Low | `VERIFY_LIVE` | Preserve no-explicit-skill compatibility | C3 claims magic-accuracy influence without dataset |
| Governing stat/dSTAT | No retail source | None | `VERIFY_LIVE` | Preserve no governing stat/dSTAT | Any stat relationship |
| Element | R1, R2 only | None retail | `VERIFY_LIVE` | Configured None, effective Dark compatibility | Retail element |
| Resistance tiers/floor | R2 only | None retail | `VERIFY_LIVE` | Preserve legacy magical tiers/floor | Retail tiers/floor |
| Nullification/absorption | R2 only | None retail | `VERIFY_LIVE` | One calculation; negative absorb clamps to zero | Retail reverse-transfer behavior |
| Undead | R2 only | None retail | `VERIFY_LIVE` | Block selected branch, no fallback | Message/fallback |
| Target-resource cap | R2, R3 | High framework | `FRAMEWORK_CORRECT_LEGACY_NUMERICS` | Remove no more than selected resource | Lethal HP order |
| Attacker-resource cap | R2, R3 | High framework; low retail | `VERIFY_LIVE` | Report target removal when actor is capped | Lost overflow |
| Main/off-hand | R1, R3 | High framework; low retail | `VERIFY_LIVE` | Active path works from either hand | Retail effect eligibility off hand |
| Multi-attack | R2, R3, C3 | Conflict | `VERIFY_LIVE` | Preserve one result per eligible server swing | C3 claims no proc on extra triple-attack swings |
| Enspell/priority | R2, R3 | High framework; low retail | `VERIFY_LIVE` | Preserve existing Enspell priority | Retail priority |
| Subeffect/message | R1–R3 | High framework; low retail | `VERIFY_LIVE` | Keep Darkness Damage subeffect; selected resource message | Exact client animation/message |
| Packet amount/order | R2, R3 | High framework; low retail | `FRAMEWORK_CORRECT_LEGACY_NUMERICS` | One 0x028 proc result reports actual removed amount | Exact retail order/rendering |

## HP/MP selection architecture

| Field | Source/type/date/control/sample/method | Confidence | Classification | Active conclusion | Retail uncertainty |
|---|---|---|---|---|---|
| Overall proc | R2/R3; repository trace and forced boundary tests; 2026-07-29; controlled server behavior; Hofud pass/fail | High framework | `FRAMEWORK_CORRECT_LEGACY_NUMERICS` | Exactly one item-proc roll | Proc/resist retail order |
| Selection | R2/R3; forced selectors; both branches | High framework | `FRAMEWORK_CORRECT_LEGACY_NUMERICS` | One `math.randomInt(1, 2)` after proc success | Distribution is `VERIFY_LIVE` |
| Mapping | R2/R3; forced 1 and 2 | High framework | `FRAMEWORK_CORRECT_LEGACY_NUMERICS` | 1=HP, 2=MP | Numeric mapping is not a retail claim |
| Retry | R2/R3; empty/resisted/nullified/undead tests | High framework | `FRAMEWORK_CORRECT_LEGACY_NUMERICS` | No fallback after selected branch | Retail retry policy is `VERIFY_LIVE` |
| Calculation | R2/R3; spies around active calculator | High framework | `FRAMEWORK_CORRECT_LEGACY_NUMERICS` | One calculation for selected resource | Formula fields are `VERIFY_LIVE` |
| Mutation | R2/R3; before/after resource observations | High framework | `FRAMEWORK_CORRECT_LEGACY_NUMERICS` | One target and one attacker resource only | Attacker-full behavior is `VERIFY_LIVE` |
| Presentation | R2/R3; direct and real 0x028 paths | High framework | `FRAMEWORK_CORRECT_LEGACY_NUMERICS` | Item subeffect plus selected HP/MP message and actual removal | Client rendering is `VERIFY_LIVE` |

## HP/MP/TP selection architecture

| Field | Source/type/date/control/sample/method | Confidence | Classification | Active conclusion | Retail uncertainty |
|---|---|---|---|---|---|
| Overall proc | R2/R3; repository trace and forced boundary tests; 2026-07-29; controlled server behavior; all scoped items | High framework | `FRAMEWORK_CORRECT_LEGACY_NUMERICS` | Exactly one item-proc roll | 15%/100% values and proc/resist order are `VERIFY_LIVE` |
| Selection | R2/R3; forced selectors across both items and all branches | High framework | `FRAMEWORK_CORRECT_LEGACY_NUMERICS` | One `math.randomInt(1, 3)` after success | Uniform distribution conflicts with C2/C3 and is `VERIFY_LIVE` |
| Mapping | R2/R3; forced 1, 2, and 3 | High framework | `FRAMEWORK_CORRECT_LEGACY_NUMERICS` | 1=HP, 2=MP, 3=TP | Numeric mapping is not a retail claim |
| Retry | R2/R3; empty MP/TP, resisted, nullified, absorbed, undead tests | High framework | `FRAMEWORK_CORRECT_LEGACY_NUMERICS` | No fallback after selected branch | Retail fallback/order is `VERIFY_LIVE` |
| Calculation | R2/R3; one scoped calculator call | High framework | `FRAMEWORK_CORRECT_LEGACY_NUMERICS` | One calculation for selected resource | Formula fields are `VERIFY_LIVE` |
| Mutation | R2/R3; every nonselected resource observed | High framework | `FRAMEWORK_CORRECT_LEGACY_NUMERICS` | Exactly one target and one attacker resource can change | Caps/overflow remain `VERIFY_LIVE` |
| Presentation | R2/R3; direct and real 0x028 paths | High framework | `FRAMEWORK_CORRECT_LEGACY_NUMERICS` | Item subeffect plus HP/MP/TP message and actual removal | Retail subeffect/message/order are `VERIFY_LIVE` |

## Evidence boundary and production decision

Evidence-backed:

- all three identities and resource sets;
- Hofud is 2007 content;
- Vampirism is 2015 Sinister Reign content;
- Crepuscular Knife is 2021 Wyrm God content;
- consequently, all three are `LATER_EXPANSION`.

Framework-correct and behaviorally test-backed:

- one authoritative profile per item;
- one proc owner;
- one branch-selection owner;
- one selected-resource calculation;
- no accidental retry;
- no cross-resource mutation;
- one transfer and one result per eligible swing;
- packet amount equals actual target resource removed;
- Phase B3 remains a separate registry while sharing only the transfer
  primitive.

Compatibility-only and `VERIFY_LIVE`:

- every configured chance and amount;
- uniform branch distribution and numeric branch mapping;
- no-retry/fallback behavior;
- empty/resisted/nullified/absorbed/undead behavior;
- magic accuracy, skill, stat, dSTAT, element, tiers, and multipliers;
- main/off-hand and multi-attack eligibility;
- Enspell priority;
- subeffect, resource-specific message, packet order, and rendered client
  presentation.

The accessible Crepuscular claims conflict materially. The accessible Hofud
and Vampirism claims lack published controlled samples. Therefore this pass
does not alter SQL numerics or replace the explicit
`UNIFORM_SINGLE_BRANCH_NO_RETRY_COMPATIBILITY` policy with an inferred retail
formula.

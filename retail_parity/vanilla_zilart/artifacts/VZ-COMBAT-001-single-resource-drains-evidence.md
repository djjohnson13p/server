# VZ-COMBAT-001 Phase B3 — Single-Resource Drain Evidence

## Scope and evidence standard

This ledger covers exactly:

- Aspir Knife (16509), MP drain;
- Bloody Rapier (16528), HP drain;
- Shinsoku (17823), TP drain.

Combined HP/MP or HP/MP/TP drains, scripted drains such as Bloody Bolt,
later-expansion items, Dispel, Death, self-buffs, and spikes are out of scope.
Current LandSandBoat code and other private-server implementations are not
retail evidence.

Evidence ranks used here are:

1. controlled retail packet logs or controlled test datasets;
2. official documentation or contemporaneous official statements;
3. contemporary reports with repeatable methodology and results;
4. community reference summaries;
5. memory, unsourced statements, or emulator implementations.

No rank-1 controlled retail dataset was found for any of the three items.
Consequently, effect identity and the supported era classifications are the
only retail-facing conclusions adopted in production. Existing numerical and
multiplier behavior remains an explicit compatibility contract and is not a
retail formula claim.

## Source inventory

| Source | Item(s) | Rank | Date / contemporary | Controlled trials | Access result | Supported conclusion |
|---|---|---:|---|---|---|---|
| [FFXIOnline Bastok Mission 6 discussion](https://www.ffxionline.com/forum/ffxi-game-related/missions-quests/15121-bastok-mission-6-windurst-san-d-oria) | Aspir Knife | 3 for date/name; 4 for mechanics | 2003; contemporary | No | Accessible | Aspir Knife existed during the Zilart period and was tied to the mission reward. It does not distinguish original-release from Zilart introduction and supplies no controlled formula. |
| [BG Wiki: Aspir Knife](https://www.bg-wiki.com/ffxi/Aspir_Knife) | Aspir Knife | 4 | Modern | No | Accessible | Item identity, level, weapon type, and displayed MP-drain effect. |
| [FFXIOnline rare-weapons post](https://www.ffxionline.com/forum/ffxi-game-related/general-ffxi-discussion/3407-rare-weapons?p=128941) | Bloody Rapier | 3 for date/name; 4 for mechanics | 2003-02-19; contemporary | No | The historical post remains search-indexed, but the forum page currently serves defaced content | Search-indexed historical text identifies Bloody Rapier and HP drain before the North American release. No numerical claim is adopted. The access limitation is preserved rather than silently upgrading confidence. |
| [BG Wiki: Bloody Rapier](https://www.bg-wiki.com/ffxi/Bloody_Rapier) | Bloody Rapier | 4 | Modern | No | Accessible | Item identity, level, weapon type, and displayed HP-drain effect. |
| [Archived official 2004-09-14 update-details URL](https://ffxiclopedia.fandom.com/wiki/2004_-_%2809/14/2004%29_Update_Details) | Shinsoku | 2 if the archived official text can be recovered | 2004-09-14; contemporary official notes | No | The page returned HTTP 402 during this pass; search archives identify it as the official update-notes page | Supports the provenance of the dated update, but inaccessible text is not treated as a controlled mechanical source. |
| [FF11用語辞典: 2004-09-14 update](https://wiki.ffo.jp/html/32061.html) | Shinsoku | 4, summarizing an official update | Modern summary of a 2004 update | No | Accessible | The update immediately preceding Chains of Promathia introduced the item group containing Shinsoku; therefore Shinsoku is classified Zilart-era. |
| [FF11用語辞典: 神息](https://wiki.ffo.jp/html/6885.html) | Shinsoku | 4 | Modern | No | Accessible | Item identity, level 72 Samurai great katana, and TP-absorption effect. Its qualitative low-proc statement has no trial table and cannot establish 8% or another rate. |
| [BG Wiki: Shinsoku](https://www.bg-wiki.com/ffxi/Shinsoku) | Shinsoku | 4 | Modern | No | Accessible | Item identity, level, weapon type, and displayed TP-drain effect. |
| [Official forum Twilight Knife report](https://forum.square-enix.com/ffxi/threads/872-Twilight-Knife-additional-effect-bug?p=8795&viewfull=1) | General drain hypothesis only | 4/5 | 2011; later item | No | Accessible | A later-item user report can motivate an undead test question, but it does not prove undead behavior for these three items. |

Searches also covered repository evidence, public issue/discussion indexes,
archived English community material, Japanese references, item databases, and
public capture indexes. No accessible packet log separated proc from resist,
showed the base calculation, or controlled attacker/target statistics,
elemental multipliers, resource caps, or exact 0x028 presentation for the
three scoped items. Repeated modern claims without an independent underlying
dataset were treated as one rank-4 hypothesis, not corroboration.

## Aspir Knife (16509)

### Identity and era conclusion

Aspir Knife is a level-12 dagger whose displayed additional effect drains MP.
Contemporary 2003 mission discussion establishes Zilart-era presence but does
not establish whether the item originated in the initial Japanese release or
the Zilart update. Introduction is therefore `ERA_UNRESOLVED`; identity and
resource are `EVIDENCE_BACKED`.

| Parameter | Evidence found | Source type / quality | Production conclusion | Classification | Unresolved question |
|---|---|---|---|---|---|
| Proc chance | No controlled rate. Qualitative community language says the effect occurs occasionally. | Rank 4, uncontrolled | Preserve SQL 10% exactly. | `VERIFY_LIVE` / legacy compatibility | Actual proc rate, level dependence, and separation from resist. |
| Level correction | No evidence. | None | Preserve SQL level-correction value 0. Item required-level eligibility remains authoritative. | `VERIFY_LIVE` | Does target or attacker level modify proc or potency? |
| Base amount / fixed vs random | No controlled values. | None | Preserve fixed SQL amount 3 before legacy multipliers. | `VERIFY_LIVE` / legacy compatibility | Fixed, random, target-relative, or skill/stat-scaled amount? |
| Skill / magic accuracy | No evidence. | None | Preserve no explicit skill input and the inherited zero-skill resistance call. | `VERIFY_LIVE` | Which skill or accuracy source governs resist, if any? |
| Governing stat / dSTAT | No evidence. | None | Preserve no explicit actor stat and no dSTAT. | `VERIFY_LIVE` | Do INT, MND, weapon skill, or target stats affect proc, accuracy, or amount? |
| MAB | No evidence. | None | Preserve disabled MAB. | `VERIFY_LIVE` | Is MAB intentionally excluded? |
| Element | No controlled elemental test. Current SQL says Dark. | Emulator data is not evidence | Preserve Dark only as explicit SQL compatibility. | `VERIFY_LIVE` | Is retail MP drain Dark-elemental for resistance/null/absorb? |
| Damage type | No evidence. | None | Preserve inherited magical-element calculation. MP transfer itself mutates MP only. | `VERIFY_LIVE` | What retail attack/damage classification drives defense? |
| Resistance tiers / lowest tier | No distribution. | None | Preserve inherited full/half/quarter/eighth and lower-floor behavior. | `VERIFY_LIVE` | Does MP drain partially resist, fully resist, or alter amount/chance differently? |
| Elemental SDT / general magic adjustment | No evidence. | None | Preserve inherited adjustments once. | `VERIFY_LIVE` | Should either affect resource drain? |
| Staff / affinity / day-weather | No evidence. | None | Preserve inherited multipliers once. | `VERIFY_LIVE` | Do held caster equipment and environment modify a weapon drain? |
| Nullification / absorption | No controlled result. | None | Preserve inherited nullification; clamp negative compatibility results to zero transfer. | `VERIFY_LIVE` | Does retail null, absorb, reverse, or simply resist the drain? |
| Phalanx / One for All / Stoneskin | No evidence for MP drain. | None | Preserve inherited stack once. | `VERIFY_LIVE` | Should HP-oriented defenses reduce MP drain? |
| Undead | Only a later-item user report. | Rank 4/5, non-scoped | Preserve the existing undead guard, now before calculation. | `VERIFY_LIVE` | Does Aspir Knife fail on every undead family and how is failure presented? |
| Target cap / over-drain | Framework invariant: cannot remove more MP than exists. No retail presentation capture. | Deterministic container behavior; no retail packet proof | Remove at most current target MP and serialize actual MP removed. | `FRAMEWORK_CORRECT_LEGACY_NUMERICS` | Does retail show zero, suppress the proc, or show nominal amount at empty MP? |
| Attacker cap | No retail capture. | None | Attacker MP container caps receipt; packet retains actual target MP removed. | `VERIFY_LIVE` | Is drain suppressed, reduced, or still removed when attacker MP is full? |
| Main/off hand / priority | No controlled retail dataset. | None | Preserve main-or-off-hand eligibility and existing Enspell/item priority. | `VERIFY_LIVE` | Exact retail dual-wield and Enspell ordering. |
| Distance / level sync | Melee hit ownership and item-level gate are framework behavior. No independent magical distance correction is present. | Framework evidence | Require a successful melee hit; block when effective level is below item level; add no second distance correction. | `FRAMEWORK_CORRECT_LEGACY_NUMERICS` for trigger; `VERIFY_LIVE` for retail details | Retail level-sync and moving/despawn boundary presentation. |
| Subeffect / message | Displayed MP drain plus existing packet vocabulary. | Rank 4 identity plus framework packet contract | `MP_DRAIN`, `ADD_EFFECT_MP_DRAIN`, actual removed amount. | `EVIDENCE_BACKED` identity; `FRAMEWORK_CORRECT_LEGACY_NUMERICS` presentation | Exact client behavior for zero/no-effect and cap boundaries. |

## Bloody Rapier (16528)

### Identity and era conclusion

Bloody Rapier is a level-55 sword whose displayed additional effect drains
HP. The dated 2003 rare-weapons record predates the North American release
and identifies the item/effect, supporting `VANILLA`. Because the underlying
forum page is currently defaced, this is moderate rather than packet-level
evidence. Identity, resource, and era are `EVIDENCE_BACKED`; no numerical
mechanic is.

| Parameter | Evidence found | Source type / quality | Production conclusion | Classification | Unresolved question |
|---|---|---|---|---|---|
| Proc chance | Modern community claims conflict and provide no controlled trial table. | Rank 4, uncontrolled and potentially derivative | Preserve SQL 5%. | `VERIFY_LIVE` / legacy compatibility | True proc rate and any time/day/level dependence. |
| Level correction | No evidence. | None | Preserve SQL value 0 plus the item required-level gate. | `VERIFY_LIVE` | Does relative level affect proc or amount? |
| Base amount / fixed vs random | No controlled values. | None | Preserve fixed SQL amount 10 before inherited multipliers. | `VERIFY_LIVE` / legacy compatibility | Fixed, random, damage-relative, or stat-scaled amount? |
| Skill / magic accuracy | No evidence. | None | Preserve no explicit skill and inherited zero-skill resistance input. | `VERIFY_LIVE` | Is sword skill, dark magic skill, or another accuracy source used? |
| Governing stat / dSTAT | No evidence. | None | Preserve no explicit stat/dSTAT. | `VERIFY_LIVE` | Does INT or another stat affect proc, resist, or amount? |
| MAB | No evidence. | None | Preserve disabled MAB. | `VERIFY_LIVE` | Is MAB excluded? |
| Element / damage type | No controlled test. SQL currently says Dark and the handler applies magical Dark damage. | Emulator data is not evidence | Preserve magical Dark compatibility. | `VERIFY_LIVE` | Is retail HP drain Dark-elemental and magical for mitigation/claim/enmity? |
| Resistance tiers / lowest tier | No distribution. | None | Preserve inherited tiers and rounding. | `VERIFY_LIVE` | Does resistance modify amount, proc, or both? |
| SDT / general magic / staff / affinity / day-weather | No evidence. | None | Preserve each inherited multiplier once. | `VERIFY_LIVE` | Which multipliers, if any, apply? |
| Nullification / absorption | No controlled result. | None | Preserve nullification; negative compatibility result produces no drain or reverse transfer. | `VERIFY_LIVE` | Can HP drain heal the target or is it simply suppressed? |
| Phalanx / One for All / Stoneskin | No evidence. | None | Preserve each defense once. | `VERIFY_LIVE` | Correct order and applicability. |
| Undead | Later-item report only. | Rank 4/5, non-scoped | Preserve early undead rejection. | `VERIFY_LIVE` | Exact family scope and packet/no-effect behavior. |
| Lethal boundary / target cap | Damage application can kill and reports actual HP removed. A direct dead-target regression rejects later attempts before proc/calculation. The real-melee fixture cannot deterministically model the last lethal swing without unrelated combat setup. | Framework proof, not retail capture | Clamp to available HP, mutate target once through authoritative damage, heal attacker once, reject already-dead target. | `FRAMEWORK_CORRECT_LEGACY_NUMERICS` | Retail lethal packet order, overkill display, and enmity/claim side effects. |
| Attacker cap | No evidence. | None | Attacker HP caps independently; packet reports actual target HP removed. | `VERIFY_LIVE` | Does full attacker HP suppress or alter target damage? |
| Main/off hand / priority | No controlled evidence. | None | Preserve main-or-off-hand and current Enspell/item priority. | `VERIFY_LIVE` | Exact dual-wield ordering and one-result-per-swing presentation. |
| Distance / level sync | Trigger inherits a successful melee hit; no second distance correction. Item-level gate remains. | Framework evidence | No effect on miss, invalid/despawned target, or below-level item. | `FRAMEWORK_CORRECT_LEGACY_NUMERICS` for trigger; `VERIFY_LIVE` for retail details | Moving-target and sync packet presentation. |
| Subeffect / message | HP-drain identity is supported; exact bytes are not captured. | Rank 3/4 identity plus framework packet contract | `HP_DRAIN`, `ADD_EFFECT_HP_DRAIN`, actual HP removed. | `EVIDENCE_BACKED` identity; `FRAMEWORK_CORRECT_LEGACY_NUMERICS` presentation | Exact zero/no-effect and lethal-boundary client display. |

## Shinsoku (17823)

### Identity and era conclusion

Shinsoku is a level-72 Samurai great katana whose displayed additional effect
absorbs TP. The dated update record places it immediately before the Chains
of Promathia release, so it is classified `ZILART`. Identity, resource, and
era are `EVIDENCE_BACKED`. The Japanese glossary's qualitative statement
that activation is not frequent is not a controlled proc-rate measurement.

| Parameter | Evidence found | Source type / quality | Production conclusion | Classification | Unresolved question |
|---|---|---|---|---|---|
| Proc chance | Qualitative low-activation community summary; no sample size or roll separation. | Rank 4 | Preserve SQL 8%. Correct only the stale SQL comment that said 5%. | `VERIFY_LIVE` / legacy compatibility | True proc rate and level dependence. |
| Level correction | No evidence. | None | Preserve SQL value 0 and item required-level gate. | `VERIFY_LIVE` | Does relative level alter proc or amount? |
| Base amount / fixed vs random | No controlled values. | None | Preserve fixed SQL amount 10. | `VERIFY_LIVE` / legacy compatibility | Fixed, random, TP-relative, or stat/skill-scaled amount? |
| Skill / magic accuracy | No evidence. | None | Preserve no explicit skill and inherited resistance input. | `VERIFY_LIVE` | Great-katana skill, dark magic skill, or another source? |
| Governing stat / dSTAT / MAB | No evidence. | None | Preserve no explicit stat/dSTAT and disabled MAB. | `VERIFY_LIVE` | Do INT, weapon skill, or other stats govern accuracy/amount? |
| Element / damage type | No controlled test. Missing SQL element was a deterministic profile/data defect; existing generic runtime nevertheless forced Dark. | Repository tracing, not retail evidence | Add explicit SQL Dark so data matches the preserved runtime compatibility policy. TP mutation remains isolated from HP/MP. | `FRAMEWORK_CORRECT_LEGACY_NUMERICS` for explicit data coherence; `VERIFY_LIVE` for retail element | Is retail TP drain Dark-elemental or non-elemental? |
| Resistance tiers / lowest tier | No distribution. | None | Preserve inherited tiers and rounding. | `VERIFY_LIVE` | Does TP absorption partially resist or use another success roll? |
| SDT / general magic / staff / affinity / day-weather | No evidence. | None | Preserve each inherited multiplier once. | `VERIFY_LIVE` | Should any apply to TP drain? |
| Nullification / absorption | No controlled result. | None | Preserve nullification; clamp negative compatibility result to zero transfer. | `VERIFY_LIVE` | Does elemental absorption reverse TP or merely suppress it? |
| Phalanx / One for All / Stoneskin | No evidence for TP drain. | None | Preserve inherited stack once. | `VERIFY_LIVE` | Should HP-oriented defenses affect TP? |
| Undead | Later-item report only. | Rank 4/5, non-scoped | Preserve early undead rejection. | `VERIFY_LIVE` | Exact family scope and presentation. |
| Target cap / attacker cap | No retail captures. | Framework/resource-container behavior | Remove at most target TP; attacker container caps receipt; serialize actual target TP removed. | `FRAMEWORK_CORRECT_LEGACY_NUMERICS` target cap; `VERIFY_LIVE` attacker-full behavior | Retail display at zero target TP or full attacker TP. |
| Main/off hand / priority | Great katana is main-only in active equipment data. No controlled effect-priority evidence. | Framework/item data | Preserve main-only eligibility and current Enspell/item priority. | `VERIFY_LIVE` | Exact retail priority and multi-attack behavior. |
| Distance / level sync | Trigger inherits a successful melee hit and item-level gate. | Framework evidence | No independent distance correction; no effect on miss, invalid/despawned target, or below-level item. | `FRAMEWORK_CORRECT_LEGACY_NUMERICS` for trigger; `VERIFY_LIVE` for retail details | Exact moving/despawn/sync packet presentation. |
| Subeffect / message | Pre-change SQL had no `ITEM_SUBEFFECT`, causing a real 0x028 result with subeffect 0 despite TP mutation. | Deterministic repository defect plus supported TP-drain identity | Add `TP_DRAIN` subeffect and explicit Dark element; serialize `ADD_EFFECT_TP_DRAIN` with actual TP removed. | `EVIDENCE_BACKED` identity; `FRAMEWORK_CORRECT_LEGACY_NUMERICS` presentation correction | Exact retail zero/no-effect display. |

## Shared framework conclusions

The safe evidence-supported implementation boundary is:

- exactly one proc roll after item-level, profile, target, and attack-path
  eligibility;
- exactly one legacy compatibility calculation after a successful proc;
- exactly one target-resource mutation and one attacker-resource receipt;
- target removal capped to the resource actually available;
- no negative or reverse resource transfer from elemental absorption;
- one normal melee 0x028 additional-effect result per legitimate swing;
- no result after physical miss, invalid/despawned/dead target, failed proc,
  level suppression, or existing Enspell priority;
- one result per successful multi-attack swing when the item effect owns that
  swing;
- combined and scripted drain handlers remain outside this registry.

These are framework and compatibility guarantees. They do not establish the
retail formula. Every unsupported numerical, accuracy, resistance,
environmental, defensive, cap-presentation, and priority field remains
`VERIFY_LIVE`.

## Controlled retail capture plan

For each item, a useful dataset must record raw 0x028 packets and full
attacker/target state while independently varying:

1. at least several hundred eligible hits at equal level to separate proc
   rate from resist/no-effect;
2. attacker and target level, including level sync immediately below/at item
   level;
3. target HP, MP, or TP below/equal/above plausible drain amounts and at zero;
4. attacker resource below cap and full;
5. actor/target INT and plausible skill/magic-accuracy changes independently;
6. Dark resistance/MEVA, nullification, absorption, undead family, and
   partial-resist candidates;
7. MAB, elemental staff, affinity, day/weather, SDT, Phalanx, Stoneskin, and
   One for All independently;
8. main/off hand, Enspell priority, multi-attack, miss, moving/despawn, and
   lethal HP-drain boundaries;
9. packet subeffect, message, nominal/applied amount, and client rendering for
   every success/no-effect boundary.

Until such a dataset exists, SQL 10%/3, 5%/10, and 8%/10 plus the inherited
Dark magical multiplier stack remain labeled compatibility, not retail
parity.

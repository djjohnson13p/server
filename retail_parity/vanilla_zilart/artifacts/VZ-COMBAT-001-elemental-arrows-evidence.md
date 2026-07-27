# VZ-COMBAT-001 Elemental Arrows Evidence Ledger

## Scope and decision rule

This ledger covers only Fire Arrow (17322), Ice Arrow (17323), and Lightning
Arrow (17324). It separates retail evidence from the active server's behavior.
LandSandBoat source code is used to reproduce the compatibility contract, not
as proof of retail behavior.

No controlled retail packet log, controlled damage dataset, or official formula
was found for these arrows. Numeric and multiplier claims therefore remain
`VERIFY_LIVE`; the implementation preserves the active behavior through an
explicit compatibility profile rather than declaring it retail-correct.

Evidence ranks used here:

1. controlled retail packet logs or test datasets;
2. official documentation or contemporaneous official statements;
3. contemporary reports with repeatable methodology and results;
4. community summaries or anecdotes without controlled methodology;
5. memory, unsourced claims, or other-server implementations.

## Sources searched

| Key | Source | Type | Contemporary | Controlled trials | Rank | What it supports |
| --- | --- | --- | --- | --- | --- | --- |
| S1 | [January 2004 Ranger guide](https://gamefaqs.gamespot.com/pc/555735-final-fantasy-xi/faqs/27654) | Contemporary community guide | Yes | No | 4 | All three level-45 arrows existed by January 2004 and were described with Fire, Ice, and Lightning additional damage. |
| S2 | [March 2004 Ranger discussion](https://www.ffxionline.com/forum/ffxi-game-related/race-job-type-q-a/ranger/29149-xbows-and-guns-only/page2) | Contemporary player anecdote | Yes | No | 4 | One poster recalled roughly 5-10 elemental-arrow damage and said it did not activate every hit. No item split, sample, target, stats, packet log, or procedure was supplied. |
| S3 | [Japanese arrow index](https://wiki.ffo.jp/html/1738.html), [Fire Arrow](https://wiki.ffo.jp/html/5020.html), [Ice Arrow](https://wiki.ffo.jp/html/5021.html), [Lightning Arrow](https://wiki.ffo.jp/html/5022.html) | Modern community reference with historical notes | No | No | 4 | Correct item identities/elements, level 45, and a historical statement that the original elemental arrows predated the July 17, 2003 recipe revision. The Fire Arrow page summarizes damage as at most about 10, without trials. |
| S4 | [FFXIclopedia Fire Arrow](https://ffxiclopedia.fandom.com/wiki/Fire_Arrow) | Modern community reference | No | No | 4 | States that additional-effect damage is based on INT, but provides no experiment, formula, target INT, or distinction between damage and accuracy. |
| S5 | [March 2013 official-forum player request](https://forum.square-enix.com/ffxi/threads/29797-How-would-you-like-certain-items-to-be-changed?p=406859) | User post hosted on the official forum | No | No | 4 | A player said even very high INT and some MAB left Ice Arrow weak. This is not an official statement or controlled comparison and cannot prove that INT or MAB participates. |
| R1 | Active repository scripts, ranged handler, helper, SQL markers, and Phase B1 tests | Current implementation evidence | N/A | Deterministic server tests | Not retail evidence | Establishes only the before/after server contract described below. |

Repository-wide searches covered the finding/inventory artifacts, item scripts,
combat helpers, ranged state and packet code, tests, issues quoted in repository
documentation, and accessible attachments. Public searches covered English and
Japanese references, archived discussions, contemporary guides, official-forum
posts, and indexed capture/test terms. No accessible issue attachment or public
capture contained controlled trials for the formula. Current emulator
implementations were deliberately excluded as retail evidence.

## Conflicts preserved

- S2 says the family did not activate on every hit, while the active helper's
  omitted chance defaults to 100%. The proc rate remains `VERIFY_LIVE`; 100% is
  retained only as compatibility.
- S2 gives an anecdotal 5-10 range and S3 says damage is at most about 10. These
  do not establish the active 7-10 minimum, uniform randomness, or per-arrow
  equality. The 7-10 uniform range remains `VERIFY_LIVE`.
- S4 calls Fire Arrow INT-based, while S5 only reports that large INT plus some
  MAB did not make Ice Arrow useful. Neither source isolates actor INT, target
  INT, dINT, magic accuracy, or MAB. No stat formula is selected.
- S3 says the three arrows share listed performance except element, but this is
  not a controlled numeric comparison. Shared compatibility policy does not
  assert that retail formulas are identical.

## Fire Arrow (17322)

| Question | Source | Source type | Contemporary | Controlled | Confidence | Classification | Conclusion | Unresolved question |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Introduction era | S1, S3 | Guide and historical community summary | S1 yes | No | Medium | `EVIDENCE_BACKED` | Present by January 2004 and described by S3 as one of the original elemental arrows. | Exact first patch/date remains without an official source. |
| Effect element | S1, S3 | Guide and item references | S1 yes | No | High | `EVIDENCE_BACKED` | Additional Fire damage. | None for element identity. |
| Proc rate | S2 | Player anecdote | Yes | No | Low | `VERIFY_LIVE` | Anecdote conflicts with the active implicit 100%. | Exact rate, level correction, and whether it varies by target. |
| Base power | S2, S3 | Anecdote and summary | S2 yes | No | Low | `VERIFY_LIVE` | Reports only an approximate upper range; does not establish 7-10. | Exact base and per-item differences. |
| Fixed versus random | None | None | N/A | No | None | `VERIFY_LIVE` | Active uniform 7-10 roll is compatibility only. | Fixed, random, distribution, and rounding. |
| Actor INT | S4; weak family context S5 | Community claims | No | No | Low | `VERIFY_LIVE` | No isolated actor-INT trial exists. | Whether INT affects damage, accuracy, both, or neither. |
| Target INT or dINT | None | None | N/A | No | None | `VERIFY_LIVE` | Active no-stat behavior is compatibility only. | Target stat and dSTAT equation/caps. |
| Magic accuracy or skill rank | None | None | N/A | No | None | `VERIFY_LIVE` | Active A+ rank and zero explicit macc are unsupported. | Governing skill/rank, macc, and level correction. |
| MAB | S5 family anecdote | Player anecdote | No | No | Very low | `VERIFY_LIVE` | Does not isolate MAB; active MAB-disabled behavior is compatibility. | Whether MAB/MDB applies and at what stage. |
| Elemental staff | None | None | N/A | No | None | `VERIFY_LIVE` | Active staff multiplier retained as compatibility. | Whether weapon-slot staff affinity affects arrow damage/accuracy. |
| Elemental affinity | None | None | N/A | No | None | `VERIFY_LIVE` | Active affinity multiplier retained as compatibility. | Whether damage and/or accuracy affinity applies. |
| Day/weather | None | None | N/A | No | None | `VERIFY_LIVE` | Active day/weather multiplier retained as compatibility. | Proc, damage, and forced-weather behavior. |
| Elemental resistance tiers | None | None | N/A | No | None | `VERIFY_LIVE` | Active magical tier system retained as compatibility. | Accuracy formula and tier probabilities. |
| Partial resist | None | None | N/A | No | None | `VERIFY_LIVE` | Active 1, 1/2, 1/4, 1/8 tiers retained. | Retail floor and rounding. |
| Nullification | None | None | N/A | No | None | `FRAMEWORK_CORRECT_LEGACY_NUMERICS` | One existing magical nullification resolution is retained. | Exact retail interaction and presentation. |
| Absorption | None | None | N/A | No | None | `FRAMEWORK_CORRECT_LEGACY_NUMERICS` | One existing Fire absorption resolution is retained. | Exact healing message, caps, and elemental absorb rules. |
| Phalanx | None | None | N/A | No | None | `VERIFY_LIVE` | Existing mitigation retained once as compatibility. | Whether it should mitigate this effect. |
| Stoneskin | None | None | N/A | No | None | `VERIFY_LIVE` | Existing mitigation retained once as compatibility. | Whether it should absorb this effect and packet amount. |
| One for All | None | None | N/A | No | None | `VERIFY_LIVE` | Existing mitigation retained once as compatibility. | Whether it should mitigate this effect. |
| Distance | None | None | N/A | No | None | `FRAMEWORK_CORRECT_LEGACY_NUMERICS` | Effect inherits the successful physical ranged hit; no second distance modifier. | Whether retail ever scales the magical component separately. |
| Level correction | None | None | N/A | No | None | `VERIFY_LIVE` | No extra proc/damage level correction is configured. | Retail correction equation, if any. |
| Level sync | R1 | Current framework test | N/A | Server-controlled | High framework only | `FRAMEWORK_CORRECT_LEGACY_NUMERICS` | Item effect is blocked when the effective level is below 45. | Live-era level-sync presentation. |
| Additional-effect priority | R1 | Current framework test | N/A | Server-controlled | High framework only | `FRAMEWORK_CORRECT_LEGACY_NUMERICS` | Scripted arrow bypasses Enspell priority and serializes one effect. | Exact retail priority versus every other source. |
| Subeffect and message | S1, S3 for element; R1 for packet | References plus framework test | S1 yes | No retail packet | High framework, medium retail | `FRAMEWORK_CORRECT_LEGACY_NUMERICS` | Fire subeffect with normal additional-damage/heal message; amount now equals actual HP change. | Client presentation and exact retail message capture. |

## Ice Arrow (17323)

| Question | Source | Source type | Contemporary | Controlled | Confidence | Classification | Conclusion | Unresolved question |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Introduction era | S1, S3 | Guide and historical community summary | S1 yes | No | Medium | `EVIDENCE_BACKED` | Present by January 2004 and described by S3 as one of the original elemental arrows. | Exact first patch/date remains without an official source. |
| Effect element | S1, S3 | Guide and item references | S1 yes | No | High | `EVIDENCE_BACKED` | Additional Ice damage. | None for element identity. |
| Proc rate | S2 | Player anecdote | Yes | No | Low | `VERIFY_LIVE` | Anecdote conflicts with the active implicit 100%. | Exact rate, level correction, and whether it varies by target. |
| Base power | S2, S3 | Anecdote and summary | S2 yes | No | Low | `VERIFY_LIVE` | Reports only an approximate family range; does not establish 7-10. | Exact base and per-item differences. |
| Fixed versus random | None | None | N/A | No | None | `VERIFY_LIVE` | Active uniform 7-10 roll is compatibility only. | Fixed, random, distribution, and rounding. |
| Actor INT | S5; Fire-only claim S4 | Community claims | No | No | Low | `VERIFY_LIVE` | S5 does not isolate INT; S4 cannot be transferred numerically. | Whether INT affects Ice Arrow damage, accuracy, both, or neither. |
| Target INT or dINT | None | None | N/A | No | None | `VERIFY_LIVE` | Active no-stat behavior is compatibility only. | Target stat and dSTAT equation/caps. |
| Magic accuracy or skill rank | None | None | N/A | No | None | `VERIFY_LIVE` | Active A+ rank and zero explicit macc are unsupported. | Governing skill/rank, macc, and level correction. |
| MAB | S5 | Player anecdote | No | No | Very low | `VERIFY_LIVE` | Does not isolate MAB; active MAB-disabled behavior is compatibility. | Whether MAB/MDB applies and at what stage. |
| Elemental staff | None | None | N/A | No | None | `VERIFY_LIVE` | Active staff multiplier retained as compatibility. | Whether weapon-slot staff affinity affects arrow damage/accuracy. |
| Elemental affinity | None | None | N/A | No | None | `VERIFY_LIVE` | Active affinity multiplier retained as compatibility. | Whether damage and/or accuracy affinity applies. |
| Day/weather | None | None | N/A | No | None | `VERIFY_LIVE` | Active day/weather multiplier retained as compatibility. | Proc, damage, and forced-weather behavior. |
| Elemental resistance tiers | None | None | N/A | No | None | `VERIFY_LIVE` | Active magical tier system retained as compatibility. | Accuracy formula and tier probabilities. |
| Partial resist | None | None | N/A | No | None | `VERIFY_LIVE` | Active 1, 1/2, 1/4, 1/8 tiers retained. | Retail floor and rounding. |
| Nullification | None | None | N/A | No | None | `FRAMEWORK_CORRECT_LEGACY_NUMERICS` | One existing magical nullification resolution is retained. | Exact retail interaction and presentation. |
| Absorption | None | None | N/A | No | None | `FRAMEWORK_CORRECT_LEGACY_NUMERICS` | One existing Ice absorption resolution is retained. | Exact healing message, caps, and elemental absorb rules. |
| Phalanx | None | None | N/A | No | None | `VERIFY_LIVE` | Existing mitigation retained once as compatibility. | Whether it should mitigate this effect. |
| Stoneskin | None | None | N/A | No | None | `VERIFY_LIVE` | Existing mitigation retained once as compatibility. | Whether it should absorb this effect and packet amount. |
| One for All | None | None | N/A | No | None | `VERIFY_LIVE` | Existing mitigation retained once as compatibility. | Whether it should mitigate this effect. |
| Distance | None | None | N/A | No | None | `FRAMEWORK_CORRECT_LEGACY_NUMERICS` | Effect inherits the successful physical ranged hit; no second distance modifier. | Whether retail ever scales the magical component separately. |
| Level correction | None | None | N/A | No | None | `VERIFY_LIVE` | No extra proc/damage level correction is configured. | Retail correction equation, if any. |
| Level sync | R1 | Current framework test | N/A | Server-controlled | High framework only | `FRAMEWORK_CORRECT_LEGACY_NUMERICS` | Item effect is blocked when the effective level is below 45. | Live-era level-sync presentation. |
| Additional-effect priority | R1 | Current framework test | N/A | Server-controlled | High framework only | `FRAMEWORK_CORRECT_LEGACY_NUMERICS` | Scripted arrow bypasses Enspell priority and serializes one effect. | Exact retail priority versus every other source. |
| Subeffect and message | S1, S3 for element; R1 for packet | References plus framework test | S1 yes | No retail packet | High framework, medium retail | `FRAMEWORK_CORRECT_LEGACY_NUMERICS` | Ice subeffect with normal additional-damage/heal message; amount now equals actual HP change. | Client presentation and exact retail message capture. |

## Lightning Arrow (17324)

| Question | Source | Source type | Contemporary | Controlled | Confidence | Classification | Conclusion | Unresolved question |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Introduction era | S1, S3 | Guide and historical community summary | S1 yes | No | Medium | `EVIDENCE_BACKED` | Present by January 2004 and described by S3 as one of the original elemental arrows. | Exact first patch/date remains without an official source. |
| Effect element | S1, S3 | Guide and item references | S1 yes | No | High | `EVIDENCE_BACKED` | Additional Thunder damage, presented by the Lightning subeffect. | None for element identity. |
| Proc rate | S2 | Player anecdote | Yes | No | Low | `VERIFY_LIVE` | Anecdote conflicts with the active implicit 100%. | Exact rate, level correction, and whether it varies by target. |
| Base power | S2, S3 | Anecdote and summary | S2 yes | No | Low | `VERIFY_LIVE` | Reports only an approximate family range; does not establish 7-10. | Exact base and per-item differences. |
| Fixed versus random | None | None | N/A | No | None | `VERIFY_LIVE` | Active uniform 7-10 roll is compatibility only. | Fixed, random, distribution, and rounding. |
| Actor INT | Fire-only S4 and Ice-only S5 | Community claims | No | No | Very low | `VERIFY_LIVE` | No Lightning Arrow INT trial was found; family transfer is unsafe. | Whether INT affects damage, accuracy, both, or neither. |
| Target INT or dINT | None | None | N/A | No | None | `VERIFY_LIVE` | Active no-stat behavior is compatibility only. | Target stat and dSTAT equation/caps. |
| Magic accuracy or skill rank | None | None | N/A | No | None | `VERIFY_LIVE` | Active A+ rank and zero explicit macc are unsupported. | Governing skill/rank, macc, and level correction. |
| MAB | Ice-only S5 | Player anecdote | No | No | Very low | `VERIFY_LIVE` | Cannot be transferred to Lightning Arrow; active MAB-disabled behavior is compatibility. | Whether MAB/MDB applies and at what stage. |
| Elemental staff | None | None | N/A | No | None | `VERIFY_LIVE` | Active staff multiplier retained as compatibility. | Whether weapon-slot staff affinity affects arrow damage/accuracy. |
| Elemental affinity | None | None | N/A | No | None | `VERIFY_LIVE` | Active affinity multiplier retained as compatibility. | Whether damage and/or accuracy affinity applies. |
| Day/weather | None | None | N/A | No | None | `VERIFY_LIVE` | Active day/weather multiplier retained as compatibility. | Proc, damage, and forced-weather behavior. |
| Elemental resistance tiers | None | None | N/A | No | None | `VERIFY_LIVE` | Active magical tier system retained as compatibility. | Accuracy formula and tier probabilities. |
| Partial resist | None | None | N/A | No | None | `VERIFY_LIVE` | Active 1, 1/2, 1/4, 1/8 tiers retained. | Retail floor and rounding. |
| Nullification | None | None | N/A | No | None | `FRAMEWORK_CORRECT_LEGACY_NUMERICS` | One existing magical nullification resolution is retained. | Exact retail interaction and presentation. |
| Absorption | None | None | N/A | No | None | `FRAMEWORK_CORRECT_LEGACY_NUMERICS` | One existing Thunder absorption resolution is retained. | Exact healing message, caps, and elemental absorb rules. |
| Phalanx | None | None | N/A | No | None | `VERIFY_LIVE` | Existing mitigation retained once as compatibility. | Whether it should mitigate this effect. |
| Stoneskin | None | None | N/A | No | None | `VERIFY_LIVE` | Existing mitigation retained once as compatibility. | Whether it should absorb this effect and packet amount. |
| One for All | None | None | N/A | No | None | `VERIFY_LIVE` | Existing mitigation retained once as compatibility. | Whether it should mitigate this effect. |
| Distance | None | None | N/A | No | None | `FRAMEWORK_CORRECT_LEGACY_NUMERICS` | Effect inherits the successful physical ranged hit; no second distance modifier. | Whether retail ever scales the magical component separately. |
| Level correction | None | None | N/A | No | None | `VERIFY_LIVE` | No extra proc/damage level correction is configured. | Retail correction equation, if any. |
| Level sync | R1 | Current framework test | N/A | Server-controlled | High framework only | `FRAMEWORK_CORRECT_LEGACY_NUMERICS` | Item effect is blocked when the effective level is below 45. | Live-era level-sync presentation. |
| Additional-effect priority | R1 | Current framework test | N/A | Server-controlled | High framework only | `FRAMEWORK_CORRECT_LEGACY_NUMERICS` | Scripted arrow bypasses Enspell priority and serializes one effect. | Exact retail priority versus every other source. |
| Subeffect and message | S1, S3 for element; R1 for packet | References plus framework test | S1 yes | No retail packet | High framework, medium retail | `FRAMEWORK_CORRECT_LEGACY_NUMERICS` | Thunder element with Lightning subeffect and normal additional-damage/heal message; amount now equals actual HP change. | Client presentation and exact retail message capture. |

## Active compatibility contract proved before migration

The three pre-migration item scripts passed an anonymous parameter table to
`executeAddEffectDamage`. Repository trace plus real ranged-action reproduction
proved:

- `ignoreEnSpell = true`;
- one uniform `math.random(7, 10)` base-power roll;
- magical attack type and Fire, Ice, or Thunder element;
- resistance enabled;
- omitted chance defaulted to 100%;
- omitted rank defaulted to A+;
- actor and target stat defaulted to 0;
- explicit magic accuracy defaulted to 0;
- MAB was disabled;
- resist tiers were accepted down through 1/8;
- general magical damage adjustment, physical-element SDT with `NONE`,
  matching magical-element SDT, elemental staff, affinity, and day/weather
  were evaluated;
- Phalanx, One for All, and Stoneskin were applied;
- nullification and absorption were evaluated once;
- one successful physical ranged hit could serialize one normal additional
  effect, while misses and invalid/out-of-range actions could not;
- the normal ranged subsystem owned ammo consumption, Recycle, Unlimited Shot,
  and the item-level eligibility gate.

This list describes compatibility behavior, not a retail formula.

## Selected Phase B1 policy

| Parameter | Policy | Classification |
| --- | --- | --- |
| Proc chance | Fixed 100% compatibility roll | `VERIFY_LIVE` |
| Level correction | No additional formula; require normal item-level eligibility | Gate is framework-correct; numeric retail rule `VERIFY_LIVE` |
| Base power | Uniform integer 7-10 | `VERIFY_LIVE` |
| Skill rank | Legacy A+ | `VERIFY_LIVE` |
| Governing stat/dSTAT | No-stat compatibility (`0`/`0`) | `VERIFY_LIVE` |
| Explicit magic accuracy | 0 | `VERIFY_LIVE` |
| MAB | Disabled | `VERIFY_LIVE` |
| Element | Fire / Ice / Thunder by item | `EVIDENCE_BACKED` |
| Damage type | Magical, elemental by item | `FRAMEWORK_CORRECT_LEGACY_NUMERICS` |
| Resistance | Existing magical tiers, 1/8 floor | `VERIFY_LIVE` |
| Staff, affinity, day/weather | Enabled | `VERIFY_LIVE` |
| General/elemental damage adjustments | Enabled | `VERIFY_LIVE` |
| Phalanx, One for All, Stoneskin | Enabled | `VERIFY_LIVE` |
| Nullification and absorption | Single existing resolution | `FRAMEWORK_CORRECT_LEGACY_NUMERICS` |
| Distance | Inherit the successful physical ranged action | `FRAMEWORK_CORRECT_LEGACY_NUMERICS` |
| Presentation | Matching elemental subeffect; normal damage/heal message; actual applied amount | `FRAMEWORK_CORRECT_LEGACY_NUMERICS` |

## Capture requirements

A controlled live-retail dataset must split the three items and record actor
level/INT/MAB/magic accuracy/weapon, target level/INT/elemental resistance,
distance, day/weather, every physical hit/miss, proc/no-proc, raw 0x028
subeffect/message/value, and actual target HP delta. Additional blocks must
isolate staff/affinity, elemental nullification/absorption, Phalanx, Stoneskin,
and (where era-appropriate) One for All. The dataset must be large enough to
distinguish a true proc rate and random distribution from misses and resists.

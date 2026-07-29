# VZ-COMBAT-001 Phase B5 — Lockheart/Mythril Heart Dispel evidence

## Scope and conclusions

This ledger covers only Lockheart (16944), Mythril Heart (16950), and
Mythril Heart +1 (16951). Repository configuration establishes current server
behavior; it is not retail-formula evidence.

| Item | Era gate | Confidence | Production decision |
|---|---|---:|---|
| Lockheart (16944) | `VANILLA_OR_ZILART` | High | Profile the current SQL-backed Dispel configuration. |
| Mythril Heart (16950) | `VANILLA_OR_ZILART` | High | Profile the current SQL-backed Dispel configuration. |
| Mythril Heart +1 (16951) | `VANILLA_OR_ZILART` | Moderate | Profile under the narrow shared-recipe conclusion below. |

No controlled retail packet log, counted proc dataset, official formula
statement, or contemporary test of accuracy, resistance, status selection, or
packet presentation was found. The numeric and selection behavior therefore
remains compatibility behavior marked `VERIFY_LIVE`.

## Source register

Evidence rank follows the Phase B5 task: 1 controlled retail data; 2 official
contemporary material; 3 contemporary repeatable report; 4 community
reference/history; 5 memory, uncited statement, or other-server behavior.

| Ref | Rank | Contemporary | Controlled | Source and useful content |
|---|---:|---:|---:|---|
| S1 | 3 | Yes | No | [Dreams in Vana'diel, Dark Knight FAQ, post #151, 2004-05-25](https://www.ffxionline.com/forum/ffxi-game-related/race-job-type-q-a/dark-knight/20340-dark-knight-f-a-q-guide/page11). The player reports killing Frostmane twice while seeking Lockheart and reports three Mythril Heart auction-history transactions. This independently places both items in circulation by 2004-05-25. It contains no Dispel trials. |
| S2 | 4 | No | No | [FFXIclopedia: Mythril Heart](https://ffxiclopedia.fandom.com/wiki/Mythril_Heart). Records the current item text “Additional effect: Dispel,” the Lockheart + Mythril Ingot synthesis, and Mythril Heart +1 as HQ1. |
| S3 | 4 | No | No | [BG Wiki: Lockheart](https://www.bg-wiki.com/ffxi/Lockheart). Records the current item identity, Dispel description, Frostmane acquisition, and Mythril Heart recipe use. |
| S4 | 4 | Partly | No | [GameFAQs Crafting Recipe List](https://gamefaqs.gamespot.com/pc/555735-final-fantasy-xi/faqs/31355). The document is copyrighted 2004–2006 and records the Lockheart + Mythril Ingot recipe with Mythril Heart NQ and Mythril Heart +1 HQ. The accessible revision was updated in 2006, so it does not prove the exact date that this recipe line entered the guide. |
| S5 | 4 | Unknown | No | [Creative Uncut FFXI Smithing Recipes](https://www.creativeuncut.com/ffxi_guild_smithing.html). Independently repeats the same NQ/HQ recipe structure, but provides no reliable publication date or methodology. |
| S6 | 4 | No | No | [FF11.jp great-sword database](https://www.ff11.jp/war/ryoteken). Current Japanese reference listing all three weapons with `追加効果：ディスペル` (additional effect: Dispel). |

The current FFXIclopedia and BG Wiki pages agree on item identity and the
recipe, but they are living community references and may share historical
sources. They are not counted as independent controlled formula evidence.
Other private-server implementations and bug lists were deliberately excluded
as retail evidence.

The accessible Allakhazam pages were blocked by robots policy. Searches of
public captures, archived discussions, Japanese references, repository issue
material, and web archives found no accessible controlled trial or packet
capture for these weapons. No reliable archived official update note naming
the three items was found.

## Era gate

### Lockheart (16944)

S1 is a dated, contemporaneous first-person report of repeated Frostmane kills
undertaken specifically to obtain Lockheart. Frostmane and Cape Teriggan are
Zilart-era content, but the classification does not rely on that inference:
the dated player activity directly establishes availability by 2004-05-25.

Conclusion: `VANILLA_OR_ZILART`, high confidence.

### Mythril Heart (16950)

S1 reports three Mythril Heart auction-history transactions on the author's
server by 2004-05-25. This directly establishes availability, independently of
item ID, level, current SQL placement, or recipe ingredients.

Conclusion: `VANILLA_OR_ZILART`, high confidence.

### Mythril Heart +1 (16951)

No direct contemporaneous sighting of Mythril Heart +1 was found. The
classification uses a narrow shared-recipe conclusion, not automatic HQ
inheritance:

1. S1 directly establishes the NQ Mythril Heart in circulation by 2004-05-25.
2. S2, S4, and S5 consistently identify Mythril Heart +1 as the HQ result of
   that exact Lockheart + Mythril Ingot synthesis, rather than a separate
   acquisition or later upgrade system.
3. No conflicting recipe history or later-introduction claim was found.

The accessible S4 revision does not prove when the recipe line was added, so
confidence is lower than for the two directly named items. This shared
synthesis conclusion is recorded explicitly as required by the era gate.

Conclusion: `VANILLA_OR_ZILART`, moderate confidence. A dated pre-CoP capture
or auction record naming the +1 remains desirable.

## Per-item evidence ledger

The three candidates share the same evidentiary limits. Rows remain separate
so later item-specific captures cannot silently generalize across the family.

| Field | Lockheart 16944 | Mythril Heart 16950 | Mythril Heart +1 16951 |
|---|---|---|---|
| Introduction evidence | S1 direct 2004 Frostmane/Lockheart report | S1 direct 2004 auction-history report | Narrow shared-recipe conclusion from S1 + S2/S4/S5 |
| Acquisition/recipe history | Frostmane drop; used in Mythril Heart synthesis (S1, S3) | Lockheart + Mythril Ingot NQ (S2, S4, S5) | HQ1 of the same synthesis (S2, S4, S5) |
| Effect identity | Dispel description (S3, S6) | Dispel description (S2, S6) | Dispel description (S6; current community item records) |
| Proc-rate evidence | None | None | None |
| Level-correction evidence | None | None | None |
| Main/off-hand evidence | Great sword identity supports deterministic two-handed main-slot configuration; no retail proc trial | Same | Same |
| Multiple-buff selection | None | None | None |
| Accuracy or skill | None | None | None |
| Governing stat/dSTAT | Not applicable to the preserved handler; no retail evidence | Same | Same |
| Element | No element established | No element established | No element established |
| Resistance/partial resist | None | None | None |
| Valid/protected categories | None beyond the effect name; current flag filtering is not retail proof | Same | Same |
| No-effect behavior | None | None | None |
| Message/subeffect | No packet capture; current community descriptions establish only “Dispel” | Same | Same |
| Controlled trials | None found | None found | None found |
| Formula confidence | Unresolved | Unresolved | Unresolved |

## Production-policy classifications

| Policy field | Classification | Bounded Phase B5 policy |
|---|---|---|
| Item and effect-family identity | `EVIDENCE_BACKED` | Exact item IDs; Dispel family only. |
| Introduction era | `EVIDENCE_BACKED` | `VANILLA_OR_ZILART`; +1 uses the documented narrow shared-recipe conclusion. |
| Proc chance | `VERIFY_LIVE` | Preserve SQL 5% / 10% / 10%. |
| Level correction | `VERIFY_LIVE` | Preserve SQL value 0. |
| Triggering attack | `FRAMEWORK_CORRECT_LEGACY_NUMERICS` | Inherit one legitimate successful melee swing. |
| Equip policy | `FRAMEWORK_CORRECT_LEGACY_NUMERICS` | Current two-handed great-sword data makes the item main-hand only. |
| Selection | `VERIFY_LIVE` | Preserve one uniform status-container selection among positive-duration effects with the Dispelable flag. |
| Protected status policy | `VERIFY_LIVE` | Preserve exclusion of effects lacking the Dispelable flag and of zero-duration effects. |
| Retry/fallback | `VERIFY_LIVE` | Preserve one selection/removal attempt and no retry. |
| Accuracy/skill | `VERIFY_LIVE` | Preserve no magic-accuracy or explicit skill layer. |
| Governing stat/dSTAT | `NOT_APPLICABLE` | No stat formula is introduced. |
| Element | `NOT_APPLICABLE` | No Dispel element is introduced. |
| Resistance/partial resist | `VERIFY_LIVE` | Preserve no resistance or partial-resist layer. |
| Removal ownership | `FRAMEWORK_CORRECT_LEGACY_NUMERICS` | Status container selects and removes exactly one effect. |
| Subeffect/message | `FRAMEWORK_CORRECT_LEGACY_NUMERICS` | Use the existing Dispel presentation convention: Darkness Damage subeffect and `ADD_EFFECT_DISPEL`. Exact client presentation remains capture-gated. |
| Message parameter | `FRAMEWORK_CORRECT_LEGACY_NUMERICS` | Serialize the actual removed effect ID. |
| No-effect behavior | `FRAMEWORK_CORRECT_LEGACY_NUMERICS` | No removable effect produces no additional-effect result. |

## Current-server reproduction and bounded correction

Before the Phase B5 production change, real main-hand melee tests for all three
weapons proved:

- the configured proc reached `dispelStatusEffect()` and removed Protect;
- the SQL entries had no `ITEM_SUBEFFECT`;
- the returned subeffect was therefore zero; and
- 0x028 marked no additional-effect result even though the status had already
  been removed.

The corrected exact-scope profiles provide a nonzero compatibility
presentation only after the authoritative status container returns an actual
removed effect. They do not change SQL, proc rates, level correction, status
selection, protected categories, accuracy, element, resistance, or retries.

## Required live-retail evidence

For each item independently:

1. counted proc trials at equal and different attacker/target levels;
2. multiple-buff trials recording selection distribution and whether a failed
   selection retries;
3. trials against undispellable, erase-only, permanent, food, aura, and
   special effects;
4. packet captures proving subeffect, message, effect-ID parameter, and
   no-effect presentation;
5. evidence for or against magic accuracy, skill, element, full resist, and
   partial resist;
6. multi-attack and Enspell-priority captures; and
7. a dated Vanilla/Zilart-era record directly naming Mythril Heart +1.

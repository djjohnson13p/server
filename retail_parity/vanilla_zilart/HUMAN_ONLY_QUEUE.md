# Human-Only Queue — Vanilla + Rise of the Zilart

Status: NOT_FINAL_ENGINEERING_CONTINUES

No gameplay, retail-capture, server-deployment, or manual test task is being assigned to the owner at this state.

The local Codex desktop environment, GitHub connectivity, MSVC toolchain,
CMake/Ninja configuration, full Debug build, focused inherited-correction
tests, `VZ-CORE-002`, `VZ-BF-001`, and the `VZ-COMBAT-001` Phase A
inventory/framework correction plus Phase B1/B2/B3/B4/B5 profile passes are
validated. The remaining known engineering work is still AI-capable, so it
does not belong in a final human-only queue yet.

## Current AI stage

Codex must still:

- complete `VZ-COMBAT-001` Phase B and the two remaining unimplemented known
  findings;
- continue the exhaustive Vanilla/Zilart local-repository audit;
- run the available C++, Lua, SQL, unit, integration, startup, and build checks;
- update the findings and project reports.

## Provisional live-retail/client candidates

These items may become human-only after all remaining AI-capable engineering and automated validation are complete. They are recorded now only to prevent loss of context:

- Confirm Temple of Uggalepih rendered opening timing and complete Windurst
  9-2/San d'Oria 8-2 route traversal. Server-side mapping, side checks,
  messages, consumption, and opening state are automated.
- Confirm new-moon fishing curve coefficients and the exact Waders
  lucky-timing magnitude. Dispatch and reachability are automated.
- Confirm Moghancement: Region fractional rounding if retail differs from the
  test-backed current truncation.
- Confirm Call-for-Help claim color/radar, outside-player attackability,
  experience/drop suppression, and rendered client updates. Server scope,
  party/pet personal-enmity distinctions, boundaries, claim clearing, and
  message cardinality are automated.
- Measure Shadowbind main-job versus `/RNG` accuracy, target-level correction,
  duration/resist behavior, and Recycle rules beyond the automated Unlimited
  Shot path.
- Capture Attack-while-fishing release packets, messages, and rendered
  animation ordering in waiting and hooked phases, plus representative
  invalid-target behavior. Server cleanup, resource accounting, stale-input
  rejection, and recovery are automated.
- Capture Ark Angel move-by-move ready/no-ready behavior where current data
  had no evidence, especially Shield Strike, Charm, and job specials. Also
  record the rendered order of a zero-time start/finish pair sent in one
  server update. State ownership, packet category, spam prevention, inherited
  standard-ready policies, and Trion/Volker exceptions are automated.
- Collect controlled item additional-effect datasets by item/family:
  separate proc from resist, test dSTAT/no-dSTAT and damage type, potency,
  duration/partial resist, drain order/accuracy/scaling, self-buff/Death/
  spikes behavior, and exact combat presentation. Acid/Sleep item-native
  A-rank is already represented; their governing-stat question and any
  extension to other ammunition remain unresolved.
- For Fire Arrow (17322), Ice Arrow (17323), and Lightning Arrow (17324),
  capture each item separately with actor/target level and INT, actor MAB and
  magic accuracy, equipped weapon/staff/affinity, distance, day/weather,
  target elemental resistance, every physical hit/miss, proc/no-proc, raw
  0x028 subeffect/message/value, and actual HP delta. Isolate nullification,
  absorption, Phalanx, Stoneskin, and One for All where available. The
  current 100% proc, uniform 7-10 power, A+ rank, no-stat/zero-macc, disabled
  MAB, 1/8 floor, staff/affinity/day-weather, and defense rules are explicit
  compatibility behavior, not retail conclusions.
- For Kabura Arrow 17325, Patriarch Protector's Arrow 17329, Blind Bolt
  18150, Venom Bolt 18152, Poison Arrow 18157, Sleep Arrow 18158, Demon Arrow
  18159, and Spartan Bullet 18160, capture each physical hit/miss and 0x028
  effect separately while varying level, rank/stat, magic evasion, associated
  element resistance, overwrite state, and elapsed status duration. Current
  proc/level/A-rank/INT/element/power/duration/half-tier behavior is explicit
  compatibility, not retail proof.
- For Spartan Bullet specifically, use two shooters and two targets to bracket
  the post-Stun interval at one-second resolution; distinguish target,
  shooter, and global ownership; compare ordinary shots with ranged weapon
  skills; and interleave spell Stun plus a different Stun additional-effect
  source. Accessible evidence supports a missing cooldown but conflicts
  between approximately 10-20, 20-30, and 30 seconds.
- For Aspir Knife 16509, Bloody Rapier 16528, and Shinsoku 17823, record
  several hundred eligible melee hits per item with raw 0x028 results and
  separate proc from no-effect/resist. Independently vary actor/target level,
  level sync, plausible skill/accuracy/stat inputs, Dark resistance/MEVA,
  MAB, staff/affinity/day/weather, SDT, nullification, absorption, undead,
  Phalanx, Stoneskin, One for All, target resource below/equal/above the
  drain and at zero, attacker resource below cap/full, main/off hand,
  Enspell priority, multi-attack, and lethal HP-drain boundaries. Current
  10%/3, 5%/10, 8%/10, Dark magical tiers/multipliers, cap behavior, and
  zero-result presentation are compatibility contracts, not retail proof.
- For later-expansion Hofud 17745, Vampirism 20706, and Crepuscular Knife
  21585, collect a counted eligible-swing dataset with raw 0x028 results and
  actual HP/MP/TP deltas. Separate overall proc from resistance; record the
  selected resource, empty/full target and attacker resources, main/off hand,
  ordinary versus extra multi-attacks, Enspell priority, dead/undead,
  nullification/absorption, and every no-effect result. Vary level, magic
  accuracy/evasion, plausible skill/stat inputs, Dark resistance/SDT, and
  defenses. The current 15%/15, 100%/20, and 15%/15 values, uniform HP/MP or
  HP/MP/TP selection, no retry, Dark legacy calculation, shared subeffect,
  resource-specific message, and cap/overflow behavior are tested server
  compatibility—not retail proof. Crepuscular evidence specifically conflicts
  between equal branches and an approximately 45% HP/45% MP/10% TP theory.
- For Lockheart 16944, Mythril Heart 16950, and Mythril Heart +1 16951,
  collect counted eligible-swing trials per item with raw 0x028 results.
  Separate proc from no removable effect; record multi-buff selection,
  selection distribution, failed-selection retry behavior, undispellable,
  erase-only, permanent, food, aura, and special-effect protection, and
  whether level, magic accuracy/skill, resistance, element, or partial resist
  participates. Include ordinary versus extra multi-attacks and Enspell
  priority. Confirm the subeffect, message, actual removed effect-ID
  parameter, and no-effect presentation. Also obtain a dated pre-CoP record
  directly naming Mythril Heart +1; its current Vanilla/Zilart gate is the
  documented moderate-confidence shared-recipe inference.
- Measure Elemental Spirit HP/MP/stat/weapon-damage scaling and Light Spirit decision behavior.
- Capture Ballista packet fields, current schedules/rules, and client-visible match behavior.

## Acceptance rule

No item above is considered an owner action until a future Codex pass:

1. completes the remaining repository audit and implementation;
2. adds and runs the available automated tests;
3. separates genuinely client/retail-only validation from work still possible in code or tooling;
4. changes this file to a final actionable state.

## Rejected intermediate requests

Per project policy, individual findings are not sent to the owner for testing during the audit. No upstream pull request may be opened or suggested.

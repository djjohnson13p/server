# Human-Only Queue — Vanilla + Rise of the Zilart

Status: NOT_FINAL_ENGINEERING_CONTINUES

No gameplay, retail-capture, server-deployment, or manual test task is being assigned to the owner at this state.

The local Codex desktop environment, GitHub connectivity, MSVC toolchain,
CMake/Ninja configuration, full Debug build, focused inherited-correction
tests, `VZ-CORE-002`, `VZ-BF-001`, and the `VZ-COMBAT-001` Phase A
inventory/framework correction are validated. The remaining known
engineering work is still AI-capable, so it does not belong in a final
human-only queue yet.

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

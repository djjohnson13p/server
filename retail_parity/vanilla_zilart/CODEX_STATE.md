# Codex State — Vanilla + Rise of the Zilart

Status: VZ_COMBAT_001_PHASE_B4_COMBINED_RESOURCE_DRAINS_PROFILED
Pass: 11
Last updated: 2026-07-29

## Local Codex environment

The autonomous local Codex path is validated on Windows:

- Codex desktop project root: `C:\GitHub\server`
- Repository and branch access: passed
- Shell execution: passed
- GitHub `origin` fetch: passed
- Repository instruction loading: passed
- Visual Studio Build Tools/MSVC initialization: passed
- Clean MSVC/Ninja Debug configuration: passed
- Clean MSVC/Ninja Debug build: passed (`1049/1049` steps)
- Final worktree cleanup: passed

The exact tool versions, commands, compiler initialization, cleanup rules, and submodule state are recorded in `LOCAL_CODEX_ENVIRONMENT.md`.

The earlier `FAILED_INFRASTRUCTURE` state applied only to the assistant's network-isolated execution container and is superseded by the validated local Codex desktop environment.

## Completed fork corrections

1. `VZ-ZONE-001` — western Temple of Uggalepih Map 2 door uses the Uggalepih Key.
2. `VZ-ECON-001` — fishing moon-pattern case 5 dispatches to `MOONPATTERN_5`.
3. `VZ-ECON-002` — Waders reach the existing fishing lucky-timing bonus.
4. `VZ-ECON-003` — Moghancement: Region applies its modifier as a percentage of base influence.
5. `VZ-JOB-002` — Shadowbind respects shared Bind immunity, resistance-trait, and effect-nullification guards while retaining unresolved accuracy coefficients.
6. `VZ-CORE-001` — Call for Help processes currently eligible personal-enmity mobs within the requesting player's current instance instead of only `GetBattleTarget()`.
7. `VZ-CORE-002` — a valid Attack safely and idempotently interrupts fishing
   after ordinary engagement validation, with stale fishing input rejected.
8. `VZ-BF-001` — mob-skill ready messages are explicit engine-owned
   state-entry policy; zero-time Ark Angel skills no longer emit packets from
   repeated eligibility checks.
9. `VZ-COMBAT-001` Phase A — generated inventory/profile ownership is in
   place; deterministic double-application, duplicate absorb/null, breath
   flag, and false status-presentation defects are corrected. Unsupported
   retail formulas remain explicitly partial.
10. `VZ-COMBAT-001` Phase B1 — Fire, Ice, and Lightning Arrow now resolve
    through one validated item-profile registry. Exact element and
    deterministic result ownership are test-backed; unsupported 7-10/100%,
    stat, accuracy, resistance, and multiplier behavior remains explicit
    compatibility/`VERIFY_LIVE`. A follow-up makes base power lazy so failed
    proc, full-nullification, and below-floor resistance paths do not advance
    power RNG; numeric callers and successful outcomes remain unchanged.
11. `VZ-COMBAT-001` Phase B2 — eight maintained status-ammunition items now
    resolve through one explicit SQL-backed policy registry. The status
    application path removes an opposing boost only after authoritative
    success. Exact numerics and the known-missing Spartan cooldown remain
    `VERIFY_LIVE`.
12. `VZ-COMBAT-001` Phase B3 — Aspir Knife, Bloody Rapier, and Shinsoku now
    resolve through one validated single-resource-drain registry and one
    exact-scope transfer owner. Shinsoku's missing TP-drain presentation data
    is corrected; unsupported retail numerics remain `VERIFY_LIVE`.
13. `VZ-COMBAT-001` Phase B4 — later-expansion Hofud, Vampirism, and
    Crepuscular Knife now resolve through one validated combined-resource-
    drain registry, one branch-selection owner, and the shared one-resource
    transfer primitive. Uniform/no-retry selection and unsupported retail
    formulas remain explicit compatibility/`VERIFY_LIVE`.

## Validation completed

- Exact source inspection and evidence records for all eleven findings.
- `VZ-ZONE-001`: five Lua interaction cases cover exact/wrong trades,
  consumption, message parameters, both door identities, and both side checks.
- `VZ-ECON-001`: Catch2 covers patterns 4 and 5 across every defined moon
  phase against the production curve dispatch.
- `VZ-ECON-002`: Catch2 covers Waders reachability, both existing boot
  branches, and unrelated-feet filtering.
- `VZ-ECON-003`: Catch2 covers 0%, 10%, 100%, small/zero awards, negative
  modifiers, and fractional truncation.
- `VZ-JOB-002`: nine Lua ability cases cover all implemented guards,
  success/failure messages, ordinary ammo consumption, Unlimited Shot
  preservation, and main/subjob level availability.
- `VZ-CORE-001`: nine Lua action cases plus one Catch2 boundary case cover
  one/multiple/no eligible targets, claim transitions, party/pet personal
  enmity, blocked/already-enabled mobs, message cardinality, battle and
  confrontation boundaries, and instance identity.
- `VZ-CORE-002`: eight Lua packet/state cases cover waiting and hooked
  interruption, pre-reward cancellation, invalid targets, exact resource
  accounting, fishing-monster cleanup, stale/crafted packets, idempotence,
  ordinary cancellation, other action restrictions, and recovery.
- `VZ-BF-001`: 11 real state/controller/battlefield Lua cases cover the
  issue-#3611 out-of-range reproduction, Ark Angel standard and no-start
  zero-time behavior, positive preparation/interruption, pool exceptions,
  failed state creation, target presentation, and custom dialogue.
- Latest focused result: all 11 selected mob-skill start-message Lua tests
  passed with both visible and hidden ready-target settings.
- Catch2 result: all 19 cases and 9,007,079 assertions passed.
- The complete 65-case `0x028` battle-action packet suite passed, including
  pets, Blood Pacts, player weapon skills, and ordinary mob skills.
- `VZ-COMBAT-001` Phase A: generated inventory covers 420 items and all 18
  maintained Vanilla/Zilart profiles pass reachability/classification sanity.
  Focused Lua covers real melee/ranged packets, Acid/Sleep status ammo,
  proc/resistance separation, exactly-once damage, absorb/nullification,
  physical/ranged/breath flags, level eligibility, status families, and all
  five maintained NM hooks.
- `VZ-COMBAT-001` Phase B1: 51 focused Lua cases cover exactly three arrow
  profiles, invalid/duplicate policy rejection, proc-before-power ordering,
  early-rejection RNG preservation, direct numeric compatibility, min/max
  power, stat and multiplier compatibility, all configured resist tiers,
  nullification, absorption, defenses, HP caps, and real ranged hit/miss/
  range/despawn/level/ammo/priority paths. Inventory generation and
  exact-scope sanity pass.
- `VZ-COMBAT-001` Phase B2: 49 new focused Lua cases cover exactly eight
  status-ammunition profiles, every real successful ranged result, every
  physical miss, range/despawn/level/ammo-preservation paths, malformed/
  duplicate/later-item rejection, Acid/Sleep separation, proc and resist
  boundaries, all eight guard/resist paths, rank/stat/element transport,
  power/duration/tick, authoritative
  application rejection, and post-success opposing-boost removal. The Phase
  A regression file adds one caller-path rejection case. Inventory generation
  and exact-scope sanity pass.
- `VZ-COMBAT-001` Phase B3: 58 focused Lua cases cover exactly three
  single-resource profiles, malformed/duplicate/SQL drift, one proc/
  calculation/transfer, HP/MP/TP caps and isolation, all compatibility
  resistance tiers, defense/null/absorb, dead/undead, real main/off-hand
  packets, miss/level/despawn/priority/multi-attack, and ordinary melee.
  Combined, scripted, and later drains are explicitly excluded.
- `VZ-COMBAT-001` Phase B4: 55 focused Lua cases cover exactly three
  `LATER_EXPANSION` combined-resource profiles, malformed/duplicate/SQL
  drift, every HP/MP/TP selector, one proc/selection/calculation/transfer,
  resource and cap boundaries, compatibility resistance tiers, no retry
  after empty/resisted/nullified/absorbed/undead branches, resource
  isolation, and real main/off-hand/miss/level/despawn/priority/multi-
  attack/ordinary melee paths.
- The mandatory six-selector aggregate reproduced the prior unexplained
  failure as a stacked Lua-double lifetime defect. Reverse installation-
  order restoration is regression-backed; the corrected pre-edit aggregate
  passed 198/198 in one process. Post-edit and final post-build repeats also
  passed 198/198.
- Lua style/purity, SQL sanity, C++ formatting, and `git diff --check` passed.
- A fresh-directory MSVC/Ninja Debug configuration passed.
- The complete all-target MSVC/Ninja Debug build passed and linked
  `xi_connect`, `xi_map`, `xi_search`, `xi_world`, and `xi_test`.
- The disposable build directory, generated root executables/PDBs, and
  isolated test database were removed; the working local `xidb` was not
  modified.

## Current work

The bounded `VZ-COMBAT-001` Phase B4 pass is complete as a shared-core
profile/framework hardening pass. Independent evidence classifies Hofud,
Vampirism, and Crepuscular Knife as 2007, 2015, and 2021
`LATER_EXPANSION`; the maintained Vanilla/Zilart count remains 18. Their SQL
numbers, uniform branch choice, no-retry policy, legacy Dark calculation,
and presentation remain explicit compatibility because no controlled retail
dataset was found. Deterministic ownership, every branch, real melee packets,
resource isolation, and B3 regression behavior are automated.

Seven findings are implemented and test-backed. `VZ-JOB-002` and
`VZ-COMBAT-001` remain partial where evidence is insufficient. Fire/Ice/
Lightning Arrow, the eight Phase B2 status items, and the three Phase B3
single-resource drains plus the three later Phase B4 combined drains are
hardened/profiled, not retail-formula-corrected. The item framework's
remaining drains, Dispel, absorb-status, self-buff, Death, spikes, and
item-specific damage/status numerics are explicit `VERIFY_LIVE` or
compatibility work, not claimed retail-correct.

## Remaining AI-capable work

- Continue `VZ-COMBAT-001` Phase B5 in bounded, evidence-backed family or
  configuration groups.
- Complete `VZ-JOB-001` Elemental Spirit data, spell-selection, and scaling work.
- Implement `VZ-SYS-001` Ballista.
- Continue the exhaustive local-repository audit beyond the eleven assistant findings.
- Run formatting, Lua, SQL, C++, unit, integration, and startup checks appropriate to each pass.

## Human-only candidates

No gameplay test is assigned to the owner. Provisional client/live-retail
candidates remain:

- Temple door rendered timing and full route traversal;
- fishing curve coefficients and exact Waders magnitude;
- conquest fractional rounding;
- Call-for-Help reward/outside-player/client presentation;
- Shadowbind numeric accuracy, level, duration/resist, and Recycle behavior;
- attack-while-fishing release packet order, rendered animation/message
  timing, and invalid-target client behavior.
- exact per-move Ark Angel ready/no-ready policy and rendered ordering of a
  zero-time start/finish pair.
- controlled Fire/Ice/Lightning Arrow datasets splitting proc from resist and
  isolating 7-10 power, actor/target INT, magic accuracy/skill, MAB, staff,
  affinity, day/weather, distance, defenses, elemental null/absorb, and 0x028
  presentation; plus other-family damage/scaling, drain ordering/accuracy,
  self-buff/Death/spikes formulas, and client presentation.
- controlled per-item status-ammunition datasets splitting proc from resist,
  rank/stat/element, power/duration/overwrite, and 0x028 presentation; plus a
  two-shooter/two-target Spartan Bullet dataset that brackets cooldown,
  distinguishes target/source ownership, covers ranged weapon skills, and
  interleaves unrelated Stun sources.
- controlled Aspir Knife/Bloody Rapier/Shinsoku datasets separating proc
  from resist and varying amount/scaling, skill/stat/dSTAT, Dark resistance,
  multiplier/defense/null/absorb/undead paths, empty/full resource caps,
  main/off-hand priority, lethal HP drain, and exact 0x028 presentation.
- controlled Hofud/Vampirism/Crepuscular datasets separating overall proc,
  branch selection, resistance, nonuniform-distribution hypotheses,
  retry/fallback, per-resource amount/scaling, empty/full caps, multi-attack,
  Dark/null/absorb/undead/defense behavior, and exact 0x028 presentation.

## Exact next-pass instructions

1. Fetch `origin` and confirm the local branch includes this completed
   inherited-validation pass.
2. Read `AGENTS.md`, `CODEX_MASTER_TASK.md`, `CODEX_BACKLOG.md`, `LOCAL_CODEX_ENVIRONMENT.md`, the status/worklog, completion report, and all finding files.
3. Confirm the worktree is clean and remain on `retail-parity/codex-vanilla-zilart`.
4. Begin one bounded `VZ-COMBAT-001` Phase B5 family/configuration pass using
   the generated inventory and evidence ledgers. Do not silently extend the
   Phase B1/B2/B3/B4 compatibility policies.
5. Initialize MSVC through `VsDevCmd.bat` for all Windows configure/build commands.
6. Run narrow tests first, then the full MSVC/Ninja Debug build.
7. Fix failures caused by the fork changes; do not hide failures or weaken unrelated assertions.
8. Update all project state/report files, create logical fork-only commits,
   and push only to `origin` when explicitly permitted.
9. Never create or suggest an upstream pull request.

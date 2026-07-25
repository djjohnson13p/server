# Codex State — Vanilla + Rise of the Zilart

Status: VZ_CORE_002_VALIDATED
Pass: 4
Last updated: 2026-07-25

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
- Latest focused result: all 8 selected fishing/Attack Lua tests passed.
- Catch2 result: all 16 cases and 9,007,070 assertions passed.
- Lua style checks and `git diff --check` passed.
- A fresh-directory MSVC/Ninja Debug configuration passed.
- The complete all-target MSVC/Ninja Debug build passed and linked
  `xi_connect`, `xi_map`, `xi_search`, `xi_world`, and `xi_test`.
- The disposable build directory, generated root executables/PDBs, and
  isolated test database were removed; the working local `xidb` was not
  modified.

## Current work

The bounded `VZ-CORE-002` pass is complete. The safe server transition is
implemented and test-backed from the waiting and hooked phases through
validated engagement, stale-input rejection, resource preservation, and
post-combat recovery. Exact retail client packet/animation presentation and
invalid-target behavior remain final live-capture candidates, not remaining
server engineering.

Six findings are implemented and test-backed. `VZ-JOB-002` remains a
test-backed partial correction: its supported guards and ammunition behavior
are covered, while exact `/RNG`, relative-level, ranged-accuracy,
duration/resist, and `BIND_MEVA` coefficients remain unresolved for lack of
evidence.

## Remaining AI-capable work

- Complete `VZ-BF-001` Ark Angel/mob-skill ready-message architecture.
- Complete `VZ-COMBAT-001` item additional-effect inventory and framework refactor.
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

## Exact next-pass instructions

1. Fetch `origin` and confirm the local branch includes this completed
   inherited-validation pass.
2. Read `AGENTS.md`, `CODEX_MASTER_TASK.md`, `CODEX_BACKLOG.md`, `LOCAL_CODEX_ENVIRONMENT.md`, the status/worklog, completion report, and all finding files.
3. Confirm the worktree is clean and remain on `retail-parity/codex-vanilla-zilart`.
4. Begin `VZ-BF-001` Ark Angel zero-delay ready-message behavior with an
   explicit message/state transition and focused tests.
5. Initialize MSVC through `VsDevCmd.bat` for all Windows configure/build commands.
6. Run narrow tests first, then the full MSVC/Ninja Debug build.
7. Fix failures caused by the fork changes; do not hide failures or weaken unrelated assertions.
8. Update all project state/report files, create logical fork-only commits,
   and push only to `origin` when explicitly permitted.
9. Never create or suggest an upstream pull request.

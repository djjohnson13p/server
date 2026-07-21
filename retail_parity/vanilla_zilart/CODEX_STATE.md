# Codex State — Vanilla + Rise of the Zilart

Status: IMPLEMENTATION_READY
Pass: 2
Last updated: 2026-07-21

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

## Validation completed

- Exact source inspection and evidence records for all eleven findings.
- Exact-match source assertions and `git diff --check` for the deterministic fishing/conquest correction commit.
- Source encoding restoration for `conquest_system.cpp`.
- Commit-diff isolation review for the door, Shadowbind, and Call for Help changes.
- Successful full local MSVC/Ninja Debug build of the current branch at commit `2ecefb7fadc15d7a849ff25809d9ad0fad165552`.
- Successful GitHub fetch and clean worktree restoration.

## Current work

The next Codex pass should add automated regression coverage for the six inherited corrections before beginning another broad gameplay system. The build environment is ready; build repair is no longer a prerequisite.

## Remaining AI-capable work

- Add focused tests for the six inherited corrections.
- Resolve any defects exposed by those tests without weakening unrelated assertions.
- Complete `VZ-CORE-002` attack-while-fishing state cleanup.
- Complete `VZ-BF-001` Ark Angel/mob-skill ready-message architecture.
- Complete `VZ-COMBAT-001` item additional-effect inventory and framework refactor.
- Complete `VZ-JOB-001` Elemental Spirit data, spell-selection, and scaling work.
- Implement `VZ-SYS-001` Ballista.
- Continue the exhaustive local-repository audit beyond the eleven assistant findings.
- Run formatting, Lua, SQL, C++, unit, integration, and startup checks appropriate to each pass.

## Human-only candidates

No gameplay test is assigned to the owner. Live-retail/client validation candidates remain provisional until the engineering and automated-validation stages are exhausted.

## Exact next-pass instructions

1. Fetch `origin` and confirm the local branch includes the latest documentation commit.
2. Read `AGENTS.md`, `CODEX_MASTER_TASK.md`, `CODEX_BACKLOG.md`, `LOCAL_CODEX_ENVIRONMENT.md`, the status/worklog, completion report, and all finding files.
3. Confirm the worktree is clean and remain on `retail-parity/codex-vanilla-zilart`.
4. Add the strongest practical automated tests for the six inherited corrections, prioritizing deterministic C++ and existing test-harness coverage.
5. Initialize MSVC through `VsDevCmd.bat` for all Windows configure/build commands.
6. Run narrow tests first, then the full MSVC/Ninja Debug build.
7. Fix failures caused by the fork changes; do not hide failures or weaken unrelated assertions.
8. Update all project state/report files, create logical fork-only commits, and push only to `origin` when explicitly permitted.
9. Never create or suggest an upstream pull request.

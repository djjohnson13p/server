# Codex State — Vanilla + Rise of the Zilart

Status: FAILED_INFRASTRUCTURE
Pass: 1
Last updated: 2026-07-21

## Completed in the Codex-stage attempt

The prepared Codex branch was created from the completed assistant handoff and the following fork-only corrections are present:

1. `VZ-ZONE-001` — western Temple of Uggalepih Map 2 door uses the Uggalepih Key.
2. `VZ-ECON-001` — fishing moon-pattern case 5 dispatches to `MOONPATTERN_5`.
3. `VZ-ECON-002` — Waders reach the existing fishing lucky-timing bonus.
4. `VZ-ECON-003` — Moghancement: Region applies its modifier as a percentage of base influence.
5. `VZ-JOB-002` — Shadowbind now respects shared Bind immunity, resistance-trait, and effect-nullification guards while retaining unresolved accuracy coefficients.
6. `VZ-CORE-001` — Call for Help now processes every currently eligible personal-enmity mob within the requesting player's current instance instead of only `GetBattleTarget()`.

Temporary workflows used during the implementation attempt were removed from the branch.

## Automated validation completed

- The three deterministic C++ corrections were applied by an exact-match workflow that failed if baseline expressions were absent or duplicated.
- Static post-edit assertions verified the intended expressions.
- `git diff --check` passed for that deterministic correction commit.
- Original source encoding for `conquest_system.cpp` was restored in a follow-up commit.
- Shadowbind's commit diff is confined to `useShadowbind`.
- Call for Help's commit diff is confined to the `Help` action block.
- The pinned source API confirms the `ForEachMobInstance` signature used by Call for Help.
- The pinned source contains matching status-effect helper signatures used by Shadowbind.

## Infrastructure failure

The full autonomous Codex stage could not execute in this runtime:

- The official Codex CLI was installed and already authenticated.
- The runtime could not reach the OpenAI responses endpoint or GitHub Git/raw endpoints because external DNS/network access was unavailable.
- A local repository clone could not be created for Codex.
- A fork GitHub Actions GCC Debug build reached dependency setup and CMake configuration successfully, then failed during the Build step.
- The first result-reporting workflow contained a reporter-script error and did not persist the compiler-log tail.
- Subsequent connector-authored workflow pushes were suppressed with “No jobs were run,” preventing a corrected diagnostic build from executing.
- GitHub connector access supports source reads and complete-file writes but cannot replace a functioning iterative local build/test environment for the remaining cross-cutting work.

Because the environment cannot execute Codex or obtain reliable build diagnostics, continuing to edit the remaining large systems would exceed the project's evidence and validation guardrails.

## Remaining AI-capable work

- Diagnose and repair the native build on the current Codex branch.
- Add automated tests for all six implemented corrections.
- Complete `VZ-CORE-002` attack-while-fishing state cleanup.
- Complete `VZ-BF-001` Ark Angel/mob-skill ready-message architecture.
- Complete `VZ-COMBAT-001` item additional-effect inventory and framework refactor.
- Complete `VZ-JOB-001` Elemental Spirit data, spell-selection, and scaling work.
- Implement `VZ-SYS-001` Ballista.
- Continue the exhaustive local-repository audit beyond the eleven assistant findings.
- Run formatting, lint, startup, Lua, SQL, C++, integration, and gameplay-oriented automated checks.

## Human-only candidates

No gameplay test is being assigned to the owner at this state. Live-retail/client validation candidates remain provisional because the engineering and automated-validation stage is incomplete.

## Exact next-pass instructions

1. Use a machine/runtime with outbound access to GitHub and the OpenAI Codex endpoint.
2. Clone `djjohnson13p/server` and check out `retail-parity/codex-vanilla-zilart` at its latest head.
3. Read `AGENTS.md`, `CODEX_MASTER_TASK.md`, `CODEX_BACKLOG.md`, `ASSISTANT_COMPLETION_REPORT.md`, this state file, the status/worklog, and all findings.
4. Run a clean GCC Debug build first and capture the first compiler error from the current branch.
5. Repair build/test failures caused by the fork changes before starting another finding.
6. Add tests for the deterministic fishing/conquest fixes, Shadowbind guards, Call for Help scope, and the inherited door correction.
7. Continue the remaining backlog in priority order without requesting intermediate owner testing.
8. Keep all work on the fork-owned Codex branch and never create or suggest an upstream pull request.

# Codex Completion Report — Vanilla + Rise of the Zilart

Status: FAILED_INFRASTRUCTURE

## Branch and source state

- Repository: `djjohnson13p/server`
- Work branch: `retail-parity/codex-vanilla-zilart`
- Pinned upstream baseline: `242ab0d055dfb80396e7398b0dd7361b750c74e2`
- Latest gameplay/source implementation commit in this attempt: `de408e05de4c8c44250f9db493492817bbe8db65`
- Later commits update findings, status, state, reports, and worklog only.
- Upstream pull requests: none; prohibited.

## Audit coverage completed

The assistant-stage audit inspected representative active source and data across:

- shared combat/action/status behavior;
- original and Zilart jobs and pets;
- national and Rise of the Zilart missions;
- Ark Angel/Divine Might battle behavior;
- Ballista protocol/content support;
- fishing, gardening, HELM, crafting, guilds, conquest, outposts, Expeditionary Forces, and transport;
- tests, TODO/FIXME markers, disabled handlers, active upstream issues, and stale issue rejection.

Eleven baseline findings met the evidence threshold:

- `MISSING`: 1
- `INACCURATE`: 10

This is not a complete local-filesystem expansion audit. The network/local-repository Codex stage could not run, so additional discrepancies may remain undiscovered.

## Findings confirmed, rejected, or revised

### Confirmed and implemented or partially implemented

- `VZ-ZONE-001` — Temple of Uggalepih door key.
- `VZ-ECON-001` — fishing new-moon pattern dispatch.
- `VZ-ECON-002` — Waders fishing bonus reachability.
- `VZ-ECON-003` — Moghancement: Region influence arithmetic.
- `VZ-JOB-002` — Shadowbind shared status guards; numeric accuracy remains unresolved.
- `VZ-CORE-001` — Call for Help current-instance personal-enmity scope; edge-case tests remain unresolved.

### Confirmed and not implemented

- `VZ-SYS-001` — Ballista.
- `VZ-COMBAT-001` — item additional-effect framework.
- `VZ-JOB-001` — Elemental Spirit behavior/scaling.
- `VZ-CORE-002` — safe attack-while-fishing transition.
- `VZ-BF-001` — Ark Angel/mob-skill ready-message architecture.

### Rejected or superseded leads

- Old nation-change opening-cutscene issue: current immigration logic supersedes it.
- Moghancement: Experience Raise TODO: the modifier is already applied during death-loss calculation.
- Bastok Mission 6-2 Oaken Door workaround: current direct Gilgamesh interaction matches cited retail captures.
- Selbina/Mhaura duplicate-arrival TODO: not promoted without a player-visible reproduction.
- Optional historical-era-module and later-expansion job TODOs were not misclassified as active Vanilla/Zilart current-retail defects.

## Implementations completed

### `VZ-ZONE-001`

- Consolidated audit commit: `ed3bb6e3e59dbe482ebc58d44587576e0b035ab9`
- `_mf9` uses and consumes an Uggalepih Key; `_mf8` remains the Prelate-Key door.

### `VZ-ECON-001`, `VZ-ECON-002`, `VZ-ECON-003`

- Implementation commit: `556ad21ccda664e012003e5898fa7b4e2936c208`
- Encoding-preservation follow-up: `0702a5be6421efd52be6ed17a4fa36347f1c69cf`
- Corrected moon-pattern case 5, Waders gear recognition, and regional-influence percentage arithmetic.

### `VZ-JOB-002`

- Implementation commit: `b0058b40ef4b71dfd7af2d24dbae7fcf8edfd7f4`
- Added Bind immunity, resistance-trait, and effect-nullification guards.
- Preserved unresolved main/subjob, level, exact accuracy, duration, and ammunition questions.

### `VZ-CORE-001`

- Implementation commit: `de408e05de4c8c44250f9db493492817bbe8db65`
- Replaced single-target handling with current-instance mob iteration.
- Preserved existing personal-enmity, already-enabled, and blocked-mob checks.
- Emits one success/failure result per request.

## Automated validation

Completed:

- Exact baseline-expression matching before the three deterministic C++ edits.
- Static post-edit source assertions.
- `git diff --check` for the deterministic correction commit.
- Restoration of original `conquest_system.cpp` source encoding.
- Commit-diff review proving the Shadowbind change is confined to `useShadowbind`.
- Commit-diff review proving the Call for Help change is confined to the `Help` action block.
- Source-API review of the instance iteration and status-effect helper signatures.

Attempted but not completed:

- A GitHub Actions Ubuntu GCC Debug build completed dependency setup and CMake configuration, then failed during compilation.
- The result reporter failed before persisting the compiler-log tail.
- Later connector-authored diagnostic workflows were suppressed with “No jobs were run.”
- No successful native build, unit-test run, integration-test run, startup check, Lua check, or SQL check was obtained for the final branch.

## Infrastructure failure

- The official Codex CLI was installed and had authentication state.
- The runtime could not reach the OpenAI responses endpoint or GitHub Git/raw endpoints.
- A local repository clone could not be created.
- The GitHub connector allowed source inspection and complete-file writes but could not provide an iterative local compilation/test loop.

The terminal state is therefore `FAILED_INFRASTRUCTURE`, not `COMPLETE` or `BLOCKED_HUMAN_ONLY`.

## Known limitations and regression risk

- The current branch has not passed native compilation.
- Call for Help may require an explicit claim-state check for rare enmity-after-unclaim transitions; tests must decide this.
- Shadowbind still uses the existing `BIND_MEVA` roll and has unresolved main/subjob and relative-level behavior.
- Fishing and conquest corrections need deterministic unit/IPC tests and explicit rounding validation.
- The Temple door fix needs client route/side/timing validation.
- The remaining five known findings include broad cross-cutting or missing systems.
- The exhaustive local-repository Vanilla/Zilart audit remains incomplete.

## Remaining unverified behavior

Engineering and automated validation still required:

1. Diagnose and fix the current build.
2. Add tests for all six implemented findings.
3. Complete attack-while-fishing cleanup.
4. Complete Ark Angel/mob-skill message architecture.
5. Complete item additional-effect inventory/refactor.
6. Complete Elemental Spirit data/behavior work.
7. Implement Ballista.
8. Continue the full local-filesystem audit and test discovery.

Live-retail/client validation candidates are listed provisionally in `HUMAN_ONLY_QUEUE.md`, but none is assigned to the owner while the engineering stage remains incomplete.

## Resume instructions

Use a networked machine with GitHub and OpenAI Codex access, clone the fork, check out the latest Codex branch, run a clean GCC Debug build, capture the first compiler error, repair build/test failures, and continue `CODEX_BACKLOG.md` in priority order. Keep all work fork-only and never create or suggest an upstream pull request.

# Codex Completion Report — Vanilla + Rise of the Zilart

Status: IN_PROGRESS

## Branch and source state

- Repository: `djjohnson13p/server`
- Work branch: `retail-parity/codex-vanilla-zilart`
- Pinned upstream baseline: `242ab0d055dfb80396e7398b0dd7361b750c74e2`
- Local Codex validation commit: `2ecefb7fadc15d7a849ff25809d9ad0fad165552`
- Latest gameplay/source implementation commit before environment validation: `de408e05de4c8c44250f9db493492817bbe8db65`
- Upstream pull requests: none; prohibited.

## Current execution state

The Codex desktop app is connected to the local clone at `C:\GitHub\server` and can:

- read repository instructions and project files;
- execute shell commands;
- fetch the fork from GitHub;
- initialize Visual Studio Build Tools/MSVC;
- configure with CMake/Ninja;
- complete a full clean Debug build;
- remove generated artifacts and restore a clean worktree.

The prior `FAILED_INFRASTRUCTURE` state applied only to the assistant's isolated container and is superseded. The project is now `IMPLEMENTATION_READY`.

Exact environment details and commands are recorded in `LOCAL_CODEX_ENVIRONMENT.md`.

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

This is not yet a complete local-filesystem expansion audit; Codex must continue it after inherited corrections receive automated test coverage.

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

Completed before local Codex setup:

- Exact baseline-expression matching before the three deterministic C++ edits.
- Static post-edit source assertions.
- `git diff --check` for the deterministic correction commit.
- Restoration of original `conquest_system.cpp` source encoding.
- Commit-diff isolation review for Shadowbind and Call for Help.
- Source-API review of instance iteration and status-effect helper signatures.

Completed in the local Codex environment:

- Correct branch, clean worktree, correct fork remote, and successful `git fetch origin`.
- Repository instruction-file loading.
- MSVC developer-environment initialization through `VsDevCmd.bat`.
- Fresh MSVC/Ninja Debug CMake configuration with exit code `0`.
- Full MSVC/Ninja Debug build with all `1049/1049` steps and exit code `0`.
- Successful linking of `xi_connect`, `xi_map`, `xi_search`, `xi_world`, and `xi_test`.
- Removal of the disposable build directory and generated root executables/PDBs.
- Final clean worktree restoration.

Not yet completed:

- Focused automated regression tests for the six inherited corrections.
- Lua, SQL, startup, integration, and gameplay-oriented checks appropriate to those findings.
- Completion and validation of the remaining five known findings.
- Exhaustive local-filesystem Vanilla/Zilart audit.

## Known limitations and regression risk

- Call for Help may require an explicit claim-state check for rare enmity-after-unclaim transitions; tests must decide this.
- Shadowbind still uses the existing `BIND_MEVA` roll and has unresolved main/subjob and relative-level behavior.
- Fishing and conquest corrections need deterministic unit/IPC tests and explicit rounding validation.
- The Temple door fix needs an interaction test and eventual client route/side/timing validation.
- The remaining five known findings include broad cross-cutting or missing systems.
- A successful build proves compile/link integrity, not retail parity.

## Next implementation pass

1. Fetch the latest `origin/retail-parity/codex-vanilla-zilart` documentation commits.
2. Add the strongest practical automated regression coverage for the six inherited corrections.
3. Run narrow tests first.
4. Run the complete validated MSVC/Ninja Debug build.
5. Fix failures caused by the fork changes without weakening unrelated assertions.
6. Update findings, state, status, worklog, and this report.
7. Commit logically and push only to the fork branch when explicitly permitted.

After inherited corrections are test-backed, continue with attack-while-fishing, Ark Angel ready-message architecture, item additional effects, Elemental Spirits, Ballista, and the remaining full expansion audit.

Live-retail/client validation candidates remain provisional in `HUMAN_ONLY_QUEUE.md`; none is assigned to the owner while the engineering stage continues.

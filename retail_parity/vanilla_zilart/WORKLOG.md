# Vanilla + Rise of the Zilart Worklog

## 2026-07-21 — Project initialization

- Deleted the prior no-value fork and created a clean fork from `LandSandBoat/server`.
- Confirmed administrative and push permissions on `djjohnson13p/server`.
- Pinned upstream baseline `242ab0d055dfb80396e7398b0dd7361b750c74e2`.
- Created `retail-parity/vanilla-zilart-audit`.
- Added the retail-parity method, evidence ranking, finding format, status taxonomy, implementation ownership, worklog, dashboard, and Vanilla/Zilart scope checklist.
- Established the rule that no upstream pull request may be opened or suggested.

## 2026-07-21 — Assistant audit passes

The assistant inspected pinned C++, Lua, SQL, tests, configuration, official/public retail documentation, and current upstream issues through connected GitHub access.

### Confirmed baseline findings

1. `VZ-SYS-001` — Ballista gameplay system missing.
2. `VZ-COMBAT-001` — item additional-effect framework inaccurate and incomplete.
3. `VZ-ZONE-001` — western Temple of Uggalepih Map 2 door used the wrong key.
4. `VZ-JOB-001` — Summoner Elemental Spirit behavior/scaling contains guessed and admitted-wrong logic.
5. `VZ-CORE-001` — Call for Help inspected only the current battle target.
6. `VZ-CORE-002` — attacking while fishing is intentionally blocked despite retail allowing it.
7. `VZ-JOB-002` — Shadowbind bypassed shared immunity/resistance handling and omitted level/subjob behavior.
8. `VZ-ECON-001` — fishing new-moon pattern dispatched to the full-moon formula.
9. `VZ-ECON-002` — Waders were filtered out before their fishing bonus could execute.
10. `VZ-BF-001` — Ark Angel zero-delay weapon skills can emit repeated/incorrect ready messages.
11. `VZ-ECON-003` — Moghancement: Region's configured 10% bonus truncated to zero.

### Assistant correction

- `VZ-ZONE-001` was corrected on the audit branch in commit `ed3bb6e3e59dbe482ebc58d44587576e0b035ab9`.
- `_mf9` now requires and consumes an Uggalepih Key; `_mf8` remains the Prelate-Key door.

### Areas inspected without a promoted finding

- Gardening lifecycle/data/tests.
- Chocobo digging.
- Expeditionary Forces.
- Outpost supply/warp rules and fees.
- HELM gathering logic/data.
- Guild rank-up, guild points, renouncement, and crafting purchases.
- Core synthesis, HQ, desynthesis, skill-up, and material-loss paths.
- Rise of the Zilart mission-sequence test coverage through ZM17.
- Selbina/Mhaura arrival TODOs without a reproduced player-visible failure.

These areas were not certified retail-equivalent; they simply lacked a sufficiently supported finding in the connected-source pass.

### Rejected stale or misleading leads

- Nation-change opening-cutscene issue: current immigration logic already handles seen nations and initial cutscene relocation.
- Moghancement: Experience Raise TODO: death-loss calculation already applies `EXPERIENCE_RETAINED`.
- Bastok Mission 6-2 Oaken Door workaround proposal: current Gilgamesh interaction matches cited retail captures.
- Optional historical `modules/era` TODOs were not mixed into the current-retail target unless active base behavior was also affected.
- Later-expansion merit/job-point TODOs were not assigned to Vanilla/Zilart solely because the job originated earlier.

## 2026-07-21 — AI-first workflow and handoff

At the owner's direction, the project was simplified to:

1. assistant audit and bounded implementation first;
2. one consolidated autonomous Codex run second;
3. one final human-only queue only after AI work is exhausted.

Repository additions included:

- root `AGENTS.md`;
- `AI_FIRST_WORKFLOW.md`;
- `CODEX_MASTER_TASK.md`;
- `CODEX_BACKLOG.md`;
- `ASSISTANT_COMPLETION_REPORT.md`;
- gated `AI_HANDOFF.md`;
- persistent `CODEX_STATE.md`;
- completion and human-only reports;
- `tools/retail_parity/run_codex_remainder.py`.

`AI_HANDOFF.md` was marked `READY`, and `retail-parity/codex-vanilla-zilart` was created from the completed audit branch.

## 2026-07-21 — Partial Codex-stage implementation

### Deterministic corrections

Commit `556ad21ccda664e012003e5898fa7b4e2936c208` implemented:

- `VZ-ECON-001`: case 5 now calls `MOONPATTERN_5`.
- `VZ-ECON-002`: Waders are retained by `GetFishingGear`.
- `VZ-ECON-003`: positive `CONQUEST_REGION_BONUS` values are applied as a percentage of base influence.

The one-time implementation workflow used exact baseline-expression counts, static post-edit assertions, and `git diff --check`, then removed itself.

Commit `0702a5be6421efd52be6ed17a4fa36347f1c69cf` restored the pre-existing UTF-8 BOM on `conquest_system.cpp` so no unrelated encoding change remained.

### Shadowbind partial correction

Commit `b0058b40ef4b71dfd7af2d24dbae7fcf8edfd7f4` added shared Bind:

- immunity checking;
- resistance-trait checking;
- effect-nullification checking.

The existing unresolved `BIND_MEVA` roll, duration, messaging, and ammunition behavior were intentionally preserved. Main/subjob, relative-level, exact accuracy, duration, and tests remain open.

### Call for Help candidate correction

Commit `de408e05de4c8c44250f9db493492817bbe8db65` replaced single-target `GetBattleTarget()` handling with current-instance mob iteration.

Every mob is changed only when:

- it is not already help-enabled;
- the requesting player's ID exists in its enmity container;
- the mob has not blocked Call for Help.

The success message is emitted once when at least one mob changes. Claim-transition, party/pet, reward, client-update, and battlefield edge cases still require automated tests and validation.

### Temporary automation cleanup

All temporary implementation and diagnostic workflow files were removed from the Codex branch after use or suppression. No permanent fork automation was left behind.

## 2026-07-21 — Isolated-container validation failure

The first autonomous attempt used the assistant's execution container rather than the owner's local Codex desktop environment.

- The Codex CLI had authentication state but the container could not reach GitHub Git/raw endpoints or the OpenAI responses endpoint.
- A local clone could not be created in that container.
- A GitHub Actions GCC Debug build reached configuration but failed during compilation, and its log tail was not retained.
- Connector-authored diagnostic workflows were later suppressed with “No jobs were run.”

`CODEX_STATE.md` was temporarily set to `FAILED_INFRASTRUCTURE`. That state described the isolated container only and has since been superseded.

## 2026-07-21 — Local Codex desktop environment validated

### Repository and Git safety

- Cloned `djjohnson13p/server` to `C:\GitHub\server`.
- Checked out `retail-parity/codex-vanilla-zilart`.
- Confirmed a clean worktree and successful `git fetch origin`.
- Confirmed all required project/instruction files are readable from Codex.
- Disabled recursive submodule behavior for normal Git fetches.
- Preserved upstream fetch access while disabling upstream push locally.
- Confirmed both top-level submodules were available at their recorded commits.

### Codex desktop execution

- Added the repository root as the Codex project.
- Confirmed Codex shell execution, repository access, branch access, instruction loading, and GitHub connectivity.
- Codex reported no tracked changes after read-only validation.

### Windows compiler/toolchain

- Found Visual Studio Build Tools 2022 `17.14.35`.
- Confirmed the x64/x86 C++ tool component.
- Initialized the x64 MSVC environment through `VsDevCmd.bat`.
- Confirmed MSVC `cl 19.44.35228`, linker `14.44.35228.0`, Windows SDK `10.0.26100.0`, CMake `4.3.3`, Ninja `1.13.2`, Python `3.14.6`, and Git `2.54.0.windows.1`.
- Missing Clang was correctly treated as irrelevant to the supported Windows MSVC path.
- MinGW GCC was not used as a substitute.

### Full build result

Using a disposable `build-codex-smoke` directory:

- Fresh MSVC/Ninja Debug CMake configuration passed with exit code `0`.
- Full build passed with all `1049/1049` Ninja steps.
- `xi_connect`, `xi_map`, `xi_search`, `xi_world`, and `xi_test` linked successfully.
- Build exit code was `0`.
- The build directory, generated executables, and PDBs were removed.
- Final Git status was clean on the required branch.

The exact commands and tool versions are recorded in `LOCAL_CODEX_ENVIRONMENT.md`.

### State transition

- `FAILED_INFRASTRUCTURE` is superseded.
- The current project state is `IMPLEMENTATION_READY`.
- The next pass is focused automated regression coverage for the six inherited corrections, followed by the remaining implementation backlog.
- No owner gameplay testing is requested.

## Current resume point

1. Fetch the latest `origin/retail-parity/codex-vanilla-zilart` documentation commits.
2. Read `AGENTS.md`, `CODEX_MASTER_TASK.md`, `CODEX_BACKLOG.md`, `LOCAL_CODEX_ENVIRONMENT.md`, `CODEX_STATE.md`, `STATUS.md`, this worklog, the completion report, and all findings.
3. Add focused automated tests for the Temple door, fishing moon pattern, Waders, Moghancement: Region, Shadowbind, and Call for Help.
4. Run narrow tests and `xi_test` where relevant.
5. Run the validated full MSVC/Ninja Debug build.
6. Fix failures caused by fork changes without weakening unrelated assertions.
7. Update all project records, commit logically, and push only to the fork branch when explicitly permitted.
8. Continue attack-while-fishing, Ark Angel messages, item additional effects, Elemental Spirits, Ballista, and the exhaustive audit after inherited corrections are test-backed.

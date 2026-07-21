# Vanilla + Rise of the Zilart Audit Status

## Baseline and branches

- **Upstream repository:** `LandSandBoat/server`
- **Fork:** `djjohnson13p/server`
- **Pinned upstream baseline:** `242ab0d055dfb80396e7398b0dd7361b750c74e2`
- **Assistant audit branch:** `retail-parity/vanilla-zilart-audit`
- **Codex work branch:** `retail-parity/codex-vanilla-zilart`
- **Audit start date:** 2026-07-21
- **Assistant source-accessible stage:** Complete
- **Codex handoff:** Ready
- **Local Codex environment:** Validated
- **Current project state:** `IMPLEMENTATION_READY`
- **Upstream pull requests:** None; prohibited

## Baseline finding counts

| Status | Count |
|---|---:|
| Retail equivalent | 0 |
| Inaccurate | 10 |
| Partial | 0 |
| Missing | 1 |
| Verify live | 0 |
| Unknown | 0 |

These are baseline discrepancy counts, not resolution counts. The absence of additional findings is not proof that unreviewed systems are retail-equivalent.

## Implementation progress

| Implementation state | Count |
|---|---:|
| Corrected or candidate-corrected on fork | 5 |
| Partially corrected on fork | 1 |
| Not yet implemented | 5 |

## Findings and implementation state

| ID | Area | Baseline status | Current fork state |
|---|---|---|---|
| `VZ-SYS-001` | Ballista | `MISSING` | Not implemented; largest remaining system |
| `VZ-COMBAT-001` | Item additional effects | `INACCURATE` | Not implemented; inventory/framework work remains |
| `VZ-ZONE-001` | Temple of Uggalepih door keys | `INACCURATE` | Corrected in audit/Codex lineage (`ed3bb6e`) |
| `VZ-JOB-001` | Summoner Elemental Spirits | `INACCURATE` | Not implemented; data/formula work remains |
| `VZ-CORE-001` | Call for Help scope | `INACCURATE` | Candidate correction at `de408e0`; focused tests pending |
| `VZ-CORE-002` | Attack while fishing | `INACCURATE` | Not implemented; safe state cleanup required |
| `VZ-JOB-002` | Ranger Shadowbind | `INACCURATE` | Partial correction at `b0058b4`; coefficients/tests remain |
| `VZ-ECON-001` | Fishing new-moon pattern | `INACCURATE` | Corrected at `556ad21`; focused test pending |
| `VZ-ECON-002` | Waders fishing bonus | `INACCURATE` | Corrected at `556ad21`; focused test pending |
| `VZ-BF-001` | Ark Angel zero-delay ready messages | `INACCURATE` | Not implemented; state/message refactor required |
| `VZ-ECON-003` | Moghancement: Region bonus | `INACCURATE` | Corrected at `556ad21`; focused IPC/unit test pending |

## Local environment validation

Completed on the local Codex desktop project:

- Correct repository, branch, clean worktree, and fork remote confirmed.
- `origin` fetch connectivity passed.
- Push to upstream was disabled locally while upstream fetch remained available.
- Recursive submodule fetches were disabled for normal Git operations.
- Both recorded top-level submodules were available at their pinned commits.
- Visual Studio Build Tools 2022 and the x64 MSVC toolchain were found and initialized.
- Fresh CMake/Ninja Debug configuration passed.
- Full Windows MSVC/Ninja Debug build passed: `1049/1049` steps.
- All disposable build outputs were removed and the worktree returned to clean status.

The validated commands and tool versions are preserved in `LOCAL_CODEX_ENVIRONMENT.md`.

## Validation state

Completed:

- Exact source inspection and evidence records for all eleven findings.
- Commit-diff review for the Temple door, Shadowbind, and Call for Help changes.
- Exact-match source assertions and `git diff --check` for the three deterministic C++ corrections.
- Restoration of the pre-existing `conquest_system.cpp` UTF-8 BOM at `0702a5b`.
- Successful full local MSVC/Ninja Debug build of the current branch.
- Removal of all temporary implementation/build workflows and local build outputs.

Still required:

- Focused automated tests for the six implemented or partial corrections.
- Lua, SQL, startup, integration, and gameplay-oriented checks appropriate to each future pass.
- Completion of the remaining five known findings.
- Continued exhaustive local-repository Vanilla/Zilart audit.
- Final client/live-retail validation.

## Work stages

- [x] Create clean fork and isolated branches
- [x] Establish scope, evidence rules, finding format, and AI-first workflow
- [x] Complete the source-accessible assistant audit
- [x] Prepare the consolidated Codex handoff
- [x] Configure Codex desktop against the local clone
- [x] Validate shell, GitHub fetch, repository instructions, MSVC, CMake, and Ninja
- [x] Complete a full clean local MSVC/Ninja Debug build
- [x] Apply six safe fork-only corrections or partial corrections
- [ ] Add focused automated tests for inherited corrections
- [ ] Complete the remaining five known findings
- [ ] Continue the exhaustive local-repository Vanilla/Zilart audit
- [ ] Produce a final actionable human-only validation queue

## Next action

Use the latest head of `retail-parity/codex-vanilla-zilart`. Fetch `origin`, read `CODEX_STATE.md`, `CODEX_BACKLOG.md`, `LOCAL_CODEX_ENVIRONMENT.md`, the worklog, completion report, and all finding files. Begin with focused automated tests for the six inherited corrections, then rerun the full MSVC/Ninja Debug build.

## Guardrails

- Never modify `base` directly.
- Never open, prepare, or suggest an upstream pull request.
- Do not ask the owner for intermediate gameplay testing.
- Do not label a system retail-equivalent merely because it compiles or lacks an open issue.
- Preserve unresolved retail coefficients rather than inventing them.

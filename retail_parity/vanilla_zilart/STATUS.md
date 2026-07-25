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
- **Current project state:** `VZ_CORE_002_VALIDATED`
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
| Corrected or candidate-corrected on fork | 6 |
| Partially corrected on fork | 1 |
| Not yet implemented | 4 |

Six findings are now implemented and test-backed. Shadowbind remains a
test-backed partial correction because unsupported accuracy/level
coefficients were deliberately not invented.

## Findings and implementation state

| ID | Area | Baseline status | Current fork state |
|---|---|---|---|
| `VZ-SYS-001` | Ballista | `MISSING` | Not implemented; largest remaining system |
| `VZ-COMBAT-001` | Item additional effects | `INACCURATE` | Not implemented; inventory/framework work remains |
| `VZ-ZONE-001` | Temple of Uggalepih door keys | `INACCURATE` | Implemented and interaction-test-backed |
| `VZ-JOB-001` | Summoner Elemental Spirits | `INACCURATE` | Not implemented; data/formula work remains |
| `VZ-CORE-001` | Call for Help scope | `INACCURATE` | Hardened claim/CE/VE/boundary rules; Lua and C++ tests pass |
| `VZ-CORE-002` | Attack while fishing | `INACCURATE` | Safe validated-target transition, lifecycle guards, and eight Lua cases pass |
| `VZ-JOB-002` | Ranger Shadowbind | `INACCURATE` | Partial correction is guard/ammo/availability-test-backed; accuracy coefficients remain |
| `VZ-ECON-001` | Fishing new-moon pattern | `INACCURATE` | Implemented and unit-test-backed across every moon phase |
| `VZ-ECON-002` | Waders fishing bonus | `INACCURATE` | Implemented and unit-test-backed |
| `VZ-BF-001` | Ark Angel zero-delay ready messages | `INACCURATE` | Not implemented; state/message refactor required |
| `VZ-ECON-003` | Moghancement: Region bonus | `INACCURATE` | Implemented and unit-test-backed with explicit truncation |

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
- Behavioral Lua interaction tests for the Temple doors, Shadowbind, and Call
  for Help: 23/23 passed.
- Catch2 coverage for fishing moon dispatch, Waders reachability, conquest
  arithmetic, and Call-for-Help instance identity: 16/16 test cases and
  9,007,070 assertions passed.
- Call for Help now rejects unclaimed/stale enmity and enforces current claim,
  positive requester CE/VE, confrontation, battlefield, instance, and battle
  boundaries.
- Attack now performs ordinary engagement validation before idempotently
  interrupting fishing. Eight Lua cases cover waiting and hooked phases,
  stale/crafted packets, invalid targets, resources, monster cleanup, and
  recovery.
- Lua style checks and `git diff --check` passed.
- Fresh-directory MSVC/Ninja Debug configuration and all-target build passed.
- Disposable build outputs and isolated test database were removed without
  modifying the working local `xidb`.

Still required:

- Completion of the remaining four known findings.
- Continued exhaustive local-repository Vanilla/Zilart audit.
- Final client/live-retail validation for behavior without an automated seam.

## Work stages

- [x] Create clean fork and isolated branches
- [x] Establish scope, evidence rules, finding format, and AI-first workflow
- [x] Complete the source-accessible assistant audit
- [x] Prepare the consolidated Codex handoff
- [x] Configure Codex desktop against the local clone
- [x] Validate shell, GitHub fetch, repository instructions, MSVC, CMake, and Ninja
- [x] Complete a full clean local MSVC/Ninja Debug build
- [x] Apply seven safe fork-only corrections or partial corrections
- [x] Add focused automated tests for inherited corrections
- [x] Complete `VZ-CORE-002` safe attack-while-fishing transition
- [ ] Complete the remaining four known findings
- [ ] Continue the exhaustive local-repository Vanilla/Zilart audit
- [ ] Produce a final actionable human-only validation queue

## Next action

Use the latest head of `retail-parity/codex-vanilla-zilart`. Fetch `origin`,
read `CODEX_STATE.md`, `CODEX_BACKLOG.md`, `LOCAL_CODEX_ENVIRONMENT.md`, the
worklog, completion report, and all finding files. Begin the next bounded
implementation pass with `VZ-BF-001` (Ark Angel zero-delay ready messages),
then continue the remaining known findings and exhaustive audit.

## Guardrails

- Never modify `base` directly.
- Never open, prepare, or suggest an upstream pull request.
- Do not ask the owner for intermediate gameplay testing.
- Do not label a system retail-equivalent merely because it compiles or lacks an open issue.
- Preserve unresolved retail coefficients rather than inventing them.

# Vanilla + Rise of the Zilart Audit Status

## Baseline and branches

- **Upstream repository:** `LandSandBoat/server`
- **Fork:** `djjohnson13p/server`
- **Pinned upstream baseline:** `242ab0d055dfb80396e7398b0dd7361b750c74e2`
- **Assistant audit branch:** `retail-parity/vanilla-zilart-audit`
- **Codex work branch:** `retail-parity/codex-vanilla-zilart`
- **Audit start date:** 2026-07-21
- **Assistant source-accessible stage:** Complete
- **Codex handoff:** Ready and attempted
- **Current terminal state:** `FAILED_INFRASTRUCTURE`
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
| `VZ-CORE-001` | Call for Help scope | `INACCURATE` | Candidate correction at `de408e0`; tests/build pending |
| `VZ-CORE-002` | Attack while fishing | `INACCURATE` | Not implemented; safe state cleanup required |
| `VZ-JOB-002` | Ranger Shadowbind | `INACCURATE` | Partial correction at `b0058b4`; coefficients/tests remain |
| `VZ-ECON-001` | Fishing new-moon pattern | `INACCURATE` | Corrected at `556ad21`; unit/build validation pending |
| `VZ-ECON-002` | Waders fishing bonus | `INACCURATE` | Corrected at `556ad21`; unit/build validation pending |
| `VZ-BF-001` | Ark Angel zero-delay ready messages | `INACCURATE` | Not implemented; state/message refactor required |
| `VZ-ECON-003` | Moghancement: Region bonus | `INACCURATE` | Corrected at `556ad21`; IPC/build validation pending |

## Validation state

Completed:

- Exact source inspection and evidence records for all eleven findings.
- Commit-diff review for the Temple door, Shadowbind, and Call for Help changes.
- Exact-match source assertions and `git diff --check` for the three deterministic C++ corrections.
- Restoration of the pre-existing `conquest_system.cpp` UTF-8 BOM at `0702a5b`.
- Removal of all temporary implementation/build workflows.

Not completed because of infrastructure failure:

- A successful native build of the current branch.
- Compiler diagnostics for the failed GCC Debug build.
- C++/Lua/SQL/unit/integration/startup checks for the current branch.
- Local Codex filesystem audit and the remainder of the implementation backlog.
- Client/live-retail validation.

## Work stages

- [x] Create clean fork and isolated branches
- [x] Establish scope, evidence rules, finding format, and AI-first workflow
- [x] Complete the source-accessible assistant audit
- [x] Prepare and open the consolidated Codex handoff
- [x] Attempt the autonomous Codex stage
- [x] Apply six safe fork-only corrections or partial corrections
- [x] Record the exact infrastructure failure and resume instructions
- [ ] Restore a networked local Codex/build environment
- [ ] Diagnose and fix the current native build
- [ ] Add automated tests for implemented findings
- [ ] Complete the remaining five known findings
- [ ] Continue the exhaustive local-repository Vanilla/Zilart audit
- [ ] Produce a final actionable human-only validation queue

## Resume point

Use the latest head of `retail-parity/codex-vanilla-zilart`. Read `CODEX_STATE.md`, `CODEX_BACKLOG.md`, `CODEX_COMPLETION_REPORT.md`, the worklog, and all findings before continuing. Start with a clean GCC Debug build and capture the first compiler error.

## Guardrails

- Never modify `base` directly.
- Never open, prepare, or suggest an upstream pull request.
- Do not ask the owner for intermediate gameplay testing.
- Do not label a system retail-equivalent merely because it compiles or lacks an open issue.
- Preserve unresolved retail coefficients rather than inventing them.

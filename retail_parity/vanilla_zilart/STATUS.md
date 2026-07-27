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
- **Current project state:** `VZ_COMBAT_001_PHASE_B1_VALIDATED`
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
| Corrected or candidate-corrected on fork | 7 |
| Partially corrected on fork | 2 |
| Not yet implemented | 2 |

Seven findings are implemented and test-backed. Shadowbind and the item
additional-effect finding remain partial because unsupported retail
coefficients and formulas were deliberately not invented.

## Findings and implementation state

| ID | Area | Baseline status | Current fork state |
|---|---|---|---|
| `VZ-SYS-001` | Ballista | `MISSING` | Not implemented; largest remaining system |
| `VZ-COMBAT-001` | Item additional effects | `INACCURATE` | Phase B1 complete: Phase A framework plus explicit tested Fire/Ice/Lightning Arrow compatibility profiles; their unsupported retail numerics remain `VERIFY_LIVE` |
| `VZ-ZONE-001` | Temple of Uggalepih door keys | `INACCURATE` | Implemented and interaction-test-backed |
| `VZ-JOB-001` | Summoner Elemental Spirits | `INACCURATE` | Not implemented; data/formula work remains |
| `VZ-CORE-001` | Call for Help scope | `INACCURATE` | Hardened claim/CE/VE/boundary rules; Lua and C++ tests pass |
| `VZ-CORE-002` | Attack while fishing | `INACCURATE` | Safe validated-target transition, lifecycle guards, and eight Lua cases pass |
| `VZ-JOB-002` | Ranger Shadowbind | `INACCURATE` | Partial correction is guard/ammo/availability-test-backed; accuracy coefficients remain |
| `VZ-ECON-001` | Fishing new-moon pattern | `INACCURATE` | Implemented and unit-test-backed across every moon phase |
| `VZ-ECON-002` | Waders fishing bonus | `INACCURATE` | Implemented and unit-test-backed |
| `VZ-BF-001` | Ark Angel zero-delay ready messages | `INACCURATE` | Engine-owned explicit start policy, 11 focused Lua cases, and issue-#3611 reproduction pass |
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
- Mob-skill checks are packet-pure. An explicit skill/pool start-message
  policy now emits at most one proper `SkillStart` after state entry, including
  zero-time Ark Angel skills. Eleven focused Lua cases, 19 Catch2 cases
  (9,007,079 assertions), and all 65 `0x028` packet cases pass.
- Item additional-effect Phase A inventories 420 active/issue-scoped items,
  including 18 maintained Vanilla/Zilart profiles. Tests reproduce and
  correct double HP mutation, duplicate absorption/nullification, the breath
  flag mismatch, and false status success presentation. Real melee/ranged
  packets, Acid/Sleep ammunition, level eligibility, status guards, physical
  flags, and all five maintained NM interactions are covered.
- Fire/Ice/Lightning Arrow Phase B1 moves exactly three scripted items to a
  validated profile registry. Forty-seven focused Lua cases cover real ranged
  hits, misses, range/despawn/level gates, ammo consumption/preservation,
  element and packet presentation, 7-10 boundaries, stat/resistance/
  multiplier compatibility, null/absorb, defenses, and actual HP-capped
  amounts. Numeric retail claims remain `VERIFY_LIVE`.
- Lua style checks and `git diff --check` passed.
- Fresh-directory MSVC/Ninja Debug configuration and all-target build passed.
- Disposable build outputs and isolated test database were removed without
  modifying the working local `xidb`.

Still required:

- Phase B evidence/formula work for `VZ-COMBAT-001`.
- Completion of the remaining two unimplemented known findings.
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
- [x] Apply eight safe fork-only corrections or partial corrections
- [x] Add focused automated tests for inherited corrections
- [x] Complete `VZ-CORE-002` safe attack-while-fishing transition
- [x] Complete `VZ-BF-001` engine-owned ready-message behavior
- [x] Complete `VZ-COMBAT-001` Phase A inventory/framework pass
- [x] Complete `VZ-COMBAT-001` Phase B1 elemental-arrow profile pass
- [ ] Complete `VZ-COMBAT-001` Phase B evidence/formula passes
- [ ] Complete the remaining two unimplemented known findings
- [ ] Continue the exhaustive local-repository Vanilla/Zilart audit
- [ ] Produce a final actionable human-only validation queue

## Next action

Use the latest head of `retail-parity/codex-vanilla-zilart`. Fetch `origin`,
read `CODEX_STATE.md`, `CODEX_BACKLOG.md`, `LOCAL_CODEX_ENVIRONMENT.md`, the
worklog, completion report, generated VZ-COMBAT-001 inventory, elemental-arrow
ledger, and finding files. Begin Phase B2 around one bounded evidence-backed
family or configuration-error group; do not extend the three-arrow profile to
later elemental arrows without separate evidence. Then continue the remaining
known findings and exhaustive audit.

## Guardrails

- Never modify `base` directly.
- Never open, prepare, or suggest an upstream pull request.
- Do not ask the owner for intermediate gameplay testing.
- Do not label a system retail-equivalent merely because it compiles or lacks an open issue.
- Preserve unresolved retail coefficients rather than inventing them.

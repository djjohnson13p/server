# Vanilla + Rise of the Zilart Audit Status

## Baseline

- **Upstream repository:** `LandSandBoat/server`
- **Fork:** `djjohnson13p/server`
- **Audited baseline branch:** `base`
- **Pinned upstream commit:** `242ab0d055dfb80396e7398b0dd7361b750c74e2`
- **Assistant audit branch:** `retail-parity/vanilla-zilart-audit`
- **Codex branch:** `retail-parity/codex-vanilla-zilart`
- **Audit start date:** 2026-07-21
- **Assistant source-accessible stage:** Complete
- **Codex handoff:** Prepared; `AI_HANDOFF.md` is the execution gate

## Current counts

| Status | Count |
|---|---:|
| Retail equivalent | 0 |
| Inaccurate | 10 |
| Partial | 0 |
| Missing | 1 |
| Verify live | 0 |
| Unknown | 0 |

Counts include only findings that passed the assistant evidence threshold. They do not represent completion of the expansion audit; Codex must continue the full local-repository audit.

## Recorded findings

| ID | Area | Status | Severity | Confidence | Disposition / implementation |
|---|---|---|---|---|---|
| `VZ-SYS-001` | Ballista | `MISSING` | `MAJOR` | `HIGH` | Codex-scale plus final retail validation |
| `VZ-COMBAT-001` | Item additional effects | `INACCURATE` | `MAJOR` | `HIGH` for framework defects | Codex-scale plus measured retail data |
| `VZ-ZONE-001` | Temple of Uggalepih door keys | `INACCURATE` at baseline | `MODERATE` | `HIGH` | Corrected in consolidated audit branch (`ed3bb6e`) |
| `VZ-JOB-001` | Summoner Elemental Spirits | `INACCURATE` | `MAJOR` | `HIGH` for admitted defects | Codex-scale; final measured values deferred |
| `VZ-CORE-001` | Call for Help scope | `INACCURATE` | `MODERATE` | `HIGH` for implementation difference | Codex-scale C++ and tests |
| `VZ-CORE-002` | Attack while fishing | `INACCURATE` | `MINOR` | `HIGH` for intentional difference | Codex-scale state transition and tests |
| `VZ-JOB-002` | Ranger Shadowbind resistance | `INACCURATE` | `MODERATE` | `HIGH` for implementation defect | Codex implementation; retail coefficients deferred |
| `VZ-ECON-001` | Fishing new-moon catch pattern | `INACCURATE` | `MODERATE` | `HIGH` | One-line C++ correction and deterministic test |
| `VZ-ECON-002` | Waders fishing bonus | `INACCURATE` | `MINOR` | `HIGH` | Bounded C++ correction and deterministic test |
| `VZ-BF-001` | Ark Angel zero-delay ready messages | `INACCURATE` | `MODERATE` | `HIGH` | Mob-skill state/message refactor and tests |
| `VZ-ECON-003` | Moghancement: Region influence bonus | `INACCURATE` | `MODERATE` | `HIGH` | Bounded conquest arithmetic correction and IPC tests |

## Assistant implementation

- `VZ-ZONE-001`: `_mf9` now requires and consumes an Uggalepih Key; `_mf8` remains the Prelate-Key door.
- Consolidated audit-branch commit: `ed3bb6e3e59dbe482ebc58d44587576e0b035ab9`
- Separate implementation-branch commit: `620d69d7c0315f70066c3484e110bb5d9baade3d`
- Final client route validation is deferred to the consolidated end-stage queue.

## Assistant completion artifacts

- `ASSISTANT_COMPLETION_REPORT.md`
- `CODEX_BACKLOG.md`
- `CODEX_MASTER_TASK.md`
- `AI_HANDOFF.md`
- `CODEX_STATE.md`
- `CODEX_COMPLETION_REPORT.md`
- `HUMAN_ONLY_QUEUE.md`
- `tools/retail_parity/run_codex_remainder.py`

## Work stages

- [x] Create clean fork
- [x] Create isolated assistant audit branch
- [x] Establish scope, evidence rules, statuses, and ownership categories
- [x] Record exact upstream baseline commit
- [x] Configure AI-first workflow, Codex master task, persistent state, reports, and autonomous runner
- [x] Complete the source-accessible assistant inventory of tests/TODOs/stubs/issues across representative scoped systems
- [x] Audit source-accessible shared-core, job, mission, battlefield, economy, crafting, gathering, conquest, and transport paths
- [x] Implement all safely bounded assistant-capable corrections available through the connected GitHub workflow
- [x] Produce prioritized Codex remediation and audit-continuation backlog
- [ ] Mark consolidated Codex handoff `READY`
- [ ] Run autonomous Codex stage
- [ ] Present one final human-only validation queue

## Codex continuation requirements

1. Verify all inherited findings and the assistant door correction.
2. Implement the prioritized backlog from deterministic fixes through Ballista.
3. Perform a full local filesystem/search/build/test audit for all Vanilla + Zilart systems.
4. Add findings not discoverable through the assistant's connected GitHub-only environment.
5. Maintain `STATUS.md`, `WORKLOG.md`, `CODEX_STATE.md`, completion report, and human-only queue.
6. Never open or suggest an upstream pull request.
7. Do not ask the owner for intermediate testing or routine decisions.

## Guardrails

- No upstream pull requests.
- No parity claim without explicit evidence and a reproducible validation path.
- No intermediate owner testing requests.
- Codex must distinguish confirmed defects, unresolved retail coefficients, and unavailable live-client evidence.

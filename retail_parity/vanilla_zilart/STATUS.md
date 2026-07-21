# Vanilla + Rise of the Zilart Audit Status

## Baseline

- **Upstream repository:** `LandSandBoat/server`
- **Fork:** `djjohnson13p/server`
- **Audited baseline branch:** `base`
- **Pinned upstream commit:** `242ab0d055dfb80396e7398b0dd7361b750c74e2`
- **Assistant audit branch:** `retail-parity/vanilla-zilart-audit`
- **Future Codex branch:** `retail-parity/codex-vanilla-zilart`
- **Audit start date:** 2026-07-21
- **Substantive code audit:** In progress
- **Codex handoff:** Not ready; assistant stage remains active

## Current counts

| Status | Count |
|---|---:|
| Retail equivalent | 0 |
| Inaccurate | 10 |
| Partial | 0 |
| Missing | 1 |
| Verify live | 0 |
| Unknown | 0 |

Counts include only findings that passed the current evidence threshold. They do not represent completion of the expansion audit.

## Recorded findings

| ID | Area | Status | Severity | Confidence | Disposition / implementation |
|---|---|---|---|---|---|
| `VZ-SYS-001` | Ballista | `MISSING` | `MAJOR` | `HIGH` | Codex-scale plus final retail validation |
| `VZ-COMBAT-001` | Item additional effects | `INACCURATE` | `MAJOR` | `HIGH` for framework defects | Codex-scale plus measured retail data |
| `VZ-ZONE-001` | Temple of Uggalepih door keys | `INACCURATE` at baseline | `MODERATE` | `HIGH` | Corrected on `retail-parity/fix-vz-zone-001` (`620d69d`) |
| `VZ-JOB-001` | Summoner Elemental Spirits | `INACCURATE` | `MAJOR` | `HIGH` for admitted defects | Codex-scale; final measured values deferred |
| `VZ-CORE-001` | Call for Help scope | `INACCURATE` | `MODERATE` | `HIGH` for implementation difference | Codex-scale C++ and tests |
| `VZ-CORE-002` | Attack while fishing | `INACCURATE` | `MINOR` | `HIGH` for intentional difference | Codex-scale state transition and tests |
| `VZ-JOB-002` | Ranger Shadowbind resistance | `INACCURATE` | `MODERATE` | `HIGH` for implementation defect | Codex implementation; retail coefficients deferred |
| `VZ-ECON-001` | Fishing new-moon catch pattern | `INACCURATE` | `MODERATE` | `HIGH` | One-line C++ correction and deterministic test |
| `VZ-ECON-002` | Waders fishing bonus | `INACCURATE` | `MINOR` | `HIGH` | Bounded C++ correction and deterministic test |
| `VZ-BF-001` | Ark Angel zero-delay ready messages | `INACCURATE` | `MODERATE` | `HIGH` | Mob-skill state/message refactor and tests |
| `VZ-ECON-003` | Moghancement: Region influence bonus | `INACCURATE` | `MODERATE` | `HIGH` | Bounded conquest arithmetic correction and IPC tests |

## Assistant implementations

- `VZ-ZONE-001`: `_mf9` now requires and consumes an Uggalepih Key; `_mf8` remains the Prelate-Key door.
- Implementation branch: `retail-parity/fix-vz-zone-001`
- Implementation commit: `620d69d7c0315f70066c3484e110bb5d9baade3d`
- Final client route validation is deferred to the consolidated end-stage queue.

## Work stages

- [x] Create clean fork
- [x] Create isolated assistant audit branch
- [x] Establish scope, evidence rules, statuses, and ownership categories
- [x] Record exact upstream baseline commit
- [x] Configure AI-first workflow, Codex master task, persistent state, reports, and autonomous runner
- [ ] Complete existing tests/TODOs/stubs/known-failure inventory — in progress
- [ ] Audit shared core systems — additional effects, Call for Help, fishing/combat transition, death/raise, and mob-skill messaging reviewed
- [ ] Audit original jobs — Ranger started
- [ ] Audit Zilart jobs — Summoner started
- [ ] Audit national missions and quests — stale nation-change issue reviewed and rejected
- [ ] Audit Zilart missions, zones, battlefields, and NMs — Temple door corrected; Ark Angel messaging recorded; mission tests reviewed
- [ ] Audit economy, crafting, gathering, conquest, and transport — fishing, crafting, guilds, and conquest started
- [ ] Implement all assistant-capable corrections — one completed
- [ ] Produce prioritized remediation backlog
- [ ] Mark consolidated Codex handoff `READY`
- [ ] Run autonomous Codex stage
- [ ] Present one final human-only validation queue

## Investigation order

1. Complete outpost travel, transport, gathering, and remaining conquest review.
2. Continue shared combat review: enmity, claims, resistance, damage, ranged attacks, skillchains, and status effects.
3. Continue original and Zilart jobs, including pets and era equipment interactions.
4. Audit mission/quest state machines, battlefields, and high-impact NMs.
5. Complete crafting, guild progression, gathering, and remaining economy systems.
6. Audit packet/client-visible differences and isolate items requiring final live validation.

## Guardrails

- No upstream pull requests.
- No parity claim without explicit evidence and a reproducible validation path.
- No intermediate owner testing requests.
- No implementation work mixed into the assistant audit branch unless it is audit tooling or documentation.
- Bounded fixes use separate fork-owned implementation branches and are consolidated before the Codex handoff.

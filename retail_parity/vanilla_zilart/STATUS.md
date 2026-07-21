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
| Inaccurate | 2 |
| Partial | 0 |
| Missing | 1 |
| Verify live | 0 |
| Unknown | 0 |

Counts include only findings that passed the current evidence threshold. They do not represent completion of the expansion audit.

## Recorded findings

| ID | Area | Status | Severity | Confidence | Disposition |
|---|---|---|---|---|---|
| `VZ-SYS-001` | Ballista | `MISSING` | `MAJOR` | `HIGH` | `AI_PLUS_HUMAN_TESTING` |
| `VZ-COMBAT-001` | Item additional effects | `INACCURATE` | `MAJOR` | `HIGH` for framework defects | `AI_PLUS_HUMAN_TESTING` |
| `VZ-ZONE-001` | Temple of Uggalepih door keys | `INACCURATE` | `MODERATE` | `MEDIUM` | `ASSISTANT_DIRECT` |

## Work stages

- [x] Create clean fork
- [x] Create isolated assistant audit branch
- [x] Establish scope, evidence rules, statuses, and ownership categories
- [x] Record exact upstream baseline commit
- [x] Configure AI-first workflow, Codex master task, persistent state, reports, and autonomous runner
- [ ] Complete existing tests/TODOs/stubs/known-failure inventory — in progress
- [ ] Audit shared core systems — started with item additional effects
- [ ] Audit original jobs
- [ ] Audit Zilart jobs
- [ ] Audit national missions and quests
- [ ] Audit Zilart missions, zones, battlefields, and NMs — started with Temple door mechanics
- [ ] Audit economy, crafting, gathering, conquest, and transport
- [ ] Implement all assistant-capable corrections
- [ ] Produce prioritized remediation backlog
- [ ] Mark consolidated Codex handoff `READY`
- [ ] Run autonomous Codex stage
- [ ] Present one final human-only validation queue

## First-pass investigation order

1. Complete repository-wide incompleteness inventory and classify leads by expansion relevance.
2. Continue shared combat review: enmity, resistance, additional effects, damage, ranged attacks, and skillchains.
3. Audit original and Zilart jobs, including pets and era equipment interactions.
4. Audit mission/quest state machines and battlefields.
5. Audit zone mechanics, NMs, drops, economy, crafting, gathering, conquest, and transport.
6. Audit packet/client-visible differences and isolate items requiring final live validation.

## Guardrails

- No upstream pull requests.
- No parity claim without explicit evidence and a reproducible validation path.
- No intermediate owner testing requests.
- No implementation work mixed into the assistant audit branch unless it is audit tooling, documentation, or a bounded assistant-capable correction with review records.
- Larger fixes use fork-owned implementation branches and are consolidated before the Codex handoff.

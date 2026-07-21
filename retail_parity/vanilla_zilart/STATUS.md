# Vanilla + Rise of the Zilart Audit Status

## Baseline

- **Upstream repository:** `LandSandBoat/server`
- **Fork:** `djjohnson13p/server`
- **Audited baseline branch:** `base`
- **Pinned upstream commit:** `242ab0d055dfb80396e7398b0dd7361b750c74e2`
- **Audit branch:** `retail-parity/vanilla-zilart-audit`
- **Audit start date:** 2026-07-21
- **Substantive code audit:** In progress

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
- [x] Create isolated audit branch
- [x] Establish scope, evidence rules, statuses, and ownership categories
- [x] Record exact upstream baseline commit
- [ ] Inventory existing tests, TODOs, disabled scripts, stubs, and known-failure markers — in progress
- [ ] Audit shared core systems — started with item additional effects
- [ ] Audit original jobs
- [ ] Audit Zilart jobs
- [ ] Audit national missions and quests
- [ ] Audit Zilart missions, zones, battlefields, and NMs — started with Temple door mechanics
- [ ] Audit economy, crafting, gathering, conquest, and transport
- [ ] Produce prioritized remediation backlog
- [ ] Begin fork-only implementation branches

## First-pass investigation order

1. Complete repository-wide incompleteness inventory and classify leads by expansion relevance.
2. Continue shared combat review: enmity, resistance, additional effects, damage, ranged attacks, and skillchains.
3. Audit original and Zilart jobs, including pets and era equipment interactions.
4. Audit mission/quest state machines and battlefields.
5. Audit zone mechanics, NMs, drops, economy, crafting, gathering, conquest, and transport.
6. Audit packet/client-visible differences and isolate items requiring live retail validation.

## Guardrails

- No upstream pull requests.
- No parity claim without explicit evidence and a reproducible validation path.
- No implementation work mixed into this audit branch unless it is audit tooling or documentation.
- Fixes will use separate fork-owned branches organized by finding ID or tightly related group.

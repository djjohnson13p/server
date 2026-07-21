# Vanilla + Rise of the Zilart Audit Status

## Baseline

- **Upstream repository:** `LandSandBoat/server`
- **Fork:** `djjohnson13p/server`
- **Audited baseline branch:** `base`
- **Audit branch:** `retail-parity/vanilla-zilart-audit`
- **Audit start date:** 2026-07-21
- **Substantive code audit:** Not started

## Current counts

| Status | Count |
|---|---:|
| Retail equivalent | 0 |
| Inaccurate | 0 |
| Partial | 0 |
| Missing | 0 |
| Verify live | 0 |
| Unknown | 0 |

These zeroes mean that no conclusion has yet passed the evidence standard; they do not imply that all systems work.

## Work stages

- [x] Create clean fork
- [x] Create isolated audit branch
- [x] Establish scope, evidence rules, statuses, and ownership categories
- [ ] Record exact upstream baseline commit
- [ ] Inventory existing tests, TODOs, disabled scripts, stubs, and known-failure markers
- [ ] Audit shared core systems
- [ ] Audit original jobs
- [ ] Audit Zilart jobs
- [ ] Audit national missions and quests
- [ ] Audit Zilart missions, zones, battlefields, and NMs
- [ ] Audit economy, crafting, gathering, conquest, and transport
- [ ] Produce prioritized remediation backlog
- [ ] Begin fork-only implementation branches

## First-pass investigation order

1. Repository-wide incompleteness indicators and test coverage.
2. Core combat and enmity behavior because many content findings depend on them.
3. Job systems and pets.
4. Mission/quest state machines and battlefields.
5. Zone mechanics, NMs, drops, economy, crafting, gathering, conquest, and transport.
6. Packet/client-visible differences and items requiring live validation.

## Guardrails

- No upstream pull requests.
- No parity claim without explicit evidence and a reproducible validation path.
- No implementation work mixed into this audit branch unless it is audit tooling or documentation.
- Fixes will use separate fork-owned branches organized by finding ID or tightly related group.

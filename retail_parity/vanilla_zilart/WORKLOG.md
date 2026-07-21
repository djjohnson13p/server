# Vanilla + Rise of the Zilart Worklog

## 2026-07-21 — Project initialization

### Completed

- Deleted the prior no-value fork and created a clean fork from `LandSandBoat/server`.
- Confirmed full administrative and push permissions on `djjohnson13p/server`.
- Created `retail-parity/vanilla-zilart-audit` from the fork's `base` branch.
- Pinned baseline commit `242ab0d055dfb80396e7398b0dd7361b750c74e2`.
- Added audit methodology, evidence ranking, status taxonomy, severity, confidence, and implementation ownership categories.
- Added a comprehensive Vanilla + Rise of the Zilart investigation checklist.
- Added standardized finding and Codex task requirements.

### Conclusions recorded

None. Project setup is not evidence that any gameplay system is correct or incorrect.

## 2026-07-21 — Static inventory pass 1

### Sources inspected

- Pinned LandSandBoat source through GitHub code search and direct file reads.
- Explicit `TODO: Unimplemented`, TODO, admitted-approximation, and empty-handler markers.
- Open upstream issues relevant to pre-CoP-origin content.
- Square Enix official Ballista documentation.
- Independent Temple of Uggalepih key and mission references.

### Confirmed findings

1. **`VZ-SYS-001` — Ballista: `MISSING`, `MAJOR`, `HIGH`.**
   - Packet structures exist, but scoreboard and scout constructors are explicitly unimplemented.
   - No functional qualification, schedule, registration, match controller, Petra, Gate Breach, Rook, scoring, or reward system was found.
   - Disposition: AI/Codex implementation plus mandatory human retail and client validation.

2. **`VZ-COMBAT-001` — Item additional effects: `INACCURATE`, `MAJOR`, `HIGH` for framework defects.**
   - The shared handler contains admitted wrong drain-selection behavior, omitted resistance paths, hardcoded assumptions, incomplete self-buff behavior, and an empty spikes stub.
   - Exact item formulas remain an item-by-item evidence task rather than a universal inferred fix.
   - Disposition: Codex-scale refactor and migration with assistant-led inventory/review and human retail datasets.

3. **`VZ-ZONE-001` — Temple of Uggalepih Map 2 Granite Doors: `INACCURATE`, `MODERATE`, `MEDIUM`.**
   - `_mf8.lua` and `_mf9.lua` both require a Prelate Key.
   - Retail references distinguish an Uggalepih-Key Map 2 door from a separate northern Prelate-Key door.
   - One in-game route check is required to map the correct entity before the bounded Lua correction.
   - Disposition: assistant-direct after route/entity validation.

### Leads rejected or deferred during this pass

- Gardening is implemented with stage, wilting, result, pot, day, moon, aura, packet, SQL, and test support; no defect was declared without retail comparison.
- Chocobo digging and Expeditionary Forces have substantial implementations; neither was classified missing based on keyword searches.
- Old “What Works” wiki claims were treated only as leads because the current project FAQ states that page is no longer maintained.
- Open issues reported against non-`base` branches or contradicted by current source were not promoted automatically.

### Next action

- Complete the incompleteness inventory for era monster skills, mission/quest TODOs, battlefields, transport, conquest, crafting, fishing, and jobs.
- Build the Vanilla/Zilart item-to-additional-effect-handler matrix.
- Validate the Temple door entity mapping before creating a fix branch.
- Continue with shared combat systems because content behavior depends on them.

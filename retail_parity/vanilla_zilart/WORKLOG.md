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

2. **`VZ-COMBAT-001` — Item additional effects: `INACCURATE`, `MAJOR`, `HIGH` for framework defects.**
   - The shared handler contains admitted wrong drain-selection behavior, omitted resistance paths, hardcoded assumptions, incomplete self-buff behavior, and an empty spikes stub.

3. **`VZ-ZONE-001` — Temple of Uggalepih Map 2 Granite Doors: `INACCURATE`, `MODERATE`.**
   - Baseline `_mf8.lua` and `_mf9.lua` both require a Prelate Key even though retail distinguishes the western Uggalepih-Key door.

### Leads rejected or deferred

- Gardening is implemented with stage, wilting, result, pot, day, moon, aura, packet, SQL, and test support; no defect was declared without retail comparison.
- Chocobo digging and Expeditionary Forces have substantial implementations; neither was classified missing based on keyword searches.
- Old “What Works” wiki claims were treated only as leads because the current project FAQ states that page is no longer maintained.
- Open issues reported against non-`base` branches or contradicted by current source were not promoted automatically.

## 2026-07-21 — Workflow simplified to AI-first execution

### Owner directive

- Do not interrupt the audit for per-finding manual tests or repeated decisions.
- The assistant audits and implements everything possible first.
- Codex then receives one consolidated script/task and performs all remaining AI-capable work.
- The owner steps in only after both AI stages are exhausted.

### Repository changes

- Added root `AGENTS.md` as the Codex navigation and guardrail file.
- Added `retail_parity/AI_FIRST_WORKFLOW.md`.
- Replaced the per-finding Codex model with `retail_parity/CODEX_MASTER_TASK.md`.
- Added gated handoff file `retail_parity/vanilla_zilart/AI_HANDOFF.md` with initial status `NOT_READY`.
- Added persistent `retail_parity/vanilla_zilart/CODEX_STATE.md`.
- Added `tools/retail_parity/run_codex_remainder.py` for autonomous multi-pass Codex execution.
- Updated project and Codex guides so human validation is consolidated at the end.

## 2026-07-21 — Static inventory and implementation pass 2

### Direct correction completed

**`VZ-ZONE-001` — Temple of Uggalepih western Map 2 door**

- Retail route references place the Uggalepih-Key door west at I-10 and the Prelate-Key door east at J-10.
- The server entities share the same north-south coordinate: `_mf9` at X `-60` is west of `_mf8` at X `-11`.
- Created `retail-parity/fix-vz-zone-001`.
- Commit `620d69d7c0315f70066c3484e110bb5d9baade3d` changes `_mf9` to require exactly one Uggalepih Key and display that key in the locked message.
- `_mf8` remains the Prelate-Key door.
- Final client route validation is deferred rather than interrupting the audit.

### New confirmed findings

4. **`VZ-JOB-001` — Summoner Elemental Spirits: `INACCURATE`, `MAJOR`, `HIGH` for framework defects.**
   - Light Spirit Curaga choice is explicitly guessed.
   - Avatar weapon damage is unverified.
   - Spirit HP/MP/stat scaling is explicitly inaccurate.
   - Spirits receive a universal `MPP +300` workaround admitted to be wrong.

5. **`VZ-CORE-001` — Call for Help scope: `INACCURATE`, `MODERATE`, `HIGH` for the implementation difference.**
   - Current code only examines `GetBattleTarget()`.
   - The source TODO states retail applies Call for Help to all claimed enemies on which the player personally has enmity and does not require engagement.

6. **`VZ-CORE-002` — Attack while fishing: `INACCURATE`, `MINOR`, `HIGH` for the intentional difference.**
   - Attack validation blocks `BlockedState::Fishing`.
   - The adjacent source comment states attacking while fishing is possible on retail and intentionally disabled in LandSandBoat.
   - A safe fishing-to-combat state transition is required rather than a blind one-line removal.

### Rejected stale lead

- Upstream issue `#405` claimed nation-changing did not play the new-player nation cutscene or award the corresponding initialization flow.
- Current immigration NPC source already tracks seen nations, sets the new-character cutscene flag, relocates the player to a valid opening location, and therefore supersedes the old report.
- No finding was created.

### Next action

- Continue the original/Zilart job audit beyond Summoner.
- Inspect explicit core enmity, claim, weaponskill, spell, and mob-skill approximations.
- Audit national mission repeat paths and Zilart battlefields.
- Inventory transport, conquest, crafting, fishing, and economy discrepancies.
- Continue implementing bounded corrections without owner interruption.

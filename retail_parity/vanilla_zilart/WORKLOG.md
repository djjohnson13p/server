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
- Current immigration NPC source already tracks seen nations, sets the new-character cutscene flag, and relocates the player to a valid opening location, superseding the old report.
- No finding was created.

## 2026-07-21 — Job, mission, transport, and fishing pass 3

### New confirmed findings

7. **`VZ-JOB-002` — Ranger Shadowbind: `INACCURATE`, `MODERATE`, `HIGH` for the implementation defect.**
   - Shadowbind uses a direct random comparison against `BIND_MEVA`.
   - It bypasses the shared target-immunity, resistance-trait, effect-nullification, and resist-rate helpers.
   - The active source explicitly notes missing `/RNG` accuracy and target-level behavior.
   - Exact retail coefficients remain a final evidence task rather than an excuse to retain the simplified model.

8. **`VZ-ECON-001` — Fishing new-moon pattern: `INACCURATE`, `MODERATE`, `HIGH`.**
   - Fishing pattern 4 is defined as full-moon preference and pattern 5 as new-moon preference.
   - The formulas are distinct and phase-opposed.
   - `GetMoonModifier` incorrectly dispatches both cases 4 and 5 to `MOONPATTERN_4`.
   - Active fish data uses pattern 5, so the bug changes catch weighting and economy availability.

9. **`VZ-ECON-002` — Waders fishing bonus: `INACCURATE`, `MINOR`, `HIGH`.**
   - The fishing system defines Waders as recognized fishing equipment and contains a Waders-specific lucky-timing bonus.
   - `GetFishingGear` filters Waders out, making the later bonus branch unreachable.

### Mission and battlefield review

- The Rise of the Zilart automated mission suite covers progression from ZM1 through ZM17, including major battlefields, headstones, pedestals, Ark Angels/Divine Might, and Celestial Nexus phases.
- This coverage is evidence that the core mission sequence exists; it is not proof that every cutscene parameter, NPC dialogue, battle mechanic, or reward is retail-equivalent.
- No broad “RotZ missions missing” finding was created.

### Leads rejected or deferred

- The Selbina transport script notes duplicate normal/pirate arrival events, but it also guards players already in an event. Without a reproducible player-visible defect, it remains a lead rather than a finding.
- The open Bastok Mission 6-2 report was reviewed. Current source triggers the relevant cutscene by speaking directly with Gilgamesh, matching retail captures cited in the upstream discussion; no mission-script correction was justified.
- Historical `modules/era` TODOs for older Ninja, Samurai, and Dragoon behavior were kept separate from the current-retail audit target.
- Later-expansion Ranger, Bard, and merit/job-point TODOs were not added to the Vanilla/Zilart backlog solely because they share an original job.

### Implementation limitation recorded

- `VZ-ECON-001` and `VZ-ECON-002` are both bounded C++ fixes, but the connected GitHub update action requires complete replacement content for the 3,290-line `fishingutils.cpp` file.
- Reconstructing a large source file through partial connector reads would be less safe than assigning the one-line corrections and tests to Codex's local repository environment.

## 2026-07-21 — Crafting, battlefield messaging, and conquest pass 4

### New confirmed findings

10. **`VZ-BF-001` — Ark Angel zero-delay ready messages: `INACCURATE`, `MODERATE`, `HIGH`.**
   - Upstream issue `#3611` reproduces repeated “readies” spam during Divine Might when a zero-delay Ark Angel weapon skill is repeatedly checked while out of range.
   - Maintainer analysis identifies manual message emission in skill-check callbacks as the architectural cause and rejects changing delay to one as a proper fix.
   - The pinned `spirits_within.lua` still emits `READIES_WS` inside `onMobSkillCheck`, and the same pattern exists across multiple humanoid weapon-skill scripts.

11. **`VZ-ECON-003` — Moghancement: Region: `INACCURATE`, `MODERATE`, `HIGH`.**
   - The Mog House enhancement applies `CONQUEST_REGION_BONUS = 10`.
   - `GainInfluencePoints` divides the modifier by 100, converts it to an integer, and adds the truncated result as a flat amount.
   - The configured value therefore becomes zero and awards no regional influence bonus.

### Crafting and guild review

- Guild rank-up, expert-quest, renouncement, guild-point purchase, synthesis success, HQ, desynthesis, and material-loss paths were inspected.
- Open crafting TODOs mainly concern event parameters, refactoring, future Escutcheon behavior, and formula research rather than a proven Vanilla/Zilart failure.
- No broad crafting-system finding was created from TODO comments alone.

### Death, Raise, and Moghancement review

- The `OnRaise` comment claiming Moghancement: Experience still needs integration is stale.
- Death-loss calculation already combines the server retain setting with `Mod::EXPERIENCE_RETAINED`.
- `MOGHANCEMENT_EXPERIENCE` applies that modifier at value 5.
- No finding was created for Moghancement: Experience.

## 2026-07-21 — Assistant-stage closure pass 5

### Final source-accessible areas reviewed

- Outpost supply-run eligibility, supply freshness, delivery rewards, teleport unlocks, city-to-outpost travel, outpost-to-city travel, fees, ownership, and alliance handling.
- Expeditionary Force sign-up, validation, badge/key-item conversion, teleport, tally cleanup, and reward paths.
- HELM gathering tools, tool breakage, weighted drops, point movement, inventory-full handling, and success hooks.
- Remaining conquest vendor and overseer interactions available through direct source reads.

### Outcome

- No new high-confidence outpost, Expeditionary Force, transport, or HELM defect was promoted.
- Existing implementation presence was not treated as proof of retail equivalence.
- The connected GitHub-only audit had reached diminishing returns: deeper completeness work now requires local filesystem search, builds, generated data inspection, automated tests, and iterative multi-file engineering.

### Consolidation completed

- Applied `VZ-ZONE-001` directly to the consolidated audit branch in commit `ed3bb6e3e59dbe482ebc58d44587576e0b035ab9`.
- Added `CODEX_BACKLOG.md` with ordered deterministic, bounded, framework, and missing-system work.
- Added `ASSISTANT_COMPLETION_REPORT.md` with findings, rejected leads, inspected areas, and environment limitations.
- Updated `STATUS.md` to mark the source-accessible assistant stage complete.

### Handoff decision

- All corrections safe through the connected GitHub workflow have been completed.
- Remaining implementation and exhaustive audit work requires Codex's local repository/build/test environment.
- `AI_HANDOFF.md` may now be changed to `READY`.
- No owner action or intermediate manual testing is requested.

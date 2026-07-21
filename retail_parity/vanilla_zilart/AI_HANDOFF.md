# Vanilla + Rise of the Zilart AI Handoff

Status: READY

## Purpose

This file authorizes the consolidated autonomous Codex stage.

The assistant has completed every audit, research, documentation, review, and safely bounded implementation task available through its connected GitHub-only environment. Codex must now verify the inherited work, implement the remaining backlog, continue the exhaustive local-repository audit, run tests/builds, and produce the final human-only queue.

## Exact handoff state

- **Repository:** `djjohnson13p/server`
- **Upstream reference:** `LandSandBoat/server`
- **Pinned upstream baseline:** `242ab0d055dfb80396e7398b0dd7361b750c74e2`
- **Assistant audit branch:** `retail-parity/vanilla-zilart-audit`
- **Codex work branch:** `retail-parity/codex-vanilla-zilart`
- **Assistant completion/worklog commit:** `96b62a6df2e8417a8855ce3d011249a7868f32c8`
- **Assistant status commit:** `5057a92f60c0ef2fc1e6738449ecaa206cb002f9`
- **Prioritized backlog commit:** `b237e8aa5d2539064664a831b2a7c455463504da`
- **Assistant completion report commit:** `84437dd96110e159732cff0ec01dfe5564326c9c`
- **No upstream pull request exists or is permitted.**

## Finding summary

The assistant recorded eleven findings at handoff:

- `MISSING`: 1
- `INACCURATE`: 10
- `PARTIAL`: 0
- `RETAIL_EQUIVALENT`: 0

Codex must not interpret the absence of additional assistant findings as proof that other systems are correct. The full expansion audit must continue locally.

## Assistant implementation already included

### `VZ-ZONE-001` — Temple of Uggalepih western Granite Door

The consolidated audit branch includes commit:

`ed3bb6e3e59dbe482ebc58d44587576e0b035ab9`

It changes `_mf9` to require and consume exactly one Uggalepih Key and to identify that key in the locked message. `_mf8` remains the Prelate-Key door.

Codex must review and test this inherited correction before treating it as resolved.

## Findings requiring Codex implementation or continuation

1. `VZ-ECON-001` — Fishing new-moon pattern dispatch.
2. `VZ-ECON-002` — Waders fishing bonus is unreachable.
3. `VZ-ECON-003` — Moghancement: Region influence bonus truncates to zero.
4. `VZ-JOB-002` — Ranger Shadowbind resistance/accuracy model.
5. `VZ-CORE-001` — Call for Help scope.
6. `VZ-CORE-002` — Attack while fishing and safe state cleanup.
7. `VZ-BF-001` — Ark Angel zero-delay ready-message architecture.
8. `VZ-COMBAT-001` — Item additional-effect framework.
9. `VZ-JOB-001` — Summoner Elemental Spirit behavior and scaling.
10. `VZ-SYS-001` — Ballista system.

Use `CODEX_BACKLOG.md` for the required order, tests, constraints, and stop conditions.

## Required Codex audit continuation

Codex must continue beyond the known findings and audit all Vanilla + Rise of the Zilart systems listed in `CODEX_MASTER_TASK.md`, including shared-core combat, jobs, missions, quests, battlefields, NMs/HNMs, zones, packets, conquest, transport, economy, guilds, crafting, fishing, gardening, HELM, auction house, delivery, treasure, and configuration/data mismatches.

For each new lead:

1. Trace the active code/data path.
2. Separate missing behavior from missing tests.
3. Compare with the strongest available evidence.
4. Create a finding only when the evidence standard is met.
5. Implement every sufficiently supported AI-capable correction.
6. Record unresolved retail coefficients or client-only behavior honestly.

## Known assistant environment limitations

- The assistant had connected GitHub source access but no local clone/build/test terminal.
- It could not run C++, Lua, SQL, formatter, startup, integration, or client tests.
- Large-file edits were not reconstructed from partial source reads merely to force a one-line patch.
- Indexed code search can miss dynamically referenced, generated, or unindexed files.
- Live FFXI retail/client packet captures were unavailable.

These limitations are the reason the local Codex stage is now required.

## Required Codex behavior

- Read `AGENTS.md`, `CODEX_MASTER_TASK.md`, `CODEX_BACKLOG.md`, `ASSISTANT_COMPLETION_REPORT.md`, `STATUS.md`, `WORKLOG.md`, and every finding before editing.
- Re-check assistant findings and the inherited implementation rather than trusting them blindly.
- Run the narrowest relevant tests first and broader required checks afterward.
- Make logical commits only on the Codex branch.
- Maintain `CODEX_STATE.md` after every autonomous pass.
- Continue without routine owner questions or intermediate gameplay-test requests.
- Never modify `base` directly.
- Never open, prepare, or suggest an upstream pull request.

## Terminal output requirements

Codex must finish in one of these states:

- `COMPLETE`
- `BLOCKED_HUMAN_ONLY`
- `FAILED_INFRASTRUCTURE`

Before entering a terminal state it must update:

- `STATUS.md`
- `WORKLOG.md`
- all relevant findings
- `CODEX_STATE.md`
- `CODEX_COMPLETION_REPORT.md`
- `HUMAN_ONLY_QUEUE.md`

## Owner involvement

No owner action is requested during the Codex stage. Human involvement is deferred until Codex produces a consolidated `HUMAN_ONLY_QUEUE.md` and reaches `COMPLETE` or `BLOCKED_HUMAN_ONLY`.

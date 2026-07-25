# Vanilla + Rise of the Zilart Codex Backlog

## Purpose

This is the resume backlog for the validated local Codex environment. It reflects the partial implementation already present on `retail-parity/codex-vanilla-zilart` and must be read together with `CODEX_STATE.md`, `STATUS.md`, `WORKLOG.md`, `LOCAL_CODEX_ENVIRONMENT.md`, all finding files, and `CODEX_COMPLETION_REPORT.md`.

## Repository rules

- Repository: `djjohnson13p/server`
- Work branch: `retail-parity/codex-vanilla-zilart`
- Never modify `base` directly.
- Never open, prepare, or suggest an upstream pull request.
- Do not ask the owner for intermediate gameplay testing.
- Preserve unresolved retail coefficients rather than inventing them.
- Use the validated Windows MSVC/Ninja build path in `LOCAL_CODEX_ENVIRONMENT.md`.
- Keep the worktree clean and remove disposable build artifacts before committing.

## Priority 0 — Inherited corrections complete

Completed on 2026-07-25:

- `VZ-ZONE-001`: five Lua interaction cases passed.
- `VZ-ECON-001`: deterministic all-phase moon-dispatch coverage passed.
- `VZ-ECON-002`: fishing-feet filter and lucky-timing reachability coverage
  passed.
- `VZ-ECON-003`: percentage and truncation coverage passed.
- `VZ-JOB-002`: all implemented guards, messages, ammo paths, and
  main/subjob availability are test-backed. Unsupported numeric accuracy,
  level, duration/resist, and Recycle behavior remains deliberately partial.
- `VZ-CORE-001`: Help-action tests exposed and corrected stale/unclaimed
  enmity eligibility. Current claim, positive requester CE/VE, boundaries,
  party/pet distinctions, and message cardinality are test-backed.

Validation commits:

- `58c30fd5ecaa6eb1b1c85f76c55c5b384fe21a27`
- `9e989c2c97395bcfef7828e339a80c49c91161dd`
- `3ef3475a9acb453fdb2ec54d68ced757ae5ded21`
- `01bb2d6556df17fcb4e26851b9b9202adb445bdf`

The focused result was 16/16 Catch2 cases (9,007,070 assertions) and 23/23
Lua cases, followed by a successful full MSVC/Ninja Debug build.

## Priority 1 — Remaining known implementation findings

### `VZ-CORE-002` — Attack while fishing

- Model and implement a safe fishing-to-combat transition.
- Cancel the fishing minigame, invalidate tokens/state, clean client fishing state, and prevent stale catch/reward processing before engaging.
- Add tests for cast, hook, active minigame, catch-resolution, cancellation, and crafted/repeated packets.
- Do not merely remove `BlockedState::Fishing`.

### `VZ-BF-001` — Ark Angel zero-delay ready-message spam

- Move ready-message emission out of repeatedly invoked skill-check callbacks.
- Implement explicit per-skill message behavior for standard ready, alternate ready, no ready, and instant use.
- Migrate Ark Angel/humanoid weapon skills using manual `READIES_WS` calls.
- Reproduce upstream issue `#3611` in an automated state test.
- Do not change zero-delay skills to one-second skills as a workaround.

### `VZ-COMBAT-001` — Item additional-effect framework

- Inventory every Vanilla/Zilart item using `ITEM_ADDEFFECT_*` data and map it to the active handler.
- Separate proc chance, accuracy/resistance, potency, duration, element, damage type, immunity, and messaging.
- Correct confirmed omitted resistance paths, known-wrong combined-drain selection, incomplete self-buffs, and dead spikes support where evidence permits.
- Use data-driven profiles and broad regression tests.
- Do not generalize one ammunition dataset to unrelated item families without evidence.

### `VZ-JOB-001` — Summoner Elemental Spirits

- Inventory Spirit HP, MP, stats, weapon damage, spell selection, and timing.
- Replace the admitted universal `MPP +300` workaround only with supported level/type data or a clearly isolated provisional profile.
- Separate Light Spirit healing, Curaga choice, buffs, and offensive decisions into deterministic tests.
- Test cooldowns, level gates, weather/day changes, and under/over-cap Summoning Magic.
- Record unsupported numeric values as unresolved rather than guessing.

### `VZ-SYS-001` — Ballista

Begin only after smaller core/framework corrections are stable.

- Design and implement qualification/license progression, schedules, Herald registration, teams, match phases, PvP rules, Petra digging, Gate Breach, Rooks, scoring, timer, results, rewards, persistence, disconnect/rejoin, and cleanup.
- Implement packet `0x0E6` scoreboard/scout behavior from available protocol evidence and captures.
- Integrate Quarry, Sprint, Scout, death/raise, statuses, parties/alliances, and reward suppression.
- Keep rules data-driven for current-retail and documented historical differences.
- Add state-machine, persistence, integration, and packet-serialization tests.
- Defer only genuinely unavailable client/retail packet fields to the final human-only queue.

## Priority 2 — Continue the full expansion audit

The eleven findings are not the complete Vanilla/Zilart audit. Perform local filesystem and test-driven review of:

- attack rounds, pDIF, accuracy/evasion, criticals, ranged distance, TP, skillchains, magic bursts, resistance, enmity, claims, aggro/linking, death/raise, experience, and statuses;
- all original and Zilart jobs, pets, abilities, traits, job quests, equipment effects, and latents;
- national missions/quests and all Zilart missions, zones, battlefields, NMs/HNMs, sky, Tu'Lia, Norg, and Kazham;
- BCNM/KSNM rules, timers, records, rewards, drops, and special mechanics;
- conquest, outposts, Expeditionary Forces, transport, airships, ferries, chocobos, auction house, delivery, bazaars, shops, guilds, crafting, fishing, gardening, HELM, treasure, and economy;
- required client-visible packet behavior;
- TODO/FIXME markers, disabled data, empty handlers, open/stale issues, test exclusions, and SQL/script mismatches.

For each lead, trace the active path, distinguish missing behavior from missing tests, apply the evidence standard, and implement every supported AI-capable correction.

## Required final artifacts

Maintain and finish:

- `STATUS.md`
- `WORKLOG.md`
- every relevant finding
- `CODEX_STATE.md`
- `CODEX_COMPLETION_REPORT.md`
- `HUMAN_ONLY_QUEUE.md`

The final human-only queue may contain only work impossible without live retail/client access, unavailable credentials/hardware, proprietary data, or an owner policy decision.

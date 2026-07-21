# Vanilla + Rise of the Zilart Codex Backlog

## Purpose

This is the resume backlog for the next networked Codex/local-build run. It reflects the partial implementation already present on `retail-parity/codex-vanilla-zilart` and must be read together with `CODEX_STATE.md`, `STATUS.md`, `WORKLOG.md`, all finding files, and `CODEX_COMPLETION_REPORT.md`.

## Repository rules

- Repository: `djjohnson13p/server`
- Work branch: `retail-parity/codex-vanilla-zilart`
- Never modify `base` directly.
- Never open, prepare, or suggest an upstream pull request.
- Do not ask the owner for intermediate gameplay testing.
- Preserve unresolved retail coefficients rather than inventing them.

## Priority 0 — Restore build and test capability

1. Clone the fork in a networked environment and check out the latest Codex branch.
2. Run a clean Ubuntu/GCC Debug build.
3. Capture and repair the first compiler error before beginning another gameplay system.
4. Run repository formatting, Lua, SQL, startup, and available unit/integration checks.
5. Record exact commands and results in `CODEX_STATE.md` and `CODEX_COMPLETION_REPORT.md`.

The previous GitHub Actions attempt completed dependencies and CMake configuration but failed in the Build step; the compiler-log tail was not recoverable from that run.

## Priority 1 — Test and validate inherited corrections

### `VZ-ZONE-001` — Temple of Uggalepih door

- Implementation present at `ed3bb6e3e59dbe482ebc58d44587576e0b035ab9`.
- Add an interaction test for correct/incorrect key, key consumption, locked-side message, and door opening.
- Preserve `_mf9` as the Uggalepih-Key door and `_mf8` as the Prelate-Key door unless stronger topology/client evidence disproves the mapping.

### `VZ-ECON-001` — Fishing new-moon dispatch

- Implementation present at `556ad21ccda664e012003e5898fa7b4e2936c208`.
- Add deterministic coverage proving pattern 4 and pattern 5 call their independent curves across moon phases.

### `VZ-ECON-002` — Waders fishing bonus

- Implementation present at `556ad21ccda664e012003e5898fa7b4e2936c208`.
- Add a test proving `GetFishingGear` retains Waders and the existing lucky-timing branch executes.

### `VZ-ECON-003` — Moghancement: Region

- Implementation present at `556ad21ccda664e012003e5898fa7b4e2936c208`.
- Original source encoding was restored at `0702a5be6421efd52be6ed17a4fa36347f1c69cf`.
- Add conquest/IPC tests for 0%, 10%, 100%, small awards, and explicit rounding behavior.

### `VZ-JOB-002` — Ranger Shadowbind

- Partial correction present at `b0058b40ef4b71dfd7af2d24dbae7fcf8edfd7f4`.
- Shared Bind immunity, resistance-trait, and nullification guards are implemented.
- Add tests for those guards, existing Bind, success/failure messages, and ammunition consumption.
- Research and implement only evidence-supported main-job versus `/RNG`, relative-level, exact accuracy, duration, and Recycle behavior.
- Do not replace the remaining roll with an invented spell formula.

### `VZ-CORE-001` — Call for Help

- Candidate correction present at `de408e05de4c8c44250f9db493492817bbe8db65`.
- Add tests for one/multiple eligible mobs, no active target, personal versus party/pet enmity, already-enabled and blocked mobs, battlefields/confrontations, instance isolation, and enmity retained after claim transitions.
- Determine from tests/source whether an explicit current-claim check is required in addition to personal enmity membership.
- Validate reward suppression, outside-player access, claim color, radar/client updates, and message behavior.

## Priority 2 — Remaining known implementation findings

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

## Priority 3 — Continue the full expansion audit

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

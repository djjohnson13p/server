# Vanilla + Rise of the Zilart Codex Backlog

## Purpose

This is the prioritized implementation and continuation backlog after the assistant-stage source audit. Codex must re-check every finding and may correct or reject assistant conclusions when the repository evidence requires it.

The backlog is ordered to deliver deterministic, low-risk corrections first, then bounded behavioral fixes, then broad framework work, and finally the largest missing system.

## Branch and repository rules

- Repository: `djjohnson13p/server`
- Work branch: `retail-parity/codex-vanilla-zilart`
- Never modify `base` directly.
- Never open, prepare, or recommend an upstream pull request.
- The assistant's consolidated audit branch already contains the `VZ-ZONE-001` door correction.
- Keep logical commits tied to finding IDs.

## Priority 0 — Verify inherited assistant correction

### `VZ-ZONE-001` — Temple of Uggalepih western Granite Door

- Review commit `ed3bb6e3e59dbe482ebc58d44587576e0b035ab9` on the audit branch.
- Verify `_mf9` is the western I-10 Uggalepih-Key door and `_mf8` remains the eastern J-10 Prelate-Key door.
- Add an interaction test if the current harness can model the locked side, accepted key, rejected key, key consumption, and door opening.
- Do not revert merely because upstream still differs; this is a fork-only correction supported by route topology and independent references.

## Priority 1 — Deterministic, bounded corrections

These findings have internally provable defects and should be implemented before formula research.

### `VZ-ECON-001` — Fishing new-moon pattern dispatch

- In `GetMoonModifier`, change case 5 to use `MOONPATTERN_5` rather than `MOONPATTERN_4`.
- Add deterministic tests for all phase indices and at least patterns 4 and 5.
- Confirm active pattern-5 fish now receive the new-moon curve.

### `VZ-ECON-002` — Waders bonus unreachable

- Include `WADERS` in the feet items retained by `GetFishingGear`.
- Add a test that proves the Waders branch in `CalculateLuckyTiming` is reachable.
- Preserve Fisherman's Boots and Angler's Boots behavior.

### `VZ-ECON-003` — Moghancement: Region influence bonus

- Apply `CONQUEST_REGION_BONUS` as a percentage of the base influence award before integer conversion.
- Decide and document rounding behavior.
- Add IPC-payload or conquest-unit tests for 0%, 10%, 100%, and small awards.

## Priority 2 — Bounded core and job behavior

### `VZ-JOB-002` — Ranger Shadowbind resistance

- Replace the raw `BIND_MEVA` roll with an explicit status-immunity/resistance path.
- Preserve ranged weapon/ammunition validation and consumption.
- Add tests for immunity, resistance traits, existing Bind, main-job Ranger, `/RNG`, relative target level, messaging, and ammunition use.
- Do not invent an undocumented universal magic formula. Implement established factors and leave unresolved coefficients clearly marked.

### `VZ-CORE-001` — Call for Help scope

- Trace every claimed mob on which the requesting player personally has enmity, not only `GetBattleTarget()`.
- Do not require the player to be actively engaged.
- Respect per-mob Call for Help blocks, claim type, battlefield/confrontation boundaries, and zone scope.
- Define atomic behavior when some eligible mobs can accept Call for Help and others cannot.
- Add multi-mob, unengaged, party/alliance, pet-enmity, blocked, and cross-boundary tests.

### `VZ-CORE-002` — Attack while fishing

- Model the retail fishing-to-combat transition before removing the Fishing validation block.
- Cancel the fishing minigame safely, invalidate tokens/state, clean client fishing state, and prevent stale catch/reward processing.
- Add tests for attack during cast, hook, active minigame, successful catch resolution, and repeated crafted packets.

## Priority 3 — Shared combat and battlefield frameworks

### `VZ-BF-001` — Ark Angel zero-delay ready-message spam

- Trace mob-skill state, delay, ready-message, and use-message architecture.
- Move message emission out of repeatedly invoked skill-check callbacks.
- Add explicit per-skill message behavior capable of standard ready, alternate ready, no ready, and instant-use semantics.
- Migrate Ark Angel/humanoid weapon skills using manual `READIES_WS` calls.
- Reproduce upstream issue `#3611` in an automated state test.
- Do not change zero-delay skills to one-second skills as a workaround.

### `VZ-COMBAT-001` — Item additional-effect framework

- First generate an inventory of every Vanilla/Zilart item using `ITEM_ADDEFFECT_*` data and map each item to the active handler.
- Separate proc chance, accuracy/resistance, potency, duration, element, damage type, immunity, and messaging.
- Correct confirmed framework defects: omitted resistance paths, known-wrong combined-drain selection, incomplete self-buff handling, and dead spikes support where evidence permits.
- Use data-driven item/effect profiles and broad regression tests.
- Do not generalize Sleep Bolt/Acid Bolt evidence to every item family without support.

### `VZ-JOB-001` — Summoner Elemental Spirits

- Inventory Spirit HP, MP, stat, weapon-damage, spell-selection, and timing behavior.
- Replace the admitted universal `MPP +300` workaround with level/type data or a clearly isolated temporary profile when evidence exists.
- Separate Light Spirit healing, Curaga choice, buffs, and offensive behavior into testable decisions.
- Add deterministic tests around spell pools, level gates, cooldowns, weather/day adjustments, and low/over-cap Summoning Magic.
- Mark numeric retail values unresolved when they lack evidence rather than inventing them.

## Priority 4 — Missing system

### `VZ-SYS-001` — Ballista

This is the largest task and should begin only after the smaller framework corrections are stable.

- Build a dedicated state-machine design for qualification/license progression, schedules, Herald registration, team assignment, match phases, PvP restrictions, Petra digging, Gate Breach, Rooks, scoring, timer, results, rewards, and persistence.
- Implement packet `0x0E6` scoreboard/scout behavior from available protocol documentation and captures.
- Integrate Quarry, Sprint, Scout, death/raise, status effects, parties/alliances, disconnect/rejoin, and match cleanup.
- Keep rules data-driven so current-retail behavior and historical differences can be represented without duplicating the engine.
- Automated state-machine and serialization tests are mandatory.
- Packet fields and client-visible behavior that cannot be established without retail captures must be placed in the final human-only queue.

## Audit continuation required from Codex

The eleven findings above are confirmed assistant-stage results, not the complete expansion audit. Codex must continue repository-wide inspection and create additional findings where evidence supports them, including:

- Core attack rounds, pDIF, accuracy/evasion, criticals, ranged distance, skillchains, magic bursts, resistance, enmity, claims, aggro/linking, death/raise, experience, and status effects.
- All original and Zilart jobs, pets, job quests, abilities, traits, equipment effects, and latents.
- National missions/quests and all Rise of the Zilart missions, zones, battlefields, NMs/HNMs, sky, Tu'Lia, Norg, and Kazham.
- BCNM/KSNM content in scope, battlefield rules, rewards, drops, timers, and records.
- Conquest, outposts, Expeditionary Forces, transport, airships, ferries, chocobos, auction house, delivery, bazaars, shops, guilds, crafting, fishing, gardening, HELM, treasure, and economy.
- Client-visible packet behavior required by scoped systems.
- TODO/FIXME markers, disabled data, empty handlers, open issues, stale issue rejection, test exclusions, and SQL/script mismatches.

## Required final reports

Codex must update:

- `STATUS.md`
- `WORKLOG.md`
- all finding files
- `CODEX_STATE.md`
- `CODEX_COMPLETION_REPORT.md`
- `HUMAN_ONLY_QUEUE.md`

The final human-only queue must contain only work impossible without live retail/client access, unavailable credentials/hardware, proprietary data, or an owner policy decision.

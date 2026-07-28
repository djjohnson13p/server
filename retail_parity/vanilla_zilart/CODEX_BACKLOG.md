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

## Priority 0 — Completed corrections

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

### `VZ-CORE-002` — Attack while fishing

Completed in
`a5bdb74c3b7511a2f098a3dc28336cf70f91dafd`.

- Valid enemy, range, attack-delay, and PAI-change checks run before fishing
  teardown; accepted engagement interrupts fishing before combat starts.
- The authoritative interruption is idempotent and clears response, token,
  animation, and hooked-monster state while preserving existing rod/bait
  rules.
- Waiting and hooked phases, the pre-reward boundary, resource accounting,
  invalid targets, late/crafted packets, duplicate actions, ordinary
  cancellation, other fishing restrictions, and recovery are covered in
  eight passing real-path Lua cases.
- Exact client packet/animation ordering and invalid-target retail
  presentation remain final live-capture candidates.

### `VZ-BF-001` — Ark Angel zero-delay ready messages

Completed on 2026-07-25.

- A successful mob-skill state entry now resolves explicit skill/pool
  start-message policy and emits at most one normal battle-action
  `SkillStart`.
- Zero-time skills remain zero-time and execute immediately after their
  configured start action. Positive-time and interruption behavior are
  unchanged.
- Seventeen active scripted `onMobSkillCheck` ready-message workarounds,
  representing 21 skill IDs, were migrated to explicit SQL policy.
- Trion pool 4006 and Volker pool 4249 retain custom dialogue through six
  explicit no-start overrides.
- Eleven Lua cases reproduce issue #3611 and cover standard/no-start,
  zero/positive time, target presentation, state failure, and encounter
  exceptions. The 19-case Catch2 run and 65-case `0x028` packet suite pass.
- Exact per-move retail ready policy and same-update client rendering remain
  final live-capture candidates; unsupported exceptions were not invented.

### `VZ-COMBAT-001` Phase A — Item additional-effect inventory/framework

Completed on 2026-07-25.

- Reproducible CSV/Markdown inventory covers 420 active or issue-scoped
  items, including 18 maintained Vanilla/Zilart entries and conservative
  `ERA_UNRESOLVED` classification where repository era metadata is absent.
- SQL remains the numeric source. The Lua profile layer separates proc,
  accuracy/resistance, outcome, and presentation and rejects malformed
  profiles explicitly.
- Behavioral tests reproduced and corrected duplicate HP mutation,
  twice-applied absorption/nullification, and the breath-flag mismatch.
  Status application now emits no false success when overwrite/application
  fails.
- Real melee and ranged 0x028 paths, Acid/Sleep bolts, status guards and
  partial duration, physical flags, level eligibility, and the five
  maintained Zilart NM interactions are test-backed.
- Only Acid/Sleep receive the issue-supported item-native A-rank policy. INT
  remains legacy-unverified; no ammunition-wide dSTAT formula was invented.
- Combined drains, other unsupported drain/scaling behavior, self-buffs,
  Death, spikes, and item-specific formulas remain explicit Phase B work.

### `VZ-COMBAT-001` Phase B1 — Fire/Ice/Lightning Arrow

Completed on 2026-07-26.

- The three level-45 elemental arrows now resolve through exactly one
  validated scripted profile registry while preserving Fire, Ice, and Thunder
  identity.
- The evidence ledger records January/March 2004 community evidence and the
  unresolved conflict between a not-always/roughly-5-10 report and inherited
  implicit-100%/uniform-7-10 behavior.
- No controlled retail formula was found. Proc, power, A+ rank, no-stat/zero
  macc, disabled MAB, resist floor, staff/affinity/day-weather, and defensive
  interactions remain tested compatibility or `VERIFY_LIVE`.
- The executor guarantees one proc/resist/null/absorb/application path,
  resolves power once only after proc and deterministic early rejection, and
  reports actual HP damage/healing at caps. Existing numeric callers remain
  compatible.
- Fifty-one focused Lua cases cover proc-before-power ordering, real ranged
  0x028 hits, ordinary misses, range/despawn/level gates, consumption,
  Recycle, Unlimited Shot, Enspell priority, profile validation, formula
  boundaries, stats, tiers, multipliers, defenses, null/absorb, and HP caps.
- Inventory sanity proves exact three-item scope and prevents later elemental
  arrows from being migrated accidentally.

### `VZ-COMBAT-001` Phase B2 — Maintained status ammunition

Completed on 2026-07-28 as a partial engineering/profile pass.

- Kabura Arrow, Patriarch Protector's Arrow, Blind Bolt, Venom Bolt, Poison
  Arrow, Sleep Arrow, Demon Arrow, and Spartan Bullet now resolve through
  exactly one validated SQL-backed item-policy registry.
- Effect identity is evidence-backed. Proc, level correction, rank/stat,
  element, power, duration, resistance, overwrite, and exact presentation
  remain explicit compatibility or `VERIFY_LIVE`; Acid/Sleep item-native
  A-rank evidence was not generalized.
- A ranked ledger records accessible public evidence and every field
  classification. It preserves conflicts instead of selecting unsupported
  numerics.
- The DEBUFF handler now performs one authoritative status application and
  removes Defense/Evasion/Attack Boost only after success. Rejection returns
  no result and leaves the opposing boost untouched.
- Forty-nine new focused cases cover all eight real successful ranged results,
  every physical miss, range/despawn/level/resource paths, exact scope,
  validation, proc/resist/application ordering, and status parameters.
- Inventory generation and sanity verify one handler per item, exact
  element/status/subeffect mappings, both test references, and no migration
  of Acid/Sleep or later Gashing/Abrasion/Oxidant ammunition.
- Spartan evidence supports a missing target-side cooldown but conflicts on
  its exact interval/ownership. The active 10%/five-second/no-cooldown policy
  is retained as known-incomplete compatibility pending controlled captures.

## Priority 1 — Remaining known implementation findings

### `VZ-COMBAT-001` Phase B3 — Evidence-backed family migrations

- Use the generated inventory to select one bounded effect family or
  configuration-error group at a time.
- Prefer a maintained drain family for the next bounded pass; do not mix
  drains with Dispel, Death, self-buffs, or spikes.
- Establish item/era evidence before changing classifications or numerics.
- Resolve damage type/MAB/dSTAT, drain accuracy/scaling/order, Dispel,
  self-buff, Death, and equipment-spikes behavior only where evidence
  supports it.
- Preserve compatibility/`VERIFY_LIVE` behavior when evidence is still
  insufficient; do not generalize the Acid/Sleep A-rank result.
- Do not generalize the Fire/Ice/Lightning Arrow compatibility profile to
  Earth/Water/Wind or other elemental ammunition without separate evidence.
- Do not generalize the status-ammunition profile or Acid/Sleep accuracy
  evidence to later bolts or another item family without separate evidence.
- Add real melee/ranged/reaction packet tests for each migrated group.

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

# Vanilla + Rise of the Zilart Worklog

## 2026-07-21 — Project initialization

- Deleted the prior no-value fork and created a clean fork from `LandSandBoat/server`.
- Confirmed administrative and push permissions on `djjohnson13p/server`.
- Pinned upstream baseline `242ab0d055dfb80396e7398b0dd7361b750c74e2`.
- Created `retail-parity/vanilla-zilart-audit`.
- Added the retail-parity method, evidence ranking, finding format, status taxonomy, implementation ownership, worklog, dashboard, and Vanilla/Zilart scope checklist.
- Established the rule that no upstream pull request may be opened or suggested.

## 2026-07-21 — Assistant audit passes

The assistant inspected pinned C++, Lua, SQL, tests, configuration, official/public retail documentation, and current upstream issues through connected GitHub access.

### Confirmed baseline findings

1. `VZ-SYS-001` — Ballista gameplay system missing.
2. `VZ-COMBAT-001` — item additional-effect framework inaccurate and incomplete.
3. `VZ-ZONE-001` — western Temple of Uggalepih Map 2 door used the wrong key.
4. `VZ-JOB-001` — Summoner Elemental Spirit behavior/scaling contains guessed and admitted-wrong logic.
5. `VZ-CORE-001` — Call for Help inspected only the current battle target.
6. `VZ-CORE-002` — attacking while fishing is intentionally blocked despite retail allowing it.
7. `VZ-JOB-002` — Shadowbind bypassed shared immunity/resistance handling and omitted level/subjob behavior.
8. `VZ-ECON-001` — fishing new-moon pattern dispatched to the full-moon formula.
9. `VZ-ECON-002` — Waders were filtered out before their fishing bonus could execute.
10. `VZ-BF-001` — Ark Angel zero-delay weapon skills can emit repeated/incorrect ready messages.
11. `VZ-ECON-003` — Moghancement: Region's configured 10% bonus truncated to zero.

### Assistant correction

- `VZ-ZONE-001` was corrected on the audit branch in commit `ed3bb6e3e59dbe482ebc58d44587576e0b035ab9`.
- `_mf9` now requires and consumes an Uggalepih Key; `_mf8` remains the Prelate-Key door.

### Areas inspected without a promoted finding

- Gardening lifecycle/data/tests.
- Chocobo digging.
- Expeditionary Forces.
- Outpost supply/warp rules and fees.
- HELM gathering logic/data.
- Guild rank-up, guild points, renouncement, and crafting purchases.
- Core synthesis, HQ, desynthesis, skill-up, and material-loss paths.
- Rise of the Zilart mission-sequence test coverage through ZM17.
- Selbina/Mhaura arrival TODOs without a reproduced player-visible failure.

These areas were not certified retail-equivalent; they simply lacked a sufficiently supported finding in the connected-source pass.

### Rejected stale or misleading leads

- Nation-change opening-cutscene issue: current immigration logic already handles seen nations and initial cutscene relocation.
- Moghancement: Experience Raise TODO: death-loss calculation already applies `EXPERIENCE_RETAINED`.
- Bastok Mission 6-2 Oaken Door workaround proposal: current Gilgamesh interaction matches cited retail captures.
- Optional historical `modules/era` TODOs were not mixed into the current-retail target unless active base behavior was also affected.
- Later-expansion merit/job-point TODOs were not assigned to Vanilla/Zilart solely because the job originated earlier.

## 2026-07-21 — AI-first workflow and handoff

At the owner's direction, the project was simplified to:

1. assistant audit and bounded implementation first;
2. one consolidated autonomous Codex run second;
3. one final human-only queue only after AI work is exhausted.

Repository additions included:

- root `AGENTS.md`;
- `AI_FIRST_WORKFLOW.md`;
- `CODEX_MASTER_TASK.md`;
- `CODEX_BACKLOG.md`;
- `ASSISTANT_COMPLETION_REPORT.md`;
- gated `AI_HANDOFF.md`;
- persistent `CODEX_STATE.md`;
- completion and human-only reports;
- `tools/retail_parity/run_codex_remainder.py`.

`AI_HANDOFF.md` was marked `READY`, and `retail-parity/codex-vanilla-zilart` was created from the completed audit branch.

## 2026-07-21 — Partial Codex-stage implementation

### Deterministic corrections

Commit `556ad21ccda664e012003e5898fa7b4e2936c208` implemented:

- `VZ-ECON-001`: case 5 now calls `MOONPATTERN_5`.
- `VZ-ECON-002`: Waders are retained by `GetFishingGear`.
- `VZ-ECON-003`: positive `CONQUEST_REGION_BONUS` values are applied as a percentage of base influence.

The one-time implementation workflow used exact baseline-expression counts, static post-edit assertions, and `git diff --check`, then removed itself.

Commit `0702a5be6421efd52be6ed17a4fa36347f1c69cf` restored the pre-existing UTF-8 BOM on `conquest_system.cpp` so no unrelated encoding change remained.

### Shadowbind partial correction

Commit `b0058b40ef4b71dfd7af2d24dbae7fcf8edfd7f4` added shared Bind:

- immunity checking;
- resistance-trait checking;
- effect-nullification checking.

The existing unresolved `BIND_MEVA` roll, duration, messaging, and ammunition behavior were intentionally preserved. Main/subjob, relative-level, exact accuracy, duration, and tests remain open.

### Call for Help candidate correction

Commit `de408e05de4c8c44250f9db493492817bbe8db65` replaced single-target `GetBattleTarget()` handling with current-instance mob iteration.

Every mob is changed only when:

- it is not already help-enabled;
- the requesting player's ID exists in its enmity container;
- the mob has not blocked Call for Help.

The success message is emitted once when at least one mob changes. Claim-transition, party/pet, reward, client-update, and battlefield edge cases still require automated tests and validation.

### Temporary automation cleanup

All temporary implementation and diagnostic workflow files were removed from the Codex branch after use or suppression. No permanent fork automation was left behind.

## 2026-07-21 — Isolated-container validation failure

The first autonomous attempt used the assistant's execution container rather than the owner's local Codex desktop environment.

- The Codex CLI had authentication state but the container could not reach GitHub Git/raw endpoints or the OpenAI responses endpoint.
- A local clone could not be created in that container.
- A GitHub Actions GCC Debug build reached configuration but failed during compilation, and its log tail was not retained.
- Connector-authored diagnostic workflows were later suppressed with “No jobs were run.”

`CODEX_STATE.md` was temporarily set to `FAILED_INFRASTRUCTURE`. That state described the isolated container only and has since been superseded.

## 2026-07-21 — Local Codex desktop environment validated

### Repository and Git safety

- Cloned `djjohnson13p/server` to `C:\GitHub\server`.
- Checked out `retail-parity/codex-vanilla-zilart`.
- Confirmed a clean worktree and successful `git fetch origin`.
- Confirmed all required project/instruction files are readable from Codex.
- Disabled recursive submodule behavior for normal Git fetches.
- Preserved upstream fetch access while disabling upstream push locally.
- Confirmed both top-level submodules were available at their recorded commits.

### Codex desktop execution

- Added the repository root as the Codex project.
- Confirmed Codex shell execution, repository access, branch access, instruction loading, and GitHub connectivity.
- Codex reported no tracked changes after read-only validation.

### Windows compiler/toolchain

- Found Visual Studio Build Tools 2022 `17.14.35`.
- Confirmed the x64/x86 C++ tool component.
- Initialized the x64 MSVC environment through `VsDevCmd.bat`.
- Confirmed MSVC `cl 19.44.35228`, linker `14.44.35228.0`, Windows SDK `10.0.26100.0`, CMake `4.3.3`, Ninja `1.13.2`, Python `3.14.6`, and Git `2.54.0.windows.1`.
- Missing Clang was correctly treated as irrelevant to the supported Windows MSVC path.
- MinGW GCC was not used as a substitute.

### Full build result

Using a disposable `build-codex-smoke` directory:

- Fresh MSVC/Ninja Debug CMake configuration passed with exit code `0`.
- Full build passed with all `1049/1049` Ninja steps.
- `xi_connect`, `xi_map`, `xi_search`, `xi_world`, and `xi_test` linked successfully.
- Build exit code was `0`.
- The build directory, generated executables, and PDBs were removed.
- Final Git status was clean on the required branch.

The exact commands and tool versions are recorded in `LOCAL_CODEX_ENVIRONMENT.md`.

### State transition

- `FAILED_INFRASTRUCTURE` is superseded.
- The current project state is `IMPLEMENTATION_READY`.
- The next pass is focused automated regression coverage for the six inherited corrections, followed by the remaining implementation backlog.
- No owner gameplay testing is requested.

## 2026-07-25 — Inherited correction validation and hardening

### Deterministic C++ coverage

- Added a production moon-pattern/phase seam and Catch2 coverage for fishing
  patterns 4 and 5 across all eight phases.
- Added production seams around fishing feet filtering and gear-only lucky
  timing. Tests prove Fisherman's Boots, Angler's Boots, Waders, and unrelated
  feet retain their intended behavior.
- Added a production conquest arithmetic seam. Tests lock down 0%, 10%, 100%,
  small and zero awards, negative modifiers, and truncation of fractional
  bonuses.
- Added a Call-for-Help instance identity seam for direct same/different
  instance boundary coverage.

### Lua interaction coverage

- Added five Temple of Uggalepih door tests against the real `_mf9` and `_mf8`
  NPC handlers.
- Added nine Shadowbind tests against the real job-ability action path,
  including guards, messages, ammo, Unlimited Shot, and Ranger main/subjob
  availability. The test-player factory now supports optional subjob and
  subjob-level setup.
- Added a Help-action packet helper and nine Call-for-Help interaction tests.

### Defect discovered and corrected

The inherited Call-for-Help candidate accepted any requester ID retained in an
enmity container. Focused claim-transition tests proved this could touch an
unclaimed mob. Eligibility now requires:

- a current claim through `HasClaim`;
- positive requester CE or VE;
- matching confrontation, battlefield, instance, and battle ID;
- a live, non-blocked, not-already-enabled mob.

This preserves multi-mob/no-active-target behavior while excluding stale,
unclaimed, or cross-boundary entries.

### Test infrastructure and database isolation

The installed local `xidb` was one schema revision behind the current source
(`mob_resistances.stun_res_rank` was absent). It was not modified. A disposable
database, `xidb_codex_validation_20260725_1435`, was created, populated through
`tools/dbtool.py update`, used for `xi_test`, and removed with the other
disposable validation artifacts. The working local `xidb` remained unchanged.

An attempted live cross-instance enmity fixture was discarded after proving
unsafe in the harness. Instance identity is instead tested through the
production boundary seam, while the action continues to enumerate with
`ForEachMobInstance`.

### Validation result

- Lua style check: passed.
- Catch2: 16/16 cases, 9,007,070 assertions passed.
- Focused Lua: 23/23 tests passed.
- Fresh-directory MSVC/Ninja Debug configuration: passed.
- Complete Debug build: passed; all server/test executables linked.
- `git diff --check`: passed.
- Disposable build directory, root executables/PDBs, and isolated test
  database: removed.

## Resume point after inherited correction validation

1. Fetch the latest `origin/retail-parity/codex-vanilla-zilart`.
2. Read the repository instructions, state, backlog, environment guide,
   worklog, completion report, and relevant findings.
3. Begin `VZ-CORE-002` attack-while-fishing with a safe state transition and
   focused tests.
4. Continue `VZ-BF-001`, `VZ-COMBAT-001`, `VZ-JOB-001`, `VZ-SYS-001`, and the
   exhaustive audit in bounded passes.
5. Preserve unsupported Shadowbind coefficients and client-only
   Call-for-Help/door/economy observations for final validation rather than
   inventing behavior or requesting intermediate owner tests.

## 2026-07-25 — VZ-CORE-002 safe attack-while-fishing transition

### Lifecycle trace

- Traced Fish action entry, CheckHook, EndMiniGame, PotentialTimeout, Release,
  hostile interruption, zone cleanup, fishing result generation, bait/rod
  rules, skill-up, monster reservation/spawn, animation ownership, and PAI
  engagement.
- Confirmed fishing is an animation/character-owned session rather than a PAI
  state. Catch resolution is synchronous packet processing; no deferred
  fishing reward callback or timer exists.
- Confirmed the baseline interruption helper already owned client release,
  hooked-phase bait loss, response destruction, animation cleanup, and
  fishing-monster unhooking, but did not invalidate the token and accepted
  late/wrong-phase fishing input remained insufficiently guarded.

### Production correction

Commit `a5bdb74c3b7511a2f098a3dc28336cf70f91dafd`:

- removed `BlockedState::Fishing` from Attack only;
- performs normal enemy, distance, attack-delay, and PAI-change checks before
  interrupting fishing, then enters the ordinary engagement path;
- made `InterruptFishing` idempotent and authoritative for token, response,
  animation, bait, hooked-monster, and release-packet cleanup;
- added fresh monotonically advancing nonzero fishing session tokens and
  delayed session allocation until cast validation succeeds;
- rejects fishing packets outside their waiting/hooked phase or without a
  matching live token/response;
- invalidates token/cast state on ordinary release;
- added controlled Lua packet/state helpers without exposing a reward-granting
  test shortcut.

### Automated coverage

Eight real-path Lua cases cover:

- waiting/no-bite and hooked/minigame interruption;
- the latest controllable pre-reward boundary;
- exact rod/bait/catch/skill-up behavior;
- fishing-monster unhooking and no stale spawn;
- duplicate Attack and repeated cancellation;
- late, malformed, duplicate, and wrong-phase fishing packets;
- invalid entity, self, range, and despawned-target Attack attempts;
- ordinary release, post-combat recovery with a fresh token, unchanged
  non-Attack fishing restrictions, and ordinary non-fishing Attack.

Final validation:

- Lua style: passed.
- Focused Lua: 8/8 passed on two final runs after fixture correction.
- Catch2: 16/16 cases and 9,007,070 assertions passed on every `xi_test` run.
- Fresh MSVC/Ninja Debug configuration: passed.
- Focused `xi_test` target build: passed (`905/905`).
- Complete all-target Debug build: passed (`151/151` remaining steps).
- `clang-format` and `git diff --check`: passed.
- The working local `xidb` was not modified; a disposable current-schema
  database was used.

### Defects and test-environment issues resolved

- The original fishing packet handler accepted late and wrong-phase packets
  after interruption. Phase, response, and token validation now prevents
  those paths.
- Session state was allocated before active animation/rod/bait validation and
  used a reusable random token. Allocation now occurs only after validation
  and uses a fresh per-character sequence.
- A fresh database requires `dbtool.py setup <database>` rather than express
  `update`; the first disposable partial import was discarded and recreated.
- The first Lua run inherited the repository default
  `map.FISHING_ENABLE=false`; the validated reruns used the explicit
  `XI_MAP_FISHING_ENABLE=true` test override.
- The first enabled fixture used a nonexistent generated item constant and
  did not make the real-time cast recast ready. The generic packet helper now
  advances only test recast readiness, and all production validation remains
  active.

### Remaining client-only uncertainty

Exact retail fishing-release packet order, rendered animation/message timing,
and the response to every invalid Attack target require a client/live capture.
The client fishing input carries no session token, so an old CheckHook arriving
during the indistinguishable waiting phase of a newly started cast cannot be
identified at protocol level. All server-distinguishable stale, post-cancel,
wrong-phase, duplicate-hook, and malformed paths are rejected.

## 2026-07-25 — VZ-BF-001 engine-owned mob-skill start messages

### Trace and inventory

- Traced `CMobController::MobSkill`, all `OnMobSkillCheck` callers,
  `CMobSkillState` construction/update/interruption, SQL skill loading,
  `SkillStart`/finish packet serialization, target presentation, and the
  `NO_START_MSG`/`NO_FINISH_MSG` flags.
- Confirmed the issue-#3611 spam path: selection calls Lua eligibility before
  range validation and can repeat on combat ticks, while 17 scripts emitted a
  user-visible basic ready message from that callback.
- Inventoried all Ark Angel and Divine Might skill lists. Only HM Circle/Swift
  Blade and EV Spirits Within/Vorpal Blade had inherited manual-ready
  evidence; other zero-time moves were not guessed.
- Identified 21 skill IDs represented by the scripted standard-ready calls,
  six Trion/Volker encounter-specific no-start cases, and a stale commented
  Aeolian Edge call.

### Production correction

- Added an `Enter()` state lifecycle hook called only after the AI container
  has successfully installed a state.
- `CMobSkillState::Enter()` now resolves and sends one configured normal
  battle-action `SkillStart`, triggers the existing listener, spends TP, and
  immediately executes a zero-time state. Positive-time preparation and
  interruption are unchanged.
- Added `mob_skill_start_messages` with backward-compatible absence,
  explicit no-start, explicit standard/alternate message, and pool override
  semantics. `NO_START_MSG` remains authoritative and `NO_FINISH_MSG` remains
  independent.
- Migrated all active manual humanoid ready calls out of `onMobSkillCheck`.
  Trion pool 4006 and Volker pool 4249 retain their custom dialogue without
  generic ready actions.
- Added a repository sanity check with an explicit empty allowlist to prevent
  future `READIES_WS`/`READIES_SKILL` side effects in mob-skill checks.

### Behavioral coverage

- Reproduced issue #3611 through a real humanoid skill list and repeated
  out-of-range controller ticks: zero start/basic/finish packets and no TP
  cost until state entry.
- Proved Ark Angel EV zero-time standard start-before-finish behavior, Ark
  Angel zero-time no-start behavior, positive preparation/interruption,
  `NO_START_MSG`, true-self and attacker-centered target presentation,
  missing-target fallback, both hidden-target settings, and Amnesia state
  rejection.
- Entered the real Heir to the Light and Where Two Paths Converge battlefield
  phases to prove Trion/Volker custom dialogue is retained without a generic
  start.
- Catch2 covers default, standard, no-start, alternate, pool override, copied
  policy, `NO_START_MSG`, and independent `NO_FINISH_MSG` resolution.

### Validation result

- Fresh MSVC/Ninja Debug configure: exit `0`.
- Focused `xi_test` target build: exit `0`.
- Catch2: 19/19 cases, 9,007,079 assertions passed.
- Focused Lua: 11/11 passed with default presentation and 11/11 passed after
  the full build with `HIDE_READIES_TARGET=true`.
- Complete `0x028` packet regression suite: 65/65 passed.
- SQL setup/import and subsequent supported `dbtool.py update` against a
  disposable database: both exit `0`.
- Lua `luacheck`, style, and mob-skill-check purity: exit `0`.
- SQL sanity, `clang-format`, and `git diff --check`: exit `0`.
- Complete all-target Debug build: exit `0`; all five executables linked.
- The owner's working `xidb` was not modified.

### Remaining retail/client uncertainty

Exact ready/no-ready behavior for Ark Angel moves that had no repository
ready evidence, exact same-update start/finish rendering, and any retail
alternate message not represented in current data require live captures.
These do not leave a known server architecture defect.

### Test-fixture/environment corrections

- The repository Lua sanity wrapper needed Python UTF-8 mode and an explicit
  Windows `luacheck.bat` bridge; all actual checks then passed.
- The first packet-regression file selectors addressed data modules rather
  than their collecting `0x028` base and therefore collected zero tests. The
  corrected `--file 0x028` run collected and passed all 65 cases.
- Early focused fixtures were corrected for the real Sonic Boom preparation
  duration, settings initialization, battle-target context, action-message
  filtering, and TP gained from dealt damage. No production workaround was
  introduced.

## Current resume point

1. Fetch the latest `origin/retail-parity/codex-vanilla-zilart`.
2. Read the repository instructions, state, backlog, environment guide,
   worklog, completion report, and relevant findings.
3. Begin the next bounded pass with `VZ-COMBAT-001` item additional effects.
4. Continue `VZ-JOB-001`, `VZ-SYS-001`, and the exhaustive audit in bounded
   passes.
5. Preserve all unsupported retail/client details for final validation rather
   than inventing behavior or requesting intermediate owner tests.

## 2026-07-25 — VZ-COMBAT-001 Phase A inventory and framework

### Evidence and lifecycle trace

- Read LandSandBoat issue #7899, all seven comments, and all eight attached
  images. The supported boundary is item-native A-rank magic accuracy for
  Acid Bolt and Sleep Bolt; dSTAT and extension to other ammunition remain
  unresolved.
- Traced melee `HandleEnspell`, ranged `OnRangedAttack`, global and per-item
  Lua callbacks, level-scaled modifiers/latents, active equipment spikes,
  NM hooks, action-result construction, and 0x028 serialization.
- Confirmed the global calculator owned HP mutation even though the family
  dispatcher also mutated HP. MP/TP drain calculation therefore also had an
  unintended HP side effect.

### Generated inventory and profile model

- Added a deterministic generator and tracked CSV/Markdown artifacts.
- Inventory currently covers 420 active or explicitly issue-scoped items:
  18 maintained Vanilla/Zilart and 402 `ERA_UNRESOLVED`.
- All 18 maintained entries are reachable and non-error. The repository-wide
  scan records 341 individual configuration findings and 122
  configuration-error rows instead of omitting them.
- Added a profile/sanity layer that leaves SQL as the numeric source and
  separates proc, accuracy/resistance, outcome, and presentation.
- Acid/Sleep alone resolve item-native A rank. Their INT argument is retained
  as `LEGACY_UNVERIFIED`; no dINT/no-dSTAT or ammunition-family formula was
  invented.
- Unsupported drains, combined-drain selection, Dispel, self-buff, Death,
  and related families resolve through explicit `VERIFY_LIVE` compatibility
  policy.

### Behavioral reproduction and production correction

The pre-correction focused run exited `1` and behaviorally reproduced:

- HP delta greater than the returned magical effect amount;
- two absorption evaluations;
- two nullification evaluations;
- ignored `NULL_BREATH_DAMAGE` because `isBreath` was read as `isBREATH`.

The corrected path makes calculation pure and applies the final HP outcome
exactly once. Absorption/nullification run once, packet amount equals the
actual HP delta/heal, MP/TP drains no longer inherit HP mutation, and the
breath flag is honored.

The new status regression exposed another inherited defect: a failed
non-overwriting `addStatusEffect` still returned a success message. It now
returns no additional-effect presentation.

### Behavioral coverage

- Real Sirocco Kukri melee actions serialize one 0x028 additional result per
  applied effect.
- Acid/Sleep real ranged states cover ammo consumption, distance handling,
  profile resolution, A-rank transport, status power/duration, and packet
  presentation.
- Direct production-path cases separate proc from resist and cover partial/
  full status resolution, immunity, resistance trait, effect nullification,
  opposing-boost removal, non-overwrite, Sleep, Defense Down, Poison, Blind,
  above-level items, and latent-derived eligibility.
- Physical-profile cases cover all/physical/ranged/breath nullification,
  physical/ranged absorption, and damage-type SDT.
- Seiryu/Zephyr, Genbu/Antarctic Wind, Suzaku/Arctic Wind, Byakko/East Wind,
  and Brigandish Blade/Buccaneer's Knife all pass, with wrong-item and
  unrelated-target negative cases.

### Validation

- Isolated database
  `xidb_codex_vz_combat_001_phase_a_20260725` was created, granted only to
  the existing local test account, and fully populated from current SQL.
  The owner's working `xidb` was not modified.
- Fresh MSVC/Ninja Debug configure: exit `0`.
- Focused `xi_test` target build: exit `0` (`906/906`).
- Pre-fix behavioral reproduction: exit `1`, with the four expected
  deterministic failures above.
- Corrected focused framework run: exit `0` (27/27 at that checkpoint).
- Real ranged run: exit `0` (3/3).
- Final combined additional-effect framework/ranged/NM repeat: exit `0`
  (39/39).
- Packet/status regression: exit `0` (74/74: all 65 `0x028` plus nine
  Shadowbind cases).
- Complete all-target Debug build: exit `0` (`148/148` remaining steps);
  `xi_connect`, `xi_search`, `xi_world`, `xi_map`, and `xi_test` linked.
- Inventory generation/check and maintained-profile sanity: exit `0`.
- Strict inventory audit: expected exit `1`, exposing all 341 recorded
  repository-wide configuration diagnostics.
- The disposable build directory, ten root executables/PDBs, isolated
  database and its two privilege rows, and issue-attachment cache were
  removed. The owner working `xidb` was not modified.

### Remaining Phase B and live-retail boundary

Exact item-specific damage/status numerics, governing stats, damage types,
drain accuracy/scaling/order, self-buff/Death/spikes formulas, and many item
introduction eras remain unresolved. These are now visible and classifiable,
but Phase A does not guess them or classify the complete finding as
corrected.

## 2026-07-26 — VZ-COMBAT-001 Phase B1 elemental arrows

### Evidence result

- Added a separate ledger for Fire Arrow 17322, Ice Arrow 17323, and
  Lightning Arrow 17324.
- A January 2004 Ranger guide and Japanese historical references support the
  item era and Fire/Ice/Thunder identities.
- No controlled retail packet log, damage dataset, or official formula was
  found. A March 2004 anecdote says roughly 5-10 damage and not every hit,
  conflicting with the inherited uniform 7-10 and implicit 100% behavior.
- An uncited Fire Arrow INT claim and a later Ice Arrow INT/MAB anecdote do
  not isolate INT, dINT, accuracy, MAB, or any multiplier. All unsupported
  numeric fields remain compatibility or `VERIFY_LIVE`.

### Profile architecture and production correction

- Added one validated scripted-damage registry for exactly the three Phase B1
  items. Each item retains explicit identity, element, subeffect, evidence
  classifications, proc/power/stat/resistance policy, multiplier policy, and
  unresolved fields.
- The three item scripts now contain only their real
  `onItemAdditionalEffect` bridge to the profile executor; numeric tables are
  not duplicated.
- Validation rejects missing/malformed policy, duplicate item IDs, wrong
  elements, unsupported later arrows, and unsupported proc/multiplier modes.
- The executor performs one compatibility proc path, one power roll, one
  resistance/nullification/absorption path, and one final HP mutation.
- A pre-correction reproduction found that the helper's returned amount could
  exceed the HP actually removed or restored at an HP cap. The Phase B1
  executor now reports the actual HP delta without altering unrelated
  scripted items.

### Behavioral coverage

- Twenty real ranged-state tests cover all three successful elemental packet
  results; ordinary miss; initial and mid-shot range failure; item-level
  suppression; target despawn; valid longer range; normal consumption;
  Recycle; Unlimited Shot; and Enspell priority.
- Twenty-seven direct profile tests cover exact scope and validation,
  duplicate registration, proc pass/fail boundary, 7-10 boundaries,
  actor/target INT and MAB compatibility, all configured resist tiers and the
  floor, skill/stat/macc transport, general/elemental/staff/affinity/
  day-weather multipliers, defenses, per-element null/absorb, and exact
  damage/healing at HP caps.
- The existing Phase A group passed 39/39 after the clean build, including
  Acid/Sleep Bolt and all maintained NM hooks. The complete `0x028` packet
  regression passed 65/65.

### Validation and cleanup

- Fresh MSVC/Ninja Debug configure: exit `0`.
- Clean `xi_test` build: exit `0` (`906/906`).
- Remaining all-target build: exit `0` (`148/148`); all five executables
  linked.
- Final Phase B1 focused run: exit `0` (47/47).
- Inventory generation/check/profile sanity, deterministic two-run hashes,
  Lua sanity/style, Black, pylint, C++ formatting, and `git diff --check`
  passed.
- Production/tests commit:
  `2ea1af27a86c2852bf3760e47301139fe91a99f1`.
- Evidence/inventory commit:
  `9ec608cbfc61686bfebcb4ae1cee53ac4407f24e`.
- Removed the disposable build, ten staged executables/PDBs, isolated
  `xidb_codex_vz_combat_001_b1_20260726`, both grants, and temporary logs.
  The owner's working `xidb` was not modified.

### Remaining boundary

Fire/Ice/Lightning Arrow are hardened and profiled, not claimed
retail-formula-correct. Proc rate, 7-10 distribution, governing stats,
accuracy/rank, resistance tiers, MAB, staff/affinity/day-weather, defense
interactions, and exact client presentation need controlled live evidence.
Phase B2 must remain a separate bounded family/configuration pass and must not
copy this compatibility policy to later elemental arrows without evidence.

## 2026-07-28 — VZ-COMBAT-001 Phase B1 RNG lifecycle hardening

### Reproduction

- Added lifecycle counters around the real scripted profile executor before
  changing production.
- The pre-correction focused run exited `1` with 48/51 passing. Exactly three
  cases failed: failed proc, full nullification, and below-floor resistance
  each consumed the eagerly evaluated 7-10 power roll.
- Successful resolution, direct numeric base-power handling, and all 20 real
  ranged arrow cases already passed, isolating the defect to power-roll
  ordering.

### Correction

- `executeAddEffectDamage` now accepts either its existing numeric base power
  or a zero-argument resolver and invokes the resolver once at the existing
  damage-calculation point.
- `executeScriptedDamageProfile` supplies the existing uniform 7-10 roll as
  that resolver. Proc chance remains owned by the shared helper and is not
  bypassed or replaced with 100%.
- The resulting order is: parameter validation, existing preconditions, one
  proc roll, nullification, resistance-floor rejection, absorption
  classification, one power roll when needed, and one outcome application.
- No proc chance, power range, stat, accuracy, resistance, multiplier,
  defense, element, presentation, or ammunition policy changed.

### Validation

- Pre-correction focused reproduction: expected exit `1` (48/51).
- Corrected focused run and final post-format/post-build repeat: exit `0`
  (51/51 each).
- Phase A/Acid/Sleep/NM regression group: exit `0` (39/39).
- Complete `0x028` battle-action packet group: exit `0` (65/65).
- Catch2 on every `xi_test` invocation: 19/19 and 9,007,079 assertions.
- Fresh MSVC/Ninja Debug configure: exit `0`.
- Resumed clean `xi_test` target build after a host crash: exit `0`
  (263 remaining steps); the complete target linked successfully.
- Complete remaining all-target Debug build: exit `0` (148/148).
- Changed Lua passed repository binding, purity, `luacheck`, and style checks;
  `git diff --check` passed.

The host crash interrupted only disposable compilation and did not alter the
branch, tracked diff, isolated database, or test evidence. No C++, Python,
SQL, inventory, profile numeric, or human-only evidence file changed.
Credential and process-environment values remained in process memory: no
environment dump, credential value, token, password, connection string, or
secret-bearing command argument was printed or persisted.

## 2026-07-28 — VZ-COMBAT-001 Phase B2 status ammunition

### Evidence and scope

- Bounded production scope: Kabura Arrow 17325, Patriarch Protector's Arrow
  17329, Blind Bolt 18150, Venom Bolt 18152, Poison Arrow 18157, Sleep Arrow
  18158, Demon Arrow 18159, and Spartan Bullet 18160.
- Read issue #7899 and all comments through the public GitHub CLI, reviewed
  all seven public image/log attachments, searched accessible historical,
  Japanese, and modern community references, and added a ranked per-item
  evidence ledger.
- Effect identities are supported. No controlled eight-item dataset resolves
  proc, level correction, rank/stat, action element, power, duration, or
  resist tiers. Acid/Sleep Bolt's controlled A-rank evidence was not copied.
- Spartan evidence conflicts: Japanese summaries describe an approximately
  30-second target-wide Spartan-only lockout; dated FFXIAH comments report
  55/132 or a first-eligible-shot/10-20-second model; issue logs support a
  modern cooldown hypothesis and roughly four-to-five-second visible Stun.
  The exact cooldown was not guessed.

### Reproduction and correction

- The inherited DEBUFF handler selected/removes opposing boosts before the
  authoritative status-container call.
- A caller-path regression drives every earlier guard successfully, forces
  authoritative application rejection, and reproduces the pre-correction
  false removal.
- Status policy lookup is now pure. The handler performs one application,
  returns no result/removal on rejection, and removes the opposing boost
  exactly once only after success.
- No SQL, proc, level, rank/stat, element, power, duration, resist, overwrite,
  presentation, or Spartan cooldown value changed.

### Profile, tests, and inventory

- Added a validated `VZ_STATUS_AMMUNITION` registry with exactly eight item
  identities, SQL-compatibility fields, field-level evidence
  classifications, and an explicit unresolved Spartan policy.
- Validation rejects duplicates, malformed/drifted entries, Acid/Sleep
  migration, and later Gashing/Abrasion/Oxidant ammunition.
- Added 49 focused cases: 22 real ranged cases and 27 direct/profile cases.
  All eight real successful shots serialize one matching status and consume
  one ordinary shot; all eight physical misses perform zero status work.
  Representative range/despawn/level/Recycle/Unlimited Shot cases pass.
- Direct cases cover exact scope, malformed/duplicate/later IDs, Acid/Sleep
  separation, one proc roll, every configured proc boundary, zero
  post-failure work, every item's guards and full/half/below-floor outcome,
  full/half/quarter/eighth/zero representative resist results,
  A-rank/INT/element transport, all eight power/duration/tick values,
  authoritative rejection, and one post-success boost removal.
- The generated inventory now records profile family and machine-readable
  field classifications. The eight scoped rows use precise status-owned
  subeffect names; unrelated subeffect-18 rows retain an explicit shared
  label. Generation/check and exact-profile sanity report 420 rows, 18
  maintained V/Z profiles, and the unchanged 341 repository-wide diagnostics.

### Validation and cleanup

- The focused Phase B2 group passed 49/49; the final shared-framework plus
  Phase B2 repeat passed 79/79. Phase A/Acid/Sleep/NM passed 40/40, Phase B1
  passed 51/51, and the complete 0x028 group passed 65/65. Catch2 passed
  19/19 with 9,007,079 assertions on every invocation.
- Lua sanity for all seven changed Lua files, Python Black/pylint, inventory
  generation/check, profile sanity, and `git diff --check` passed.
- Fresh MSVC/Ninja Debug configure and `xi_test` build passed; the complete
  all-target build finished its remaining 148/148 steps.
- Two inventory writes were deterministic:
  CSV `6B1FC13D5090DC3F0B09F2592AB3BE7B243EC163225E1C37A23A3F38B193B16D`
  and Markdown
  `26CEC1575F390103C43AB4A6B4E64D10D6C1F9037EB2B28211C5FE873F1A6F53`.
- The disposable build, root executables/PDBs, isolated MariaDB process/data,
  and downloaded public-evidence cache were removed. The owner's `xidb` was
  untouched.
- Changed-file secret-pattern scanning found no PAT, JWT, signed query,
  assigned secret, or embedded remote credential. Shell commands printed
  environment-variable names only, not values. During evidence retrieval the
  GitHub connector itself returned short-lived signed attachment parameters
  in a transient tool response; they were not echoed into shell output,
  written to project files, committed, or retained in the deleted cache.

### Phase assessment

Phase B2 is `PARTIAL`: the framework, profile, real ranged path, inventory,
and evidence boundary are hardened, but the eight items are not claimed
retail-formula-correct and Spartan's missing cooldown remains explicit.
Phase B3 should select a separate bounded family, preferably maintained
drains.

## 2026-07-28 — VZ-COMBAT-001 Phase B3 single-resource drains

### Evidence and bounded scope

- Scoped exactly Aspir Knife 16509 (MP), Bloody Rapier 16528 (HP), and
  Shinsoku 17823 (TP). Combined drains, scripted drains, later items,
  Dispel, Death, self-buffs, spikes, Elemental Spirits, and Ballista were
  excluded.
- Added a ranked evidence ledger using contemporary English discussion,
  dated update records, Japanese references, modern item summaries, and
  explicit inaccessible-source notes.
- Effect identities are supported. Bloody Rapier is classified Vanilla and
  Shinsoku Zilart; Aspir Knife's 2003 evidence does not distinguish original
  release from Zilart, so its introduction remains `ERA_UNRESOLVED`.
- No controlled retail dataset resolves proc/level correction, fixed/random
  amount, skill/accuracy/stat/dSTAT, Dark element, resistance/multipliers,
  defenses, resource caps, undead, priority, or exact packet presentation.
  The existing 10%/3, 5%/10, and 8%/10 policies remain compatibility and
  `VERIFY_LIVE`.

### Reproduction and production correction

- A pre-change direct Shinsoku result removed 10 TP but serialized subeffect
  0 because SQL lacked `ITEM_SUBEFFECT`. The generic handler's hardcoded Dark
  element also concealed missing element data.
- Added Shinsoku `TP_DRAIN` and explicit Dark SQL data. Corrected the stale
  SQL comment from 5% to the already-active 8%; no numeric changed.
- Added one validated `VZ_SINGLE_RESOURCE_DRAIN` registry with exact
  per-item identity, resource, proc/level/equip, formula/multiplier,
  cap/application, presentation, field-classification, and unresolved-
  evidence policy.
- Added one exact-scope executor that rejects dead/undead targets, calculates
  once, clamps negative compatibility results, caps removal to actual target
  resource, mutates target once, credits attacker once, and reports actual
  HP/MP/TP removed.
- Combined and scripted handlers remain on the inherited generic/script
  paths. Existing Enspell/item priority and one-result-per-swing ownership
  remain unchanged.

### Tests, inventory, and validation

- Added 58 focused cases across direct profiles and real melee state/action/
  0x028 paths. They cover exact scope and validation, proc/level boundaries,
  one calculation and transfer, every resource/cap boundary, resistance
  tiers and rounding, defenses/null/absorb, dead/undead, MP/TP isolation,
  main/off hand, miss, despawn, priority, multi-attack, and ordinary melee.
- A test observer records values immediately around the real executor to
  avoid unrelated world regeneration while preserving the real state,
  handler, mutation, and packet paths.
- The generated inventory maps all three items to the exact profile and both
  tests, emits field policies/classifications/evidence, and continues to
  exclude combined/scripted/later drains.
- Focused Phase B3 passed 58/58 after correcting the observer to preserve all
  three Lua return values. Catch2 passed 19/19 and 9,007,079 assertions on
  each invocation.
- Full regression, formatting, deterministic-generation, SQL/import,
  clean MSVC/Ninja configure, `xi_test`, all-target build, cleanup, and final
  Git results are recorded in `CODEX_COMPLETION_REPORT.md`.

### Phase assessment

Phase B3 is `COMPLETE_PHASE_B3` as a bounded profile/framework pass, not as a
retail-formula claim. `VZ-COMBAT-001` remains partial. Phase B4 should select
the maintained combined HP/MP and HP/MP/TP drain group as a separate pass and
must retain every unresolved field until controlled retail evidence supports
a correction.

## 2026-07-29 — VZ-COMBAT-001 Phase B4 combined-resource drains

### Starting state and mandatory aggregate

- Synchronized the GitHub Desktop repository at
  `ceea3840fd780e95dabf41cc0d44df3a83037959` on the required branch; origin
  was the fork, upstream push was disabled, recursive submodule fetch was
  disabled, and the worktree was clean.
- Created a disposable MariaDB database and fresh MSVC/Ninja Debug test
  build. The owner's working `xidb` and ForgeRaid paths/services were not
  used.
- The mandatory six-selector aggregate reproduced the previously unexplained
  failure as a Windows access violation at case 76/198.
- Binary splits isolated the trigger to loading the NM file after earlier
  elemental-arrow profile tests. Stacked Lua doubles on one path were
  restored by type/in installation order, leaving a Lua global pointing at a
  freed earlier stub; the extra file changed heap reuse and exposed it.
- `MockManager` now tracks one combined installation order and restores
  doubles in reverse before freeing them. Lua framework regressions cover
  stacked stub/stub and stub/spy paths. Focused framework tests passed 9/9;
  the corrected mandatory pre-B4 aggregate passed 198/198 in one process.
- The isolated harness correction was committed separately as
  `ed17e640af test: restore stacked Lua doubles safely`.

### Evidence and exact scope

- Scoped exactly Hofud 17745, Vampirism 20706, and Crepuscular Knife 21585.
  No scripted drain, unrelated combined drain, Dispel, absorb-status, Death,
  self-buff, spikes, Elemental Spirits, Ballista, or other area was migrated.
- Independent sources establish the three items as 2007, 2015, and 2021
  `LATER_EXPANSION`; the maintained Vanilla/Zilart count remains 18.
- Added a ranked evidence ledger with independent item and HP/MP versus
  HP/MP/TP architecture sections. Public mechanics claims are uncontrolled
  and conflict materially for Crepuscular selection/proc/amount behavior.
- No SQL numeric changed. The active 15%/15, 100%/20, and 15%/15 policies,
  uniform branch selection, no retry, legacy Dark calculation, caps,
  multi-attack eligibility, and presentation remain compatibility/
  `VERIFY_LIVE`.

### Architecture and tests

- Added exactly three validated `VZ_COMBINED_RESOURCE_DRAIN` profiles with
  item/era/resource/proc/level/equip, selection/timing/retry, formula/
  resistance/null/absorb/undead, amount/caps/defenses, outcome/presentation,
  field-classification, and unresolved-evidence ownership.
- Added a single combined selection owner. Proc failure makes zero selection
  rolls; success maps HPMP 1/2 to HP/MP and HPMPTP 1/2/3 to HP/MP/TP, selects
  once, and never retries another branch.
- Factored the B3 one-resource mutation into a shared transfer primitive
  without combining the B3 and B4 registries. It calculates and transfers
  one selected resource, reports actual target removal, and clamps negative
  absorption to zero.
- Added 55 focused B4 cases covering exact scope/validation, all eight
  item/branch combinations, proc/selection/calculation cardinality, every
  resource and attacker boundary, resistance tiers, null/absorb, empty/dead/
  invalid/undead/no-retry, isolation, and real main/off-hand/miss/level/
  despawn/Enspell/multi-attack/ordinary-melee 0x028 behavior.
- The first focused run passed 51/55. One fixture incorrectly mutated
  Vampirism's authoritative 100% profile, correctly triggering drift
  validation; three HP assertions assumed a fixed max HP instead of the
  job-derived value. The corrected focused run passed 55/55. No production
  defect was hidden.
- Final review found that a missing resource-message table could raise while
  validating a malformed profile. Validation now reports the malformed
  resource mapping cleanly, with a focused regression; valid profile
  execution is unchanged.
- The Phase B3 assertion intentionally changed only to recognize the separate
  combined registry; its complete external regression still passed 58/58.
- The final post-build repeats passed B4 55/55, B3 58/58, and the mandatory
  six-selector aggregate 198/198 (132.916 seconds). Earlier focused groups
  passed B2 49/49, B1 51/51, Phase A 40/40, and 0x028 65/65. Catch2 passed
  19/19 with 9,007,079 assertions on every invocation.

### Inventory and phase result

- Extended generation and exact-scope sanity with three
  `LATER_EXPANSION` rows, verified SQL chance/amount/family/subeffect,
  resource-set mapping, exact handler/test/evidence references, no unrelated
  migration, and all required unresolved fields.
- Two consecutive writes were identical: CSV
  `D93DF1289C3A936C5FD0556176DEED9170F38B930548CB4F82E64BEAD205D11F`
  and Markdown
  `9240CA8BC15F540B5FE6CE97F5500FC7A208C4F6F3763EA9EC8CCADFB4D0A174`.
  Generation/check and profile sanity report 420 rows, 18 maintained V/Z
  profiles, three later-expansion combined profiles, and the unchanged 341
  repository-wide diagnostics.
- Phase B4 is `COMPLETE_PHASE_B4` as a bounded shared-core framework/profile
  pass. The items are not retail-formula-correct and `VZ-COMBAT-001` remains
  partial.
- Fresh MSVC/Ninja Debug configuration passed; `xi_test` built 906/906 and
  the remaining all-target build passed 148/148. Changed-Lua style/purity,
  Black, pylint, C++ clang-format, profile sanity, deterministic generation,
  and `git diff --check` passed. No SQL changed.

## 2026-07-29 — VZ-COMBAT-001 Phase B5 Dispel weapons

### Starting state, scope, and evidence

- Resumed the intentional in-progress checkpoint at
  `f9ef4966f9487c2c719ca6d7158919ce6c741d1d` on
  `retail-parity/codex-vanilla-zilart`. The fork origin and disabled upstream
  push were confirmed without fetching, pulling, checking out, cleaning, or
  resetting the worktree.
- Scoped exactly Lockheart 16944, Mythril Heart 16950, and Mythril Heart +1
  16951. Balmung 16942, Claustrum 18330, Zanmato +1 21966, and every other
  Dispel configuration remain outside the Phase B5 registry.
- Dated 2004 evidence directly gates Lockheart and Mythril Heart to
  `VANILLA_OR_ZILART` with high confidence. Mythril Heart +1 is moderate-
  confidence through a narrow shared-recipe inference; no direct dated
  pre-CoP record naming the +1 was found.
- The evidence ledger distinguishes era/effect identity from formulas.
  Community records support the Dispel identity, but no controlled retail
  packet log, counted trial dataset, or reliable formula evidence was found.
- SQL remains unchanged: Dispel family 10, 5%/10%/10% proc chances, and zero
  level correction. Selection, protected categories, retry, accuracy,
  resistance, element/stat non-ownership, and exact presentation remain
  compatibility/`VERIFY_LIVE`.

### Reproduction, architecture, and tests

- Real pre-correction main-hand tests reproduced a deterministic silent-
  removal defect for all three weapons: `dispelStatusEffect()` removed
  Protect, but absent SQL subeffect data caused no normal 0x028 additional
  result after the target had already been mutated.
- Added exactly three validated `VZ_DISPEL_WEAPON` profiles. A successful
  authoritative removal supplies `xi.subEffect.DARKNESS_DAMAGE`,
  `ADD_EFFECT_DISPEL`, and the actual removed effect ID; no SQL or formula
  changed.
- Preserved one uniform status-container selection among positive-duration
  `Dispelable` effects, exactly one removal, and no retry. False, nil,
  `xi.effect.NONE`, negative, empty, protected, permanent, dead, and invalid
  outcomes produce no additional-effect result.
- Added 31 focused cases covering exact scope/validation and SQL drift, proc
  boundaries, selection/removal cardinality, effect-ID transport, protected
  and no-effect paths, and real main-hand/miss/level/despawn/Enspell/multi-
  attack/ordinary-melee 0x028 behavior.
- The initial Phase A run after the new profiles passed 39/40 because its
  explicit compatibility assertion still expected legacy `SINGLE` policy.
  The test-only expectation was updated for the three Dispel profiles and
  repeated at 40/40.
- The mandatory pre-edit aggregate had one intermittent B2 target-despawn
  failure at 197/198. Its focused retry and full aggregate repeat passed
  before production edits; no behavior change was made for it.

### Validation, inventory, and phase result

- Fresh MSVC/Ninja Debug validation completed: `xi_test` had already built
  906/906, and the remaining all-target build passed 148/148 while linking
  `xi_connect`, `xi_map`, `xi_search`, and `xi_world`.
- A restart of the Phase-B5-only disposable MariaDB exposed invalid empty
  trigger definers in that disposable schema. Reloading the current
  repository trigger and recipe SQL repaired only the disposable test
  database; fixture rows were removed, the owner's working database and
  services were untouched, and no project SQL changed.
- Final B5 passed 31/31; the seven-selector item aggregate passed 284/284 in
  193.550 seconds; the complete 0x028 suite passed 65/65 in 55.941 seconds.
  Catch2 passed 19/19 with 9,007,079 assertions on each invocation.
- Deterministic inventory output contains 420 rows, 21 maintained
  Vanilla/Zilart profiles, three exact Dispel profiles, and 341 unchanged
  repository-wide diagnostics. Two consecutive writes matched:
  CSV `FA157E41618D74F41F4F70493842AA9AE2E50A85A5122720E93E229B0160BE2D`
  and Markdown
  `8F647BB1A90644785B30AC7B288180C45ECBE4A627D44876102DB6B7702E5BEF`.
- Inventory generation twice, `--check`, profile sanity, the repository Lua
  style/binding/purity check, Black, pylint errors-only, and
  `git diff --check` passed. The verified Phase B5 disposable database,
  build directories, and generated root executables/PDBs were removed; the
  owner's database remained untouched.
- The source/test implementation was committed as
  `c450ce872011c10e7f2f6dc9881f6762f5d3ca2c`
  (`feat(retail-parity): profile VZ Dispel weapons`).
- Phase B5 is `COMPLETE_PHASE_B5` as a bounded evidence/profile/framework
  pass, not a retail-formula claim. `VZ-COMBAT-001` remains partial. Phase B6
  should separately evidence-gate Balmung, Claustrum, and every other
  remaining Dispel configuration rather than generalizing this registry.

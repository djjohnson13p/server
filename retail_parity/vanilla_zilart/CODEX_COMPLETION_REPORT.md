# Codex Completion Report — Vanilla + Rise of the Zilart

Status: BOUNDED_PASS_COMPLETE_PROJECT_IN_PROGRESS

## Branch and source state

- Repository: `djjohnson13p/server`
- Work branch: `retail-parity/codex-vanilla-zilart`
- Current bounded-pass starting commit: `f9ef4966f9487c2c719ca6d7158919ce6c741d1d`
- Pinned upstream baseline: `242ab0d055dfb80396e7398b0dd7361b750c74e2`
- Upstream pull requests: none; prohibited
- Upstream push: disabled/prohibited

The bounded `VZ-COMBAT-001` Phase B5 pass is complete as an evidence/profile/
framework pass. Lockheart, Mythril Heart, and Mythril Heart +1 now use one
exact-scope Dispel registry. Successful removal has deterministic
presentation ownership and reports the actual removed effect ID with direct
and real-melee packet coverage.

The overall finding remains partial. The three scoped items are gated to
Vanilla/Zilart, but no controlled retail formula was found. Their configured
proc values, uniform eligible-status selection, no-retry policy, protected
categories, lack of accuracy/resistance/element/stat layers, and exact client
presentation remain explicit compatibility/`VERIFY_LIVE`, not retail
conclusions.

## Commits created

- `2ea1af27a86c2852bf3760e47301139fe91a99f1` —
  `feat(retail-parity): profile elemental arrow effects`
- `9ec608cbfc61686bfebcb4ae1cee53ac4407f24e` —
  `docs(retail-parity): inventory elemental arrow evidence`
- `2f3d6fe5c33f1ac0eceba0b8efc7bedc51a38a00` —
  `fix(retail-parity): correct item additional-effect framework`
- `1684e6fd9a836db206e7d3504edca27aa3735e73` —
  `feat(retail-parity): inventory item additional effects`
- `9a917a7b542e2840d6c092ecaa6a8e4122dfb3de` —
  `test(retail-parity): pin drain compatibility profiles`
- `b98b576c95f27c8882e5401eea67b0716f01f6dc` —
  `fix(retail-parity): own mob-skill start messages in state`
- `94acc4f249c5db5b3b892f508bee3c3de7099178` —
  `test(retail-parity): migrate humanoid ready-message checks`
- `a5bdb74c3b7511a2f098a3dc28336cf70f91dafd` —
  `fix(retail-parity): safely interrupt fishing on attack`
- `58c30fd5ecaa6eb1b1c85f76c55c5b384fe21a27` —
  `test(retail-parity): validate fishing and conquest fixes`
- `9e989c2c97395bcfef7828e339a80c49c91161dd` —
  `fix(retail-parity): harden call for help eligibility`
- `3ef3475a9acb453fdb2ec54d68ced757ae5ded21` —
  `test(retail-parity): validate Shadowbind behavior`
- `01bb2d6556df17fcb4e26851b9b9202adb445bdf` —
  `test(retail-parity): validate Uggalepih door keys`
- `ed17e640af9ea3d133839d9cce651bc89ed8cb31` —
  `test: restore stacked Lua doubles safely`
- `4969a50bae343cf21745976ee486d38b053f5372` —
  `feat: profile combined resource drain effects`
- `c450ce872011c10e7f2f6dc9881f6762f5d3ca2c` —
  `feat(retail-parity): profile VZ Dispel weapons`

The documentation/state commit follows these source/test commits.

## Tests added by finding

### `VZ-CORE-002`

`scripts/tests/systems/fishing/attack_transition.lua` adds eight real
packet/state cases for:

- waiting/no-bite interruption and exactly-once cleanup before engagement;
- hooked fish interruption at the latest controllable pre-reward boundary;
- exact waiting/hooked bait rules, rod preservation, no catch, and no skill-up;
- reserved fishing-monster release and no stale spawn;
- duplicate Attack, late fishing input, wrong-phase input, duplicate
  CheckHook, malformed stamina, and repeated release;
- invalid entity index, self target, out-of-range target, and despawned target
  preserving the original fishing session;
- ordinary release plus fresh-token recovery;
- post-combat fishing recovery, unchanged non-Attack fishing restrictions,
  and unchanged ordinary non-fishing Attack.

The Lua harness now emits real Fish, Attack, AttackOff, and fishing-minigame
packets and exposes read-only session state. Its controlled hooked-state
fixture can only advance an existing valid waiting session; it cannot start a
session or grant a reward.

### `VZ-ZONE-001`

`scripts/tests/zones/temple_of_uggalepih_doors.lua` adds five interaction
cases for:

- exact Uggalepih Key acceptance, consumption, key-break message, and opening;
- wrong and non-exact trade rejection without consumption;
- `_mf9` locked-side Uggalepih Key message;
- unchanged `_mf8` Prelate Key consumption/opening/messages;
- both existing unlocked-side coordinate checks.

### `VZ-ECON-001`

`src/test/tests/fishingutils_tests.cpp` calls the production moon-dispatch
seam for patterns 4 and 5 across all eight defined moon phases and proves the
curves remain independent.

### `VZ-ECON-002`

The same Catch2 file proves Waders, Fisherman's Boots, and Angler's Boots
survive the production feet filter, reach their configured lucky-timing
branches, and unrelated feet remain filtered.

### `VZ-ECON-003`

`src/test/tests/conquest_system_tests.cpp` covers 0%, 10%, 100%, small and zero
awards, a negative modifier, and explicit fractional truncation. Production
still passes only the adjusted point value into the unchanged
nation/region/IPC aggregation path.

### `VZ-JOB-002`

`scripts/tests/jobs/rng/abilities/shadowbind.lua` adds nine action-path cases
for:

- success and `IS_EFFECT`;
- controlled failure and `JA_MISS`;
- existing Bind;
- immunity, resistance-trait, and nullification guards;
- ammo consumption on success/failure;
- Unlimited Shot ammo preservation and effect consumption;
- Ranger level-39 rejection;
- Ranger subjob level-40 availability.

The Lua simulation player factory now accepts optional `sjob`/`slevel`
parameters for the subjob action test.

### `VZ-CORE-001`

`scripts/tests/systems/combat/call_for_help.lua` adds nine real Help-action
cases for:

- one eligible mob with no active target;
- multiple eligible mobs and one success message;
- retained enmity after unclaim;
- party claim without/with requester CE or VE;
- pet claim without/with master CE or VE;
- already-enabled and explicitly blocked mobs with one failure message;
- battle-ID and confrontation boundaries.

`src/test/tests/battleutils_tests.cpp` directly covers the production instance
identity seam for non-instanced, same-instance, and different-instance
entities.

## VZ-CORE-002 defects discovered and corrected

- Removing the Attack blocked-state flag alone would leave the character's
  response, token, animation, and hooked monster alive during engagement.
  Attack now interrupts through one authoritative helper only after ordinary
  engagement validation succeeds.
- The existing interruption did not invalidate the fishing token/cast state.
  It is now idempotent, invalidates token/state, preserves existing
  waiting/hooked bait rules, destroys the response, unhooks the monster,
  clears animation, and sends the existing release packet once.
- The fishing packet handler accepted CheckHook, EndMiniGame, and Timeout
  outside their lifecycle phases. It now requires an active session, correct
  animation phase, live response, hook state, and matching nonzero token.
- StartFishing allocated response/token state before active animation and
  rod/bait validation and used a random value that could be reused. Allocation
  now happens after validation with a fresh nonzero per-character sequence.

## VZ-CORE-002 exact validation commands and results

### Fresh configure

```text
cmd.exe /d /s /c 'call "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\Common7\Tools\VsDevCmd.bat" -no_logo -arch=x64 -host_arch=x64 && cmake -G Ninja -S . -B build-codex-vz-core-002 --fresh -DCMAKE_BUILD_TYPE=Debug -DENABLE_CLANG_TIDY=OFF -DTRACY_ENABLE=OFF -DPCH_ENABLE=OFF -DCACHE_OPTION=sccache'
```

Result: exit `0`; CMake `4.3.3`, Ninja generator, MSVC `19.44.35228`,
x64 Debug.

### Focused test target

```text
cmd.exe /d /s /c 'call "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\Common7\Tools\VsDevCmd.bat" -no_logo -arch=x64 -host_arch=x64 && cmake --build build-codex-vz-core-002 --target xi_test'
```

Result: exit `0`; the fresh build linked `xi_test` at `905/905`. The
post-fixture incremental rebuild also exited `0`.

### Isolated test database

The owner database was not modified. A disposable
`xidb_codex_vz_core_002_20260725162306` was created with:

```text
python tools\dbtool.py setup xidb_codex_vz_core_002_20260725162306
```

Result: exit `0`; repository SQL imported successfully. Existing credentials
were passed only through process environment/arguments and were not printed
or stored in the repository.

### Focused Catch2 and Lua

```text
.\xi_test.exe --keep-going --file attack_transition
```

The successful runs used `XI_MAP_FISHING_ENABLE=true` plus
`XI_NETWORK_SQL_*` for the disposable database.

Final result: exit `0`.

- Catch2: 16/16 cases and 9,007,070 assertions passed.
- Focused Lua: 8/8 cases in two suites passed.
- A second final focused run also passed 8/8 after formatting and the complete
  build.

### Lua style

```text
python tools\ci\sanity_checks\lua_stylecheck.py scripts\tests\systems\fishing\attack_transition.lua
```

Result: exit `0`.

### C++ formatting

```text
C:\Program Files\LLVM\bin\clang-format.exe -i --style=file <all modified C++ and header files>
```

Result: exit `0`; clang-format `22.1.8`.

### Complete Debug build

```text
cmd.exe /d /s /c 'call "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\Common7\Tools\VsDevCmd.bat" -no_logo -arch=x64 -host_arch=x64 && cmake --build build-codex-vz-core-002'
```

Result: exit `0`; all remaining `151/151` steps passed and `xi_connect`,
`xi_map`, `xi_search`, `xi_world`, and `xi_test` linked. The final
post-format all-target check also exited `0`.

### Diff and cleanup

```text
git diff --check
```

Result: exit `0`.

- `build-codex-vz-core-002`: removed.
- Generated root `xi_*.exe`/`xi_*.pdb`: 10 files removed.
- Disposable database: dropped and confirmed absent.
- Working local `xidb`: not modified.

## VZ-CORE-002 intermediate failures resolved

- The first command-shell attempt quoted `VsDevCmd.bat` incorrectly and exited
  `1` before CMake. The corrected `cmd.exe /d /s /c 'call "..." ...'`
  invocation configured successfully.
- `dbtool.py update` on an empty database exited `1` after importing only
  express tables; migration 006 reported missing `spell_list`. The disposable
  database was dropped and recreated through the supported
  `dbtool.py setup <database>` path.
- The first Lua run exited `1`: all eight cases reached the repository default
  `map.FISHING_ENABLE=false` and reported `Fishing is currently disabled`.
  Reruns used the explicit test override.
- The first enabled run exited `1` with 4/8 passing. Two fixtures used the
  nonexistent `MOAT_CARP` constant, and immediate recovery hit the real cast
  recast. The fixture now uses `MOAT_CARP_1`; the generic Fish packet helper
  makes only the test recast ready while retaining every production
  validation. Both final runs passed 8/8.

## Defect discovered and corrected

The inherited Call-for-Help implementation accepted requester ID membership
in an enmity container. A focused claim-transition case demonstrated that
stale personal enmity could remain after a mob became unclaimed. The action
could therefore mark an unclaimed mob.

Eligibility now requires:

- a live mob not already help-enabled or blocked;
- matching confrontation, battlefield, instance, and battle ID;
- a current requester/party/alliance claim through `HasClaim`;
- positive requester CE or VE.

The action still iterates through `ForEachMobInstance`, changes every eligible
mob, and sends exactly one success or failure message.

## Prior inherited-correction validation commands and results

### Fresh configure

```text
call "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\Common7\Tools\VsDevCmd.bat" -no_logo -arch=x64 -host_arch=x64 && cmake -G Ninja -S . -B build-codex-validation --fresh -DCMAKE_BUILD_TYPE=Debug -DENABLE_CLANG_TIDY=OFF -DTRACY_ENABLE=OFF -DPCH_ENABLE=OFF -DCACHE_OPTION=sccache
```

Result: exit `0`; CMake `4.3.3`, Ninja generator, MSVC
`19.44.35228.0`, x64 Debug.

### Test executable build

```text
call "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\Common7\Tools\VsDevCmd.bat" -no_logo -arch=x64 -host_arch=x64 && cmake --build build-codex-validation --target xi_test
```

Result: exit `0`. The final post-format rebuild completed `26/26` steps and
linked `xi_test.exe`.

### Isolated current-schema test database

The installed local `xidb` was not modified because it lacked the current
`mob_resistances.stun_res_rank` column. A uniquely named disposable database
was created and populated with current repository SQL:

```text
python tools\dbtool.py update
```

The command ran with `XI_NETWORK_SQL_*` pointing to
`xidb_codex_validation_20260725_1435` and the existing local `xi` account.
Result: exit `0`; all SQL files imported and no migrations remained.
Credentials were never printed or stored in repository files.

### Focused Catch2 and Lua run

```text
.\xi_test.exe --keep-going --file shadowbind --file call_for_help --file temple_of_uggalepih_doors
```

Result: exit `0`.

- Catch2: 16/16 test cases, 9,007,070 assertions passed.
- Lua: 23/23 tests in six suites passed.
- Final Lua duration: 19.239 seconds.

### Lua style

```text
python tools\ci\sanity_checks\lua_stylecheck.py scripts\tests\jobs\rng\abilities\shadowbind.lua scripts\tests\systems\combat\call_for_help.lua scripts\tests\zones\temple_of_uggalepih_doors.lua
```

Result: exit `0`.

### C++ formatting

Modified/new C++ and header files were formatted with:

```text
C:\Program Files\LLVM\bin\clang-format.exe -i --style=file <modified C++ files>
```

Version: `clang-format 22.1.8`.

### Complete Debug build

```text
call "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\Common7\Tools\VsDevCmd.bat" -no_logo -arch=x64 -host_arch=x64 && cmake --build build-codex-validation
```

Result: exit `0`. The complete all-target pass finished `148/148` remaining
steps after the focused test target and linked `xi_connect`, `xi_world`,
`xi_search`, and `xi_map`. The final post-format all-target check also exited
`0` and relinked the affected world/map executables.

### Diff validation

```text
git diff --check
```

Result: exit `0`. Git emitted only expected line-ending notices for files
whose checkout normalization is configured by the repository.

### Cleanup

- `build-codex-validation`: removed.
- Generated root `xi_*.exe`/`xi_*.pdb`: removed.
- `xidb_codex_validation_20260725_1435`: dropped and confirmed absent.
- Working local `xidb`: not modified.

## Intermediate failures resolved

- The first test compile found missing `fishingutils::` qualifiers in the new
  Catch2 translation unit. The test was corrected; the next build passed.
- The first local Lua attempt could not authenticate with the default
  `root/root` settings. The repository's existing local `xi` credentials were
  used without disclosure.
- The working local `xidb` was schema-stale. It was left untouched and replaced
  for testing by the disposable current-schema database.
- Initial Lua fixtures exposed out-of-range Shadowbind targeting, wrong
  locked-door-side positioning, and unsafe repeated Help actions in one
  party/pet fixture. The fixtures were corrected to model the real action
  paths.
- A manufactured cross-instance live-enmity fixture proved unsafe and was
  removed. Instance identity is covered through the production C++ boundary
  seam; the action itself remains scoped by `ForEachMobInstance`.

## VZ-BF-001 completion evidence

### Architecture and migration

- Added a one-time `CState::Enter()` lifecycle seam invoked after successful
  container installation.
- `CMobSkillState` now emits configured starts only from that seam. A
  zero-time state sends its start, spends TP, and completes immediately in
  the same update; positive-time timing and interruption remain unchanged.
- Added `mob_skill_start_messages` with backward-compatible default,
  explicit no-start, explicit message, and pool override semantics.
- Migrated 17 active Lua scripts representing 21 standard-ready skill IDs.
  The stale Aeolian Edge comment was removed.
- Added six explicit no-start pool policies for Qu'Bia Arena Trion and Throne
  Room Volker, preserving their custom dialogue.
- Added the empty-allowlist `mobskill_check_purity.py` sanity check to reject
  ready-message calls in future `onMobSkillCheck` implementations.

### Exact validation commands and results

Every Windows build command used:

```text
call "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\Common7\Tools\VsDevCmd.bat" -no_logo -arch=x64 -host_arch=x64
```

Fresh configure:

```text
cmake -G Ninja -S . -B build-codex-vz-bf-001 --fresh -DCMAKE_BUILD_TYPE=Debug -DENABLE_CLANG_TIDY=OFF -DTRACY_ENABLE=OFF -DPCH_ENABLE=OFF -DCACHE_OPTION=sccache
```

Result: exit `0`.

Focused build:

```text
cmake --build build-codex-vz-bf-001 --target xi_test
```

Result: exit `0` (`24/24` final post-format steps).

Disposable database setup:

```text
python tools/dbtool.py setup xidb_codex_vz_bf_001_update2_20260725
python tools/dbtool.py update
```

Result: both exit `0`; all current SQL, including
`mob_skill_start_messages.sql`, imported, and the supported existing-database
update reported `Database is up to date.` The owner's working `xidb` was not
used.

Focused state/controller/battlefield tests:

```text
.\xi_test.exe --keep-going --file mobskill_start_messages --file mobskill_start_message_exceptions
```

Result: exit `0`; Catch2 19/19 with 9,007,079 assertions and focused Lua
11/11. The same command was repeated after the full build with
`XI_MAP_HIDE_READIES_TARGET=true`; exit `0`, Lua 11/11.

Battle-action packet regression:

```text
.\xi_test.exe --keep-going --file 0x028
```

Result: exit `0`; Catch2 19/19 and Lua 65/65, including ordinary mob skills,
interruption, pet Ready, wyvern breaths, Blood Pacts, and player weapon
skills.

Lua checks:

```text
tools/ci/sanity_checks/lua.sh <all changed Lua files>
python tools/ci/sanity_checks/mobskill_check_purity.py
```

Result: exit `0` with Python UTF-8 mode and the installed Windows
`luacheck.bat` bridged into the shell. `luacheck`, repository Lua style,
binding usage, and mob-skill-check purity all passed.

SQL sanity:

```text
tools/ci/sanity_checks/sql.sh sql/mob_skill_start_messages.sql
```

Result: exit `0`.

C++ formatting:

```text
C:\Program Files\LLVM\bin\clang-format.exe -i --style=file <all changed C++ and header files>
```

Result: exit `0`.

Complete Debug build:

```text
cmake --build build-codex-vz-bf-001
```

Result: exit `0` (`148/148` remaining steps); `xi_connect`, `xi_world`,
`xi_search`, `xi_map`, and `xi_test` linked.

Diff validation:

```text
git diff --check
```

Result: exit `0`; only checkout line-ending notices were emitted.

### Defects and intermediate issues resolved

- The baseline code sent ready text from repeatable `skillCheck` callbacks
  and could never generate an engine start for a zero-time skill. Both causes
  are corrected.
- A zero-time state is immediately updated during `Enter()`. The former
  per-update reset of `m_skillSuccess` would have cleared the result on a
  later cleanup tick; success now initializes once and changes only when the
  skill actually completes.
- The first command-shell quoting attempt failed before invoking CMake; the
  corrected `cmd.exe` quoting initialized MSVC and all builds passed.
- The first Lua sanity wrapper run exposed Windows Python encoding and
  `luacheck` PATH issues. UTF-8 mode and the installed batch wrapper allowed
  the complete check to run and pass.
- Initial focused fixtures were corrected to use real cast time, initialized
  settings, proper battle-target context, message-specific basic-packet
  filtering, and TP assertions tolerant of TP generated by damage.
- Initial individual packet-module selectors collected zero tests because
  the `0x028` base module owns collection. The corrected selector collected
  and passed all 65 cases.

### Cleanup

- `build-codex-vz-bf-001`: removed after the complete build.
- Generated root `xi_*.exe` and `xi_*.pdb`: removed.
- Both disposable validation databases were dropped and confirmed absent.
- Owner working `xidb`: not modified.

### Retail/client uncertainty retained

- Exact ready/no-ready policy for Shield Strike, Charm, job specials, and
  other Ark Angel moves with no repository ready evidence.
- Exact client rendering order for a same-update zero-time start/finish pair.
- Any alternate retail start message not represented in current production
  data. Alternate-message transport is covered only by a synthetic C++
  policy fixture.

## VZ-COMBAT-001 Phase A — inventory and deterministic framework correction

### Inventory result

The tracked generator emits a 420-row CSV and Markdown report with the 34
required fields.

| Dimension | Totals |
|---|---|
| Era | 18 `VANILLA_OR_ZILART`; 402 `ERA_UNRESOLVED` |
| Effect family | 183 damage; 124 debuff; 46 equipment-spikes; 27 scripted; 13 HP-drain; five Dispel; six NM-specific; remaining families in the artifact |
| Configuration source | 387 SQL; 25 SQL+item-script; five SQL+latent; one item-script; two issue-evidence-only |
| Classification | 122 configuration-error; 185 era-unresolved; 98 `VERIFY_LIVE`; ten framework-correct/legacy-numerics; five special-test-backed |

All 18 maintained Vanilla/Zilart entries are reachable and non-error. The 341
individual repository-wide configuration findings include unresolved
later-era configurations and are deliberately reported rather than hidden.

Artifacts:

- `retail_parity/vanilla_zilart/artifacts/VZ-COMBAT-001-item-inventory.csv`
- `retail_parity/vanilla_zilart/artifacts/VZ-COMBAT-001-item-inventory.md`
- `tools/retail_parity/generate_item_additional_effect_inventory.py`
- `tools/retail_parity/check_item_additional_effect_profiles.py`

### Production architecture and corrections

- `additional_effect_profiles.lua` resolves SQL-backed proc,
  accuracy/resistance, outcome, and presentation policy.
- Acid/Sleep Bolt alone use issue-supported item-native A rank. Governing INT
  remains `LEGACY_UNVERIFIED`; the profile does not claim dINT or no-dSTAT.
- Calculators are pure and one operation applies final HP damage/healing.
- Absorption and nullification are evaluated once.
- Damage, HP drain, MP/TP drain calculation, physical-profile damage, and NM
  hooks have one explicit mutation owner.
- `isBreath` is now read consistently, enabling `NULL_BREATH_DAMAGE`.
- A failed/non-overwriting status application no longer emits a false
  success additional effect.
- Level correction is applied independently after profile resolution and
  before the proc roll; above-level items are rejected before resolution.
- Unsupported drain/order, self-buff, Death, and related families retain
  named `VERIFY_LIVE` compatibility behavior.

No SQL schema or numeric item data changed.

### Defect reproduction

With the legacy mutations temporarily restored, the focused test exited `1`
and reported:

- target HP mutation did not match packet amount;
- absorption evaluated twice;
- nullification evaluated twice;
- breath additional damage was not nullified.

After restoring the correction, all four cases pass. The status
non-overwrite regression independently reproduced and corrected its false
success presentation.

### Tests and validation

Focused files:

- `scripts/tests/systems/combat/item_additional_effects.lua`
- `scripts/tests/systems/combat/item_additional_effects_ranged.lua`
- `scripts/tests/systems/combat/item_additional_effects_nm.lua`

They cover real melee and ranged 0x028 action paths, Acid/Sleep ammunition,
proc-versus-resistance, exact damage/healing ownership, elemental/general
absorb/nullification, physical/ranged/breath flags, damage-type SDT, status
guards and parameters, level eligibility, and every maintained NM hook.

Validation results:

- isolated current-SQL database import: exit `0`;
- fresh MSVC/Ninja Debug configure: exit `0`;
- `xi_test` build: exit `0` (`906/906`);
- corrected focused framework checkpoint: 27/27, exit `0`;
- real ranged checkpoint: 3/3, exit `0`;
- final combined additional-effect framework/ranged/NM repeat: 39/39,
  exit `0`;
- all 65 `0x028` plus nine Shadowbind regressions: 74/74, exit `0`;
- all-target Debug build: exit `0` (`148/148` remaining steps), all five
  executables linked;
- generator write/check, profile sanity, Lua/Python formatting/sanity, and
  `git diff --check`: exit `0`.
- generator strict audit: expected exit `1`, reporting all 341 known
  repository-wide configuration diagnostics rather than suppressing them.

Cleanup:

- `build-codex-phase-a`: removed after the complete build and final focused
  repeat.
- Generated root `xi_*.exe`/`xi_*.pdb`: ten files removed.
- `xidb_codex_vz_combat_001_phase_a_20260725` and both temporary privilege
  rows: removed and confirmed absent.
- Issue-#7899 attachment cache: removed.
- Owner working `xidb`: not modified.

### Compatibility and remaining Phase B

Fire/Ice/Lightning Arrow remain reachable per-item `VERIFY_LIVE` scripts.
Ten maintained status-ammunition entries retain framework-correct legacy
numerics. The five Zilart special hooks are behaviorally test-backed.

Combined drains, other drain accuracy/scaling, Dispel, self-buffs, Death,
spikes, item-specific damage/status formulas, and 402 unresolved era
classifications remain Phase B work. Controlled retail datasets and client
captures are required where repository evidence cannot resolve them. Phase A
does not classify the overall finding as corrected.

## VZ-COMBAT-001 Phase B1 — Fire/Ice/Lightning Arrow profiles

### Evidence and selected policy

The tracked elemental-arrow ledger records every required field separately
for Fire Arrow 17322, Ice Arrow 17323, and Lightning Arrow 17324. The strongest
accessible evidence is:

- a January 2004 Ranger guide listing all three arrows and their elements;
- Japanese community references preserving their original-era identity;
- a March 2004 uncontrolled report of roughly 5-10 damage and less-than-
  every-hit activation.

No controlled retail packet capture, damage dataset, or official formula was
found. The last report conflicts with the inherited 100%/7-10 behavior and is
not strong enough to replace it. Modern INT and later INT/MAB claims also lack
controlled comparisons. The exact item element is `EVIDENCE_BACKED`; every
unsupported numeric/stat/resistance/multiplier field remains compatibility or
`VERIFY_LIVE`.

### Architecture and corrected defect

- Exactly three registry entries own item identity, level gate, proc and
  uniform-power policy, A+ and no-stat compatibility, explicit macc/MAB,
  item-specific element/subeffect, resistance floor, mandatory multipliers,
  defenses, result ownership, presentation, and unresolved evidence.
- Registry construction and runtime application validate the profile.
  Duplicate IDs, missing/malformed fields, wrong element/presentation,
  unsupported policy, and later-arrow migration fail visibly.
- Each item wrapper calls `executeScriptedDamageProfile` once and contains no
  duplicate numeric table.
- The executor uses one proc, power, resistance, nullification, absorption,
  and HP-application path. The existing ranged subsystem remains the sole
  owner of physical validation, range, level eligibility, priority, ammo,
  Recycle, and Unlimited Shot.
- Pre-correction reproduction showed that planned damage/healing could be
  serialized when current/max HP clamped the actual change. The scoped
  executor now returns actual applied HP damage/healing without changing
  unrelated item scripts.

### Tests

The two new files contain 47 cases:

- 20 real ranged-state cases cover all three correct elemental 0x028 results,
  actual HP value, one ammo consumption, ordinary miss, initial/mid-shot
  range rejection, item-level gate, despawn, longer valid range, Recycle,
  Unlimited Shot, and Enspell priority;
- 27 direct executor/profile cases cover exact scope, malformed/duplicate
  profiles, a synthetic configured proc pass/fail boundary with one roll,
  both 7-10 endpoints, no-INT/no-MAB compatibility, full/half/quarter/eighth/
  below-floor resistance, per-item skill/stat/element transport, every
  retained multiplier/defense, per-element null/absorb, and HP cap amounts.

Post-build regressions passed:

- Phase B1 focused group: 47/47;
- Phase A framework plus Acid/Sleep ranged and NM group: 39/39;
- battle-action packet suite: 65/65 `0x028` cases;
- Catch2: 19/19 cases and 9,007,079 assertions on every xi_test invocation.

### Exact validation commands

All Windows configure/build commands initialized:

```text
call "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\Common7\Tools\VsDevCmd.bat" -no_logo -arch=x64 -host_arch=x64
```

Commands and results:

```text
cmake -G Ninja -S . -B build-codex-phase-b1 -DCMAKE_BUILD_TYPE=Debug -DCMAKE_C_COMPILER=cl -DCMAKE_CXX_COMPILER=cl -DENABLE_CLANG_TIDY=OFF -DTRACY_ENABLE=OFF -DPCH_ENABLE=OFF -DCACHE_OPTION=sccache
# exit 0

cmake --build build-codex-phase-b1 --target xi_test
# exit 0, 906/906

cmake --build build-codex-phase-b1
# exit 0, 148/148 remaining steps

xi_test.exe --keep-going --file item_additional_effects_elemental_arrow
# exit 0, 47/47

xi_test.exe --keep-going --file "item_additional_effects\.lua" --file "item_additional_effects_ranged\.lua" --file "item_additional_effects_nm\.lua"
# exit 0, 39/39

xi_test.exe --keep-going --file 0x028_battle2
# exit 0, 65/65

python tools/retail_parity/generate_item_additional_effect_inventory.py
python tools/retail_parity/generate_item_additional_effect_inventory.py --check
python tools/retail_parity/check_item_additional_effect_profiles.py
python -m black --check tools/retail_parity/generate_item_additional_effect_inventory.py tools/retail_parity/check_item_additional_effect_profiles.py
python -m pylint --errors-only tools/retail_parity/generate_item_additional_effect_inventory.py tools/retail_parity/check_item_additional_effect_profiles.py
tools/ci/sanity_checks/lua.sh <all changed Lua files>
git diff --check
# all exit 0
```

Two consecutive inventory writes produced identical SHA-256 hashes:

- CSV:
  `6EEFA0CBB629FBA92A6CDCA759B9B6CAE8F63849BE88D1E56255B325D4F60ED3`;
- Markdown:
  `6A6E7EC619C166F48C5C8B5B08C87925F5EDA3D517D2540BA91BDA1A11221A60`.

No SQL source changed. A disposable current-SQL database was used for tests,
then the schema and its two explicit grants were removed and confirmed absent.
The build directory, five root executables, five PDBs, and temporary logs were
removed. The owner's working `xidb` was not modified.

### Phase result and remaining evidence

Phase B1 is complete as an engineering/profile hardening pass, but the three
arrows are not claimed retail-formula-correct. A controlled item-separated
retail dataset must isolate proc versus resist, 7-10 distribution, actor and
target INT, skill/macc, MAB, staff/affinity, day/weather, level/distance,
defenses, elemental null/absorb, and raw client presentation.

Phase B2 must select another bounded family or configuration group. It must
not copy this compatibility profile to Earth/Water/Wind or later elemental
arrows without separate evidence.

## VZ-COMBAT-001 Phase B1 RNG lifecycle follow-up

Starting from `72dbd42cb04ed9cca87585b0f69d22bede922ee7`, a bounded follow-up
reproduced and corrected eager power RNG in the scripted-damage executor.
Before correction, `executeScriptedDamageProfile` evaluated
`math.random(7, 10)` while building helper parameters, before the helper's
configured proc roll. Failed proc, full-nullification, and below-floor
resistance attempts therefore advanced unused power RNG.

The shared helper now preserves either a numeric base power or a zero-argument
resolver through validation. It invokes the resolver once only after proc
success, nullification, resistance-floor rejection, and absorption
classification. The three arrow profiles pass their unchanged 7-10 roll as
that resolver. Proc remains owned by the helper; no 100% bypass, second roll,
numeric, multiplier, packet, or ammunition policy changed.

Regression-first evidence:

- pre-correction focused run: expected exit `1`, 48/51 passed; exactly the
  three eager-power cases failed;
- corrected focused run: exit `0`, 51/51;
- Phase A/Acid/Sleep/NM group: exit `0`, 39/39;
- complete `0x028` packet group: exit `0`, 65/65;
- final post-format/post-build focused repeat: exit `0`, 51/51;
- Catch2 on every invocation: 19/19 and 9,007,079 assertions.

The 31 direct profile cases now prove failed-proc zero downstream work,
successful exactly-once proc/power/nullification/resistance/absorption/
application, zero power RNG after full nullification or below-floor resist,
and unchanged direct numeric base-power callers. The 20 real ranged cases
continue to prove all three items' ordinary hit/miss/range/level/ammunition/
packet behavior.

Validation and environment:

```text
cmake -G Ninja -S . -B build-codex-phase-b1-rng -DCMAKE_BUILD_TYPE=Debug -DCMAKE_C_COMPILER=cl -DCMAKE_CXX_COMPILER=cl -DENABLE_CLANG_TIDY=OFF -DTRACY_ENABLE=OFF -DPCH_ENABLE=OFF -DCACHE_OPTION=sccache
# exit 0

cmake --build build-codex-phase-b1-rng --target xi_test
# exit 0 after resuming 263 remaining steps following a host crash

xi_test.exe --keep-going --file item_additional_effects_elemental_arrow
# expected pre-fix exit 1 (48/51); corrected and final exit 0 (51/51)

xi_test.exe --keep-going --file "item_additional_effects\.lua" --file "item_additional_effects_ranged\.lua" --file "item_additional_effects_nm\.lua"
# exit 0 (39/39)

xi_test.exe --keep-going --file 0x028_battle2
# exit 0 (65/65)

tools/ci/sanity_checks/lua.sh scripts/combat/action_additional_effect_damage.lua scripts/tests/systems/combat/item_additional_effects_elemental_arrow_profiles.lua
# exit 0 with the documented Windows UTF-8 and luacheck launcher prerequisites

cmake --build build-codex-phase-b1-rng
# exit 0 (148/148 remaining targets)

git diff --check
# exit 0
```

No C++, header, Python, SQL, inventory, numeric profile, or human-only queue
content changed. The isolated database and build products were disposable;
the owner's working `xidb` was not modified. The three arrows remain hardened
compatibility profiles, not retail-formula-correct claims. Credential and
process-environment values remained process-local; no environment dump,
credential value, token, password, connection string, or secret-bearing
command argument was printed or recorded.

## Findings now fully test-backed

- `VZ-ZONE-001` — server-side Uggalepih/Prelate door behavior.
- `VZ-ECON-001` — moon-pattern dispatch.
- `VZ-ECON-002` — Waders branch reachability.
- `VZ-ECON-003` — conquest region-bonus arithmetic and truncation.
- `VZ-CORE-001` — server eligibility, scope, claim/enmity distinctions,
  boundaries, and message cardinality, subject to the client limits below.
- `VZ-CORE-002` — validated fishing interruption, waiting/hooked lifecycle,
  stale-input rejection, resources, invalid targets, idempotence, and
  recovery, subject to the client limits below.
- `VZ-BF-001` — issue-#3611 packet spam, engine-owned start policy,
  zero/positive-time behavior, Ark Angel state entry, target presentation,
  Trion/Volker exceptions, and migration completeness, subject to the
  move-by-move retail presentation limits below.

## Findings still partial

`VZ-JOB-002` remains partial only where evidence is insufficient:

- `/RNG` accuracy penalty, if any;
- relative target-level correction;
- ranged-accuracy contribution;
- whether `BIND_MEVA` is the correct terminal roll;
- duration/partial-resist rules;
- Recycle behavior beyond the tested Unlimited Shot path.

No spell-skill, dSTAT, ranged-accuracy, subjob, or level formula was invented.

`VZ-COMBAT-001` is Phase-A complete but remains partial for item-specific
retail numerics, unsupported family formulas, unresolved era classifications,
and client presentation. Its inventory, profile ownership, and deterministic
framework corrections are complete and test-backed.

## VZ-COMBAT-001 Phase B2 status-ammunition pass

Starting from `13762583a85d7e3c078f4445b3c7096d213690c0`, this bounded pass
profiled exactly eight maintained Vanilla/Zilart status-ammunition items:
Kabura Arrow 17325, Patriarch Protector's Arrow 17329, Blind Bolt 18150,
Venom Bolt 18152, Poison Arrow 18157, Sleep Arrow 18158, Demon Arrow 18159,
and Spartan Bullet 18160.

The production policy remains the current SQL behavior, made explicit and
machine-readable rather than relabeled as retail-correct:

| Item | Status / effective element | Proc / level | Power / duration | Classification |
|---|---|---|---|---|
| Kabura Arrow | Silence / Wind | 95% / 5 | 1 / 60s | `VERIFY_LIVE`; SQL compatibility |
| Patriarch Protector's Arrow | Paralysis / Ice | 95% / 5 | 30 / 30s | `VERIFY_LIVE`; SQL compatibility |
| Blind Bolt | Blind / Dark | 100% / 5 | 10 / 30s | `VERIFY_LIVE`; SQL compatibility |
| Venom Bolt | Poison / Water | 100% / 5 | 4 per 3s / 30s | `VERIFY_LIVE`; SQL compatibility |
| Poison Arrow | Poison / Water fallback | 95% / 5 | 4 per 3s / 30s | `VERIFY_LIVE`; SQL compatibility |
| Sleep Arrow | Sleep / None | 95% / 5 | 0 / 25s | `VERIFY_LIVE`; SQL compatibility |
| Demon Arrow | Attack Down / Water fallback | 95% / 5 | 12 / 60s | `VERIFY_LIVE`; SQL compatibility |
| Spartan Bullet | Stun / Thunder fallback | 10% / 5 | 10 / 5s | `VERIFY_LIVE`; known incomplete without cooldown |

All eight retain the active A-rank/INT accuracy inputs, status immunity and
nullification guards, full/half-duration compatibility floor, successful
physical ranged-hit trigger, ordinary ammunition ownership, and normal
0x028 additional-effect presentation. These are tested compatibility
contracts, not retail formula claims. The issue-#7899 controlled A-rank
dataset remains owned only by Acid Bolt and Sleep Bolt.

The ranked evidence ledger records issue #7899 and all public comments,
seven attached retail images/logs, Japanese historical/mechanics summaries,
dated FFXIAH comments, modern item references, and inaccessible-source
limits. Effect identities are supported. No controlled dataset establishes
the eight items' proc, level correction, rank/stat, action element, power,
duration, overwrite, or resist distribution. Kabura's qualitative
low-activation claim conflicts with current 95% SQL. Spartan sources support
a missing target-side lockout but conflict between roughly 10-20, 20-30,
and 30 seconds and do not fully establish ownership or weapon-skill
interaction. No cooldown or alternate numeric formula was guessed.

### Architecture and deterministic correction

`additional_effect_profiles.lua` now owns one validated
`VZ_STATUS_AMMUNITION` registry with exactly eight item identities,
field-level evidence classifications, SQL compatibility expectations,
item-specific status/subeffect/element data, and an explicit unresolved
Spartan policy. Validation rejects malformed or duplicate entries, SQL
drift, Acid/Sleep migration, and later Gashing/Abrasion/Oxidant ammunition.

The inherited DEBUFF handler removed an opposing Defense/Evasion/Attack
Boost before asking the authoritative status container to add the Down
effect. A caller-path regression forced the earlier guards to pass and the
container to reject the add; before correction it failed 29/30 because the
opposing boost was still removed. Status lookup is now pure, the handler
applies once, returns no result on rejection, and removes an opposing boost
exactly once only after successful application.

No SQL, proc, level, rank/stat, element, power, duration, resist, overwrite,
packet, or Spartan cooldown value changed.

### Behavioral coverage

The 49 Phase B2 cases comprise 22 real ranged-action tests and 27 direct
profile tests:

- all eight successful shots emit exactly one matching status result and
  consume one ordinary ammunition unit;
- all eight physical misses perform no status work;
- out-of-range start, mid-shot target despawn, below-level suppression,
  longer valid range, Recycle, and Unlimited Shot use the ordinary ranged
  path;
- exact eight-item registration, Acid/Sleep separation, malformed,
  duplicate, and later-item rejection are enforced;
- one proc roll, every configured pass/fail boundary, level correction, and
  zero downstream work after proc failure are covered;
- every item runs immunity, trait-resistance, nullification, full, half, and
  below-floor behavior; representative quarter, eighth, and zero resist
  results preserve no-effect behavior below the compatibility half floor;
- A-rank/INT/effective-element transport, all eight status powers,
  durations/ticks, authoritative rejection, and post-success opposing-boost
  removal are covered.

The shared framework file adds the real caller-path rejection regression.
The Acid/Sleep ranged fixture now seeds the physical hit immediately before
the player state tick, eliminating unrelated world-RNG consumption without
changing the production path or expected results. The Phase B2 target-
despawn fixture makes its otherwise unkillable target killable immediately
before despawn so the test exercises genuine invalidation deterministically.

### Exact validation

Every test invocation used the isolated database
`xidb_codex_vz_combat_001_b2_20260728` on a disposable local MariaDB 10.6
server. The owner's working `xidb` was not modified.

```text
call "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\Common7\Tools\VsDevCmd.bat" -no_logo -arch=x64 -host_arch=x64
cmake -G Ninja -S . -B build-codex-phase-b2 -DCMAKE_BUILD_TYPE=Debug -DCMAKE_C_COMPILER=cl -DCMAKE_CXX_COMPILER=cl -DENABLE_CLANG_TIDY=OFF -DTRACY_ENABLE=OFF -DPCH_ENABLE=OFF -DCACHE_OPTION=sccache
# exit 0

cmake --build build-codex-phase-b2 --target xi_test
# exit 0 (906/906)

xi_test.exe --keep-going --file item_additional_effects_status_ammunition
# exit 0 (49/49)

xi_test.exe --keep-going --file "item_additional_effects\.lua" --file "item_additional_effects_ranged\.lua" --file "item_additional_effects_nm\.lua"
# exit 0 (40/40)

xi_test.exe --keep-going --file item_additional_effects_elemental_arrow
# exit 0 (51/51)

xi_test.exe --keep-going --file 0x028_battle2
# exit 0 (65/65)

cmake --build build-codex-phase-b2
# exit 0 (148/148 remaining all-target steps)

xi_test.exe --keep-going --file "item_additional_effects\.lua" --file item_additional_effects_status_ammunition
# final post-format/post-build exit 0 (79/79)

python tools/retail_parity/generate_item_additional_effect_inventory.py
python tools/retail_parity/generate_item_additional_effect_inventory.py
python tools/retail_parity/generate_item_additional_effect_inventory.py --check
python tools/retail_parity/check_item_additional_effect_profiles.py
# all exit 0; 420 rows, 18 maintained profiles, 341 unchanged repository diagnostics

python -m black --check tools/retail_parity/generate_item_additional_effect_inventory.py tools/retail_parity/check_item_additional_effect_profiles.py
python -m pylint --errors-only tools/retail_parity/generate_item_additional_effect_inventory.py tools/retail_parity/check_item_additional_effect_profiles.py
tools/ci/sanity_checks/lua.sh <all seven changed Lua files>
git diff --check
# all exit 0
```

Catch2 passed 19/19 with 9,007,079 assertions on every `xi_test`
invocation. No C++, header, or SQL source changed, so clang-format and SQL
source migration checks were not applicable. Two inventory writes were
identical:

- CSV SHA-256:
  `6B1FC13D5090DC3F0B09F2592AB3BE7B243EC163225E1C37A23A3F38B193B16D`;
- Markdown SHA-256:
  `26CEC1575F390103C43AB4A6B4E64D10D6C1F9037EB2B28211C5FE873F1A6F53`.

An immediate second Windows/Python inventory rewrite once returned transient
`OSError 22` after the first write succeeded; `--check` passed immediately,
and the controlled two-write repeat with a two-second file-handle interval
produced the identical hashes above. Two pre-final test runs exposed the
fixture issues described above (48/49 on the unkillable despawn case and
39/40 on Sleep Bolt RNG); both corrected suites and the combined final
79-case repeat pass.

The disposable build directory, five generated root executables and PDBs,
isolated MariaDB process/data directory, and downloaded evidence cache were
removed. The owner's `xidb` was untouched. Changed-file scanning found no
PAT, JWT, signed query, assigned secret, or embedded remote credential.
Shell commands printed environment-variable names only, never their values.
The GitHub connector did return short-lived signed attachment parameters in
its transient evidence-retrieval response; they were not echoed to shell,
written to the repository, committed, or retained after cache deletion.

Phase B2 result is `PARTIAL`: profile ownership, deterministic status
application, real ranged lifecycle, inventory, and evidence boundaries are
complete and test-backed, but the eight items are not claimed
retail-formula-correct. Spartan's missing cooldown and every listed
`VERIFY_LIVE` field require the controlled capture plan in
`HUMAN_ONLY_QUEUE.md`. Phase B3 should select a separate bounded family,
preferably maintained drains, without mixing Dispel, Death, self-buffs,
spikes, or another audit area.

## VZ-COMBAT-001 Phase B3 single-resource-drain pass

Starting from `1dd627e84e99d80502d266ff07533e658a410950`, this bounded pass
profiles exactly Aspir Knife 16509, Bloody Rapier 16528, and Shinsoku 17823.
It does not change combined drains, scripted drains, later items, Dispel,
Death, self-buffs, spikes, Elemental Spirits, Ballista, or another audit
area.

### Evidence and classification

The ranked ledger
`retail_parity/vanilla_zilart/artifacts/VZ-COMBAT-001-single-resource-drains-evidence.md`
records contemporary English discussion, dated update records, Japanese
references, modern item summaries, inaccessible/defaced source limits, and a
field-by-field capture plan.

Effect/resource identity is supported. Bloody Rapier is classified Vanilla;
Shinsoku is classified Zilart; Aspir Knife's 2003 evidence proves Zilart-era
presence but not original-release versus Zilart introduction, so its era is
`ERA_UNRESOLVED`. No controlled retail dataset establishes the three items'
proc, level correction, amount/scaling, accuracy/skill, governing stat/dSTAT,
Dark element, resistance/multiplier/defense rules, undead behavior, resource
cap/zero presentation, main/off-hand priority, or exact 0x028 behavior.
Existing numerics and multipliers remain compatibility and `VERIFY_LIVE`.

| Item | Resource | Effective compatibility policy | Evidence-backed fields |
|---|---|---|---|
| Aspir Knife 16509 | MP | 10%, adjustment 0, fixed 3, Dark legacy stack, main/off hand | item/resource identity; era unresolved |
| Bloody Rapier 16528 | HP | 5%, adjustment 0, fixed 10, Dark legacy stack, main/off hand | item/resource identity and Vanilla era |
| Shinsoku 17823 | TP | 8%, adjustment 0, fixed 10, Dark legacy stack, main only | item/resource identity and Zilart era |

### Reproduced defect and correction

Before the production correction, the direct Shinsoku handler test removed
10 TP and returned amount 10 but failed because the subeffect was 0 rather
than `TP_DRAIN`. Its SQL rows lacked both `ITEM_SUBEFFECT` and an explicit
element; the generic handler's hardcoded Dark assignment concealed the
second data omission.

Shinsoku now has `TP_DRAIN` and explicit Dark compatibility data. The stale
SQL chance comment changed from 5% to the already-active value 8%; no active
numeric changed.

`additional_effect_profiles.lua` owns one validated
`VZ_SINGLE_RESOURCE_DRAIN` registry with exactly three items and explicit
identity, resource, proc/level/equip, skill/stat/dSTAT/MAB, element/
resistance, null/absorb/undead, amount/scaling/defense, target/attacker cap,
application, presentation, field-classification, and unresolved-evidence
policies. Validation rejects unsupported, malformed, duplicate, cross-
resource, presentation, element, and SQL/profile drift. The generated
inventory maps the exact three profiles to both focused test files and their
evidence source.

`executeSingleResourceDrain` owns the scoped transfer. After normal item,
level, profile, target, and one proc check, it rejects dead/undead targets,
calculates once, clamps negative compatibility results to zero, caps removal
to actual target resource, mutates the target once, credits the attacker
once, and returns the resource-specific subeffect/message with actual target
resource removed. HP uses authoritative magical-Dark damage once; MP and TP
mutate only their respective resource containers. Attacker caps remain
container-owned and do not falsify the packet's target-removal amount.

Combined and scripted drains still resolve through their inherited generic
or script paths. Existing Enspell/item priority and one-result-per-swing
ownership are unchanged.

### Behavioral coverage

The 58 Phase B3 cases cover:

- exact three-profile scope, every required field, SQL consistency,
  malformed/duplicate/resource/presentation rejection, and explicit
  combined/scripted/later exclusions;
- one proc and no downstream work on failure, every proc boundary, and item
  required-level eligibility;
- one calculation and one HP/MP/TP transfer;
- below/equal/above target-resource caps, attacker near/full caps, zero
  target resource, actual applied packet amounts, and MP/TP isolation;
- full, half, quarter, eighth, and below-floor resistance with rounding;
- inherited SDT/environment/defense handling once, nullification once, and
  negative absorption clamped to no transfer;
- actual undead rejection for all three and already-dead rejection before
  proc/calculation;
- real main-hand actions for all three, real off-hand Aspir/Bloody actions,
  physical miss, below-level, despawn, Enspell/item priority, multi-attack,
  and ordinary melee;
- one normal 0x028 resource-specific result per eligible swing.

The real-melee observer records resources immediately around the production
executor, preventing unrelated world regeneration from corrupting the
packet/mutation comparison while preserving the real state, item selection,
handler, mutation, and serialization paths.

Available-HP capping and already-dead rejection are direct production-path
tests. The real-melee fixture did not safely model the final lethal physical
swing without unrelated combat setup, so exact lethal packet order and
client rendering remain unclaimed.

### Exact validation

All `xi_test` commands used the isolated Phase B3 database on a disposable
local MariaDB 12.3 server. Database environment-variable values are omitted
from this report; the owner's working `xidb` was not modified.

```text
# Every relevant Windows configure/build shell first ran:
call "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\Common7\Tools\VsDevCmd.bat" -no_logo -arch=x64 -host_arch=x64

cmake -G Ninja -S . -B build-codex-phase-b3-final -DCMAKE_BUILD_TYPE=Debug -DCMAKE_C_COMPILER=cl -DCMAKE_CXX_COMPILER=cl -DENABLE_CLANG_TIDY=OFF -DTRACY_ENABLE=OFF -DPCH_ENABLE=OFF -DCACHE_OPTION=sccache
# exit 0

cmake --build build-codex-phase-b3-final --target xi_test
# exit 0 (906/906)

cmake --build build-codex-phase-b3-final
# exit 0 (148/148 remaining all-target steps)

xi_test.exe --keep-going --file item_additional_effects_single_resource_drain_profiles --file item_additional_effects_single_resource_drains
# focused and final post-build repeats: exit 0 (58/58 each)

xi_test.exe --keep-going --file "item_additional_effects\.lua" --file "item_additional_effects_ranged\.lua" --file "item_additional_effects_nm\.lua"
# regression and final post-build repeats: exit 0 (40/40 each)

xi_test.exe --keep-going --file item_additional_effects_elemental_arrow
# exit 0 (51/51)

xi_test.exe --keep-going --file item_additional_effects_status_ammunition
# exit 0 (49/49)

xi_test.exe --keep-going --file 0x028_battle2
# exit 0 (65/65)

python tools/retail_parity/generate_item_additional_effect_inventory.py
python tools/retail_parity/generate_item_additional_effect_inventory.py
python tools/retail_parity/generate_item_additional_effect_inventory.py --check
python tools/retail_parity/check_item_additional_effect_profiles.py
# all exit 0; 420 rows, 18 maintained profiles, 341 pre-existing diagnostics

python -m black --check tools/retail_parity/generate_item_additional_effect_inventory.py tools/retail_parity/check_item_additional_effect_profiles.py
python -m pylint --errors-only tools/retail_parity/generate_item_additional_effect_inventory.py tools/retail_parity/check_item_additional_effect_profiles.py
tools/ci/sanity_checks/lua.sh <all five changed Lua files>
tools/ci/sanity_checks/sql.sh sql/item_mods.sql
python tools/dbtool.py update
git diff --check
# all exit 0
```

Catch2 passed 19/19 with 9,007,079 assertions on every `xi_test`
invocation. No C++ or header changed, so clang-format was not applicable.
Fresh isolated database setup/import passed before testing; `dbtool update`
then reported the database up to date. The imported item rows contained the
expected type, subeffect, amount, chance, and explicit Dark policy for all
three items.

Two inventory writes were identical:

- CSV SHA-256:
  `7D0A25CE25FF3A7D9827600BAA8707BF0106A47A70D986D171E05A02CEEF0601`;
- Markdown SHA-256:
  `6A81C5BD2CC26F2E77AFAD29B1649A5E68C8A11B331AB0C01BFFA62A0CD07EE5`.

During development, Lua sanity initially exposed a cyclomatic-complexity
violation in the first profile implementation; the profile was factored into
validation helpers and the final five-file sanity run passed. Initial
real-melee fixtures exposed world-regeneration timing in packet/resource
comparisons; the final observer measures immediately around the unchanged
production executor. One observer iteration accidentally returned only the
first of Lua's three values, producing packet message 0 in the test; restoring
all three returns corrected the fixture and the final 58-case runs pass.

A broad exploratory 198-test single-process aggregation exited 1 during the
Phase B1 portion without an emitted failure summary. The authoritative
bounded groups were rerun in fresh processes and all passed: 40, 51, 49, and
58 cases respectively, plus 65 packet cases and the two final post-build
repeats. No production correction was made in response to the unexplained
aggregate-runner exit.

The disposable build directories, five generated root executables/PDBs,
test-result JSON files, isolated databases/server process/data directory, and
temporary logs were removed before commit. The owner's `xidb` and ForgeRaid
paths/services were untouched. Changed-file scanning found no PAT, JWT,
signed query, assigned secret, embedded remote credential, or persisted
database connection value.

Phase B3 result is `COMPLETE_PHASE_B3` as a bounded profile/framework pass.
The three items are not claimed retail-formula-correct and
`VZ-COMBAT-001` remains partial. The exact capture plan is preserved in the
evidence ledger and `HUMAN_ONLY_QUEUE.md`.

Phase B4 should address the maintained combined HP/MP and HP/MP/TP drain
configuration group as a separate bounded pass. It must not infer branch
selection/order or generalize Phase B3's compatibility formula without
separate evidence.

## VZ-COMBAT-001 Phase B4 combined-resource-drain pass

### Scope, era, and evidence boundary

Phase B4 covers exactly Hofud 17745, Vampirism 20706, and Crepuscular Knife
21585. Independent public sources date them to 2007, 2015, and 2021, so all
three are `LATER_EXPANSION`; the maintained Vanilla/Zilart profile count
remains 18.

The evidence ledger records official release evidence where available,
Japanese and English community summaries, current repository configuration,
and controlled server tests separately. No controlled retail packet log or
counted trial dataset was found. Hofud's reported roughly-20-percent rate and
per-resource maxima are uncited; Vampirism's reported 100-percent behavior
lacks a denominator; and Crepuscular sources conflict between equal/100-
percent behavior and approximately 45/45/10 branch behavior. No numeric or
selection claim was promoted from those reports.

The active configuration remains:

- Hofud: HP/MP family, 15-percent configured proc, fixed 15 amount, no level
  correction, configured None/effective Dark, Darkness Damage subeffect;
- Vampirism: HP/MP/TP family, 100-percent configured proc, fixed 20 amount,
  no level correction, configured None/effective Dark, MP Drain subeffect;
- Crepuscular Knife: HP/MP/TP family, 15-percent configured proc, fixed 15
  amount, no level correction, configured None/effective Dark, Darkness
  Damage subeffect.

These are compatibility facts, not retail-formula conclusions. No SQL
changed.

### Aggregate-test isolation correction

The mandatory pre-edit six-selector aggregate reproduced the earlier
unexplained failure as Windows access violation `0xC0000005` at case 76/198.
Binary splits isolated it to stacked Lua doubles. `MockManager::restoreAll()`
restored doubles by type and installation order, which could leave a Lua
global pointing to a freed earlier stub. The test framework now records one
combined installation order and restores all doubles in reverse before
freeing them. Stacked stub/stub and stub/spy regressions passed 9/9, and the
corrected pre-edit aggregate passed 198/198.

This deterministic harness correction was committed separately as
`ed17e640af test: restore stacked Lua doubles safely`. It does not change
production item behavior.

### Profile and execution architecture

The exact three-item `VZ_COMBINED_RESOURCE_DRAIN` registry owns item/era/
resource identity, configured proc and level policies, equip/attack
eligibility, selection timing and distribution, retry policy, legacy
calculation policy, caps, packet presentation, field classifications, and
unresolved evidence. Validation rejects unsupported IDs, duplicates,
malformed resource/message mappings, SQL drift, handler-family drift,
element drift, and unsupported policy changes.

The ordinary item layer retains the only overall proc roll. A successful
Hofud proc selects one uniform integer in 1..2 and maps it to HP/MP. A
successful Vampirism or Crepuscular proc selects one integer in 1..3 and maps
it to HP/MP/TP. The selected resource is resolved once and never retried after
empty, resisted, nullified, absorbed, dead, or undead outcomes. This mapping
and no-retry behavior are preserved compatibility, not retail claims.

The Phase B3 fixed-resource executor now delegates only its transfer work to
a shared one-resource primitive; B3 and B4 keep separate registries and
selection owners. The primitive resolves the legacy calculation once,
clamps negative absorption to zero, removes no more than the selected target
resource, credits only that attacker resource, and reports actual target
removal in one normal 0x028 additional-effect result.

### Behavioral coverage and validation

The 55 focused B4 cases cover:

- exact scope, complete policies, SQL and resource/message consistency,
  malformed/duplicate/unsupported profiles, and B3/scripted separation;
- all eight item/resource combinations and invalid selectors;
- one proc, one selection, one calculation, one transfer, and no retry;
- below/equal/above/zero target resource, attacker near/full caps, every
  legacy resistance tier/floor, nullification, absorption, dead/invalid/
  undead targets, and nonselected-resource isolation;
- real main/off-hand attacks for all three items, one ordinary result,
  physical miss, level gate, target despawn, Enspell priority, multi-attack
  cardinality, and ordinary melee.

The final validation matrix passed:

```text
# Every Windows configure/build shell first ran:
call "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\Common7\Tools\VsDevCmd.bat" -no_logo -arch=x64 -host_arch=x64

xi_test.exe --keep-going --file item_additional_effects_combined_resource_drain_profiles --file item_additional_effects_combined_resource_drains
# exit 0, 55/55 focused and final post-build

xi_test.exe --keep-going --file item_additional_effects_single_resource_drain_profiles --file item_additional_effects_single_resource_drains
# exit 0, 58/58 Phase B3 and final post-build

xi_test.exe --keep-going --file item_additional_effects_status_ammunition
# exit 0, 49/49 Phase B2

xi_test.exe --keep-going --file item_additional_effects_elemental_arrow
# exit 0, 51/51 Phase B1

xi_test.exe --keep-going --file "item_additional_effects\.lua" --file "item_additional_effects_ranged\.lua" --file "item_additional_effects_nm\.lua"
# exit 0, 40/40 Phase A

xi_test.exe --keep-going --file 0x028_battle2
# exit 0, 65/65 packet regression

xi_test.exe --keep-going --file "item_additional_effects\.lua" --file "item_additional_effects_ranged\.lua" --file "item_additional_effects_nm\.lua" --file item_additional_effects_elemental_arrow --file item_additional_effects_status_ammunition --file item_additional_effects_single_resource_drain
# corrected pre-edit, post-edit, and final post-build repeats: exit 0,
# 198/198 each; final repeat 132.916 seconds

cmake -G Ninja -S . -B build-codex-phase-b4-final -DCMAKE_BUILD_TYPE=Debug -DCMAKE_C_COMPILER=cl -DCMAKE_CXX_COMPILER=cl -DENABLE_CLANG_TIDY=OFF -DTRACY_ENABLE=OFF -DPCH_ENABLE=OFF -DCACHE_OPTION=sccache
# exit 0

cmake --build build-codex-phase-b4-final --target xi_test
# exit 0, 906/906

cmake --build build-codex-phase-b4-final
# exit 0, 148/148 remaining all-target steps
```

Catch2 passed 19/19 with 9,007,079 assertions on every `xi_test`
invocation. Inventory generation twice, `--check`, profile sanity, changed-
Lua style/purity, Black, pylint, C++ clang-format, and `git diff --check` all
passed. There was no SQL change, so SQL/dbtool mutation was not applicable.

The deterministic inventory has 420 rows, 18 maintained Vanilla/Zilart
profiles, three later-expansion combined profiles, and 341 unchanged
repository-wide diagnostics. Its SHA-256 values are:

- CSV: `D93DF1289C3A936C5FD0556176DEED9170F38B930548CB4F82E64BEAD205D11F`;
- Markdown: `9240CA8BC15F540B5FE6CE97F5500FC7A208C4F6F3763EA9EC8CCADFB4D0A174`.

Phase B4 is `COMPLETE_PHASE_B4` as a bounded profile/framework pass. The
three items are not claimed retail-formula-correct, and `VZ-COMBAT-001`
remains partial. The next bounded pass selected Dispel only and did not
combine absorb-status, Death, self-buffs, spikes, Elemental Spirits,
Ballista, or another audit area.

## VZ-COMBAT-001 Phase B5 Lockheart/Mythril Heart Dispel pass

### Scope, era, and evidence boundary

Phase B5 covers exactly Lockheart 16944, Mythril Heart 16950, and Mythril
Heart +1 16951. A dated 2004 report directly establishes Lockheart and
Mythril Heart in circulation, so both are `VANILLA_OR_ZILART` with high
confidence. Mythril Heart +1 is moderate-confidence through a documented
narrow shared-recipe inference: the directly established NQ item and
consistent recipe references identify the +1 as the HQ result of the same
synthesis. No direct dated pre-CoP sighting of the +1 was found.

Current community references support each item's Dispel identity but do not
provide a controlled packet capture, counted proc denominator, official
formula, or repeatable test of selection, accuracy, resistance, status
protection, or packet presentation. Repository configuration is recorded
separately and is not treated as retail-formula evidence.

The active SQL configuration is unchanged:

- Lockheart: Dispel family 10, 5-percent configured proc, zero level
  correction;
- Mythril Heart: Dispel family 10, 10-percent configured proc, zero level
  correction;
- Mythril Heart +1: Dispel family 10, 10-percent configured proc, zero level
  correction.

### Exact profile and deterministic correction

The exact three-item `VZ_DISPEL_WEAPON` registry owns item/effect/era identity,
configured proc and level policy, successful-melee equip policy, status-
selection/removal ownership, retry policy, presentation, field
classifications, and unresolved evidence. Validation rejects unsupported IDs,
duplicates, malformed fields, handler-family drift, and SQL chance/level
drift. Balmung 16942, Claustrum 18330, Zanmato +1 21966, and every other
Dispel configuration remain outside the registry.

Before correction, a real eligible main-hand swing could remove Protect via
`dispelStatusEffect()` and emit no normal 0x028 additional-effect result. The
three SQL entries lacked `ITEM_SUBEFFECT`, so the handler returned subeffect
zero only after the status container had already mutated the target.

The bounded correction preserves exactly one configured proc roll and one
uniform status-container selection among positive-duration effects carrying
the `Dispelable` flag. The container removes exactly one selected effect and
the executor never retries. False, nil, `xi.effect.NONE`, negative, empty,
protected, permanent, dead, and invalid outcomes produce no additional
result. Actual removal supplies `xi.subEffect.DARKNESS_DAMAGE`,
`ADD_EFFECT_DISPEL`, and the actual removed effect ID.

No SQL, proc, level, selection, eligibility, retry, accuracy, skill, stat,
dSTAT, element, resistance, or partial-resist behavior changed. The retained
mechanics and exact client presentation remain compatibility/`VERIFY_LIVE`.

### Behavioral coverage and validation

The 31 focused Phase B5 cases cover:

- exact three-item scope, complete policy, era/evidence ownership, SQL
  consistency, duplicate/malformed/unsupported/drift rejection, and explicit
  exclusion of Balmung, Claustrum, Zanmato +1, and unrelated items;
- 5%/10% pass/fail boundaries, one status-container call, one selection and
  removal, actual effect-ID transport, and no retry;
- positive-duration `Dispelable` eligibility, protected/permanent exclusion,
  empty/no-effect, false, nil, sentinel, negative, dead, and invalid outcomes;
- real main-hand success for all three items, physical miss, level gate,
  target despawn, Enspell priority, multi-attack cardinality, ordinary melee,
  and one normal 0x028 result.

Phase A initially passed 39/40 because its explicit compatibility assertion
still expected legacy `SINGLE` policy. Its test-only expectation was updated
for the three Dispel profiles and the repeat passed 40/40. Before production
edits, the mandatory aggregate had one intermittent B2 target-despawn failure
at 197/198; the focused retry and full aggregate repeat passed. Neither
observation caused a production behavior change.

The final validation matrix passed:

```text
xi_test.exe --keep-going --file item_additional_effects_dispel_weapon
# exit 0, 31/31 Phase B5

xi_test.exe --keep-going --file "item_additional_effects\.lua" --file "item_additional_effects_ranged\.lua" --file "item_additional_effects_nm\.lua" --file item_additional_effects_elemental_arrow --file item_additional_effects_status_ammunition --file item_additional_effects_single_resource_drain --file item_additional_effects_combined_resource_drain --file item_additional_effects_dispel_weapon
# exit 0, 284/284 aggregate; 193.550 seconds

xi_test.exe --keep-going --file 0x028_battle2
# exit 0, 65/65 packet regression; 55.941 seconds

cmake --build build-codex-phase-b5-final
# exit 0, 148/148 remaining all-target steps
```

Catch2 passed 19/19 with 9,007,079 assertions on every `xi_test` invocation.
The build linked `xi_connect`, `xi_map`, `xi_search`, and `xi_world`; `xi_test`
had already completed its 906/906 build.

A restart of the Phase-B5-only disposable MariaDB exposed empty trigger
definers in that disposable schema. Reloading the current repository trigger
and recipe SQL repaired only the disposable test database and removed test
fixture rows. The owner's working database and services were not touched, and
no project SQL changed.

Deterministic inventory output has 420 rows, 21 maintained Vanilla/Zilart
profiles, three exact Dispel profiles, and 341 unchanged repository-wide
diagnostics. Two consecutive writes matched:

- CSV: `FA157E41618D74F41F4F70493842AA9AE2E50A85A5122720E93E229B0160BE2D`;
- Markdown: `8F647BB1A90644785B30AC7B288180C45ECBE4A627D44876102DB6B7702E5BEF`.

Inventory generation twice, `--check`, profile sanity, the repository Lua
style/binding/purity check, Black, pylint errors-only, and
`git diff --check` passed. No C++/header or SQL changed, so clang-format and
SQL/dbtool mutation were not applicable. The disposable MariaDB was stopped
only after verifying its executable and port. The four named Phase B5
database/build directories and ten generated root executables/PDBs were
removed; the owner's database remained running and untouched.

Phase B5 is `COMPLETE_PHASE_B5` as a bounded evidence/profile/framework pass.
The three items are not claimed retail-formula-correct, and
`VZ-COMBAT-001` remains partial. Phase B6 should separately evidence-gate
Balmung, Claustrum, and every other remaining Dispel configuration rather
than generalizing the exact Phase B5 policy.

## Client/live-retail-only candidates

- Temple door rendered timing and complete mission-route traversal.
- Fishing curve coefficients and exact Waders magnitude.
- Conquest fractional rounding if retail differs from current truncation.
- Call-for-Help reward suppression, outside-player attackability, claim
  color/radar, and rendered client update. Source tracing supports these paths,
  but this pass does not label them end-to-end validated.
- Shadowbind numeric accuracy/level/duration/resist/Recycle behavior.
- Attack-while-fishing release-packet ordering, rendered animation/message
  timing, and invalid-target retail presentation. The client fishing packet
  has no session token, so an old CheckHook received during a new waiting
  phase is protocol-indistinguishable.
- Ark Angel move-by-move ready/no-ready behavior and rendered ordering of a
  same-update zero-time start/finish pair.
- Item additional-effect governing-stat/dSTAT and item-family proc/resist
  datasets, damage type/scaling, drain ordering/accuracy, self-buff/Death/
  spikes formulas, and exact client presentation beyond Phase A.
- Controlled Aspir Knife/Bloody Rapier/Shinsoku datasets separating proc
  from resist and varying amount/scaling, skill/stat/dSTAT, Dark resistance,
  multipliers/defenses/null/absorb/undead, empty/full resource caps,
  main/off-hand priority, lethal HP-drain ordering, and 0x028 presentation.
- Controlled Lockheart/Mythril Heart/Mythril Heart +1 datasets separating
  proc from no eligible effect and varying multi-buff selection, protected
  categories, retry, level/accuracy/skill/resistance hypotheses, Enspell and
  multi-attack eligibility, and raw 0x028 presentation. Obtain direct dated
  Vanilla/Zilart evidence naming Mythril Heart +1.

## Recommended next pass

Begin a bounded `VZ-COMBAT-001` Phase B6 pass by separately evidence-gating
Balmung, Claustrum, and the other remaining Dispel configurations in the
generated inventory. Do not migrate them automatically from the exact Phase
B5 registry. Then continue `VZ-JOB-001`, `VZ-SYS-001`, and the exhaustive
Vanilla/Zilart audit in bounded passes, followed by the remaining expansions
through Treasures of Aht Urhgan.

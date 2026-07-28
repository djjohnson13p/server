# Codex Completion Report — Vanilla + Rise of the Zilart

Status: BOUNDED_PASS_COMPLETE_PROJECT_IN_PROGRESS

## Branch and source state

- Repository: `djjohnson13p/server`
- Work branch: `retail-parity/codex-vanilla-zilart`
- Current bounded-pass starting commit: `27192abe552cca8223d4be9637b774e25113f73f`
- Pinned upstream baseline: `242ab0d055dfb80396e7398b0dd7361b750c74e2`
- Upstream pull requests: none; prohibited
- Upstream push: disabled/prohibited

The bounded `VZ-COMBAT-001` Phase B1 pass is complete. Fire Arrow, Ice Arrow,
and Lightning Arrow now use one exact-scope scripted profile registry with
real ranged-state, packet, ammunition, mitigation, and validation coverage.
Element identity is evidence-backed and packet amount now follows actual HP
change at caps.

The overall finding remains partial. No controlled retail formula was found,
so the inherited 100% proc, uniform 7-10 power, A+ rank, no-stat model,
resistance floor, and multipliers remain explicit compatibility/
`VERIFY_LIVE`, not retail conclusions. Seven findings are fully implemented
and test-backed; Shadowbind and item additional effects remain deliberately
partial where evidence is insufficient.

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

## Recommended next pass

Begin one bounded `VZ-COMBAT-001` Phase B family/configuration group using
the generated inventory and its evidence classifications. Then continue
`VZ-JOB-001`, `VZ-SYS-001`, and the exhaustive Vanilla/Zilart audit in
bounded passes.

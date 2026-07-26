# Codex Completion Report — Vanilla + Rise of the Zilart

Status: BOUNDED_PASS_COMPLETE_PROJECT_IN_PROGRESS

## Branch and source state

- Repository: `djjohnson13p/server`
- Work branch: `retail-parity/codex-vanilla-zilart`
- Current bounded-pass starting commit: `94806464c77e3cdd3c21d15cf78c85f2613beaa9`
- Pinned upstream baseline: `242ab0d055dfb80396e7398b0dd7361b750c74e2`
- Upstream pull requests: none; prohibited
- Upstream push: disabled/prohibited

The bounded `VZ-BF-001` pass is complete. Ready-message policy is explicit
and engine-owned after successful mob-skill state entry. Zero-time Ark Angel
skills can emit one proper start immediately before one finish without an
artificial delay, while repeatable Lua eligibility checks emit no packets.
Seven findings are implemented and test-backed. Shadowbind remains a
test-backed partial correction because its exact accuracy, relative-level,
duration/resist, and Recycle coefficients remain unsupported by sufficient
evidence.

## Commits created

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
python tools/dbtool.py setup xidb_codex_vz_bf_001_202607251900
```

Result: exit `0`; all current SQL, including
`mob_skill_start_messages.sql`, imported. The owner's working `xidb` was not
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
- `xidb_codex_vz_bf_001_202607251900`: dropped and confirmed absent.
- Owner working `xidb`: not modified.

### Retail/client uncertainty retained

- Exact ready/no-ready policy for Shield Strike, Charm, job specials, and
  other Ark Angel moves with no repository ready evidence.
- Exact client rendering order for a same-update zero-time start/finish pair.
- Any alternate retail start message not represented in current production
  data. Alternate-message transport is covered only by a synthetic C++
  policy fixture.

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

## Finding still partial

`VZ-JOB-002` remains partial only where evidence is insufficient:

- `/RNG` accuracy penalty, if any;
- relative target-level correction;
- ranged-accuracy contribution;
- whether `BIND_MEVA` is the correct terminal roll;
- duration/partial-resist rules;
- Recycle behavior beyond the tested Unlimited Shot path.

No spell-skill, dSTAT, ranged-accuracy, subjob, or level formula was invented.

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

## Recommended next pass

Begin `VZ-COMBAT-001` item additional-effect inventory and framework work.
Then continue `VZ-JOB-001`, `VZ-SYS-001`, and the exhaustive Vanilla/Zilart
audit in bounded passes.

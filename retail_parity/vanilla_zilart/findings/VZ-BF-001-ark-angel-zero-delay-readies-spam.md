# VZ-BF-001 — Ark Angel and Humanoid Zero-Delay Ready Messages

## Identification

- **ID:** `VZ-BF-001`
- **Expansion scope:** Rise of the Zilart
- **Area:** Ark Angels / Divine Might / humanoid mob skills
- **Baseline status:** `INACCURATE`
- **Fork status:** `CORRECTED_SERVER_DEFECT_RETAIL_PRESENTATION_PENDING`
- **Severity:** `MODERATE`
- **Confidence:** `HIGH` for the repeated-check defect and corrected packet
  ownership; `MEDIUM` for inherited per-move ready policy
- **Disposition:** `CODEX_COMPLETE`

## Confirmed defect

LandSandBoat issue
[#3611](https://github.com/LandSandBoat/server/issues/3611) records repeated
Ark Angel ready lines while the intended target is out of range. Current
source tracing confirmed the mechanism:

1. `CMobController::MobSkill` calls Lua `onMobSkillCheck` while selecting a
   candidate, before its range check.
2. The controller can repeat this work on later combat ticks while the
   candidate remains unusable.
3. Seventeen humanoid scripts emitted a user-visible `messageBasic` ready
   line from that repeatable callback.
4. A zero-activation-time `CMobSkillState` emitted no engine start action,
   so the scripts were compensating for a missing state-entry policy.
5. The compensation used a basic-message packet instead of the ordinary
   battle-action `SkillStart` packet.

Changing activation time to one second would alter timing and
interruptibility. Moving the same scripted packet to `onMobSkillUse` would
retain split ownership and the wrong packet path. Neither workaround was
used.

## Lifecycle and packet inventory

| Case | Baseline start behavior | Fork behavior |
|---|---|---|
| Positive activation, ordinary policy | One engine `SkillStart`, message 43 | Unchanged |
| Positive activation, `NO_START_MSG` | A `SkillStart` action whose result used message 0 | No start action |
| Zero activation, no explicit policy | No start; immediate finish | Unchanged |
| Zero activation, inherited scripted ready | Repeatable basic message from `skillCheck`; no engine start | One engine `SkillStart` after state entry, then immediate finish |
| Explicit alternate start | Not representable independently | Explicit message ID in the policy table |
| `NO_FINISH_MSG` | Finish policy independent | Still independent |

`CMobSkillState` validates Amnesia/Impairment and the target in its constructor.
Only after `CAIContainer` successfully installs the state does `Enter()` emit
the configured start action, trigger `WEAPONSKILL_STATE_ENTER`, spend TP, and
immediately update a zero-time state. Positive-time states retain their
existing preparation, facing, interruption, and completion behavior.

The action target remains:

- caster for a true `TARGET_SELF` skill;
- current battle target for an attacker-centered damaging area skill;
- validated target for an ordinary targeted skill;
- caster as the safe presentation fallback;
- caster when `map.HIDE_READIES_TARGET` is enabled for a non-player actor.

The start action is one `0x028` battle action with category `SkillStart`,
action ID `FourCC::SkillUse`, skill ID as its result parameter, and the
resolved `MsgBasic`. It is sent before an immediate zero-time finish. No
`0x029` basic ready packet is generated.

## Explicit policy model

`sql/mob_skill_start_messages.sql` owns explicit start-message policy:

- no row: backward-compatible default (positive time uses message 43; zero
  time has no start);
- message `0`: explicitly no start action;
- positive message ID: emit that message in one normal `SkillStart` action;
- pool `0`: skill-wide policy;
- nonzero pool: encounter/pool override;
- `SKILLFLAG_NO_START_MSG`: authoritative no-start compatibility override.

This keeps start and finish policy separate and permits a shared script to
have a narrow encounter exception without mutating its shared `CMobSkill`
object. The table is loaded through the ordinary SQL/dbtool import path.

## Migrated manual ready-message inventory

All active ready-message side effects were removed from
`onMobSkillCheck`. The policy table replaces them as follows:

| Script | Skill IDs with standard start policy | Notes |
|---|---:|---|
| `burning_blade.lua` | 33 | Generic humanoid |
| `circle_blade.lua` | 38, 938 | Generic and Ark Angel HM |
| `fast_blade.lua` | 32 | Generic humanoid |
| `fast_blade_ii.lua` | 229 | Generic humanoid |
| `flat_blade.lua` | 35 | Trion pool exception below |
| `gust_slash.lua` | 19 | Generic humanoid |
| `nott.lua` | 3502 | `READIES_SKILL` is the same confirmed message ID 43 |
| `red_lotus_blade.lua` | 34 | Trion/Volker pool exceptions below |
| `savage_blade.lua` | 42 | Trion pool exception below |
| `seraph_blade.lua` | 37 | Generic humanoid |
| `shining_blade.lua` | 36 | Generic humanoid |
| `skullbreaker.lua` | 165 | Generic humanoid |
| `spirits_within.lua` | 39, 942 | Generic and Ark Angel EV; Volker exception below |
| `swift_blade.lua` | 41, 939 | Generic and Ark Angel HM |
| `true_strike.lua` | 166 | Generic humanoid |
| `uriel_blade.lua` | 238 | Generic humanoid |
| `vorpal_blade.lua` | 40, 943 | Generic and Ark Angel EV; Volker exception below |

`aeolian_edge.lua` contained only a stale commented ready-message call; that
comment was removed. Repository-wide inspection found no other active
user-visible packet/text side effect in a mob-skill `onMobSkillCheck`.

The encounter-specific no-start policies are:

| Pool | Skill IDs | Preserved behavior |
|---:|---:|---|
| 4006, Qu'Bia Arena Trion | 968, 969, 970 | Red Lotus Blade, Flat Blade, and Savage Blade retain custom dialogue without a generic ready action |
| 4249, Throne Room Volker | 973, 974, 975 | Red Lotus Blade, Spirits Within, and Vorpal Blade retain custom dialogue without a generic ready action |

The scripts' eligibility, damage, effects, completion messages, and custom
dialogue remain in their original callbacks. Only ready-packet ownership
moved.

## Ark Angel policy and evidence

The four zero-time Ark Angel skills that had an active manual standard-ready
workaround retain that intended policy through explicit data:

- Ark Angel HM Circle Blade (938)
- Ark Angel HM Swift Blade (939)
- Ark Angel EV Spirits Within (942)
- Ark Angel EV Vorpal Blade (943)

Ark Angel EV Vorpal Blade and Ark Angel HM Circle Blade are exercised through
the real state and packet path. The remaining Ark Angel EV, GK, MR, and TT
zero-time moves that had no manual-ready evidence remain silent by the legacy
default; no Shield Strike, Charm, job-special, or other exception was
invented. Positive-time Ark Angel moves retain the legacy standard start
policy.

Evidence levels:

- **High:** repeated `skillCheck` packet defect, state-entry ownership,
  exactly-once `SkillStart`, zero-time ordering, no-start compatibility,
  positive-time regression, Trion/Volker repository dialogue behavior.
- **Medium:** the 21 migrated standard-ready skill IDs, because the fork
  preserves existing scripted intent while correcting packet ownership.
- **Unverified retail detail:** exact ready/no-ready policy for every
  individual Ark Angel move and exact client rendering of two same-tick
  start/finish actions.

## Behavioral validation

Automated tests prove:

- repeated out-of-range controller consideration of a real humanoid skill
  list emits no `SkillStart`, fake ready message, finish, or TP cost;
- Ark Angel EV Vorpal Blade enters once, emits exactly one correct start
  action, immediately emits exactly one finish action in that order, spends
  TP once, and does not repeat on a later tick;
- zero-time Shield Strike executes with no start action;
- a positive-time skill starts once, cannot finish early, finishes once, and
  can be interrupted without a finish;
- positive-time `NO_START_MSG` suppresses only start and retains finish;
- explicit standard, no-start, alternate-message, pool override, copied-skill,
  and independent `NO_FINISH_MSG` policies resolve in Catch2;
- true self, enemy target, attacker-centered area, missing presentation
  target, and both `HIDE_READIES_TARGET` settings resolve correctly;
- Amnesia prevents state creation, packets, and TP spending;
- real Trion and Volker battlefield phases preserve exactly one custom
  dialogue packet and no generic start;
- the full 65-case `0x028` packet suite preserves mob skills, pet Ready,
  wyvern breaths, Blood Pacts, player weapon skills, interruption, and
  unrelated action packets;
- the new repository purity check rejects any future manual
  `READIES_WS`/`READIES_SKILL` call inside `onMobSkillCheck`.

## Classification and remaining uncertainty

The confirmed server defect is corrected: repeatable eligibility checks are
packet-pure, and all configured starts are engine-owned, state-entry-bound,
proper battle actions. The architecture supports standard, no-start,
alternate, zero-time, positive-time, and pool-specific policy without
changing activation duration.

The following remain client/live-retail validation candidates and do not
block the server correction:

- move-by-move confirmation of ready/no-ready policy for Ark Angel Shield
  Strike, Charm, job specials, and other moves for which the repository had
  no ready evidence;
- exact rendered ordering when a zero-time start and finish are serialized in
  the same server update;
- whether any retail encounter uses an alternate start message not present in
  current production data.

# VZ-CORE-002 — Safe Attack-While-Fishing Transition

## Identification

- **ID:** `VZ-CORE-002`
- **Title:** Server rejected attack actions during fishing even though retail permits them
- **Expansion scope:** Shared core / original release
- **Area:** Fishing / combat-state transitions / action validation
- **Baseline status:** `INACCURATE`
- **Severity:** `MINOR`
- **Confidence:** `HIGH` for the server correction; exact retail client presentation remains unverified
- **Implementation state:** `IMPLEMENTED_AND_TEST_BACKED_WITH_CLIENT_LIMITS`
- **Implementation commit:** `a5bdb74c3b7511a2f098a3dc28336cf70f91dafd`

## Expected retail behavior

A player in the fishing state can issue an attack action on retail. Correct
server parity requires a deliberate transition: a valid engagement must end
the active fishing attempt exactly once before combat starts, while invalid
attack requests must not corrupt the fishing session.

## Baseline behavior

At pinned baseline `242ab0d055dfb80396e7398b0dd7361b750c74e2`,
`GP_CLI_COMMAND_ACTION` validated `Attack` with `BlockedState::Fishing`. The
adjacent comment explicitly said retail permits the action and that the
server blocked it intentionally. If the validation flag were removed alone,
the accepted action would proceed to `PAI->Engage` without tearing down the
fishing response, animation, hooked monster, or reward-capable state.

## Fishing lifecycle discovered

Fishing is not a PAI state. `CCharEntity::isFishing()` derives from the
character's fishing animation, while `CCharEntity` owns the active
`fishresponse_t`, cast/recast times, hook delay, and server-side token.
Fishing progression is synchronous packet handling; no deferred fishing
reward callback or timer was found.

| Phase | Owner and start | Valid client input | Ordinary exit | Cleanup/reward boundary |
|---|---|---|---|---|
| Idle | Character animation is non-fishing; no response/token | `GP_CLI_COMMAND_ACTION::Fish` | Valid cast enters waiting | Rod, bait, area, level, animation, and recast validate before a session is allocated |
| Waiting/no bite | Character owns a placeholder response and fresh token; animation is `FISHING_START` | `RequestCheckHook`, `RequestRelease` | Check-hook runs `FishingCheck`; release cancels | No bait loss or reward on release; stale response/token must be destroyed |
| Hooked/minigame | Character owns the hooked response; animation is `FISHING_FISH` | `RequestEndMiniGame`, `RequestPotentialTimeout`, `RequestRelease` | End-minigame resolves synchronously; release completes/cancels | Existing interruption loses bait once, preserves rod, unhooks a reserved mob, and sends fishing release |
| Result awaiting release | End-minigame may have synchronously granted an item/fish, spawned a monster/chest, or recorded success; fishing animation remains | `RequestRelease` | Release may apply fishing skill-up, destroys response, clears animation | Successful resolution invalidates the token before release |
| Interrupted | Authoritative interruption owns teardown | No fishing input is valid | Ordinary Attack engagement continues | Token and response are invalidated, animation is cleared, hooked mob is released, and late inputs are rejected |

The fish-pool reservation for a generated hook occurs synchronously during
check-hook and is not a queued character reward. The existing authoritative
interruption does not return that population reservation; this correction
preserves that behavior.

## Correction implemented

The production path now:

1. Allows only `Attack` past the fishing blocked-state check. Magic,
   abilities, ranged attacks, weapon skills, mounting, interaction, and the
   other existing restrictions remain unchanged.
2. Performs ordinary target, target-type, distance, attack-delay, and PAI
   state-change validation in `CPlayerController::Engage` while the fishing
   session is still intact.
3. Calls the centralized, idempotent `fishingutils::InterruptFishing` only
   after those checks accept the engagement and before `CAttackState` starts.
4. Invalidates the active token and response, clears the fishing animation,
   applies the existing hooked-phase bait-loss rule exactly once, preserves
   the rod, unhooks a reserved fishing monster, and sends the existing
   `EVENTUCOFF::Fishing` release packet.
5. Uses a monotonically advancing nonzero character-local token sequence so a
   later session does not reuse the interrupted session's token.
6. Allocates the response/token only after cast, animation, rod, bait, and
   area validation succeeds.
7. Rejects fishing packets unless the character is in the correct waiting or
   hooked phase with a live response and matching nonzero token.
8. Invalidates token/cast state on ordinary release as well as attack
   interruption.

`CAIContainer::Internal_Engage` can fail only at its state transition after
the checks above. The new `CanChangeState` guard is evaluated before
interruption; with a valid target and a changeable state, the existing forced
`CAttackState` transition is the ordinary engagement path. No rollback or
PAI-wide rewrite was required.

Files changed:

- `src/map/packets/c2s/0x01a_action.cpp`
- `src/map/ai/controllers/player_controller.cpp`
- `src/map/packets/c2s/0x110_fishing_2.cpp`
- `src/map/utils/fishingutils.cpp`
- `src/map/utils/fishingutils.h`
- `src/map/entities/char_entity.cpp`
- `src/map/entities/char_entity.h`

## Automated validation completed

`scripts/tests/systems/fishing/attack_transition.lua` emits real Attack,
Fish, AttackOff, and fishing-minigame packets through the production
handlers. Eight cases cover:

- waiting/no-bite interruption before engagement, one release packet, no
  bait/rod change, and duplicate-Attack idempotence;
- a hooked fish at the latest server-side pre-resolution boundary, existing
  one-bait loss, rod preservation, no catch, no skill-up, and rejection of
  late End/Release input;
- a reserved fishing monster being unhooked without spawning, including
  stale completion input;
- invalid entity index, self target, out-of-range target, and despawned
  target preserving the original fishing session;
- End/Timeout packets in the waiting phase, duplicate CheckHook in the hooked
  phase, and malformed stamina input leaving the session and resources
  unchanged;
- ordinary release idempotence and a fresh token on the next session;
- attack, disengagement, and successful recovery into a fresh fishing
  session;
- unchanged blocking for magic, abilities, ranged attack, weapon skills, and
  repeated Fish, plus unchanged ordinary non-fishing engagement.

The controlled hooked-state fixture can only advance an already valid waiting
session and cannot start fishing, grant an item, resolve a catch, or bypass
the real Attack and late-packet handlers.

The final focused run passed 8/8 Lua cases. Every run also passed all 16
Catch2 cases and 9,007,070 assertions, including the existing fishing utility
coverage. Fresh MSVC/Ninja Debug configuration and the complete all-target
build passed.

## Guarantees proven

- Waiting interruption does not consume bait or change the rod.
- Hooked interruption consumes exactly one bait through the pre-existing
  cancellation rule and does not change the rod.
- Duplicate Attack and late fishing inputs do not repeat bait loss or client
  release.
- Interrupted fish do not grant catch items or fishing skill-up.
- Interrupted fishing monsters are unreserved and do not spawn.
- Wrong-phase or malformed fishing input cannot advance or restore the
  cancelled session.
- Invalid Attack targets do not half-clear or strand fishing.
- A later session receives a fresh internal token and remains usable after
  combat.
- No fishing fatigue implementation or deferred reward callback exists in the
  active path; therefore there was no independent fatigue/queued-callback
  state to clear or test.

## Remaining retail/client uncertainty

- The server reuses its established fishing interruption packet and animation
  cleanup. Exact retail client packet ordering, rendered animation timing,
  and whether retail uses an additional message cannot be confirmed without a
  client/live capture.
- The safe server policy is to preserve fishing for attacks rejected by
  ordinary entity, enemy-type, range, attack-delay, or PAI-change validation.
  Exact retail behavior for every invalid-target case is not documented.
- `GP_CLI_COMMAND_FISHING_2` carries no client-visible session token. A late
  CheckHook from an old cast that arrives during the indistinguishable waiting
  phase of a newly started cast cannot be distinguished at protocol level.
  Inputs received after cancellation, in the wrong phase, or after a hook are
  rejected and cannot award a stale result.
- The server-side catch-resolution function is synchronous. Tests cover the
  latest controllable boundary before it runs; they cannot interleave an
  Attack inside that function.

## Completion criteria

- [x] Attack is no longer categorically blocked by fishing.
- [x] Valid engagement ends fishing exactly once before combat begins.
- [x] Invalid Attack attempts preserve the active fishing session.
- [x] Response, token, animation, and hooked-monster state are cleaned.
- [x] Rod, bait, catch, skill-up, and duplicate-cleanup paths are automated.
- [x] Late, duplicate, malformed, and wrong-phase fishing packets are guarded.
- [x] Ordinary cancellation, later fishing, ordinary Attack, and other
      fishing action restrictions are regression-tested.
- [x] Native formatting, focused tests, fresh configuration, and complete
      Debug compilation pass.
- [ ] Exact retail client animation/message/packet ordering is live-capture
      validated.

The server finding is corrected and test-backed. The unchecked item is a
client-presentation validation candidate, not remaining server engineering.

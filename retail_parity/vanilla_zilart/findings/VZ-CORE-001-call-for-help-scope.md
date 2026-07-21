# VZ-CORE-001 — Call for Help Applies Only to the Current Battle Target

## Identification

- **ID:** `VZ-CORE-001`
- **Expansion scope:** Shared core / original release
- **Area:** Combat / claims / enmity / Call for Help
- **Baseline status:** `INACCURATE`
- **Severity:** `MODERATE`
- **Confidence:** `HIGH` for the implementation difference; broader retail edge cases require validation
- **Implementation state:** `CANDIDATE_CORRECTION_IMPLEMENTED`
- **Implementation commit:** `de408e05de4c8c44250f9db493492817bbe8db65`

## Expected retail behavior

Call for Help applies help state to every eligible claimed enemy on which the requesting player personally has enmity. It does not require an active battle target or active engagement. Eligible help-enabled mobs suppress normal rewards and become attackable under the retail Call for Help rules.

## Baseline behavior

At pinned baseline `242ab0d055dfb80396e7398b0dd7361b750c74e2`, the `Help` action:

1. Called `GetBattleTarget()`.
2. Inspected only that one mob.
3. Required the requesting player's ID in that mob's enmity container.
4. Applied the help flag only to that one mob.
5. Returned failure when no current battle target existed, even if the player retained personal enmity elsewhere.

The adjacent source TODO explicitly documented the missing multi-mob, unengaged retail scope.

## Correction implemented

The `Help` action now:

- iterates mobs within the requesting character's current zone instance through `ForEachMobInstance`;
- preserves the existing per-mob eligibility checks:
  - not already help-enabled;
  - the requesting player's ID exists in the mob's enmity container;
  - the mob has not blocked Call for Help;
- sets the help flag on every eligible mob;
- sends the success message once when at least one mob changes;
- sends the failure message only when no eligible mob exists;
- no longer depends on `GetBattleTarget()` or active engagement.

Files changed:

- `src/map/packets/c2s/0x01a_action.cpp`

## Validation completed

- The commit diff is confined to the `Help` action block.
- The pinned zone API defines `ForEachMobInstance(CBaseEntity*, FnRef<void(CMobEntity*)>)`.
- The implementation remains instance-scoped rather than iterating unrelated instances.
- Existing `SetCallForHelpFlag`, personal-enmity membership, and per-mob block checks are preserved.
- The resulting source was read back and the commit diff inspected.

## Remaining work

- Add automated tests for:
  - one eligible mob;
  - multiple eligible mobs;
  - no active battle target;
  - personal versus party-only enmity;
  - pets and charmed entities;
  - already-enabled mobs;
  - `m_CallForHelpBlocked` mobs;
  - battlefields, confrontations, and instance isolation;
  - mobs that retain enmity after a claim transition.
- Confirm whether an explicit claim-owner check is required in addition to personal enmity membership for edge cases.
- Verify experience, treasure, claim color, outside-player access, radar/client updates, and message behavior.
- Compile and run the server/tests in a functioning local/CI environment.

## Completion criteria

- [x] Call for Help no longer requires an active battle target.
- [x] Every currently eligible personal-enmity mob in the player's instance is processed.
- [x] Existing blocked/already-enabled checks remain intact.
- [x] Success/failure messaging is emitted once per request.
- [ ] Claim-transition and party/pet edge cases are covered by tests.
- [ ] Reward suppression and client-visible help state are validated.
- [ ] Native compilation and automated tests pass.

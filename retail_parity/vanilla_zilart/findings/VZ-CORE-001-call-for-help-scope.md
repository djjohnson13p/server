# VZ-CORE-001 — Call for Help Applies Only to the Current Battle Target

## Identification

- **ID:** `VZ-CORE-001`
- **Expansion scope:** Shared core / original release
- **Area:** Combat / claims / enmity / Call for Help
- **Baseline status:** `INACCURATE`
- **Severity:** `MODERATE`
- **Confidence:** `HIGH` for the implementation difference; broader retail edge cases require validation
- **Implementation state:** `IMPLEMENTED_AND_TEST_BACKED_WITH_CLIENT_LIMITS`
- **Implementation commit:** `de408e05de4c8c44250f9db493492817bbe8db65`
- **Hardening/validation commit:** `9e989c2c97395bcfef7828e339a80c49c91161dd`

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
- delegates eligibility to `battleutils::IsCallForHelpEligible`;
- requires a live mob that is not already help-enabled or blocked;
- requires matching confrontation, battlefield, instance, and battle ID;
- requires a current personal/party/alliance claim through `HasClaim`;
- requires positive requester CE or VE, not mere stale enmity-container
  membership;
- sets the help flag on every eligible mob;
- sends the success message once when at least one mob changes;
- sends the failure message only when no eligible mob exists;
- no longer depends on `GetBattleTarget()` or active engagement.

Files changed:

- `src/map/packets/c2s/0x01a_action.cpp`
- `src/map/utils/battleutils.cpp`
- `src/map/utils/battleutils.h`

## Automated validation completed

`scripts/tests/systems/combat/call_for_help.lua` emits the real Help action
packet. Nine focused cases prove:

- one eligible mob changes without an active target;
- multiple eligible mobs change and one success message is emitted;
- retained personal enmity after unclaim is rejected;
- a party claim without requester CE/VE is rejected;
- requester CE/VE on a party claim is accepted;
- pet-only enmity is not treated as master personal enmity;
- master CE/VE on a pet claim is accepted;
- already-enabled and explicitly blocked mobs do not change and one failure
  message is emitted;
- battle-ID and confrontation mismatches are rejected.

`src/test/tests/battleutils_tests.cpp` locks down the production instance
identity seam for non-instanced, same-instance, and different-instance
pointers. The Help action additionally enumerates through
`ForEachMobInstance`, so mobs outside the requester's instance are not
presented to eligibility.

The tests exposed a real defect in the inherited candidate: enmity-container
membership alone allowed unclaimed/stale entries. The implementation now
requires `HasClaim` and positive requester CE/VE. All focused Lua and Catch2
cases passed, and the full MSVC/Ninja Debug build passed.

## Side-effect trace

Source tracing confirms:

- `SetCallForHelpFlag(true)` clears `m_OwnerID`, which the Lua tests verify by
  observing that the requester no longer has claim.
- The same method marks `UPDATE_COMBAT`, causing the normal entity-update
  packet path to publish the flag.
- `ClaimMob` does not acquire ownership while the flag is set.
- `DistributeRewards` gates learning, records, experience/capacity, gil, and
  item drops behind a valid owner and a false Call-for-Help flag; clearing
  ownership therefore suppresses that reward path.
- called mobs use the existing all-zone target expansion for applicable mob
  AoE behavior.

Only claim clearing and message cardinality are directly asserted here.
Reward suppression, outside-player attackability, claim color/radar, and the
rendered client update remain source-traced rather than end-to-end validated.

## Remaining work

- Add a safe end-to-end reward/kill seam if the harness gains one; do not
  declare experience, treasure, or outside-player access client-validated
  from source tracing alone.
- Validate claim color, radar/client update, and outside-player attackability
  on client/live infrastructure at the final stage.
- Add a dedicated battlefield fixture if one becomes practical. Matching
  battle ID and confrontation behavior are already automated, and battlefield
  pointer identity remains enforced in production.
- Charmed-entity behavior was not manufactured because the existing pet/master
  cases cover the supported personal-enmity distinction without inventing an
  unsafe fixture.

## Completion criteria

- [x] Call for Help no longer requires an active battle target.
- [x] Every currently eligible personal-enmity mob in the player's instance is processed.
- [x] Existing blocked/already-enabled checks remain intact.
- [x] Success/failure messaging is emitted once per request.
- [x] Current claim plus positive personal CE/VE is required.
- [x] Claim-transition and party/pet edge cases are covered by tests.
- [x] Instance, battle-ID, and confrontation boundaries are enforced.
- [ ] Reward suppression and client-visible help state are validated.
- [x] Native compilation and automated tests pass.

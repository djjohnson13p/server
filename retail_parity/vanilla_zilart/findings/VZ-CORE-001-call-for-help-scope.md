# VZ-CORE-001 — Call for Help Applies Only to the Current Battle Target

## Identification

- **ID:** `VZ-CORE-001`
- **Title:** Call for Help does not apply to every claimed enemy on the player's enmity lists
- **Expansion scope:** Shared core / original release
- **Area:** Combat / claims / enmity / Call for Help
- **Status:** `INACCURATE`
- **Severity:** `MODERATE`
- **Confidence:** `HIGH` for the implementation difference; broader retail edge cases require validation
- **Disposition:** `CODEX`

## Expected retail behavior

Call for Help changes eligible claimed enemies into help-enabled targets so players outside the claimant's party or alliance can participate. Help-enabled enemies do not provide normal experience or item drops.

The LandSandBoat action handler itself documents the unimplemented retail scope: Call for Help applies to all claimed enemies on which the requesting player personally has enmity and does not require the player to be actively engaged.

## Current LandSandBoat behavior

At pinned baseline `242ab0d055dfb80396e7398b0dd7361b750c74e2`, `src/map/packets/c2s/0x01a_action.cpp` handles the `Help` action by:

1. Calling `PChar->GetBattleTarget()`.
2. Casting only that one target to `CMobEntity`.
3. Setting Call for Help only on that one mob when the player appears in its enmity container.
4. Returning `CannotCallForHelp` when there is no current battle target or that one target fails validation.

The adjacent TODO states that retail applies Call for Help to all claimed enemies on which the player personally has enmity and does not require engagement.

## Difference

LandSandBoat's result depends on the player's current battle target and active battle state. Retail behavior, as documented in the source TODO, is enmity-list based and may affect multiple eligible claimed enemies.

Consequences include:

- Additional enemies involved in the same pull may retain normal claim/reward behavior.
- A player with valid enmity but no current battle target may be incorrectly told that Call for Help cannot be used.
- Client-visible help state can become inconsistent across linked or multi-target encounters.

## Evidence

- **Current source:** `src/map/packets/c2s/0x01a_action.cpp`, `GP_CLI_COMMAND_ACTION_ACTIONID::Help`.
- **Supporting source areas:** `CMobEntity::SetCallForHelpFlag`, mob enmity containers, zone entity iteration, and mob-controller help-state handling.
- **General retail behavior:** https://ffxiclopedia.fandom.com/wiki/Call_for_Help
- **Uncertainty:** The exact inclusion rule for party/alliance-generated enmity, pets, charmed monsters, battlefields, and enemies with Call for Help blocked requires targeted tests.

## Reproduction

### Baseline server

1. Claim two enemies and personally generate enmity on both.
2. Remain engaged to only one, or disengage while preserving enmity.
3. Activate Call for Help.
4. Observe that only `GetBattleTarget()` is inspected and marked.
5. Verify claim color, outside-player attackability, experience, and drops for both enemies.

### Retail comparison

1. Personally establish enmity on multiple claimed enemies.
2. Use Call for Help while engaged to one target and while not engaged.
3. Record which enemies receive help state and which rewards are suppressed.
4. Repeat with party-generated versus personal enmity and with pets.

## Dependencies and regression risk

- Zone entity iteration and lifetime safety.
- Enmity-container membership.
- Claim ownership and party/alliance claims.
- Experience and treasure suppression.
- Call-for-help-blocked mobs and battlefields.
- Client update packets, radar markers, and claim color.

Risk is moderate because a correct implementation must find all eligible mobs without touching unrelated enemies or invalid entity pointers.

## Proposed correction

Implement a safe zone-level query for mobs that:

- are currently claimed;
- contain the requesting player's ID in their enmity container;
- are eligible for Call for Help;
- are not already help-enabled.

Apply the help flag to every eligible result, emit the appropriate message/update behavior once, and return failure only when no eligible mob exists. The action must not require `GetBattleTarget()` or active engagement.

## Implementation plan

- Trace claim ownership and `SetCallForHelpFlag` side effects.
- Add a safe entity-query helper if one does not already exist.
- Update the `Help` action handler.
- Add tests for one mob, multiple mobs, no battle target, personal versus non-personal enmity, blocked mobs, already-enabled mobs, and reward suppression.
- Defer only client-visible multi-target retail confirmation to final validation.

## Completion criteria

- Call for Help succeeds without an active battle target when eligible personal enmity exists.
- Every eligible claimed enemy on the player's enmity lists receives help state.
- Ineligible and unrelated enemies remain unchanged.
- Experience, drops, claim color, outside-player access, and client updates are consistent.
- Automated tests cover multi-target and failure cases.

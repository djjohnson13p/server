# VZ-CORE-002 — Attacking While Fishing Is Intentionally Blocked

## Identification

- **ID:** `VZ-CORE-002`
- **Title:** Server rejects attack actions during fishing even though retail permits them
- **Expansion scope:** Shared core / original release
- **Area:** Fishing / combat-state transitions / action validation
- **Status:** `INACCURATE`
- **Severity:** `MINOR`
- **Confidence:** `HIGH` that the behavior intentionally differs; exact retail state transition needs validation
- **Disposition:** `CODEX`

## Expected retail behavior

A player in the fishing state can issue an attack action on retail. Correct parity also requires the server to reproduce what happens to the active fishing attempt, animation, rod/catch state, and subsequent combat state when the attack begins.

## Current LandSandBoat behavior

At pinned baseline `242ab0d055dfb80396e7398b0dd7361b750c74e2`, `src/map/packets/c2s/0x01a_action.cpp` validates the `Attack` action with `BlockedState::Fishing`.

The adjacent source comment is explicit:

> It is possible to attack while fishing on retail and is disabled here on purpose.

Therefore, the difference is intentional and confirmed rather than inferred from an old issue.

## Difference

LandSandBoat rejects an attack request whenever the character is fishing. Retail accepts that action. The missing piece is not merely removing one validation flag; the fishing session must transition safely into combat without stale catch state, duplicated packets, invalid animation, or exploitable timing.

## Evidence

- **Current source:** `src/map/packets/c2s/0x01a_action.cpp`, attack validation.
- **Related systems to inspect:** fishing controller/state, fishing packets, animation state, PAI engagement, rod/bait consumption, and interruption cleanup.
- **Retail uncertainty:** Public documentation does not clearly specify whether attacking cancels the cast immediately, preserves a hooked catch, or follows a special interruption packet sequence.

## Reproduction

### Baseline server

1. Begin fishing and remain in the active fishing state.
2. Target an attackable enemy in range.
3. Issue an attack action.
4. Observe validation rejection due to `BlockedState::Fishing`.

### Retail comparison

1. Begin fishing with no bite and issue an attack.
2. Repeat while a bite or reeling state is active where possible.
3. Record fishing messages, animation, bait/rod state, combat engagement, and packets.
4. Repeat when the target is invalid, out of range, or the character is attacked first.

## Dependencies and regression risk

- Fishing state machine and cancellation cleanup.
- Character animation and action locking.
- Combat PAI engagement.
- Bait/rod/catch accounting.
- Packet ordering and anti-cheat validation.

The visible feature is small, but a one-line change without cleanup analysis could cause state corruption.

## Proposed correction

Add an explicit fishing-to-combat transition rather than simply allowing the existing attack path through. The transition should cancel or resolve the fishing attempt exactly once, clear fishing-specific state and animation, send required client updates, and then engage the target if the normal attack checks succeed.

## Implementation plan

- Trace every entry and exit path of the fishing state.
- Determine whether an existing fishing-cancel helper can be reused.
- Add a dedicated attack interruption path.
- Add tests for no-bite, hooked/reeling where testable, invalid target, repeated packets, bait/catch accounting, and clean subsequent fishing.
- Defer only exact client packet/animation comparison to final validation.

## Completion criteria

- Attack requests are no longer categorically blocked by the fishing state.
- Fishing is exited safely and exactly once before combat engagement.
- No rod, bait, catch, animation, or status state is duplicated or stranded.
- Automated tests cover transition and failure paths.

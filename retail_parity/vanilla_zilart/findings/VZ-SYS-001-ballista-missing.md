# VZ-SYS-001 — Ballista System Missing

## Identification

- **ID:** `VZ-SYS-001`
- **Title:** Ballista gameplay system is not functionally implemented
- **Expansion scope:** Shared core; pre-Chains-of-Promathia system within the Vanilla + Rise of the Zilart audit boundary
- **Area:** Conflict / Ballista / player-versus-player
- **Status:** `MISSING`
- **Severity:** `MAJOR`
- **Confidence:** `HIGH`
- **Disposition:** `AI_PLUS_HUMAN_TESTING`

## Expected retail behavior

Retail Ballista is a scheduled nation-versus-nation Conflict activity. At minimum, the observable system includes:

- Ballista qualification/license progression.
- Match schedule and eligible-nation selection.
- Herald registration and match-state transitions.
- Team assignment and participation restrictions.
- Player-versus-player combat rules.
- Digging for Petras.
- Gate Breach qualification.
- Rook discovery and scoring.
- Match timer, scoreboard, result resolution, points, and rewards.
- Client-visible Ballista scoreboard and scout information.

Square Enix's official Ballista documentation describes registration through a Herald, digging for Petras, locating Rooks, Gate Breach, scoring, and timed match resolution.

## Current LandSandBoat behavior

At pinned baseline `242ab0d055dfb80396e7398b0dd7361b750c74e2`:

- `src/map/packets/s2c/0x0e6_ballista.h` defines packet structures for `SCOREBOARD` and `SCOUT`, but both constructors are explicitly marked `TODO: Unimplemented`.
- Repository-wide source searches for `ballista`, `BALLISTA LICENSE`, `Herald Ballista`, `Petra`, `Gate Breach`, and Ballista-specific Rook behavior found constants, titles, packet identifiers, and unrelated name matches, but no functional match controller, registration flow, schedule manager, license quest chain, Petra/Rook gameplay logic, scoring state machine, or reward resolution.
- Ballista titles are present in title-enum/title-changing data, but title data is not gameplay implementation.

## Difference

The client protocol contains partial Ballista metadata support, but the server does not provide the retail gameplay system. A player cannot complete the expected qualification-to-match gameplay loop.

## Evidence

- **Official source:**
  - https://www.playonline.com/ff11us/guide/conflict/ballista01.html?pageID=conflict
  - https://www.playonline.com/ff11us/guide/conflict/ballista02.html?pageID=conflict
  - https://www.playonline.com/ff11us/guide/development/vt/26/02-2.html
- **Current source:**
  - `src/map/packets/s2c/0x0e6_ballista.h`
- **Retail observation/test:** Still required for current packet fields, exact schedules, rewards, edge cases, and modern-retail rule adjustments.
- **Contradictory evidence or uncertainty:** Ballista rules changed repeatedly after introduction. The initial implementation target must explicitly choose current-retail behavior for pre-CoP-origin content while recording historical differences.

## Reproduction

### Fork/server test

1. Start a clean server at the pinned baseline.
2. Attempt the retail Ballista qualification and registration flow for an eligible character.
3. Search for a working Herald registration option and initiate an official match.
4. Verify that no complete match can progress through Petra digging, Gate Breach, Rook scoring, scoreboard updates, and match resolution.

### Retail comparison

1. Confirm current Ballista access requirements and schedule behavior on retail.
2. Capture registration, match-start, scoring, scout, scoreboard, match-end, and reward packets.
3. Record nation eligibility, level restrictions, temporary-item behavior, status-effect adjustments, and disconnect/rejoin handling.

## Dependencies and regression risk

- PvP targeting, alliance/party behavior, enmity, damage, status effects, and death/raise rules.
- Zone scheduling and dynamic event state.
- Character qualification/license variables and key items.
- C2S/S2C packet handling, particularly packet `0x0E6`.
- Conquest/nation affiliation, rewards, titles, and match points.
- Later Conflict content must remain separable from Ballista.

Risk is high because this is a cross-cutting system with client-protocol, combat, persistence, scheduling, and content dependencies.

## Proposed correction

Implement Ballista as a dedicated, testable server-side state machine rather than scattered NPC scripts. Separate qualification, scheduling, registration, match lifecycle, field objects, scoring, rewards, and packet serialization. Keep rule data configurable so historical and current-retail variants can be compared without duplicating the engine.

## Implementation plan

- **Assistant-direct work:** Audit documentation, define state transitions, create test matrices, review bounded scripts/data, and implement isolated low-risk helpers.
- **Codex work:** Build the multi-file Ballista engine, persistence, NPC integration, packet constructors, automated state-machine tests, and integration tests.
- **Files likely affected:** New Ballista globals/services; Herald and qualification NPC scripts; character persistence/variables; zone/event lifecycle; PvP combat checks; packet `0x0E6`; tests and fixtures.
- **Tests to add or extend:** Qualification, registration, eligibility, team assignment, match phases, Petra inventory, Gate Breach, Rook scoring, timer/result handling, disconnects, and packet serialization.
- **Human validation required:** Current-retail captures and full client playtests.
- **Beyond reliable AI:** Deriving undocumented packet semantics or exact retail edge-case rules without captures.

## Completion criteria

- A player can obtain the required qualification/license through retail-equivalent progression.
- Eligible players can register with a Herald for a scheduled match.
- A match reliably progresses through all phases and enforces retail-equivalent PvP rules.
- Petra, Gate Breach, Rook, scoring, timer, scoreboard, results, rewards, and persistence work.
- Automated tests cover deterministic server state transitions.
- Human retail comparison validates client-visible behavior and packet fields.

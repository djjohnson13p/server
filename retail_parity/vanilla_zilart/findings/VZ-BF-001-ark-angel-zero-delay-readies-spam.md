# VZ-BF-001 — Ark Angel Zero-Delay Weapon Skills Emit Incorrect Repeated “Readies” Messages

## Identification

- **ID:** `VZ-BF-001`
- **Title:** Ark Angel weapon skills fake ready messages in the skill-check callback, producing repeated and packet-inaccurate messages
- **Expansion scope:** Rise of the Zilart
- **Area:** Ark Angels / Divine Might / mob-skill state and client messaging
- **Status:** `INACCURATE`
- **Severity:** `MODERATE`
- **Confidence:** `HIGH`
- **Disposition:** `CODEX`

## Expected retail behavior

Ark Angel weapon skills should present the correct client-visible preparation/use messaging for each skill. A zero-delay or instant mob skill must not repeatedly broadcast a “readies” message every time the server re-evaluates whether the skill can execute. Skills that retail presents only with a use message must not receive a fabricated ready message.

## Current LandSandBoat behavior

At pinned baseline `242ab0d055dfb80396e7398b0dd7361b750c74e2`:

- Open upstream issue `#3611` reproduces repeated “Ark Angel EV readies Spirits Within” and similar messages by engaging Divine Might, giving an Ark Angel TP, and moving out of range.
- The issue is reported against `base` and remains open.
- Maintainer discussion identifies the cause as zero-delay skills manually emitting ready text from the skill-check path. Skill checks can execute repeatedly before the skill is used.
- The discussion also states that the manually faked message is packet-inaccurate and that changing delay from zero to one would merely make one bug conceal another.
- Current `scripts/actions/mobskills/spirits_within.lua` still calls `mob:messageBasic(xi.msg.basic.READIES_WS, 0, 39)` inside `onMobSkillCheck` for nearly every user of the skill.
- Source search finds the same manual `READIES_WS` pattern across numerous humanoid weapon-skill scripts used by Ark Angels and other NPC combatants.

## Difference

The ready message is coupled to a callback that may execute more than once and is used as a workaround for missing zero-delay message semantics. This causes repeated messages and can emit the wrong message type compared with retail. The defect is shared infrastructure plus data, not merely one Ark Angel script.

## Evidence

- **Current source:**
  - `scripts/actions/mobskills/spirits_within.lua`
  - Other mob-skill scripts found through the same manual `READIES_WS` pattern
  - Mob-skill state/message infrastructure to be traced by Codex
- **Upstream issue:** https://github.com/LandSandBoat/server/issues/3611
- **Reproduction:** The upstream issue provides exact Divine Might reproduction steps and screenshot evidence.
- **Maintainer analysis:** Issue discussion explains the repeated skill-check execution, the fabricated message, and why altering skill delay is not a correct fix.
- **Uncertainty:** The exact ready/use message behavior must be established per skill from retail captures. The architecture defect and repeated-message behavior are confirmed independently.

## Reproduction

### Fork/server test

1. Enter Divine Might with Ark Angel EV active.
2. Engage, grant sufficient TP, then move outside the selected weapon skill’s valid range.
3. Allow the AI to repeatedly evaluate the skill.
4. Observe repeated ready messages without corresponding skill execution.
5. Repeat with other Ark Angel zero-delay humanoid weapon skills.

### Automated test

1. Build a mob-skill state fixture whose skill check executes repeatedly before use.
2. Verify a single attempted skill does not emit multiple ready messages.
3. Verify message selection is independent of cast duration and comes from explicit skill data/state behavior.
4. Verify instant skills that should have no ready message emit only the appropriate use result.

## Dependencies and regression risk

- Mob-skill state lifecycle and check/use callbacks.
- `mob_skills.sql` timing and any message metadata.
- Battle action packets and localized battle messages.
- All mob weapon skills manually emitting `READIES_WS`, not only Ark Angels.
- NPC skills that genuinely need a visible ready message despite minimal delay.

Regression risk is high if solved by globally suppressing messages or changing skill delays. The correct solution must preserve per-skill messaging semantics.

## Proposed correction

Move ready-message emission out of repeatable skill-check scripts and into a single state transition that occurs once per committed skill attempt. Add explicit per-skill message metadata or another data-driven mechanism that can express:

- standard ready message;
- alternate ready message;
- no ready message;
- instant use with only a use message.

Migrate Ark Angel and related humanoid weapon skills away from manual `onMobSkillCheck` message calls.

## Implementation plan

- **Assistant work completed:** Verified the open issue against the pinned source and confirmed the manual message remains in current skill scripts.
- **Codex work:** Trace the complete mob-skill state and packet path, design the smallest data-driven message model, migrate affected scripts/data, and add state/message regression tests.
- **Do not:** Change zero-delay skills to one-second skills solely to force a message, or remove every message without per-skill evidence.
- **Human validation required:** Retail capture comparison for Ark Angel EV Shield Strike, Spirits Within, Charm, and representative other Ark Angel weapon skills.

## Completion criteria

- Repeated skill checks cannot produce repeated ready messages for one attempted action.
- Ark Angel skills emit the correct ready/use sequence according to explicit data.
- Zero-delay timing remains zero-delay when retail requires it.
- Manual ready-message calls are removed from migrated scripts.
- Automated tests reproduce the baseline spam and pass after correction.
- Final retail captures validate representative Ark Angel skills.

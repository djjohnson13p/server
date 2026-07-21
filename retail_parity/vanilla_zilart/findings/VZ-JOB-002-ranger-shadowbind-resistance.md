# VZ-JOB-002 — Ranger Shadowbind Uses an Incomplete Accuracy and Resistance Model

## Identification

- **ID:** `VZ-JOB-002`
- **Title:** Shadowbind bypasses the standard status-resistance pipeline and omits known accuracy factors
- **Expansion scope:** Vanilla
- **Area:** Ranger / Shadowbind / ranged job ability
- **Status:** `INACCURATE`
- **Severity:** `MODERATE`
- **Confidence:** `HIGH` for the implementation defect; exact retail formula remains unresolved
- **Disposition:** `CODEX` with final retail validation

## Expected retail behavior

Shadowbind is a ranged Ranger job ability that consumes ammunition and attempts to apply Bind. Retail-equivalent behavior requires:

- Correct ranged weapon and ammunition validation.
- One round of ammunition consumed subject to any retail ammunition-preservation rules.
- Target immunity and status-nullification handling.
- An accuracy/resistance calculation that accounts for the applicable Ranger level or subjob penalty, target level and resistance, and any Shadowbind-specific modifiers.
- Correct success and miss messaging.

The exact retail accuracy equation is not established by this finding. The minimum requirement is that Shadowbind not use a raw target-modifier roll that bypasses the server's normal status-effect validation and resistance abstractions.

## Current LandSandBoat behavior

At pinned baseline `242ab0d055dfb80396e7398b0dd7361b750c74e2`:

- `sql/abilities.sql` defines `shadowbind` as Ranger level 40 with an enemy target and a 20-yalm range.
- `scripts/globals/job_utils/ranger.lua` validates an archery or marksmanship weapon/ammunition combination.
- On use, the code calculates duration, then compares a uniform random integer directly against `target:getMod(xi.mod.BIND_MEVA)`.
- It only checks whether Bind is already present; it does not call the shared target-immunity, target-resistance, effect-nullification, or resist-rate helpers used by other current status abilities.
- The code explicitly contains `TODO: Acc penalty for /RNG, acc vs. mob level?`.
- It consumes one ammunition item when the ranged subsystem says ammunition should be used.

## Difference

Shadowbind's Bind application is governed by a simplified raw roll. The implementation explicitly omits subjob and target-level accuracy behavior and does not consistently participate in shared immunity/resistance handling. This can produce materially incorrect success rates and behavior against resistant or immune targets.

## Evidence

- **Current source:**
  - `scripts/globals/job_utils/ranger.lua`
  - `sql/abilities.sql`
- **Source admission:** The active implementation explicitly marks the subjob and mob-level accuracy behavior as unresolved.
- **Retail observation/test:** Needed to establish the exact skill basis, level correction, modifiers, immunity behavior, duration reduction, and ammunition-preservation interaction.
- **Uncertainty:** Shadowbind may use a job-ability-specific model rather than a standard magic-skill formula. The correction must not blindly copy a spell formula.

## Reproduction

### Fork/server test

1. Use Shadowbind against targets with controlled level, `BIND_MEVA`, explicit Bind immunity, resistance traits, and existing Bind.
2. Repeat as main-job Ranger and `/RNG` with the same ranged-accuracy equipment.
3. Record success rate, effect duration, messages, and ammunition consumption.
4. Confirm that the baseline can apply or reject Bind based only on the direct `BIND_MEVA` comparison and existing-effect check.

### Retail comparison

1. Repeat controlled trials as Ranger main and Ranger subjob against targets of several relative levels.
2. Test targets known to be Bind immune or resistant.
3. Separate activation success, resist result, and duration.
4. Test Recycle or other ammunition-preservation interaction if applicable.

## Dependencies and regression risk

- Status immunity, resistance traits, and effect-nullification helpers.
- Magic hit-rate or a dedicated physical job-ability accuracy model.
- Ranger main/subjob level and ranged accuracy.
- Ammunition consumption and Recycle.
- Existing Bind overwrite and duration behavior.

Regression risk is moderate because a correction is localized but the exact formula may share or require a new reusable ability-resistance path.

## Proposed correction

Route Shadowbind through a dedicated, explicit accuracy/resistance calculation that first checks immunity, resistance traits, and nullification. Parameterize the factors supported by evidence rather than hardcoding a raw `BIND_MEVA` roll. Keep proc success and duration reduction separately testable.

## Implementation plan

- **Assistant-direct work:** Source audit, finding definition, test matrix, and review of a candidate patch.
- **Codex work:** Trace current ranged and status systems, implement the supported Shadowbind accuracy path, add tests for main/subjob, relative level, immunity, resistance, existing Bind, messaging, and ammunition use.
- **Files likely affected:** `scripts/globals/job_utils/ranger.lua`, combat/status helper code if a dedicated ability path is needed, and tests.
- **Human validation required:** Controlled retail rate and duration data.
- **Stop condition:** Do not invent a skill rank or dSTAT formula when the evidence is insufficient; implement only established factors and mark remaining coefficients pending validation.

## Completion criteria

- Shadowbind respects target immunity, resistance traits, and status nullification.
- Main-job and subjob behavior is explicitly represented and tested.
- Relative-level behavior is represented when supported by evidence.
- Ammunition behavior remains correct.
- Automated tests cover success, failure, immunity, resistance, existing Bind, and messages.
- Unresolved numeric retail coefficients are clearly documented rather than guessed.

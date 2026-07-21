# VZ-ECON-003 — Moghancement: Region Awards No Conquest Influence Bonus

## Identification

- **ID:** `VZ-ECON-003`
- **Title:** The configured 10% Moghancement: Region bonus is truncated to zero before influence is awarded
- **Expansion scope:** Vanilla shared system
- **Area:** Conquest / Mog House / regional influence
- **Status:** `INACCURATE`
- **Severity:** `MODERATE`
- **Confidence:** `HIGH`
- **Disposition:** `CODEX` for the bounded C++ correction and tests

## Expected retail behavior

Moghancement: Region should increase the influence points awarded to the player's nation when conquest points generate regional influence. The server already represents the enhancement as a value of `10`, consistent with a 10% bonus.

## Current LandSandBoat behavior

At pinned baseline `242ab0d055dfb80396e7398b0dd7361b750c74e2`:

- `CCharEntity::changeMoghancement` handles `MOGHANCEMENT_REGION` by adding `10` to `Mod::CONQUEST_REGION_BONUS`.
- `modifier.h` describes `CONQUEST_REGION_BONUS` as increasing influence points awarded to the player's nation when receiving conquest points.
- `conquest::GainInfluencePoints` currently executes:

  `points += (uint32)(PChar->getMod(Mod::CONQUEST_REGION_BONUS) / 100.0);`

- With the configured modifier value `10`, `10 / 100.0` equals `0.1`, which is converted to `uint32` and truncated to `0` before being added.
- Even a value of `100` would add only one flat influence point rather than scaling the original award.

## Difference

The enhancement is present in Mog House selection and modifier state but has no effect at its configured value. Regional influence earned while Moghancement: Region is active is identical to influence earned without it.

## Evidence

- **Current source:**
  - `src/map/entities/char_entity.cpp` — `MOGHANCEMENT_REGION` adds modifier value `10`.
  - `src/map/modifier.h` — describes the modifier's purpose.
  - `src/map/conquest_system.cpp` — truncates `modifier / 100.0` and adds it as a flat integer.
- **Internal consistency evidence:** The encoded value, division by 100, and modifier description establish a percentage-style bonus; applying the division before multiplying by base points makes the encoded value ineffective.
- **Retail observation/test:** Useful to validate rounding behavior and confirm the exact 10% value, but not required to prove the current implementation awards zero.

## Reproduction

### Deterministic unit test

1. Create a character with no regional bonus and award a known influence amount, such as 50 or 100 points.
2. Create the same state with `CONQUEST_REGION_BONUS = 10`.
3. Intercept or inspect the `ConquestAddInfluencePoints` IPC payload.
4. Confirm the baseline sends the same point amount in both cases.
5. After correction, confirm the bonus case sends the base amount plus the expected percentage contribution.

### Integration test

1. Activate Moghancement: Region through furniture.
2. Earn conquest points that invoke `GainInfluencePoints`.
3. Compare the nation influence payload or resulting regional influence against a control character without the Moghancement.

## Dependencies and regression risk

- Conquest influence IPC messages and world-server aggregation.
- Mog House enhancement selection and modifier application.
- Integer rounding for small influence awards.
- Any custom modules that set `CONQUEST_REGION_BONUS` to values other than 10.

Regression risk is low because the correction is isolated to bonus arithmetic.

## Proposed correction

Apply the percentage to the base award before integer conversion, for example:

`points += static_cast<uint32>(points * PChar->getMod(Mod::CONQUEST_REGION_BONUS) / 100.0f);`

Choose floor/round behavior deliberately and cover it with tests. Clamp or validate negative custom modifier values if needed.

## Implementation plan

- **Assistant work completed:** Traced modifier creation, documented semantics, and influence arithmetic.
- **Codex work:** Correct `GainInfluencePoints`, add deterministic IPC-payload tests for 0%, 10%, 100%, small awards, and custom negative/large values as appropriate, then run conquest and C++ checks.
- **Human validation required:** None for proving the zero-bonus bug; optional retail observation for rounding at small influence values.

## Completion criteria

- A modifier value of 10 produces a nonzero percentage increase for ordinary influence awards.
- Zero modifier preserves baseline awards.
- Rounding behavior is explicit and tested.
- IPC/world conquest behavior remains unchanged apart from the intended bonus.
- Relevant automated checks pass.

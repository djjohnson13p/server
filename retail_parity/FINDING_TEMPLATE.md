# Finding Template

Use one section or one dedicated file per independently actionable discrepancy.

## Identification

- **ID:** `VZ-AREA-###`
- **Title:**
- **Expansion scope:** Vanilla / Rise of the Zilart / Shared core
- **Area:**
- **Status:** `RETAIL_EQUIVALENT | INACCURATE | PARTIAL | MISSING | VERIFY_LIVE | UNKNOWN`
- **Severity:** `BLOCKER | MAJOR | MODERATE | MINOR`
- **Confidence:** `HIGH | MEDIUM | LOW`
- **Disposition:** `ASSISTANT_DIRECT | CODEX | AI_PLUS_HUMAN_TESTING | BEYOND_RELIABLE_AI`

## Expected retail behavior

Describe the observable result, applicable conditions, timing, formulas, messages, state transitions, and known exceptions.

## Current LandSandBoat behavior

Describe what the current `base` code and data actually implement. Include repository paths and relevant symbols, IDs, or database rows.

## Difference

State the smallest precise difference between expected and implemented behavior. Separate confirmed differences from suspected ones.

## Evidence

- Official source:
- Retail observation/test:
- Independent corroboration:
- Historical evidence, when relevant:
- Contradictory evidence or uncertainty:

## Reproduction

### Fork/server test

1.
2.
3.

### Retail comparison

1.
2.
3.

## Dependencies and regression risk

List related jobs, zones, quests, packet behavior, SQL data, core systems, later-expansion content, and compatibility concerns.

## Proposed correction

Describe the intended behavior without prematurely prescribing code architecture.

## Implementation plan

- Files likely affected:
- Tests to add or extend:
- Human validation required:
- Rollback or configuration considerations:

## Completion criteria

Define objective conditions required before the finding may be marked resolved.

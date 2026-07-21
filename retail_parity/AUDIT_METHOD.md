# Audit Method

## Comparison targets

This project separates two questions that are often incorrectly combined:

1. **Current-retail equivalence:** Does the server behave like present-day retail FFXI for content and systems originating in Vanilla or Rise of the Zilart?
2. **Historical-era equivalence:** Does the server reproduce the behavior that existed during the original/Zilart era?

The primary target requested for this fork is current-retail equivalence or better. Historical behavior is recorded when it helps explain differences or when the desired behavior must be chosen explicitly.

## Audit sequence

For each system or content group:

1. Define the expected retail behavior and its evidence quality.
2. Locate all relevant C++, Lua, SQL, configuration, data, and test files.
3. Trace execution paths rather than relying on filenames or comments.
4. Identify interactions with later-expansion systems.
5. Record implementation status and confidence.
6. Define reproducible validation steps.
7. Assign implementation ownership and risk.
8. Implement only after the finding and test target are sufficiently clear.

## Evidence ranking

From strongest to weakest:

1. Reproducible current-retail observation, packet capture, or controlled test.
2. Official Square Enix documentation, update notes, manuals, or help text.
3. Multiple independent, well-documented retail observations.
4. Reputable community documentation with dated citations.
5. Archived era documentation or captures.
6. Existing emulator/private-server implementations.
7. Memory, assumptions, comments, TODOs, or uncited claims.

Weak evidence may identify an investigation target but cannot by itself support a high-confidence parity claim.

## Confidence

- `HIGH`: Code path and retail expectation are both well supported.
- `MEDIUM`: Likely conclusion, but one side has incomplete evidence or limited testing.
- `LOW`: Preliminary lead requiring further inspection or experimentation.

## Severity

- `BLOCKER`: Prevents completion of major progression or core operation.
- `MAJOR`: Materially changes combat, progression, economy, missions, or repeated gameplay.
- `MODERATE`: Noticeable functional difference with a workaround or limited scope.
- `MINOR`: Cosmetic, edge-case, text, timing, or low-impact discrepancy.

## Change rules

- Do not alter the fork's `base` branch for audit work.
- Do not open pull requests against `LandSandBoat/server`.
- Keep unrelated fixes in separate fork-owned branches when implementation begins.
- Every fix should include automated tests where practical and a human validation checklist where automation cannot establish retail parity.
- Do not label a system retail-equivalent merely because it compiles, runs, or has no open upstream issue.

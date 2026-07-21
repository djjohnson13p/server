# FFXI Retail-Parity Project

This directory tracks the private, fork-only effort to compare LandSandBoat behavior against Final Fantasy XI retail behavior and improve this fork where reliable implementation is possible.

## Repository policy

- Upstream: `LandSandBoat/server`
- Working fork: `djjohnson13p/server`
- Upstream pull requests are out of scope.
- Audit notes and implementation work remain on fork-owned branches.
- The upstream `base` branch remains a clean synchronization target.

## Current phase

**Phase 1: Original release (Vanilla) through Rise of the Zilart**

Assistant audit branch: `retail-parity/vanilla-zilart-audit`

Consolidated Codex branch: `retail-parity/codex-vanilla-zilart`

## AI-first execution

The project does not pause for owner testing after each finding.

1. The assistant audits and implements everything it can first.
2. Codex then receives one consolidated master task and completes all remaining AI-capable audit, implementation, testing, and review work.
3. The owner steps in only for the final human-only queue.

See `AI_FIRST_WORKFLOW.md`, `CODEX_GUIDE.md`, and `CODEX_MASTER_TASK.md`.

## Finding statuses

- `RETAIL_EQUIVALENT`: Evidence indicates behavior is equivalent to or better than current retail.
- `INACCURATE`: Implemented, but materially differs from retail.
- `PARTIAL`: Some required behavior or content exists, but important portions are absent.
- `MISSING`: No functional implementation was found.
- `VERIFY_LIVE`: Static inspection is insufficient; controlled server or retail testing is required.
- `UNKNOWN`: Reliable evidence is unavailable or contradictory.

## Implementation routing

Finding dispositions describe likely engineering ownership, not when the owner must intervene:

- `ASSISTANT_DIRECT`: The assistant should audit, implement, and review the bounded correction before handoff.
- `CODEX`: The assistant still completes all preparatory audit/evidence work; Codex receives the remaining multi-file or terminal-intensive engineering.
- `AI_PLUS_HUMAN_TESTING`: Assistant and Codex complete all possible implementation and automated validation before the item enters the final human queue.
- `BEYOND_RELIABLE_AI`: The behavior may ultimately require unavailable retail evidence or reverse engineering, but all independent AI-capable work must still be exhausted first.

## Evidence rule

No finding is treated as confirmed solely because a TODO, issue, comment, wiki page, or old private-server implementation claims it. Findings must distinguish:

1. What the current fork actually does.
2. What reliable evidence says retail does.
3. Whether the comparison is current-retail parity, historical-era parity, or both.
4. What remains uncertain.

Uncertainty delays a parity claim; it does not justify stopping unrelated audit or implementation work.

# FFXI Retail-Parity Project

This directory tracks the private, fork-only effort to compare LandSandBoat behavior against Final Fantasy XI retail behavior and improve this fork where reliable implementation is possible.

## Repository policy

- Upstream: `LandSandBoat/server`
- Working fork: `djjohnson13p/server`
- Upstream pull requests are out of scope.
- Audit notes and implementation work remain on fork-owned branches.
- The upstream `base` branch should remain a clean synchronization target.

## Current phase

**Phase 1: Original release (Vanilla) through Rise of the Zilart**

Working branch: `retail-parity/vanilla-zilart-audit`

## Finding statuses

- `RETAIL_EQUIVALENT`: Evidence indicates behavior is equivalent to or better than current retail.
- `INACCURATE`: Implemented, but materially differs from retail.
- `PARTIAL`: Some required behavior or content exists, but important portions are absent.
- `MISSING`: No functional implementation was found.
- `VERIFY_LIVE`: Static inspection is insufficient; controlled server or retail testing is required.
- `UNKNOWN`: Reliable evidence is unavailable or contradictory.

## Implementation ownership

Every actionable finding must be assigned one of these dispositions:

- `ASSISTANT_DIRECT`: Small, well-bounded change that can be implemented and reviewed directly.
- `CODEX`: Repository-wide or multi-file engineering task suited to Codex with a precise prompt and tests.
- `AI_PLUS_HUMAN_TESTING`: AI can implement a candidate fix, but authoritative validation requires human gameplay, packet captures, timing measurements, or retail comparison.
- `BEYOND_RELIABLE_AI`: Requires undocumented proprietary behavior, extensive reverse engineering, unavailable evidence, or expert live-retail research beyond reliable AI inference.

## Evidence rule

No finding is treated as confirmed solely because a TODO, issue, comment, wiki page, or old private-server implementation claims it. Findings must distinguish:

1. What the current fork actually does.
2. What reliable evidence says retail does.
3. Whether the comparison is current-retail parity, historical-era parity, or both.
4. What remains uncertain.

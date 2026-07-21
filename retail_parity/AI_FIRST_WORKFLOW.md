# AI-First Audit and Implementation Workflow

## Goal

Complete as much of the Vanilla + Rise of the Zilart retail-parity audit and implementation as possible before asking the repository owner to intervene.

The owner should not be asked to perform intermediate gameplay tests, collect evidence, choose implementation details, or repeatedly launch individual Codex tasks.

## Stage 1 — Assistant-first work

The assistant performs all work possible through source inspection, public research, connected GitHub access, bounded code edits, documentation, and review.

For each area, the assistant should:

1. Audit the current source and data.
2. Establish expected retail behavior from the strongest accessible evidence.
3. Record findings with confidence and uncertainty.
4. Implement every correction that is sufficiently evidenced and safely bounded.
5. Add tests or validation tooling where possible.
6. Review its own changes and update the status/worklog.
7. Defer rather than request intermediate manual testing.

Assistant work continues until the remaining tasks require a local build environment, broad multi-file engineering, repeated autonomous terminal work, or evidence unavailable to the assistant.

## Stage 2 — One consolidated Codex handoff

Codex receives one master task after the assistant marks `AI_HANDOFF.md` as `READY`.

Codex must then:

1. Read `AGENTS.md` and all retail-parity project records.
2. Re-check assistant findings and implementations rather than trusting them blindly.
3. Complete the remaining static audit across the entire Vanilla + Zilart scope.
4. Implement every remaining evidence-supported correction it can.
5. Add, run, and repair automated tests.
6. Perform code review, regression review, formatting, lint, and startup/build checks available in its environment.
7. Continue over multiple autonomous passes without asking the owner routine questions.
8. Commit and push logical changes only to the fork-owned Codex branch.
9. Produce a completion report and a minimal human-only queue.

The orchestration script may invoke multiple Codex passes. Repository state, not chat memory, is the handoff mechanism between passes.

## Stage 3 — Human-only final validation

The owner steps in only after Codex reaches a terminal state.

Permitted human-only items include:

- Live retail packet captures or observations that no accessible public evidence can replace.
- FFXI client testing that cannot be simulated or automated.
- Credentials, account access, server deployment, or hardware access unavailable to AI.
- Final acceptance decisions where multiple historically valid behaviors remain possible.
- Destructive operations that require explicit owner authorization.

The final queue must not contain work that the assistant or Codex could reasonably complete through code, tests, documentation, repository research, or local automation.

## Terminal states

`CODEX_STATE.md` must use one of these states:

- `NOT_STARTED` — Codex has not begun.
- `CONTINUE` — another autonomous pass can make meaningful progress.
- `COMPLETE` — all in-scope AI-capable work and automated validation are complete.
- `BLOCKED_HUMAN_ONLY` — all remaining work genuinely requires human-only access or observation.
- `FAILED_INFRASTRUCTURE` — the environment cannot build, test, access, or modify the repository and Codex cannot repair the environment safely.

## No-interruption rule

Neither the assistant nor Codex should ask the owner to test an individual finding during the audit. Findings that require human confirmation remain marked as pending final validation while AI continues with all independent work.

The owner receives one consolidated request only after the AI stages are exhausted.

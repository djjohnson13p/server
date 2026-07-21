# Vanilla + Rise of the Zilart AI Handoff

Status: NOT_READY

## Purpose

This file gates the consolidated Codex run.

The assistant changes `Status` to `READY` only after it has completed every audit and implementation task possible through its available research, GitHub, review, and editing tools.

## Handoff requirements

Before setting this file to `READY`, the assistant must:

- Update `STATUS.md` and `WORKLOG.md`.
- Record every confirmed finding in `findings/`.
- Implement and review all sufficiently evidenced, safely bounded corrections it can perform.
- Record unfinished multi-file, local-build, or terminal-intensive engineering tasks.
- Preserve unresolved evidence questions without inventing retail behavior.
- Provide Codex with a clean audit branch containing the complete repository-based context.

## Codex start condition

The orchestration script must refuse to run while this file says `NOT_READY`.

When ready, this section will include:

- Assistant completion commit
- Exact audit branch and baseline
- Findings already implemented
- Findings still requiring Codex
- Known test/build limitations
- Evidence that remains unresolved

## Owner involvement

No owner action is requested at this stage. Human involvement is deferred until Codex produces `HUMAN_ONLY_QUEUE.md` and reaches `COMPLETE` or `BLOCKED_HUMAN_ONLY`.

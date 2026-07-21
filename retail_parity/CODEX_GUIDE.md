# Codex Task Guide

## Simplified project model

This project uses one consolidated Codex handoff per expansion phase rather than asking the owner to launch separate tasks for every finding.

The sequence is:

1. The assistant completes every audit and implementation task possible with its available tools.
2. The assistant marks `retail_parity/vanilla_zilart/AI_HANDOFF.md` as `READY`.
3. Codex follows `retail_parity/CODEX_MASTER_TASK.md` over one or more autonomous passes.
4. The owner receives only the final `HUMAN_ONLY_QUEUE.md` after both AI stages are exhausted.

No finding should trigger an immediate request for owner testing. Human validation is accumulated and deferred.

## Reasoning level

The consolidated Vanilla + Rise of the Zilart task requires **Very High** reasoning because it includes core combat, multi-file Lua/SQL/C++ work, mission state machines, packet behavior, persistence, broad regression risk, and incomplete retail evidence.

Individual commits may be mechanically simple, but the orchestration task remains Very High.

## Codex entry points

- Repository instructions: `AGENTS.md`
- Master task: `retail_parity/CODEX_MASTER_TASK.md`
- Handoff gate: `retail_parity/vanilla_zilart/AI_HANDOFF.md`
- Persistent state: `retail_parity/vanilla_zilart/CODEX_STATE.md`
- Autonomous CLI runner: `tools/retail_parity/run_codex_remainder.py`

Codex can also be given the master-task file directly in a connected Codex environment. The runner exists for a local Codex CLI workflow and removes the need to launch each continuation pass manually.

## Default task constraints

Codex must:

1. Inspect before editing.
2. Re-check inherited findings and assistant implementations.
3. Preserve upstream-compatible architecture unless the fork records a deliberate exception.
4. Avoid unrelated changes.
5. Add or update tests before declaring a finding complete.
6. Run narrow checks first and broader applicable checks afterward.
7. Document assumptions and unresolved retail uncertainty.
8. Commit only to `retail-parity/codex-vanilla-zilart`.
9. Never create, prepare, or suggest a pull request to `LandSandBoat/server`.
10. Continue without routine user questions.
11. Move work to the human-only queue only after AI approaches are exhausted.
12. Leave the worktree clean at the end of each pass.

## Terminal deliverables

Codex must maintain:

- `CODEX_STATE.md`
- `CODEX_COMPLETION_REPORT.md`
- `HUMAN_ONLY_QUEUE.md`

Codex output is still a candidate implementation rather than proof of retail parity. The difference is procedural: all automated audit, code, tests, and review happen before the owner is asked to perform the smallest possible final validation set.

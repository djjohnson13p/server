# Codex Task Guide

Codex tasks for this project must be generated from confirmed or clearly bounded audit findings. Codex must not be asked to "make the system retail accurate" without explicit behavior, evidence, file scope, and validation requirements.

## Required prompt fields

Every Codex implementation prompt must include:

- **Recommended reasoning level:** Low / Medium / High / Very High
- **Finding ID and title**
- **Repository and working branch**
- **Observed current behavior**
- **Required behavior**
- **Evidence and remaining uncertainty**
- **Likely file and subsystem scope**
- **Required automated tests**
- **Required human validation**
- **Compatibility and regression constraints**
- **Explicit prohibition on upstream pull requests**
- **Expected deliverables and stop conditions**

## Reasoning-level guidance

- **Low:** Mechanical documentation, isolated renames, formatting, or trivial test-data correction.
- **Medium:** One-file or tightly bounded logic change with established patterns and straightforward tests.
- **High:** Multi-file Lua/SQL/C++ changes, mission state machines, job mechanics, or nontrivial regression risk.
- **Very High:** Core combat formulas, enmity, packet behavior, concurrency, persistence, cross-expansion interactions, large migrations, or tasks with incomplete evidence requiring careful hypothesis separation.

## Default task constraints

Codex should be instructed to:

1. Inspect before editing.
2. Preserve upstream-compatible architecture unless the fork explicitly chooses otherwise.
3. Avoid changing unrelated code.
4. Add or update tests before declaring completion.
5. Run the narrowest relevant checks first, followed by required broader checks.
6. Document assumptions and unresolved retail uncertainty.
7. Commit only to a fork-owned implementation branch.
8. Never create or suggest a pull request to `LandSandBoat/server`.
9. Stop and report rather than inventing retail behavior when evidence is insufficient.

## Review ownership

Codex output is a candidate implementation, not proof of retail parity. Completion still requires code review, automated test review, and any human/retail validation specified by the finding.

# Codex Instructions for the FFXI Retail-Parity Fork

This repository is a private, fork-only LandSandBoat retail-parity project.

## Repository boundaries

- Upstream reference: `LandSandBoat/server`
- Working fork: `djjohnson13p/server`
- Never open, prepare, or recommend a pull request to the upstream repository.
- Never modify the fork's `base` branch directly.
- Work only on the branch selected by the task or orchestration script.
- Preserve LandSandBoat conventions unless a documented fork-only decision says otherwise.

## Current project

The active scope is original FFXI through Rise of the Zilart.

Read these files before changing code:

1. `retail_parity/README.md`
2. `retail_parity/AI_FIRST_WORKFLOW.md`
3. `retail_parity/AUDIT_METHOD.md`
4. `retail_parity/CODEX_GUIDE.md`
5. `retail_parity/vanilla_zilart/STATUS.md`
6. `retail_parity/vanilla_zilart/WORKLOG.md`
7. Every relevant file under `retail_parity/vanilla_zilart/findings/`
8. `documentation/ai_agents/README.md` and any linked guide relevant to files being changed

`AGENTS.md` is a map. The files above are the project system of record.

## Operating rules

- Inspect neighboring code, tests, SQL, scripts, and current patterns before editing.
- Do not infer FFXI retail behavior from emulator code alone.
- Do not turn TODO comments or old issues into confirmed findings without checking the current code path and evidence.
- Separate confirmed behavior, reasonable inference, and unresolved uncertainty.
- When retail evidence is insufficient, implement only architecture or behavior that is independently justified; record the rest for final validation.
- Do not stop to ask the user routine questions. Make the safest evidence-supported choice and document it.
- Stop only for destructive ambiguity, missing credentials, unavailable required files, or behavior that cannot be responsibly inferred.
- Do not require the user to perform intermediate testing. Defer all truly human-only validation to the final queue.

## Code and test rules

- Keep each change tied to one finding or a tightly related group.
- Add or update automated tests whenever practical.
- Run the narrowest relevant tests first, then the broader required checks.
- Fix test, formatting, lint, and startup-check failures caused by the change.
- Do not conceal failing tests or weaken unrelated assertions.
- Mark code that remains retail-unverified in the finding and completion report.
- Keep generated files and database migrations consistent with repository tooling.

## Git rules

- Make logical commits with descriptive messages.
- Do not amend or rewrite existing history.
- Leave the worktree clean at the end of every completed pass.
- Push only to `djjohnson13p/server` when the orchestration environment permits it.
- Do not create an upstream PR.

## Required final artifacts

Codex must maintain:

- `retail_parity/vanilla_zilart/CODEX_STATE.md`
- `retail_parity/vanilla_zilart/CODEX_COMPLETION_REPORT.md`
- `retail_parity/vanilla_zilart/HUMAN_ONLY_QUEUE.md`

The human-only queue must contain only work that remains after both assistant and Codex efforts are exhausted, such as live-retail captures, client-only observations, credentials, or unavailable proprietary behavior.

# Codex Master Task — Vanilla + Rise of the Zilart Retail Parity

## Recommended reasoning level

**Very High**

## Mission

Continue this fork-only project after the assistant has exhausted its available audit and implementation capabilities. Complete all remaining AI-capable audit, engineering, testing, review, and documentation work for original FFXI through Rise of the Zilart before requesting any owner involvement.

Do not treat this as a single known-bug task. It is a repository-wide audit and remediation program bounded to Vanilla + Rise of the Zilart content and the shared systems required for that content.

## Hard boundaries

- Repository: `djjohnson13p/server`
- Upstream reference only: `LandSandBoat/server`
- Audit baseline recorded in `retail_parity/vanilla_zilart/STATUS.md`
- Work branch: `retail-parity/codex-vanilla-zilart`
- Never modify `base`.
- Never open, prepare, or suggest an upstream pull request.
- Do not merge the Codex branch into another branch.
- Do not ask the owner routine questions or request intermediate gameplay tests.
- Do not invent FFXI retail behavior when evidence is insufficient.

## Start gate

Read `retail_parity/vanilla_zilart/AI_HANDOFF.md`.

- If its status is not `READY`, do not change gameplay code. Update `CODEX_STATE.md` to explain that the handoff is not ready and stop.
- If its status is `READY`, continue with the full task below.

## Required context

Read and follow:

1. `AGENTS.md`
2. `retail_parity/README.md`
3. `retail_parity/AI_FIRST_WORKFLOW.md`
4. `retail_parity/AUDIT_METHOD.md`
5. `retail_parity/CODEX_GUIDE.md`
6. `retail_parity/vanilla_zilart/AI_HANDOFF.md`
7. `retail_parity/vanilla_zilart/STATUS.md`
8. `retail_parity/vanilla_zilart/WORKLOG.md`
9. All files in `retail_parity/vanilla_zilart/findings/`
10. `documentation/ai_agents/README.md` and applicable linked guides
11. Current repository conventions, nearby implementations, tests, SQL schema, settings, and tooling

## Work sequence

### Phase A — Verify inherited work

- Review the assistant's findings, evidence, code changes, and classifications.
- Correct documentation or code when repository evidence disproves an inherited conclusion.
- Do not silently accept an assistant implementation because it compiles or looks plausible.
- Record every correction in the worklog and completion report.

### Phase B — Complete the audit

Audit all Vanilla + Rise of the Zilart systems, including shared-core behavior that materially affects them:

- Core combat, attack rounds, damage, defense, accuracy, evasion, critical hits, resistance, enmity, claims, links, aggro, death, raise, experience, level correction, skillchains, magic bursts, TP, weapon skills, spells, status effects, and item additional effects.
- Original jobs and Zilart jobs, job abilities, traits, pets, avatars, wyverns, charmed pets, equipment effects, latent effects, and job quests.
- National missions, rank progression, mission interactions, quests, fame, titles, cutscenes, state machines, repeat behavior, prerequisites, and rewards.
- Rise of the Zilart missions, sky, Tu'Lia, Norg, Kazham, Zilart zones, doors, teleporters, NMs, HNMs, battlefields, BCNM/KSNM content available in scope, drops, spawn rules, and special mechanics.
- Conquest, regions, outposts, Expeditionary Forces, transport, airships, ferries, chocobos, Ballista, Mog House, storage, delivery, auction house, bazaars, shops, guilds, crafting, fishing, gardening, gathering, treasure, economy, and era currencies.
- Networking and client-visible packet behavior necessary for scoped gameplay.
- Configuration defaults, disabled content, TODO/FIXME markers, empty handlers, approximations, missing tests, stale issues, and data/script mismatches.

For every candidate discrepancy:

1. Trace the current code path.
2. Separate implementation absence from missing test coverage.
3. Compare against evidence already recorded in the repository.
4. Use repository-accessible evidence and testable behavior; do not browse unsupported private sources.
5. Create or update a finding only when the conclusion meets the audit standard.
6. Mark unresolved retail questions honestly.

### Phase C — Implement everything AI-capable

- Implement every correction whose required behavior is sufficiently supported.
- Prefer small, reviewable commits tied to finding IDs.
- Refactor shared systems only when necessary and with broad regression tests.
- Use data-driven approaches when item, monster, battlefield, or job behavior varies.
- Preserve later-expansion compatibility unless a documented fork-only decision explicitly changes it.
- Do not leave a known, safely fixable defect merely because human testing would improve confidence. Implement the best evidence-supported correction and mark it pending final validation.

### Phase D — Test and review

- Add or extend automated tests for each implemented finding where practical.
- Run narrow tests first, then applicable formatting, lint, code generation, startup, database, Lua, unit, integration, and build checks.
- Repair failures caused by the work.
- Review the final diff for unrelated changes, stale assumptions, missing migrations, unsafe SQL, test gaps, and cross-expansion regressions.
- Leave the worktree clean and commit all intended changes.

### Phase E — Produce final artifacts

Maintain these files throughout the work:

#### `retail_parity/vanilla_zilart/CODEX_STATE.md`

Update after every pass with:

- `Status: CONTINUE`, `COMPLETE`, `BLOCKED_HUMAN_ONLY`, or `FAILED_INFRASTRUCTURE`
- Pass number
- Commits and findings completed
- Current task
- Remaining AI-capable work
- Tests run and their results
- Next pass instructions

Use `CONTINUE` whenever another autonomous pass can make meaningful progress.

#### `retail_parity/vanilla_zilart/CODEX_COMPLETION_REPORT.md`

Include:

- Audit coverage completed
- Findings confirmed, rejected, revised, and implemented
- Commit list grouped by finding
- Tests and build checks run
- Known regressions or limitations
- Remaining unverified behavior
- Exact branch and final commit

#### `retail_parity/vanilla_zilart/HUMAN_ONLY_QUEUE.md`

Include only tasks that truly remain impossible for both assistant and Codex, such as:

- Live-retail captures or observations unavailable from public/repository evidence
- FFXI client-only behavior that cannot be automated
- Credentials, deployment, or server access unavailable in the environment
- Final choice between multiple historically valid behaviors

For each item provide one concise procedure, expected observation, and the finding it unblocks. Do not include ordinary code review, test writing, source inspection, issue research, or implementation work.

## Autonomous multi-pass behavior

This task may be invoked repeatedly by `tools/retail_parity/run_codex_remainder.py`.

At the start of every pass:

1. Read `CODEX_STATE.md` and recent commits.
2. Continue from repository state rather than repeating completed work.
3. Choose the highest-impact remaining AI-capable task.

At the end of every pass:

1. Update all affected findings, status, and worklog records.
2. Update `CODEX_STATE.md`.
3. Run the relevant checks.
4. Commit logical changes.
5. Leave the worktree clean.

On the final available pass, finish all work possible, consolidate the reports, and choose `COMPLETE`, `BLOCKED_HUMAN_ONLY`, or `FAILED_INFRASTRUCTURE`. Do not leave the state as `CONTINUE` merely because perfect retail certainty is unavailable.

## Stop conditions

Stop only when one of these is true:

- `COMPLETE`: No meaningful AI-capable audit, implementation, testing, or documentation work remains in scope.
- `BLOCKED_HUMAN_ONLY`: Every remaining item genuinely requires human-only access or live-client/retail observation.
- `FAILED_INFRASTRUCTURE`: Required environment capabilities are unavailable and cannot be repaired safely.

Do not stop merely because one finding needs final human validation. Continue all independent work first.

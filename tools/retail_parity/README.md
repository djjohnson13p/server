# Retail-Parity Codex Runner

`run_codex_remainder.py` executes the consolidated Codex stage without requiring the owner to launch each task or continuation pass manually.

## Start condition

Do not run it until:

`retail_parity/vanilla_zilart/AI_HANDOFF.md`

contains:

`Status: READY`

The script refuses to start otherwise.

## Run

From the repository root:

```bash
python tools/retail_parity/run_codex_remainder.py
```

On Windows, `py` may be used instead of `python`:

```powershell
py tools/retail_parity/run_codex_remainder.py
```

## What it does

- Confirms the repository is `djjohnson13p/server` and the worktree is clean.
- Fetches the fork.
- Creates or resumes `retail-parity/codex-vanilla-zilart` from the assistant audit branch.
- Runs Codex non-interactively in full-auto mode.
- Repeats up to ten passes by default, using `CODEX_STATE.md` as persistent memory.
- Pushes clean committed passes to the fork when Git authentication permits it.
- Stops only at `COMPLETE`, `BLOCKED_HUMAN_ONLY`, or `FAILED_INFRASTRUCTURE`.
- Stores run logs under `.git/retail-parity-codex-logs/` so logs do not dirty the repository.

## Optional environment controls

- `CODEX_MAX_PASSES`: Change the maximum autonomous pass count. Default: `10`.
- `CODEX_BIN`: Use a non-default Codex executable name or path.
- `CODEX_AUTO_PUSH=0`: Keep commits local instead of automatically pushing them.

No owner interaction is expected between passes.

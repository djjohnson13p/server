#!/usr/bin/env python3
"""Run the consolidated Vanilla + Zilart Codex handoff without intermediate user input."""

from __future__ import annotations

import os
import re
import shutil
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

AUDIT_BRANCH = "retail-parity/vanilla-zilart-audit"
WORK_BRANCH = "retail-parity/codex-vanilla-zilart"
HANDOFF_PATH = Path("retail_parity/vanilla_zilart/AI_HANDOFF.md")
STATE_PATH = Path("retail_parity/vanilla_zilart/CODEX_STATE.md")
MASTER_TASK_PATH = Path("retail_parity/CODEX_MASTER_TASK.md")
TERMINAL_STATES = {"COMPLETE", "BLOCKED_HUMAN_ONLY", "FAILED_INFRASTRUCTURE"}
DEFAULT_MAX_PASSES = 10


class RunnerError(RuntimeError):
    """Raised for a safe, actionable orchestration failure."""


def run(
    args: list[str],
    *,
    cwd: Path,
    check: bool = True,
    capture: bool = True,
) -> subprocess.CompletedProcess[str]:
    result = subprocess.run(
        args,
        cwd=cwd,
        check=False,
        text=True,
        stdout=subprocess.PIPE if capture else None,
        stderr=subprocess.STDOUT if capture else None,
    )
    if check and result.returncode != 0:
        output = result.stdout.strip() if result.stdout else "No command output."
        raise RunnerError(f"Command failed ({result.returncode}): {' '.join(args)}\n{output}")
    return result


def repository_root() -> Path:
    result = subprocess.run(
        ["git", "rev-parse", "--show-toplevel"],
        check=False,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
    )
    if result.returncode != 0:
        raise RunnerError("Run this script from inside the djjohnson13p/server Git repository.")
    return Path(result.stdout.strip()).resolve()


def read_status(path: Path, root: Path) -> str:
    full_path = root / path
    if not full_path.exists():
        return "MISSING"
    match = re.search(r"(?im)^Status:\s*([A-Z_]+)\s*$", full_path.read_text(encoding="utf-8"))
    return match.group(1) if match else "UNKNOWN"


def ensure_expected_repository(root: Path) -> None:
    origin = run(["git", "remote", "get-url", "origin"], cwd=root).stdout.strip()
    normalized = origin.lower().replace("\\", "/")
    if "djjohnson13p/server" not in normalized and "djjohnson13p/server.git" not in normalized:
        raise RunnerError(f"Refusing to run because origin is not djjohnson13p/server: {origin}")


def ensure_clean_worktree(root: Path) -> None:
    status = run(["git", "status", "--porcelain"], cwd=root).stdout.strip()
    if status:
        raise RunnerError(
            "The worktree must be clean before starting the autonomous Codex run.\n"
            f"Current changes:\n{status}"
        )


def ref_exists(root: Path, ref: str) -> bool:
    result = run(["git", "show-ref", "--verify", "--quiet", ref], cwd=root, check=False)
    return result.returncode == 0


def prepare_work_branch(root: Path) -> None:
    run(["git", "fetch", "origin"], cwd=root, capture=False)

    local_work_ref = f"refs/heads/{WORK_BRANCH}"
    remote_work_ref = f"refs/remotes/origin/{WORK_BRANCH}"
    local_audit_ref = f"refs/heads/{AUDIT_BRANCH}"
    remote_audit_ref = f"refs/remotes/origin/{AUDIT_BRANCH}"

    if ref_exists(root, local_work_ref):
        run(["git", "switch", WORK_BRANCH], cwd=root, capture=False)
        if ref_exists(root, remote_work_ref):
            run(["git", "pull", "--ff-only", "origin", WORK_BRANCH], cwd=root, capture=False)
        return

    if ref_exists(root, remote_work_ref):
        run(["git", "switch", "--track", "-c", WORK_BRANCH, f"origin/{WORK_BRANCH}"], cwd=root, capture=False)
        return

    if ref_exists(root, local_audit_ref):
        base_ref = AUDIT_BRANCH
    elif ref_exists(root, remote_audit_ref):
        base_ref = f"origin/{AUDIT_BRANCH}"
    else:
        raise RunnerError(f"Required audit branch not found: {AUDIT_BRANCH}")

    run(["git", "switch", "-c", WORK_BRANCH, base_ref], cwd=root, capture=False)


def build_pass_prompt(pass_number: int, max_passes: int, root: Path) -> str:
    state = read_status(STATE_PATH, root)
    final_pass = pass_number == max_passes
    final_instruction = (
        "This is the final available pass. Finish all meaningful AI-capable work, consolidate the reports, "
        "leave the worktree clean, and set a terminal state: COMPLETE, BLOCKED_HUMAN_ONLY, or "
        "FAILED_INFRASTRUCTURE. Do not leave Status as CONTINUE."
        if final_pass
        else "Set Status to CONTINUE if another autonomous pass can make meaningful progress."
    )

    return f"""
Execute the repository task in retail_parity/CODEX_MASTER_TASK.md.

This is autonomous pass {pass_number} of {max_passes} on branch {WORK_BRANCH}.
Current recorded Codex state: {state}.

Read AGENTS.md, the master task, AI_HANDOFF.md, CODEX_STATE.md, STATUS.md, WORKLOG.md, all findings,
and recent commits before acting. Continue from repository state; do not repeat completed work. Choose the
highest-impact remaining AI-capable task. Do not ask the user routine questions or request intermediate testing.

Before finishing this pass:
- update findings, STATUS.md, WORKLOG.md, CODEX_STATE.md, and completion/human-only reports as applicable;
- run the narrowest relevant tests and broader required checks;
- commit every intended change in logical commits;
- leave the worktree clean;
- do not open or prepare any pull request.

{final_instruction}
""".strip()


def run_codex_pass(root: Path, pass_number: int, max_passes: int) -> int:
    codex_name = os.environ.get("CODEX_BIN", "codex")
    codex_bin = shutil.which(codex_name)
    if codex_bin is None:
        raise RunnerError(
            f"Codex executable not found: {codex_name}. Install/sign in to Codex before running the handoff."
        )

    log_dir = root / ".git" / "retail-parity-codex-logs"
    log_dir.mkdir(parents=True, exist_ok=True)
    timestamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")
    log_path = log_dir / f"pass-{pass_number:02d}-{timestamp}.log"
    prompt = build_pass_prompt(pass_number, max_passes, root)

    command = [codex_bin, "exec", "--full-auto", "-"]
    print(f"\n=== Codex pass {pass_number}/{max_passes} ===")
    print(f"Log: {log_path}")

    with log_path.open("w", encoding="utf-8") as log_file:
        process = subprocess.Popen(
            command,
            cwd=root,
            text=True,
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            bufsize=1,
        )
        assert process.stdin is not None
        assert process.stdout is not None
        process.stdin.write(prompt)
        process.stdin.close()

        for line in process.stdout:
            print(line, end="")
            log_file.write(line)
            log_file.flush()

        return_code = process.wait()

    return return_code


def push_commits(root: Path) -> None:
    auto_push = os.environ.get("CODEX_AUTO_PUSH", "1").strip().lower() not in {"0", "false", "no"}
    if not auto_push:
        return
    result = run(["git", "push", "-u", "origin", "HEAD"], cwd=root, check=False, capture=True)
    if result.returncode != 0:
        print("Warning: Codex work was committed locally, but automatic push failed:", file=sys.stderr)
        print(result.stdout, file=sys.stderr)


def main() -> int:
    root = repository_root()
    ensure_expected_repository(root)
    ensure_clean_worktree(root)

    handoff_status = read_status(HANDOFF_PATH, root)
    if handoff_status != "READY":
        raise RunnerError(
            f"Codex handoff is not ready (AI_HANDOFF.md Status: {handoff_status}). "
            "The assistant must finish its stage and mark the handoff READY first."
        )

    if not (root / MASTER_TASK_PATH).exists():
        raise RunnerError(f"Missing master task: {MASTER_TASK_PATH}")

    try:
        max_passes = int(os.environ.get("CODEX_MAX_PASSES", str(DEFAULT_MAX_PASSES)))
    except ValueError as exc:
        raise RunnerError("CODEX_MAX_PASSES must be a positive integer.") from exc
    if max_passes < 1:
        raise RunnerError("CODEX_MAX_PASSES must be at least 1.")

    prepare_work_branch(root)
    ensure_clean_worktree(root)

    for pass_number in range(1, max_passes + 1):
        return_code = run_codex_pass(root, pass_number, max_passes)
        if return_code != 0:
            raise RunnerError(f"Codex pass {pass_number} exited with status {return_code}.")

        worktree_status = run(["git", "status", "--porcelain"], cwd=root).stdout.strip()
        state = read_status(STATE_PATH, root)

        if worktree_status:
            print("Codex left uncommitted changes; another pass will be allowed to review and commit them.")
        else:
            push_commits(root)

        print(f"Recorded state after pass {pass_number}: {state}")
        if state in TERMINAL_STATES and not worktree_status:
            print(f"Codex orchestration finished with terminal state: {state}")
            return 0

    final_state = read_status(STATE_PATH, root)
    dirty = run(["git", "status", "--porcelain"], cwd=root).stdout.strip()
    if dirty:
        raise RunnerError(
            "Maximum Codex passes reached with uncommitted changes. Review the latest log under "
            ".git/retail-parity-codex-logs."
        )
    raise RunnerError(
        f"Maximum Codex passes reached without a terminal state. Current state: {final_state}. "
        "Increase CODEX_MAX_PASSES only after reviewing the completion report and logs."
    )


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except RunnerError as error:
        print(f"Error: {error}", file=sys.stderr)
        raise SystemExit(1)

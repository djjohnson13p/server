# ===========================================================================
#
#  Copyright (c) 2026 LandSandBoat Dev Teams
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see http://www.gnu.org/licenses/
#
# ===========================================================================

import pathlib
import re
import sys


ROOT = pathlib.Path(__file__).resolve().parents[3]
MOBSKILL_DIRECTORY = ROOT / "scripts" / "actions" / "mobskills"
ALLOWLIST: set[tuple[str, int]] = set()

CHECK_FUNCTION = re.compile(
    r"\.onMobSkillCheck\s*=\s*function\b(?P<body>.*?)"
    r"(?=\n\w+(?:\.\w+)*\.onMob\w+\s*=\s*function\b|\Z)",
    re.DOTALL,
)
READY_MESSAGE = re.compile(r"\bmessageBasic\s*\([^)]*\bREADIES_(?:WS|SKILL(?:_2)?)\b", re.DOTALL)


def strip_comments(source: str) -> str:
    source = re.sub(r"--\[\[.*?\]\]", "", source, flags=re.DOTALL)
    return re.sub(r"--[^\n]*", "", source)


def main() -> int:
    failures: list[str] = []

    for path in sorted(MOBSKILL_DIRECTORY.glob("*.lua")):
        source = path.read_text(encoding="utf-8")
        uncommented = strip_comments(source)

        for check in CHECK_FUNCTION.finditer(uncommented):
            for ready_call in READY_MESSAGE.finditer(check.group("body")):
                line = uncommented.count("\n", 0, check.start("body") + ready_call.start()) + 1
                relative_path = path.relative_to(ROOT).as_posix()
                if (relative_path, line) not in ALLOWLIST:
                    failures.append(
                        f"{relative_path}:{line}: onMobSkillCheck must not emit a ready message"
                    )

    if failures:
        print("\n".join(failures))
        return 1

    return 0


if __name__ == "__main__":
    sys.exit(main())

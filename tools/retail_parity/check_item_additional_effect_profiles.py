#!/usr/bin/env python3
"""Validate the VZ-COMBAT-001 inventory and maintained profile boundary."""

from __future__ import annotations

import importlib.util
import sys
from collections import Counter
from pathlib import Path
from types import ModuleType

ALLOWED_CLASSIFICATIONS = {
    "EVIDENCE_BACKED",
    "FRAMEWORK_CORRECT_LEGACY_NUMERICS",
    "VERIFY_LIVE",
    "SPECIAL_CASE_TEST_BACKED",
    "CONFIGURATION_ERROR",
    "NOT_ACTIVE",
    "ERA_UNRESOLVED",
}

ISSUE_7899_ITEM_IDS = {
    17325,
    17329,
    18148,
    18149,
    18150,
    18152,
    18157,
    18158,
    18159,
    18160,
    21313,
    21314,
    21323,
}


def load_generator(root: Path) -> ModuleType:
    generator_path = (
        root / "tools/retail_parity/generate_item_additional_effect_inventory.py"
    )
    spec = importlib.util.spec_from_file_location(
        "item_additional_effect_inventory", generator_path
    )
    if spec is None or spec.loader is None:
        raise RuntimeError(f"could not load {generator_path}")

    module = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = module
    spec.loader.exec_module(module)
    return module


def main() -> int:
    root = Path(__file__).resolve().parents[2]
    generator = load_generator(root)
    rows, issues = generator.build_rows(root)
    errors: list[str] = []

    artifact_dir = root / "retail_parity/vanilla_zilart/artifacts"
    expected_artifacts = {
        artifact_dir / "VZ-COMBAT-001-item-inventory.csv": generator.csv_text(rows),
        artifact_dir
        / "VZ-COMBAT-001-item-inventory.md": generator.markdown_text(rows, issues),
    }
    for path, expected in expected_artifacts.items():
        if not path.exists():
            errors.append(f"missing generated artifact: {path.relative_to(root)}")
        elif path.read_text(encoding="utf-8") != expected:
            errors.append(f"stale generated artifact: {path.relative_to(root)}")

    item_ids = [int(row["item_id"]) for row in rows]
    duplicate_ids = sorted(
        item_id for item_id, count in Counter(item_ids).items() if count > 1
    )
    if duplicate_ids:
        errors.append(f"conflicting inventory rows: {duplicate_ids}")

    by_id = {int(row["item_id"]): row for row in rows}
    missing_issue_items = sorted(ISSUE_7899_ITEM_IDS - by_id.keys())
    if missing_issue_items:
        errors.append(f"issue #7899 items absent from inventory: {missing_issue_items}")

    maintained = {
        item_id: row
        for item_id, row in by_id.items()
        if row["era"] == "VANILLA_OR_ZILART"
    }
    missing_scope = sorted(generator.AUDIT_SCOPE_ITEMS - maintained.keys())
    if missing_scope:
        errors.append(f"maintained V/Z items absent from inventory: {missing_scope}")

    for item_id, row in sorted(maintained.items()):
        if row["handler_reachable"] != "YES":
            errors.append(f"item {item_id}: maintained handler is not reachable")
        if row["current_classification"] not in ALLOWED_CLASSIFICATIONS:
            errors.append(
                f"item {item_id}: unknown classification "
                f"{row['current_classification']!r}"
            )
        if row["current_classification"] in {
            "CONFIGURATION_ERROR",
            "NOT_ACTIVE",
            "ERA_UNRESOLVED",
        }:
            errors.append(
                f"item {item_id}: invalid maintained classification "
                f"{row['current_classification']}"
            )

    for item_id in (18148, 18149):
        row = by_id[item_id]
        if row["accuracy_or_skill_basis"] != "ITEM_NATIVE_A_RANK":
            errors.append(f"item {item_id}: item-native A rank was not preserved")
        if row["governing_stat_or_dstat"] != "UNRESOLVED; LEGACY_INT_COMPATIBILITY":
            errors.append(
                f"item {item_id}: unresolved governing-stat boundary was lost"
            )
        if "governing dSTAT/no-dSTAT behavior" not in row["unresolved_questions"]:
            errors.append(f"item {item_id}: dSTAT uncertainty is not recorded")

    if errors:
        for error in errors:
            print(f"profile sanity error: {error}", file=sys.stderr)
        return 1

    print(
        "profile sanity: "
        f"{len(rows)} inventory rows, {len(maintained)} maintained V/Z profiles, "
        f"{len(issues)} repository-wide configuration finding(s)"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

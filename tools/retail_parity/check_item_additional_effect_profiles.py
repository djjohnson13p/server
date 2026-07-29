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
    "NOT_APPLICABLE",
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

ELEMENTAL_ARROW_CONSTANTS = {
    17322: ("FIRE_ARROW", "fire_arrow.lua", "FIRE", "FIRE_DAMAGE"),
    17323: ("ICE_ARROW", "ice_arrow.lua", "ICE", "ICE_DAMAGE"),
    17324: (
        "LIGHTNING_ARROW",
        "lightning_arrow.lua",
        "THUNDER",
        "LIGHTNING_DAMAGE",
    ),
}

STATUS_AMMUNITION_CONSTANTS = {
    17325: ("KABURA_ARROW", "SILENCE", "SILENCE", "NONE", "WIND"),
    17329: (
        "PATRIARCH_PROTECTORS_ARROW",
        "PARALYSIS",
        "PARALYSIS",
        "NONE",
        "ICE",
    ),
    18150: ("BLIND_BOLT", "BLINDNESS", "BLIND", "DARK", "DARK"),
    18152: ("VENOM_BOLT", "POISON", "POISON", "WATER", "WATER"),
    18157: ("POISON_ARROW", "POISON", "POISON", "NONE", "WATER"),
    18158: ("SLEEP_ARROW", "SLEEP_I", "SLEEP", "NONE", "NONE"),
    18159: ("DEMON_ARROW", "ATTACK_DOWN", "ATTACK_DOWN", "NONE", "WATER"),
    18160: ("SPARTAN_BULLET", "STUN", "STUN", "NONE", "THUNDER"),
}

COMBINED_RESOURCE_DRAIN_CONSTANTS = {
    17745: ("HOFUD", "HP_OR_MP", 8, 15, 15, "DARKNESS_DAMAGE"),
    20706: ("VAMPIRISM", "HP_OR_MP_OR_TP", 9, 100, 20, "MP_DRAIN"),
    21585: (
        "CREPUSCULAR_KNIFE",
        "HP_OR_MP_OR_TP",
        9,
        15,
        15,
        "DARKNESS_DAMAGE",
    ),
}

DISPEL_WEAPON_CONSTANTS = {
    16944: ("LOCKHEART", "lockheart", 5, 64),
    16950: ("MYTHRIL_HEART", "mythril_heart", 10, 66),
    16951: ("MYTHRIL_HEART_PLUS_1", "mythril_heart_plus_1", 10, 66),
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

    profile_path = root / generator.ELEMENTAL_ARROW_PROFILE_SOURCE
    profile_text = profile_path.read_text(encoding="utf-8")
    if profile_text.count("elementalArrowProfile(") != 4:
        errors.append(
            "elemental-arrow registry must contain one constructor and exactly "
            "three profile definitions"
        )

    for item_id, (
        item_constant,
        script_name,
        element,
        subeffect,
    ) in ELEMENTAL_ARROW_CONSTANTS.items():
        row = by_id[item_id]
        script_path = root / "scripts/items" / script_name
        script_text = script_path.read_text(encoding="utf-8")

        if script_text.count("executeScriptedDamageProfile(") != 1:
            errors.append(
                f"item {item_id}: script must call the profile executor exactly once"
            )
        if "executeAddEffectDamage(" in script_text or "math.random" in script_text:
            errors.append(f"item {item_id}: script still duplicates profile numerics")

        expected_fragment = (
            f"xi.item.{item_constant},\n"
            f"        '{script_name.removesuffix('.lua')}',\n"
            f"        xi.element.{element},\n"
            f"        xi.subEffect.{subeffect})"
        )
        if expected_fragment not in profile_text:
            errors.append(
                f"item {item_id}: profile identity/element/presentation drift"
            )

        config = generator.parse_configs(root)[item_id]
        if config.mods.get(1181) != [1] or config.value(431):
            errors.append(
                f"item {item_id}: expected exactly one scripted handler marker"
            )

        expected_row_values = {
            "profile_source": generator.ELEMENTAL_ARROW_PROFILE_SOURCE,
            "current_handler": "PER_ITEM_LUA_PROFILE",
            "proc_chance": "100",
            "proc_policy": "FIXED_PERCENT_COMPATIBILITY; VERIFY_LIVE",
            "base_power_policy": (
                "UNIFORM_INTEGER_RANGE_7_TO_10_COMPATIBILITY; VERIFY_LIVE"
            ),
            "accuracy_or_skill_basis": "LEGACY_A_PLUS; VERIFY_LIVE",
            "governing_stat_or_dstat": ("NO_STAT_COMPATIBILITY; VERIFY_LIVE"),
            "mab_policy": "DISABLED_COMPATIBILITY; VERIFY_LIVE",
            "element": element,
            "subeffect": subeffect,
            "current_classification": "VERIFY_LIVE",
            "evidence_sources": generator.ELEMENTAL_ARROW_EVIDENCE_SOURCE,
        }
        for field, expected in expected_row_values.items():
            if row[field] != expected:
                errors.append(
                    f"item {item_id}: {field} was {row[field]!r}, "
                    f"expected {expected!r}"
                )

        for test_name in (
            "item_additional_effects_elemental_arrows.lua",
            "item_additional_effects_elemental_arrow_profiles.lua",
        ):
            if test_name not in row["automated_test_reference"]:
                errors.append(
                    f"item {item_id}: missing behavioral test reference {test_name}"
                )

    for later_script in (
        "earth_arrow.lua",
        "water_arrow.lua",
        "wind_arrow.lua",
        "grand_knights_arrow.lua",
        "temple_knights_arrow.lua",
    ):
        text = (root / "scripts/items" / later_script).read_text(encoding="utf-8")
        if "executeScriptedDamageProfile" in text:
            errors.append(f"out-of-scope item migrated: {later_script}")

    if profile_text.count("statusAmmunitionProfile(") != 9:
        errors.append(
            "status-ammunition registry must contain one constructor and exactly "
            "eight profile definitions"
        )

    enum_text = (root / "scripts/enum/item.lua").read_text(encoding="utf-8")
    for item_id, (
        item_constant,
        status,
        subeffect,
        configured_element,
        effective_element,
    ) in STATUS_AMMUNITION_CONSTANTS.items():
        row = by_id[item_id]
        if f"{item_constant}" not in enum_text:
            errors.append(f"item {item_id}: missing item enum constant {item_constant}")

        expected_fragment = (
            f"xi.item.{item_constant},\n"
            f"        '{generator.STATUS_AMMUNITION_PROFILES[item_id][0]}',"
        )
        if expected_fragment not in profile_text:
            errors.append(f"item {item_id}: status-ammunition identity drift")

        for expected_policy in (
            f"xi.effect.{status}",
            f"xi.subEffect.{subeffect}",
            f"xi.element.{configured_element}",
            f"xi.element.{effective_element}",
        ):
            if expected_policy not in profile_text:
                errors.append(
                    f"item {item_id}: missing scoped profile policy {expected_policy}"
                )

        config = generator.parse_configs(root)[item_id]
        if config.value(431) != 2 or config.value(1181):
            errors.append(f"item {item_id}: expected exactly one global DEBUFF handler")

        expected_row_values = {
            "profile_family": "VZ_STATUS_AMMUNITION",
            "profile_source": generator.STATUS_AMMUNITION_PROFILE_SOURCE,
            "current_handler": "GLOBAL_ADDITIONAL_EFFECT_PROFILE",
            "proc_policy": "SQL_MODIFIER_COMPATIBILITY; VERIFY_LIVE",
            "accuracy_or_skill_basis": "LEGACY_A_RANK; VERIFY_LIVE",
            "status_effect": status,
            "subeffect": subeffect,
            "current_classification": "VERIFY_LIVE",
            "evidence_sources": generator.STATUS_AMMUNITION_EVIDENCE_SOURCE,
        }
        for field, expected in expected_row_values.items():
            if row[field] != expected:
                errors.append(
                    f"item {item_id}: {field} was {row[field]!r}, "
                    f"expected {expected!r}"
                )

        expected_element = (
            f"CONFIGURED_{configured_element};EFFECTIVE_{effective_element};"
            "VERIFY_LIVE"
        )
        if row["element"] != expected_element:
            errors.append(
                f"item {item_id}: element was {row['element']!r}, "
                f"expected {expected_element!r}"
            )

        for test_name in (
            "item_additional_effects_status_ammunition.lua",
            "item_additional_effects_status_ammunition_profiles.lua",
        ):
            if test_name not in row["automated_test_reference"]:
                errors.append(
                    f"item {item_id}: missing behavioral test reference {test_name}"
                )

    for reference_item in (18148, 18149):
        row = by_id[reference_item]
        if row["profile_family"] == "VZ_STATUS_AMMUNITION":
            errors.append(
                f"item {reference_item}: reference bolt was incorrectly migrated"
            )

    for later_item in (21313, 21314, 21323):
        row = by_id[later_item]
        if row["profile_family"] == "VZ_STATUS_AMMUNITION":
            errors.append(f"out-of-scope later ammunition migrated: {later_item}")

    if profile_text.count("combinedResourceDrainProfile(") != 4:
        errors.append(
            "combined-resource drain registry must contain one constructor and "
            "exactly three profile definitions"
        )

    for item_id, (
        item_constant,
        resource_set,
        family,
        chance,
        amount,
        subeffect,
    ) in COMBINED_RESOURCE_DRAIN_CONSTANTS.items():
        row = by_id[item_id]
        if item_constant not in enum_text:
            errors.append(f"item {item_id}: missing item enum constant {item_constant}")

        profile = generator.COMBINED_RESOURCE_DRAIN_PROFILES[item_id]
        expected_fragment = (
            f"xi.item.{item_constant},\n"
            f"        '{profile['name']}',\n"
            f"        '{profile['introduction_date']}',"
        )
        if expected_fragment not in profile_text:
            errors.append(f"item {item_id}: combined-drain profile identity drift")

        config = generator.parse_configs(root)[item_id]
        expected_mods = {
            431: family,
            499: profile["subeffect_id"],
            500: amount,
            501: chance,
            950: 0,
            1181: 0,
        }
        for mod_id, expected in expected_mods.items():
            actual = config.value(mod_id) or 0
            if actual != expected:
                errors.append(
                    f"item {item_id}: modifier {mod_id} was {actual}, "
                    f"expected {expected}"
                )
        if config.script_paths:
            errors.append(f"item {item_id}: combined drain has a per-item script")

        expected_row_values = {
            "era": "LATER_EXPANSION",
            "profile_family": "VZ_COMBINED_RESOURCE_DRAIN",
            "profile_source": generator.COMBINED_RESOURCE_DRAIN_PROFILE_SOURCE,
            "current_handler": "GLOBAL_COMBINED_RESOURCE_DRAIN_PROFILE",
            "proc_policy": "FIXED_PERCENT_SQL_COMPATIBILITY; VERIFY_LIVE",
            "proc_chance": str(chance),
            "base_power_policy": (f"FIXED_{amount}_SQL_COMPATIBILITY; VERIFY_LIVE"),
            "element": ("CONFIGURED_NONE;EFFECTIVE_DARK_COMPATIBILITY;VERIFY_LIVE"),
            "subeffect": subeffect,
            "current_classification": "VERIFY_LIVE",
            "evidence_sources": (generator.COMBINED_RESOURCE_DRAIN_EVIDENCE_SOURCE),
        }
        for field, expected in expected_row_values.items():
            if row[field] != expected:
                errors.append(
                    f"item {item_id}: {field} was {row[field]!r}, "
                    f"expected {expected!r}"
                )

        for expected_text in (
            resource_set,
            "uniform",
            "retry/fallback",
        ):
            if expected_text.lower() not in row["unresolved_questions"].lower():
                errors.append(
                    f"item {item_id}: unresolved boundary omits {expected_text}"
                )

        for test_name in (
            "item_additional_effects_combined_resource_drains.lua",
            "item_additional_effects_combined_resource_drain_profiles.lua",
        ):
            if test_name not in row["automated_test_reference"]:
                errors.append(
                    f"item {item_id}: missing behavioral test reference {test_name}"
                )

    if profile_text.count("dispelWeaponProfile(") != 4:
        errors.append(
            "Dispel-weapon registry must contain one constructor and exactly "
            "three profile definitions"
        )

    for item_id, (
        item_constant,
        item_name,
        chance,
        level,
    ) in DISPEL_WEAPON_CONSTANTS.items():
        row = by_id[item_id]
        if item_constant not in enum_text:
            errors.append(f"item {item_id}: missing item enum constant {item_constant}")

        expected_fragment = (
            f"xi.item.{item_constant},\n"
            f"        '{item_name}',\n"
            f"        {chance},"
        )
        if expected_fragment not in profile_text:
            errors.append(f"item {item_id}: Dispel profile identity/chance drift")

        config = generator.parse_configs(root)[item_id]
        expected_mods = {
            278: 0,
            431: 10,
            499: 0,
            501: chance,
            950: 0,
            1181: 0,
        }
        for mod_id, expected in expected_mods.items():
            actual = config.value(mod_id) or 0
            if actual != expected:
                errors.append(
                    f"item {item_id}: modifier {mod_id} was {actual}, "
                    f"expected {expected}"
                )
        if config.script_paths:
            errors.append(f"item {item_id}: Dispel profile has a per-item script")

        expected_row_values = {
            "item_level": str(level),
            "item_slot": "MAIN",
            "weapon_or_ammo_type": "GREAT_SWORD",
            "era": "VANILLA_OR_ZILART",
            "profile_family": "VZ_DISPEL_WEAPON",
            "profile_source": generator.DISPEL_WEAPON_PROFILE_SOURCE,
            "current_handler": "GLOBAL_DISPEL_WEAPON_PROFILE",
            "proc_type": "DISPEL",
            "proc_policy": "FIXED_PERCENT_SQL_COMPATIBILITY; VERIFY_LIVE",
            "proc_chance": str(chance),
            "level_correction": "0_SQL_COMPATIBILITY; VERIFY_LIVE",
            "accuracy_or_skill_basis": (
                "NO_MAGIC_ACCURACY_OR_SKILL_COMPATIBILITY; VERIFY_LIVE"
            ),
            "governing_stat_or_dstat": "NOT_APPLICABLE",
            "resistance_mode": "NO_RESISTANCE_LAYER_COMPATIBILITY; VERIFY_LIVE",
            "element": "NOT_APPLICABLE",
            "status_effect": "ONE_DISPELABLE_POSITIVE_DURATION_EFFECT",
            "subeffect": "DARKNESS_DAMAGE",
            "message_id": "ADD_EFFECT_DISPEL; ACTUAL_REMOVED_EFFECT_ID",
            "current_classification": "VERIFY_LIVE",
            "evidence_sources": generator.DISPEL_WEAPON_EVIDENCE_SOURCE,
        }
        for field, expected in expected_row_values.items():
            if row[field] != expected:
                errors.append(
                    f"item {item_id}: {field} was {row[field]!r}, "
                    f"expected {expected!r}"
                )

        for expected_text in (
            "selection",
            "protected status",
            "retry",
            "accuracy",
            "resistance",
            "client presentation",
        ):
            if expected_text.lower() not in row["unresolved_questions"].lower():
                errors.append(
                    f"item {item_id}: unresolved boundary omits {expected_text}"
                )

        for test_name in (
            "item_additional_effects_dispel_weapons.lua",
            "item_additional_effects_dispel_weapon_profiles.lua",
        ):
            if test_name not in row["automated_test_reference"]:
                errors.append(
                    f"item {item_id}: missing behavioral test reference {test_name}"
                )

    for excluded_item in (16942, 18330, 21966):
        row = by_id[excluded_item]
        if row["profile_family"] == "VZ_DISPEL_WEAPON":
            errors.append(f"out-of-scope Dispel item migrated: {excluded_item}")
        if row["current_handler"] == "GLOBAL_DISPEL_WEAPON_PROFILE":
            errors.append(
                f"out-of-scope Dispel item uses scoped handler: {excluded_item}"
            )

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

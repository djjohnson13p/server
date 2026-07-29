#!/usr/bin/env python3
"""Generate the VZ-COMBAT-001 item additional-effect inventory.

The active repository data is authoritative for configuration values. Era and
retail-accuracy claims are deliberately conservative: an item without a
maintained evidence entry remains ERA_UNRESOLVED instead of being classified
from its numeric ID or description.
"""

from __future__ import annotations

import argparse
import csv
import io
import re
import sys
from collections import Counter, defaultdict
from dataclasses import dataclass, field
from pathlib import Path

RELEVANT_MODS = {
    278: "ITEM_ADDEFFECT_LVADJUST",
    280: "ITEM_ADDEFFECT_DSTAT",
    431: "ITEM_ADDEFFECT_TYPE",
    499: "ITEM_SUBEFFECT",
    500: "ITEM_ADDEFFECT_DMG",
    501: "ITEM_ADDEFFECT_CHANCE",
    950: "ITEM_ADDEFFECT_ELEMENT",
    951: "ITEM_ADDEFFECT_STATUS",
    952: "ITEM_ADDEFFECT_POWER",
    953: "ITEM_ADDEFFECT_DURATION",
    1180: "ITEM_ADDEFFECT_PRIORITY",
    1181: "ITEM_ADDEFFECT_SCRIPTED",
}

PROC_FAMILIES = {
    1: "DAMAGE",
    2: "DEBUFF",
    3: "HP_HEAL",
    4: "MP_HEAL",
    5: "HP_DRAIN",
    6: "MP_DRAIN",
    7: "TP_DRAIN",
    8: "HPMP_DRAIN",
    9: "HPMPTP_DRAIN",
    10: "DISPEL",
    11: "ABSORB_STATUS",
    12: "SELF_BUFF",
    13: "DEATH",
    14: "NM_SPECIFIC",
    15: "PHYS_DAMAGE",
}

ELEMENTS = {
    0: "NONE",
    1: "FIRE",
    2: "ICE",
    3: "WIND",
    4: "EARTH",
    5: "THUNDER",
    6: "WATER",
    7: "LIGHT",
    8: "DARK",
}

SUBEFFECTS = {
    0: "NONE",
    1: "FIRE_DAMAGE",
    2: "ICE_DAMAGE",
    3: "WIND_DAMAGE",
    4: "EARTH_DAMAGE_OR_CURSE_SPIKES",
    5: "LIGHTNING_DAMAGE",
    6: "WATER_DAMAGE",
    7: "LIGHT_DAMAGE",
    8: "DARKNESS_DAMAGE_OR_HPMP_DRAIN",
    9: "SLEEP_OR_MP_DRAIN",
    10: "POISON_OR_TP_DRAIN",
    11: "PARALYSIS_OR_HPMPTP_DRAIN",
    12: "BLIND",
    13: "SILENCE",
    14: "PETRIFY",
    15: "PLAGUE",
    16: "STUN",
    17: "CURSE",
    18: "DEFENSE_OR_EVASION_OR_ATTACK_DOWN_OR_SLOW",
    21: "HP_DRAIN",
    22: "MP_OR_TP_DRAIN",
}

SKILL_TYPES = {
    1: "HAND_TO_HAND",
    2: "DAGGER",
    3: "SWORD",
    4: "GREAT_SWORD",
    5: "AXE",
    6: "GREAT_AXE",
    7: "SCYTHE",
    8: "POLEARM",
    9: "KATANA",
    10: "GREAT_KATANA",
    11: "CLUB",
    12: "STAFF",
    25: "ARCHERY",
    26: "MARKSMANSHIP",
    27: "THROWING",
}

SLOT_BITS = {
    1: "MAIN",
    2: "SUB",
    4: "RANGED",
    8: "AMMO",
    16: "HEAD",
    32: "BODY",
    64: "HANDS",
    128: "LEGS",
    256: "FEET",
    512: "NECK",
    1024: "WAIST",
    2048: "LEFT_EAR",
    4096: "RIGHT_EAR",
    8192: "LEFT_RING",
    16384: "RIGHT_RING",
    32768: "BACK",
}

STATUS_NAMES = {
    2: "SLEEP_I",
    3: "POISON",
    4: "PARALYSIS",
    5: "BLINDNESS",
    6: "SILENCE",
    10: "STUN",
    11: "BIND",
    130: "PLAGUE",
    147: "ATTACK_DOWN",
    148: "EVASION_DOWN",
    149: "DEFENSE_DOWN",
    155: "SLOW",
}

# These entries are evidence routing, not formula claims. The task explicitly
# places these items in the Vanilla/Zilart audit set. Later issue #7899 ammo is
# intentionally left unresolved until independent introduction-date evidence
# is recorded.
AUDIT_SCOPE_ITEMS = {
    17322,
    17323,
    17324,
    17325,
    17329,
    17622,
    18148,
    18149,
    18150,
    18152,
    18157,
    18158,
    18159,
    18160,
    18161,
    18162,
    18163,
    18164,
}

ELEMENTAL_ARROW_PROFILES = {
    17322: {
        "name": "fire_arrow",
        "element": "FIRE",
        "subeffect": "FIRE_DAMAGE",
    },
    17323: {
        "name": "ice_arrow",
        "element": "ICE",
        "subeffect": "ICE_DAMAGE",
    },
    17324: {
        "name": "lightning_arrow",
        "element": "THUNDER",
        "subeffect": "LIGHTNING_DAMAGE",
    },
}

ELEMENTAL_ARROW_PROFILE_SOURCE = "scripts/globals/additional_effect_profiles.lua"
ELEMENTAL_ARROW_EVIDENCE_SOURCE = (
    "retail_parity/vanilla_zilart/artifacts/"
    "VZ-COMBAT-001-elemental-arrows-evidence.md"
)

STATUS_AMMUNITION_PROFILES = {
    17325: ("kabura_arrow", "ARCHERY", "SILENCE", "SILENCE", "NONE", "WIND"),
    17329: (
        "patriarch_protectors_arrow",
        "ARCHERY",
        "PARALYSIS",
        "PARALYSIS",
        "NONE",
        "ICE",
    ),
    18150: (
        "blind_bolt",
        "MARKSMANSHIP_BOLT",
        "BLINDNESS",
        "BLIND",
        "DARK",
        "DARK",
    ),
    18152: (
        "venom_bolt",
        "MARKSMANSHIP_BOLT",
        "POISON",
        "POISON",
        "WATER",
        "WATER",
    ),
    18157: ("poison_arrow", "ARCHERY", "POISON", "POISON", "NONE", "WATER"),
    18158: ("sleep_arrow", "ARCHERY", "SLEEP_I", "SLEEP", "NONE", "NONE"),
    18159: (
        "demon_arrow",
        "ARCHERY",
        "ATTACK_DOWN",
        "ATTACK_DOWN",
        "NONE",
        "WATER",
    ),
    18160: (
        "spartan_bullet",
        "MARKSMANSHIP_BULLET",
        "STUN",
        "STUN",
        "NONE",
        "THUNDER",
    ),
}

STATUS_AMMUNITION_PROFILE_SOURCE = "scripts/globals/additional_effect_profiles.lua"
STATUS_AMMUNITION_EVIDENCE_SOURCE = (
    "retail_parity/vanilla_zilart/artifacts/"
    "VZ-COMBAT-001-status-ammunition-evidence.md"
)

SINGLE_RESOURCE_DRAIN_PROFILES = {
    16509: {
        "name": "aspir_knife",
        "era": "ERA_UNRESOLVED",
        "resource": "MP",
        "family": 6,
        "chance": 10,
        "amount": 3,
        "subeffect": "MP_DRAIN",
        "subeffect_id": 22,
        "message": "ADD_EFFECT_MP_DRAIN",
        "equip_policy": "MAIN_OR_OFF_HAND",
    },
    16528: {
        "name": "bloody_rapier",
        "era": "VANILLA",
        "resource": "HP",
        "family": 5,
        "chance": 5,
        "amount": 10,
        "subeffect": "HP_DRAIN",
        "subeffect_id": 21,
        "message": "ADD_EFFECT_HP_DRAIN",
        "equip_policy": "MAIN_OR_OFF_HAND",
    },
    17823: {
        "name": "shinsoku",
        "era": "ZILART",
        "resource": "TP",
        "family": 7,
        "chance": 8,
        "amount": 10,
        "subeffect": "TP_DRAIN",
        "subeffect_id": 22,
        "message": "ADD_EFFECT_TP_DRAIN",
        "equip_policy": "MAIN_HAND_ONLY",
    },
}

SINGLE_RESOURCE_DRAIN_PROFILE_SOURCE = "scripts/globals/additional_effect_profiles.lua"
SINGLE_RESOURCE_DRAIN_EVIDENCE_SOURCE = (
    "retail_parity/vanilla_zilart/artifacts/"
    "VZ-COMBAT-001-single-resource-drains-evidence.md"
)

COMBINED_RESOURCE_DRAIN_PROFILES = {
    17745: {
        "name": "hofud",
        "era": "LATER_EXPANSION",
        "introduction_date": "2007-06-06",
        "resource_set": "HP_OR_MP",
        "resources": "HP|MP",
        "family": 8,
        "chance": 15,
        "amount": 15,
        "subeffect": "DARKNESS_DAMAGE",
        "subeffect_id": 8,
        "equip_policy": "MAIN_OR_OFF_HAND",
    },
    20706: {
        "name": "vampirism",
        "era": "LATER_EXPANSION",
        "introduction_date": "2015-08-05",
        "resource_set": "HP_OR_MP_OR_TP",
        "resources": "HP|MP|TP",
        "family": 9,
        "chance": 100,
        "amount": 20,
        "subeffect": "MP_DRAIN",
        "subeffect_id": 22,
        "equip_policy": "MAIN_OR_OFF_HAND",
    },
    21585: {
        "name": "crepuscular_knife",
        "era": "LATER_EXPANSION",
        "introduction_date": "2021-07-12",
        "resource_set": "HP_OR_MP_OR_TP",
        "resources": "HP|MP|TP",
        "family": 9,
        "chance": 15,
        "amount": 15,
        "subeffect": "DARKNESS_DAMAGE",
        "subeffect_id": 8,
        "equip_policy": "MAIN_OR_OFF_HAND",
    },
}

COMBINED_RESOURCE_DRAIN_PROFILE_SOURCE = (
    "scripts/globals/additional_effect_profiles.lua"
)
COMBINED_RESOURCE_DRAIN_EVIDENCE_SOURCE = (
    "retail_parity/vanilla_zilart/artifacts/"
    "VZ-COMBAT-001-combined-resource-drains-evidence.md"
)

ISSUE_7899_ITEMS = {
    "poison_arrow",
    "sleep_arrow",
    "demon_arrow",
    "patriarch_protectors_arrow",
    "ptr.prt._arrow",
    "kabura_arrow",
    "blind_bolt",
    "acid_bolt",
    "sleep_bolt",
    "venom_bolt",
    "oxidant_bolt",
    "gashing_bolt",
    "abrasion_bolt",
    "spartan_bullet",
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

SCRIPT_CALLBACK = re.compile(r"\bonItemAdditionalEffect\s*=")
SCRIPT_ID = re.compile(r"^\s*--\s*ID:\s*(\d+)\s*$", re.MULTILINE)
INSERT_VALUES = re.compile(r"INSERT INTO `[^`]+` VALUES \((.*)\);")
MOD_INSERT = re.compile(
    r"INSERT INTO `(?P<table>item_mods|item_latents)` VALUES "
    r"\((?P<item>\d+),\s*(?P<mod>\d+),\s*(?P<value>-?\d+)"
)


@dataclass
class ItemConfig:
    item_id: int
    mods: dict[int, list[int]] = field(default_factory=lambda: defaultdict(list))
    sources: list[str] = field(default_factory=list)
    latent_sources: list[str] = field(default_factory=list)
    script_paths: list[str] = field(default_factory=list)

    def value(self, mod_id: int) -> int | None:
        values = self.mods.get(mod_id, [])
        if not values:
            return None
        return sum(values)

    def has_conflicting_values(self, mod_id: int) -> bool:
        values = self.mods.get(mod_id, [])
        return len(set(values)) > 1 and mod_id not in {500, 501}


def split_sql_values(raw: str) -> list[str]:
    values: list[str] = []
    current: list[str] = []
    quoted = False
    escaped = False

    for character in raw:
        if escaped:
            current.append(character)
            escaped = False
        elif character == "\\" and quoted:
            current.append(character)
            escaped = True
        elif character == "'":
            quoted = not quoted
            current.append(character)
        elif character == "," and not quoted:
            values.append("".join(current).strip())
            current = []
        else:
            current.append(character)

    values.append("".join(current).strip())
    return values


def unquote(value: str) -> str:
    if value.startswith("'") and value.endswith("'"):
        return value[1:-1].replace("\\'", "'").replace("\\\\", "\\")
    return value


def parse_insert_file(path: Path) -> dict[int, list[str]]:
    rows: dict[int, list[str]] = {}
    for line in path.read_text(encoding="utf-8-sig").splitlines():
        match = INSERT_VALUES.search(line)
        if not match:
            continue
        values = split_sql_values(match.group(1))
        if values and values[0].isdigit():
            rows[int(values[0])] = values
    return rows


def parse_configs(root: Path) -> dict[int, ItemConfig]:
    configs: dict[int, ItemConfig] = {}
    for relative in ("sql/item_mods.sql", "sql/item_latents.sql"):
        path = root / relative
        for line_number, line in enumerate(
            path.read_text(encoding="utf-8-sig").splitlines(), start=1
        ):
            match = MOD_INSERT.search(line)
            if not match:
                continue
            mod_id = int(match.group("mod"))
            if mod_id not in RELEVANT_MODS:
                continue
            item_id = int(match.group("item"))
            value = int(match.group("value"))
            config = configs.setdefault(item_id, ItemConfig(item_id))
            config.mods[mod_id].append(value)
            source = f"{relative}:{line_number}"
            config.sources.append(source)
            if match.group("table") == "item_latents":
                config.latent_sources.append(source)
    # Issue #7899 also discusses currently unconfigured ammunition. Retain
    # those rows as explicit NOT_ACTIVE inventory entries instead of silently
    # dropping them because no additional-effect selector exists.
    for item_id in ISSUE_7899_ITEM_IDS:
        configs.setdefault(item_id, ItemConfig(item_id=item_id))

    return configs


def parse_scripts(root: Path, configs: dict[int, ItemConfig]) -> None:
    roots = [root / "scripts/items", root / "modules"]
    for script_root in roots:
        if not script_root.exists():
            continue
        for path in sorted(script_root.rglob("*.lua")):
            text = path.read_text(encoding="utf-8-sig")
            if not SCRIPT_CALLBACK.search(text):
                continue
            id_match = SCRIPT_ID.search(text)
            if not id_match:
                raise ValueError(
                    f"{path.relative_to(root)} defines onItemAdditionalEffect "
                    "without a '-- ID: <number>' header"
                )
            item_id = int(id_match.group(1))
            config = configs.setdefault(item_id, ItemConfig(item_id))
            config.script_paths.append(path.relative_to(root).as_posix())


def join_names(
    item_id: int,
    basic: dict[int, list[str]],
    equipment: dict[int, list[str]],
    weapon: dict[int, list[str]],
) -> str:
    if item_id in basic and len(basic[item_id]) > 2:
        return unquote(basic[item_id][2])
    if item_id in equipment and len(equipment[item_id]) > 1:
        return unquote(equipment[item_id][1])
    if item_id in weapon and len(weapon[item_id]) > 1:
        return unquote(weapon[item_id][1])
    return f"UNKNOWN_ITEM_{item_id}"


def item_level(item_id: int, equipment: dict[int, list[str]]) -> str:
    row = equipment.get(item_id)
    return row[2] if row and len(row) > 2 else ""


def item_slot(item_id: int, equipment: dict[int, list[str]]) -> str:
    row = equipment.get(item_id)
    if not row or len(row) <= 8 or not row[8].lstrip("-").isdigit():
        return "UNKNOWN"
    slot_mask = int(row[8])
    names = [name for bit, name in SLOT_BITS.items() if slot_mask & bit]
    return "|".join(names) if names else f"MASK_{slot_mask}"


def weapon_type(item_id: int, weapon: dict[int, list[str]]) -> str:
    row = weapon.get(item_id)
    if not row or len(row) <= 2 or not row[2].isdigit():
        return "EQUIPMENT"
    return SKILL_TYPES.get(int(row[2]), f"SKILL_{row[2]}")


def damage_type(item_id: int, weapon: dict[int, list[str]], family: str) -> str:
    if family == "PHYS_DAMAGE":
        return "PROFILE_REQUIRED"
    if family in {
        "DAMAGE",
        "HP_DRAIN",
        "MP_DRAIN",
        "TP_DRAIN",
        "HPMP_DRAIN",
        "HPMPTP_DRAIN",
        "NM_SPECIFIC",
    }:
        return "ELEMENTAL_LEGACY"
    row = weapon.get(item_id)
    if row and len(row) > 7:
        return f"WEAPON_DMGTYPE_{row[7]}"
    return "N/A"


def classify(config: ItemConfig, name: str, handler: str, reachable: bool) -> str:
    family_id = config.value(431)
    if not reachable:
        return "CONFIGURATION_ERROR"
    if handler == "CXX_EQUIPMENT_SPIKES":
        return "VERIFY_LIVE"
    if handler == "PER_ITEM_LUA":
        return "VERIFY_LIVE"
    if config.item_id in STATUS_AMMUNITION_PROFILES:
        return "VERIFY_LIVE"
    if family_id in {5, 6, 7, 8, 9, 10, 11, 12, 13}:
        return "VERIFY_LIVE"
    if config.item_id not in AUDIT_SCOPE_ITEMS:
        return "ERA_UNRESOLVED"
    if family_id == 14:
        return "SPECIAL_CASE_TEST_BACKED"
    if config.item_id in {18148, 18149}:
        return "FRAMEWORK_CORRECT_LEGACY_NUMERICS"
    return "FRAMEWORK_CORRECT_LEGACY_NUMERICS"


def resolve_handler(config: ItemConfig, slot: str) -> tuple[str, bool, list[str]]:
    family = config.value(431) or 0
    scripted = config.value(1181) or 0
    subeffect = config.value(499) or 0
    issues: list[str] = []

    if family and scripted:
        issues.append("global and scripted handlers are both configured")
    if len(config.script_paths) > 1:
        issues.append("multiple onItemAdditionalEffect scripts map to the item")

    if scripted:
        if not config.script_paths:
            issues.append("ITEM_ADDEFFECT_SCRIPTED has no matching item script")
        return "PER_ITEM_LUA", bool(config.script_paths) and not family, issues

    if family:
        if family not in PROC_FAMILIES:
            issues.append(f"unsupported proc type {family}")
        return "GLOBAL_ADDITIONAL_EFFECT", family in PROC_FAMILIES, issues

    armor_slots = {
        "SUB",
        "HEAD",
        "BODY",
        "HANDS",
        "LEGS",
        "FEET",
    }
    if subeffect and any(part in armor_slots for part in slot.split("|")):
        return "CXX_EQUIPMENT_SPIKES", True, issues

    if config.script_paths:
        issues.append("item script exists without ITEM_ADDEFFECT_SCRIPTED")
        return "PER_ITEM_LUA_UNREACHABLE", False, issues

    issues.append("additional-effect modifiers have no active handler selector")
    return "NOT_ACTIVE", False, issues


def validate_family(config: ItemConfig, handler: str) -> list[str]:
    issues: list[str] = []
    family_id = config.value(431) or 0
    chance = config.value(501)
    damage = config.value(500)
    status = config.value(951)
    duration = config.value(953)
    element = config.value(950)

    for mod_id in RELEVANT_MODS:
        if config.has_conflicting_values(mod_id):
            issues.append(
                f"conflicting {RELEVANT_MODS[mod_id]} values " f"{config.mods[mod_id]}"
            )

    if handler == "GLOBAL_ADDITIONAL_EFFECT":
        if chance is None or chance <= 0 or chance > 100:
            issues.append(f"invalid proc chance {chance}")
        if family_id == 1 and (damage is None or damage <= 0):
            issues.append("DAMAGE requires positive ITEM_ADDEFFECT_DMG")
        if family_id == 1 and (
            element is None or element not in ELEMENTS or element == 0
        ):
            issues.append("DAMAGE requires a valid nonzero element")
        if family_id == 2:
            if status is None or status <= 0:
                issues.append("DEBUFF requires a positive status effect")
            if duration is None or duration <= 0:
                issues.append("DEBUFF requires a positive duration")
        if family_id in {3, 4, 5, 6, 7, 8, 9} and (damage is None or damage <= 0):
            issues.append(f"{PROC_FAMILIES[family_id]} requires positive potency")
        if family_id == 12 and (status is None or status <= 0):
            issues.append("SELF_BUFF requires a positive status effect")
        if family_id == 15:
            issues.append("PHYS_DAMAGE has no SQL profile schema in the legacy handler")

    if handler == "CXX_EQUIPMENT_SPIKES":
        if chance is None or chance <= 0 or chance > 100:
            issues.append(f"invalid spikes proc chance {chance}")
        if (config.value(499) or 0) not in range(1, 7):
            issues.append("C++ equipment spikes requires subeffect 1..6")
        if damage is None:
            issues.append("C++ equipment spikes requires ITEM_ADDEFFECT_DMG")

    return issues


def validate_single_resource_drain(config: ItemConfig) -> list[str]:
    expected = SINGLE_RESOURCE_DRAIN_PROFILES.get(config.item_id)
    if expected is None:
        return []

    issues: list[str] = []
    expected_mods = {
        278: 0,
        431: expected["family"],
        499: expected["subeffect_id"],
        500: expected["amount"],
        501: expected["chance"],
        950: 8,
        1181: 0,
    }
    for mod_id, expected_value in expected_mods.items():
        actual = config.value(mod_id) or 0
        if actual != expected_value:
            issues.append(
                f"{RELEVANT_MODS[mod_id]} expected {expected_value}, got {actual}"
            )

    if config.script_paths:
        issues.append("scoped single-resource drain must not use a per-item script")

    return issues


def validate_combined_resource_drain(config: ItemConfig) -> list[str]:
    expected = COMBINED_RESOURCE_DRAIN_PROFILES.get(config.item_id)
    if expected is None:
        return []

    issues: list[str] = []
    expected_mods = {
        278: 0,
        431: expected["family"],
        499: expected["subeffect_id"],
        500: expected["amount"],
        501: expected["chance"],
        950: 0,
        1181: 0,
    }
    for mod_id, expected_value in expected_mods.items():
        actual = config.value(mod_id) or 0
        if actual != expected_value:
            issues.append(
                f"{RELEVANT_MODS[mod_id]} expected {expected_value}, got {actual}"
            )

    if config.script_paths:
        issues.append("scoped combined-resource drain must not use a per-item script")

    return issues


def era_for(config: ItemConfig, name: str) -> tuple[str, str]:
    combined_drain = COMBINED_RESOURCE_DRAIN_PROFILES.get(config.item_id)
    if combined_drain:
        evidence = {
            17745: (
                "Japanese community item history dates Hofud to the "
                "2007-06-06 Einherjar update"
            ),
            20706: (
                "The official 2015-08-05 update introduced Sinister Reign; "
                "Japanese item history dates Vampirism to that update"
            ),
            21585: (
                "The official 2021-07-12 update introduced the Wyrm God "
                "battlefield and explicitly names Crepuscular Knife"
            ),
        }
        return combined_drain["era"], evidence[config.item_id]

    drain = SINGLE_RESOURCE_DRAIN_PROFILES.get(config.item_id)
    if drain:
        evidence = {
            16509: (
                "Contemporary 2003 community records establish Zilart-era "
                "presence but not a precise Vanilla-versus-Zilart introduction"
            ),
            16528: (
                "Contemporary 2003 rare-weapon record predating the North "
                "American release identifies Bloody Rapier and HP drain"
            ),
            17823: (
                "Official 2004-09-14 update notes list Shinsoku before the "
                "Chains of Promathia release"
            ),
        }
        return drain["era"], evidence[config.item_id]

    if config.item_id in AUDIT_SCOPE_ITEMS:
        return (
            "VANILLA_OR_ZILART",
            "VZ-COMBAT-001 Phase A maintained audit-scope manifest",
        )
    if name in ISSUE_7899_ITEMS:
        return (
            "ERA_UNRESOLVED",
            "LandSandBoat issue #7899 names the item but does not prove introduction era",
        )
    return (
        "ERA_UNRESOLVED",
        "No introduction-era metadata exists in active repository item tables",
    )


def profile_fields(config: ItemConfig, family: str) -> dict[str, str]:
    item_id = config.item_id
    status_id = config.value(951)
    element_id = config.value(950)
    chance = config.value(501)
    level_adjust = config.value(278)
    dstat = config.value(280)

    if item_id in COMBINED_RESOURCE_DRAIN_PROFILES:
        drain = COMBINED_RESOURCE_DRAIN_PROFILES[item_id]
        return {
            "profile_family": "VZ_COMBINED_RESOURCE_DRAIN",
            "profile_source": COMBINED_RESOURCE_DRAIN_PROFILE_SOURCE,
            "field_classifications": (
                "IDENTITY_AND_ERA=EVIDENCE_BACKED;"
                "APPLICATION_AND_OUTCOME_OWNERSHIP="
                "FRAMEWORK_CORRECT_LEGACY_NUMERICS;"
                "NUMERICS_BRANCH_SELECTION_MULTIPLIERS_PRESENTATION=VERIFY_LIVE"
            ),
            "proc_policy": "FIXED_PERCENT_SQL_COMPATIBILITY; VERIFY_LIVE",
            "base_power_policy": (
                f"FIXED_{drain['amount']}_SQL_COMPATIBILITY; VERIFY_LIVE"
            ),
            "mab_policy": "DISABLED_COMPATIBILITY; VERIFY_LIVE",
            "multiplier_policies": (
                "BRANCH_SELECTION=UNIFORM_SINGLE_NO_RETRY_COMPATIBILITY_VERIFY_LIVE;"
                "GENERAL_MAGIC_DAMAGE=ENABLED_VERIFY_LIVE;"
                "ELEMENTAL_SDT=ENABLED_VERIFY_LIVE;"
                "STAFF=ENABLED_VERIFY_LIVE;"
                "AFFINITY=ENABLED_VERIFY_LIVE;"
                "DAY_WEATHER=ENABLED_VERIFY_LIVE;"
                "PHALANX=ENABLED_VERIFY_LIVE;"
                "ONE_FOR_ALL=ENABLED_VERIFY_LIVE;"
                "STONESKIN=ENABLED_VERIFY_LIVE;"
                "NULLIFICATION=ENABLED_NO_RETRY_VERIFY_LIVE;"
                "ABSORPTION=NEGATIVE_CLAMPED_TO_ZERO_NO_RETRY_VERIFY_LIVE"
            ),
            "evidence_sources": COMBINED_RESOURCE_DRAIN_EVIDENCE_SOURCE,
            "proc_chance": str(drain["chance"]),
            "level_correction": "0_SQL_COMPATIBILITY; VERIFY_LIVE",
            "accuracy_or_skill_basis": (
                "NO_EXPLICIT_SKILL_LEGACY_DAMAGE_RESISTANCE; VERIFY_LIVE"
            ),
            "governing_stat_or_dstat": (
                "NO_GOVERNING_STAT_OR_DSTAT_COMPATIBILITY; VERIFY_LIVE"
            ),
            "resistance_mode": (
                "LEGACY_MAGICAL_DAMAGE_TIERS_AND_FLOOR; SELECTED_BRANCH_"
                "NO_RETRY; VERIFY_LIVE"
            ),
            "element": "CONFIGURED_NONE;EFFECTIVE_DARK_COMPATIBILITY;VERIFY_LIVE",
            "potency_or_damage": (
                f"FIXED_{drain['amount']}_SQL_COMPATIBILITY; VERIFY_LIVE"
            ),
            "duration": "NOT_APPLICABLE",
            "status_effect": "NOT_APPLICABLE",
            "unresolved_questions": (
                f"{drain['resource_set']} uniform branch distribution, ordering, "
                "and retry/fallback; proc chance and level correction; fixed "
                "versus random per-resource amount and scaling; skill, accuracy, "
                "stat, dSTAT, and Dark element; resistance, nullification, "
                "absorption, undead, empty-resource, and defensive behavior; "
                "main/off-hand, multi-attack, Enspell priority, resource caps, "
                "and exact resource-specific presentation"
            ),
        }

    if item_id in SINGLE_RESOURCE_DRAIN_PROFILES:
        drain = SINGLE_RESOURCE_DRAIN_PROFILES[item_id]
        return {
            "profile_family": "VZ_SINGLE_RESOURCE_DRAIN",
            "profile_source": SINGLE_RESOURCE_DRAIN_PROFILE_SOURCE,
            "field_classifications": (
                "IDENTITY=EVIDENCE_BACKED;"
                f"ERA={'ERA_UNRESOLVED' if item_id == 16509 else 'EVIDENCE_BACKED'};"
                "APPLICATION=FRAMEWORK_CORRECT_LEGACY_NUMERICS;"
                "NUMERICS_AND_MULTIPLIERS=VERIFY_LIVE"
            ),
            "proc_policy": "FIXED_PERCENT_SQL_COMPATIBILITY; VERIFY_LIVE",
            "base_power_policy": (
                f"FIXED_{drain['amount']}_SQL_COMPATIBILITY; VERIFY_LIVE"
            ),
            "mab_policy": "DISABLED_COMPATIBILITY; VERIFY_LIVE",
            "multiplier_policies": (
                "GENERAL_MAGIC_DAMAGE=ENABLED_VERIFY_LIVE;"
                "ELEMENTAL_SDT=ENABLED_VERIFY_LIVE;"
                "STAFF=ENABLED_VERIFY_LIVE;"
                "AFFINITY=ENABLED_VERIFY_LIVE;"
                "DAY_WEATHER=ENABLED_VERIFY_LIVE;"
                "PHALANX=ENABLED_VERIFY_LIVE;"
                "ONE_FOR_ALL=ENABLED_VERIFY_LIVE;"
                "STONESKIN=ENABLED_VERIFY_LIVE;"
                "NULLIFICATION=ENABLED_VERIFY_LIVE;"
                "ABSORPTION=NEGATIVE_CLAMPED_TO_ZERO_VERIFY_LIVE"
            ),
            "evidence_sources": SINGLE_RESOURCE_DRAIN_EVIDENCE_SOURCE,
            "proc_chance": str(drain["chance"]),
            "level_correction": "0_SQL_COMPATIBILITY; VERIFY_LIVE",
            "accuracy_or_skill_basis": (
                "NO_EXPLICIT_SKILL_LEGACY_DAMAGE_RESISTANCE; VERIFY_LIVE"
            ),
            "governing_stat_or_dstat": (
                "NO_GOVERNING_STAT_OR_DSTAT_COMPATIBILITY; VERIFY_LIVE"
            ),
            "resistance_mode": ("LEGACY_MAGICAL_DAMAGE_TIERS_AND_FLOOR; VERIFY_LIVE"),
            "element": "DARK_SQL_COMPATIBILITY; VERIFY_LIVE",
            "potency_or_damage": (
                f"FIXED_{drain['amount']}_SQL_COMPATIBILITY; VERIFY_LIVE"
            ),
            "duration": "NOT_APPLICABLE",
            "status_effect": "NOT_APPLICABLE",
            "unresolved_questions": (
                "proc chance and level correction; fixed versus random amount "
                "and scaling; skill, accuracy, governing stat, and dSTAT; Dark "
                "element and resistance tiers; nullification, absorption, and "
                "undead behavior; attacker-full, target-empty, main/off-hand, "
                "Enspell priority, HP-oriented defenses, and exact presentation"
            ),
        }

    if item_id in ELEMENTAL_ARROW_PROFILES:
        arrow = ELEMENTAL_ARROW_PROFILES[item_id]
        return {
            "profile_family": "VZ_ELEMENTAL_ARROW",
            "profile_source": ELEMENTAL_ARROW_PROFILE_SOURCE,
            "field_classifications": (
                "ELEMENT=EVIDENCE_BACKED;NUMERICS=VERIFY_LIVE;"
                "APPLICATION=FRAMEWORK_CORRECT_LEGACY_NUMERICS"
            ),
            "proc_policy": "FIXED_PERCENT_COMPATIBILITY; VERIFY_LIVE",
            "base_power_policy": (
                "UNIFORM_INTEGER_RANGE_7_TO_10_COMPATIBILITY; VERIFY_LIVE"
            ),
            "mab_policy": "DISABLED_COMPATIBILITY; VERIFY_LIVE",
            "multiplier_policies": (
                "GENERAL_MAGIC_DAMAGE=ENABLED_VERIFY_LIVE;"
                "ELEMENTAL_SDT=ENABLED_VERIFY_LIVE;"
                "STAFF=ENABLED_VERIFY_LIVE;"
                "AFFINITY=ENABLED_VERIFY_LIVE;"
                "DAY_WEATHER=ENABLED_VERIFY_LIVE;"
                "PHALANX=ENABLED_VERIFY_LIVE;"
                "ONE_FOR_ALL=ENABLED_VERIFY_LIVE;"
                "STONESKIN=ENABLED_VERIFY_LIVE;"
                "NULLIFICATION=ENABLED_FRAMEWORK_CORRECT;"
                "ABSORPTION=ENABLED_FRAMEWORK_CORRECT"
            ),
            "evidence_sources": ELEMENTAL_ARROW_EVIDENCE_SOURCE,
            "proc_chance": "100",
            "level_correction": "ITEM_REQUIRED_LEVEL_GATE",
            "accuracy_or_skill_basis": "LEGACY_A_PLUS; VERIFY_LIVE",
            "governing_stat_or_dstat": ("NO_STAT_COMPATIBILITY; VERIFY_LIVE"),
            "resistance_mode": (
                "MAGICAL_TIERS; LOWEST_0.125_COMPATIBILITY; VERIFY_LIVE"
            ),
            "element": arrow["element"],
            "potency_or_damage": "UNIFORM_INTEGER_7_TO_10; VERIFY_LIVE",
            "duration": "NOT_APPLICABLE",
            "status_effect": "NOT_APPLICABLE",
            "unresolved_questions": (
                "proc chance and level correction; base power and random range; "
                "governing stat and dSTAT; magic accuracy and skill rank; MAB, "
                "staff, affinity, and day/weather multipliers; resist tiers and "
                "lowest tier; defensive mitigation and absorption details"
            ),
        }

    if item_id in STATUS_AMMUNITION_PROFILES:
        (
            _name,
            category,
            status,
            _subeffect,
            configured_element,
            effective_element,
        ) = STATUS_AMMUNITION_PROFILES[item_id]
        unresolved = (
            "proc chance and level correction; magic accuracy, skill basis, "
            "and governing stat; action element and resistance tiers; power, "
            "duration, overwrite, and status-removal semantics; exact client "
            "presentation"
        )
        if item_id == 18160:
            unresolved += (
                "; Spartan target/source cooldown duration, ownership, "
                "weapon-skill eligibility, and unrelated-Stun interaction"
            )

        return {
            "profile_family": "VZ_STATUS_AMMUNITION",
            "profile_source": STATUS_AMMUNITION_PROFILE_SOURCE,
            "field_classifications": (
                "IDENTITY=EVIDENCE_BACKED;PROC_LEVEL_STAT_ELEMENT_POWER_DURATION_"
                "RESIST=VERIFY_LIVE;DSTAT=NOT_APPLICABLE;"
                "TRIGGER_AMMO_PRESENTATION=FRAMEWORK_CORRECT_LEGACY_NUMERICS"
            ),
            "proc_policy": "SQL_MODIFIER_COMPATIBILITY; VERIFY_LIVE",
            "base_power_policy": "STATUS_POWER_SQL_COMPATIBILITY; VERIFY_LIVE",
            "mab_policy": "NOT_APPLICABLE",
            "multiplier_policies": (
                "IMMUNITY=STATUS_HELPERS_FRAMEWORK_CORRECT;"
                "TRAIT_RESISTANCE=STATUS_HELPERS_FRAMEWORK_CORRECT;"
                "NULLIFICATION=STATUS_HELPERS_FRAMEWORK_CORRECT;"
                "PARTIAL_DURATION=MIN_HALF_COMPATIBILITY_VERIFY_LIVE;"
                "OVERWRITE=STATUS_CONTAINER_COMPATIBILITY_VERIFY_LIVE"
            ),
            "evidence_sources": STATUS_AMMUNITION_EVIDENCE_SOURCE,
            "proc_chance": "" if chance is None else str(chance),
            "level_correction": "" if level_adjust is None else str(level_adjust),
            "accuracy_or_skill_basis": "LEGACY_A_RANK; VERIFY_LIVE",
            "governing_stat_or_dstat": (
                "LEGACY_INT_ACCURACY; DSTAT_NOT_USED_BY_STATUS_HANDLER; " "VERIFY_LIVE"
            ),
            "resistance_mode": (
                "STATUS_MAGIC_TIER; DURATION_SCALED_MIN_HALF; VERIFY_LIVE"
            ),
            "element": (
                f"CONFIGURED_{configured_element};EFFECTIVE_{effective_element};"
                "VERIFY_LIVE"
            ),
            "potency_or_damage": (
                "" if config.value(952) is None else str(config.value(952))
            ),
            "duration": "" if config.value(953) is None else str(config.value(953)),
            "status_effect": status,
            "unresolved_questions": unresolved,
        }

    accuracy = "N/A"
    governing_stat = "N/A"
    resistance = "NONE_OR_HANDLER_SPECIFIC"
    if family == "DEBUFF":
        accuracy = (
            "ITEM_NATIVE_A_RANK" if item_id in {18148, 18149} else "LEGACY_A_RANK"
        )
        governing_stat = (
            "UNRESOLVED; LEGACY_INT_COMPATIBILITY"
            if item_id in {18148, 18149}
            else ("LEGACY_INT" if dstat is not None else "LEGACY_INT_DEFAULT")
        )
        resistance = "STATUS_MAGIC_TIER"
    elif family in {
        "DAMAGE",
        "HP_DRAIN",
        "MP_DRAIN",
        "TP_DRAIN",
        "HPMP_DRAIN",
        "HPMPTP_DRAIN",
        "ABSORB_STATUS",
    }:
        accuracy = "LEGACY_ADDITIONAL_EFFECT_MAGIC_ACCURACY"
        governing_stat = (
            f"MOD_{dstat}" if dstat not in {None, 0} else "NO_DSTAT_CONFIGURED"
        )
        resistance = "MAGICAL_DAMAGE_TIER_OR_LEGACY_HANDLER"

    unresolved: list[str] = []
    if item_id in {18148, 18149}:
        unresolved.append("governing dSTAT/no-dSTAT behavior")
        unresolved.append("item-specific proc/potency/duration retail confirmation")
    elif family in {"HPMP_DRAIN", "HPMPTP_DRAIN"}:
        unresolved.append("combined-drain resolution ordering")
    elif family in {"HP_DRAIN", "MP_DRAIN", "TP_DRAIN"}:
        unresolved.append("drain accuracy, scaling, and element")
    elif family == "SELF_BUFF":
        unresolved.append("self-buff power, duration, tier, and overwrite rules")
    elif family == "DEATH":
        unresolved.append("Death accuracy and resistance formula")
    elif family == "EQUIPMENT_SPIKES":
        unresolved.append("equipment auto-spikes retail formula")
    else:
        unresolved.append("item-specific retail numerics")

    return {
        "profile_family": "",
        "profile_source": "",
        "field_classifications": "",
        "proc_policy": "",
        "base_power_policy": "",
        "mab_policy": "",
        "multiplier_policies": "",
        "evidence_sources": "",
        "proc_chance": "" if chance is None else str(chance),
        "level_correction": "" if level_adjust is None else str(level_adjust),
        "accuracy_or_skill_basis": accuracy,
        "governing_stat_or_dstat": governing_stat,
        "resistance_mode": resistance,
        "element": (
            ""
            if element_id is None
            else ELEMENTS.get(element_id, f"INVALID_{element_id}")
        ),
        "potency_or_damage": (
            "" if config.value(500) is None else str(config.value(500))
        ),
        "duration": "" if config.value(953) is None else str(config.value(953)),
        "status_effect": (
            ""
            if status_id is None
            else STATUS_NAMES.get(status_id, f"EFFECT_{status_id}")
        ),
        "unresolved_questions": "; ".join(unresolved),
    }


COLUMNS = [
    "item_id",
    "item_name",
    "item_level",
    "item_slot",
    "weapon_or_ammo_type",
    "era",
    "era_evidence",
    "configuration_source",
    "modifier_or_script_source",
    "profile_family",
    "profile_source",
    "field_classifications",
    "active_call_path",
    "proc_type",
    "subeffect",
    "proc_chance",
    "proc_policy",
    "level_correction",
    "base_power_policy",
    "accuracy_or_skill_basis",
    "governing_stat_or_dstat",
    "mab_policy",
    "multiplier_policies",
    "resistance_mode",
    "element",
    "damage_type",
    "potency_or_damage",
    "duration",
    "status_effect",
    "immunity_handling",
    "nullification_handling",
    "absorb_handling",
    "message_id",
    "special_target_or_nm_rule",
    "level_sync_behavior",
    "current_handler",
    "handler_reachable",
    "automated_test_reference",
    "evidence_sources",
    "evidence_confidence",
    "current_classification",
    "unresolved_questions",
]


def build_rows(root: Path) -> tuple[list[dict[str, str]], list[str]]:
    basic = parse_insert_file(root / "sql/item_basic.sql")
    equipment = parse_insert_file(root / "sql/item_equipment.sql")
    weapon = parse_insert_file(root / "sql/item_weapon.sql")
    configs = parse_configs(root)
    parse_scripts(root, configs)

    rows: list[dict[str, str]] = []
    all_issues: list[str] = []
    for item_id in sorted(configs):
        config = configs[item_id]
        name = join_names(item_id, basic, equipment, weapon)
        slot = item_slot(item_id, equipment)
        kind = weapon_type(item_id, weapon)
        handler, reachable, issues = resolve_handler(config, slot)
        issues.extend(validate_family(config, handler))
        issues.extend(validate_single_resource_drain(config))
        issues.extend(validate_combined_resource_drain(config))
        if name.startswith("UNKNOWN_ITEM_"):
            issues.append("item ID is absent from item basic/equipment/weapon tables")

        family_id = config.value(431)
        if handler == "CXX_EQUIPMENT_SPIKES":
            family = "EQUIPMENT_SPIKES"
        elif handler.startswith("PER_ITEM"):
            family = "SCRIPTED"
        elif family_id:
            family = PROC_FAMILIES.get(family_id, f"UNKNOWN_{family_id}")
        else:
            family = "UNSELECTED"

        era, era_evidence = era_for(config, name)
        profile = profile_fields(config, family)
        if issues:
            reachable = False
            all_issues.extend(
                f"{item_id} {name}: {issue}" for issue in sorted(set(issues))
            )

        classification = classify(config, name, handler, reachable)
        if not reachable:
            classification = "CONFIGURATION_ERROR"

        script_source = ";".join(config.script_paths)
        modifier_source = ";".join(config.sources)
        source_kinds = []
        if config.sources:
            source_kinds.append("SQL_MODIFIERS")
        if config.latent_sources:
            source_kinds.append("SQL_LATENTS")
        if config.script_paths:
            source_kinds.append("ITEM_SCRIPT")
        if item_id in ELEMENTAL_ARROW_PROFILES:
            source_kinds.append("SCRIPTED_PROFILE")
        if item_id in STATUS_AMMUNITION_PROFILES:
            source_kinds.append("STATUS_AMMUNITION_PROFILE")
        if item_id in SINGLE_RESOURCE_DRAIN_PROFILES:
            source_kinds.append("SINGLE_RESOURCE_DRAIN_PROFILE")
        if item_id in COMBINED_RESOURCE_DRAIN_PROFILES:
            source_kinds.append("COMBINED_RESOURCE_DRAIN_PROFILE")
        if not source_kinds and item_id in ISSUE_7899_ITEM_IDS:
            source_kinds.append("ISSUE_EVIDENCE_ONLY")
            script_source = "LandSandBoat issue #7899"

        if item_id in COMBINED_RESOURCE_DRAIN_PROFILES:
            call_path = (
                "successful melee swing -> HandleEnspell item selection -> "
                "luautils::additionalEffectAttack -> xi.additionalEffect.attack -> "
                "executeCombinedResourceDrain -> executeResourceDrainTransfer"
            )
        elif item_id in SINGLE_RESOURCE_DRAIN_PROFILES:
            call_path = (
                "successful melee swing -> HandleEnspell item selection -> "
                "luautils::additionalEffectAttack -> xi.additionalEffect.attack -> "
                "executeSingleResourceDrain"
            )
        elif item_id in STATUS_AMMUNITION_PROFILES:
            call_path = (
                "successful ranged OnRangedAttack -> "
                "luautils::additionalEffectAttack -> xi.additionalEffect.attack"
            )
        elif handler == "GLOBAL_ADDITIONAL_EFFECT":
            call_path = (
                "melee HandleEnspell or ranged OnRangedAttack -> "
                "luautils::additionalEffectAttack -> xi.additionalEffect.attack"
            )
        elif handler == "PER_ITEM_LUA":
            if item_id in ELEMENTAL_ARROW_PROFILES:
                call_path = (
                    "successful ranged OnRangedAttack -> "
                    "luautils::OnItemAdditionalEffect -> onItemAdditionalEffect -> "
                    "executeScriptedDamageProfile -> executeAddEffectDamage"
                )
            else:
                call_path = (
                    "melee HandleEnspell or ranged OnRangedAttack -> "
                    "luautils::OnItemAdditionalEffect -> onItemAdditionalEffect"
                )
        elif handler == "CXX_EQUIPMENT_SPIKES":
            call_path = (
                "melee reaction -> battleutils::HandleSpikesDamage -> HandleSpikesEquip"
            )
        else:
            call_path = "NO_REACHABLE_RUNTIME_PATH"

        test_reference = ""
        if item_id in {18148, 18149}:
            test_reference = (
                "scripts/tests/systems/combat/item_additional_effects.lua;"
                "scripts/tests/systems/combat/item_additional_effects_ranged.lua"
            )
        elif family == "NM_SPECIFIC" and item_id in {17622, 18161, 18162, 18163, 18164}:
            test_reference = (
                "scripts/tests/systems/combat/item_additional_effects_nm.lua"
            )
        elif item_id in ELEMENTAL_ARROW_PROFILES:
            test_reference = (
                "scripts/tests/systems/combat/"
                "item_additional_effects_elemental_arrows.lua;"
                "scripts/tests/systems/combat/"
                "item_additional_effects_elemental_arrow_profiles.lua"
            )
        elif item_id in STATUS_AMMUNITION_PROFILES:
            test_reference = (
                "scripts/tests/systems/combat/"
                "item_additional_effects_status_ammunition.lua;"
                "scripts/tests/systems/combat/"
                "item_additional_effects_status_ammunition_profiles.lua"
            )
        elif item_id in SINGLE_RESOURCE_DRAIN_PROFILES:
            test_reference = (
                "scripts/tests/systems/combat/"
                "item_additional_effects_single_resource_drains.lua;"
                "scripts/tests/systems/combat/"
                "item_additional_effects_single_resource_drain_profiles.lua"
            )
        elif item_id in COMBINED_RESOURCE_DRAIN_PROFILES:
            test_reference = (
                "scripts/tests/systems/combat/"
                "item_additional_effects_combined_resource_drains.lua;"
                "scripts/tests/systems/combat/"
                "item_additional_effects_combined_resource_drain_profiles.lua"
            )

        unresolved = profile["unresolved_questions"]
        if issues:
            unresolved = "; ".join(sorted(set(issues + [unresolved])))

        row = {
            "item_id": str(item_id),
            "item_name": name,
            "item_level": item_level(item_id, equipment),
            "item_slot": slot,
            "weapon_or_ammo_type": kind,
            "era": era,
            "era_evidence": era_evidence,
            "configuration_source": "+".join(source_kinds),
            "modifier_or_script_source": ";".join(
                value
                for value in (
                    modifier_source,
                    script_source,
                    (
                        COMBINED_RESOURCE_DRAIN_PROFILE_SOURCE
                        if item_id in COMBINED_RESOURCE_DRAIN_PROFILES
                        else (
                            ELEMENTAL_ARROW_PROFILE_SOURCE
                            if item_id in ELEMENTAL_ARROW_PROFILES
                            else (
                                STATUS_AMMUNITION_PROFILE_SOURCE
                                if item_id in STATUS_AMMUNITION_PROFILES
                                else (
                                    SINGLE_RESOURCE_DRAIN_PROFILE_SOURCE
                                    if item_id in SINGLE_RESOURCE_DRAIN_PROFILES
                                    else ""
                                )
                            )
                        )
                    ),
                )
                if value
            ),
            "active_call_path": call_path,
            "proc_type": family,
            "subeffect": (
                COMBINED_RESOURCE_DRAIN_PROFILES[item_id]["subeffect"]
                if item_id in COMBINED_RESOURCE_DRAIN_PROFILES
                else (
                    SINGLE_RESOURCE_DRAIN_PROFILES[item_id]["subeffect"]
                    if item_id in SINGLE_RESOURCE_DRAIN_PROFILES
                    else (
                        ELEMENTAL_ARROW_PROFILES[item_id]["subeffect"]
                        if item_id in ELEMENTAL_ARROW_PROFILES
                        else (
                            STATUS_AMMUNITION_PROFILES[item_id][3]
                            if item_id in STATUS_AMMUNITION_PROFILES
                            else (
                                ""
                                if config.value(499) is None
                                else SUBEFFECTS.get(
                                    config.value(499),
                                    f"SUBEFFECT_{config.value(499)}",
                                )
                            )
                        )
                    )
                )
            ),
            **profile,
            "damage_type": (
                "DARK_MAGICAL_COMPATIBILITY; VERIFY_LIVE"
                if item_id in COMBINED_RESOURCE_DRAIN_PROFILES
                else (
                    "ELEMENTAL_BY_PROFILE; FRAMEWORK_CORRECT_LEGACY_NUMERICS"
                    if item_id in ELEMENTAL_ARROW_PROFILES
                    else damage_type(item_id, weapon, family)
                )
            ),
            "immunity_handling": (
                "DEAD_AND_UNDEAD_GUARD_BEFORE_AMOUNT_CALCULATION;"
                "SELECTED_BRANCH_NO_RETRY; VERIFY_LIVE"
                if item_id in COMBINED_RESOURCE_DRAIN_PROFILES
                else (
                    "DEAD_AND_UNDEAD_GUARD_BEFORE_AMOUNT_CALCULATION; VERIFY_LIVE"
                    if item_id in SINGLE_RESOURCE_DRAIN_PROFILES
                    else (
                        "STATUS_HELPERS; FRAMEWORK_CORRECT_LEGACY_NUMERICS"
                        if item_id in STATUS_AMMUNITION_PROFILES
                        else (
                            "STATUS_HELPERS"
                            if family == "DEBUFF"
                            else (
                                "UNDEAD_GUARD"
                                if "DRAIN" in family
                                else "HANDLER_SPECIFIC"
                            )
                        )
                    )
                )
            ),
            "nullification_handling": (
                "SCOPED_CALCULATOR_SINGLE_PASS; SELECTED_BRANCH_NO_RETRY; "
                "VERIFY_LIVE"
                if item_id in COMBINED_RESOURCE_DRAIN_PROFILES
                else (
                    "SCOPED_CALCULATOR_SINGLE_PASS; VERIFY_LIVE"
                    if item_id in SINGLE_RESOURCE_DRAIN_PROFILES
                    else (
                        "STATUS_HELPERS; FRAMEWORK_CORRECT_LEGACY_NUMERICS"
                        if item_id in STATUS_AMMUNITION_PROFILES
                        else (
                            "SCRIPTED_PROFILE_SINGLE_PASS"
                            if item_id in ELEMENTAL_ARROW_PROFILES
                            else (
                                "DAMAGE_PROFILE_SINGLE_PASS"
                                if family in {"DAMAGE", "PHYS_DAMAGE"}
                                else "HANDLER_SPECIFIC"
                            )
                        )
                    )
                )
            ),
            "absorb_handling": (
                "NEGATIVE_RESULT_CLAMPED_TO_ZERO; SELECTED_BRANCH_NO_RETRY; "
                "VERIFY_LIVE"
                if item_id in COMBINED_RESOURCE_DRAIN_PROFILES
                else (
                    "NEGATIVE_RESULT_CLAMPED_TO_ZERO; VERIFY_LIVE"
                    if item_id in SINGLE_RESOURCE_DRAIN_PROFILES
                    else (
                        "NOT_APPLICABLE_TO_STATUS"
                        if item_id in STATUS_AMMUNITION_PROFILES
                        else (
                            "SCRIPTED_PROFILE_SINGLE_PASS"
                            if item_id in ELEMENTAL_ARROW_PROFILES
                            else (
                                "DAMAGE_PROFILE_SINGLE_PASS"
                                if family in {"DAMAGE", "PHYS_DAMAGE"}
                                else "HANDLER_SPECIFIC"
                            )
                        )
                    )
                )
            ),
            "message_id": (
                "SELECTED_RESOURCE_HP_MP_TP_DRAIN_MESSAGE; "
                "ACTUAL_TARGET_RESOURCE_REMOVED"
                if item_id in COMBINED_RESOURCE_DRAIN_PROFILES
                else (
                    (
                        f"{SINGLE_RESOURCE_DRAIN_PROFILES[item_id]['message']}; "
                        "ACTUAL_TARGET_RESOURCE_REMOVED"
                    )
                    if item_id in SINGLE_RESOURCE_DRAIN_PROFILES
                    else (
                        "ADD_EFFECT_STATUS_2; EFFECT_ID"
                        if item_id in STATUS_AMMUNITION_PROFILES
                        else (
                            "ADD_EFFECT_DMG_OR_HEAL; ACTUAL_APPLIED_AMOUNT"
                            if item_id in ELEMENTAL_ARROW_PROFILES
                            else "FAMILY_DEFAULT_OR_SCRIPT_RETURN"
                        )
                    )
                )
            ),
            "special_target_or_nm_rule": (
                "SPARTAN_COOLDOWN_NOT_IMPLEMENTED_VERIFY_LIVE"
                if item_id == 18160
                else (
                    "NM_NAME_AND_REQUIRED_ITEM"
                    if family == "NM_SPECIFIC"
                    else "NONE_RECORDED"
                )
            ),
            "level_sync_behavior": (
                "BLOCKED_WHEN_ITEM_LEVEL_EXCEEDS_MAIN_LEVEL"
                if handler in {"GLOBAL_ADDITIONAL_EFFECT", "PER_ITEM_LUA"}
                else "GetScaledItemModifier returns zero for unsupported synced mods"
            ),
            "current_handler": (
                "GLOBAL_COMBINED_RESOURCE_DRAIN_PROFILE"
                if item_id in COMBINED_RESOURCE_DRAIN_PROFILES
                else (
                    "GLOBAL_SINGLE_RESOURCE_DRAIN_PROFILE"
                    if item_id in SINGLE_RESOURCE_DRAIN_PROFILES
                    else (
                        "PER_ITEM_LUA_PROFILE"
                        if item_id in ELEMENTAL_ARROW_PROFILES
                        else (
                            "GLOBAL_ADDITIONAL_EFFECT_PROFILE"
                            if item_id in STATUS_AMMUNITION_PROFILES
                            else handler
                        )
                    )
                )
            ),
            "handler_reachable": "YES" if reachable else "NO",
            "automated_test_reference": test_reference,
            "evidence_confidence": (
                "HIGH_FRAMEWORK_LOW_RETAIL_NUMERICS"
                if classification
                in {
                    "FRAMEWORK_CORRECT_LEGACY_NUMERICS",
                    "VERIFY_LIVE",
                    "ERA_UNRESOLVED",
                }
                else "HIGH"
            ),
            "current_classification": classification,
            "unresolved_questions": unresolved,
        }
        rows.append({column: row.get(column, "") for column in COLUMNS})

    return rows, sorted(all_issues)


def csv_text(rows: list[dict[str, str]]) -> str:
    output = io.StringIO(newline="")
    writer = csv.DictWriter(output, fieldnames=COLUMNS, lineterminator="\n")
    writer.writeheader()
    writer.writerows(rows)
    return output.getvalue()


def markdown_text(rows: list[dict[str, str]], issues: list[str]) -> str:
    era_counts = Counter(row["era"] for row in rows)
    family_counts = Counter(row["proc_type"] for row in rows)
    source_counts = Counter(row["configuration_source"] for row in rows)
    class_counts = Counter(row["current_classification"] for row in rows)

    lines = [
        "# VZ-COMBAT-001 Item Additional-Effect Inventory",
        "",
        "Machine-generated by "
        "`tools/retail_parity/generate_item_additional_effect_inventory.py`. "
        "Do not edit this file or the CSV by hand.",
        "",
        "The inventory intentionally includes every item found in active "
        "additional-effect SQL or per-item scripts. Items lacking repository "
        "introduction-era evidence remain `ERA_UNRESOLVED`; numeric item IDs "
        "and descriptions are not treated as era proof.",
        "",
        f"- Total items: {len(rows)}",
        f"- Configuration findings: {len(issues)}",
        "",
        "## Totals",
        "",
        "### Era",
        "",
    ]

    for key, value in sorted(era_counts.items()):
        lines.append(f"- {key}: {value}")
    lines.extend(["", "### Effect family", ""])
    for key, value in sorted(family_counts.items()):
        lines.append(f"- {key}: {value}")
    lines.extend(["", "### Configuration source", ""])
    for key, value in sorted(source_counts.items()):
        lines.append(f"- {key}: {value}")
    lines.extend(["", "### Classification", ""])
    for key, value in sorted(class_counts.items()):
        lines.append(f"- {key}: {value}")

    lines.extend(
        [
            "",
            "## Configuration findings",
            "",
        ]
    )
    if issues:
        lines.extend(f"- {issue}" for issue in issues)
    else:
        lines.append("- None.")

    visible = [
        "item_id",
        "item_name",
        "item_level",
        "item_slot",
        "proc_type",
        "current_handler",
        "era",
        "current_classification",
        "handler_reachable",
        "unresolved_questions",
    ]
    lines.extend(
        [
            "",
            "## Inventory",
            "",
            "| " + " | ".join(visible) + " |",
            "|" + "|".join("---" for _ in visible) + "|",
        ]
    )
    for row in rows:
        cells = [
            row[column].replace("|", "\\|").replace("\n", " ") for column in visible
        ]
        lines.append("| " + " | ".join(cells) + " |")
    lines.append("")
    return "\n".join(lines)


def write_or_check(path: Path, content: str, check: bool) -> bool:
    if check:
        return path.exists() and path.read_text(encoding="utf-8") == content
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content, encoding="utf-8", newline="\n")
    return True


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--root",
        type=Path,
        default=Path(__file__).resolve().parents[2],
        help="repository root",
    )
    parser.add_argument(
        "--check",
        action="store_true",
        help="fail if tracked artifacts differ from freshly generated output",
    )
    parser.add_argument(
        "--strict",
        action="store_true",
        help="fail when configuration findings are present",
    )
    args = parser.parse_args()
    root = args.root.resolve()
    artifact_dir = root / "retail_parity/vanilla_zilart/artifacts"
    csv_path = artifact_dir / "VZ-COMBAT-001-item-inventory.csv"
    markdown_path = artifact_dir / "VZ-COMBAT-001-item-inventory.md"

    try:
        rows, issues = build_rows(root)
    except (OSError, ValueError) as exception:
        print(f"inventory generation failed: {exception}", file=sys.stderr)
        return 2

    generated = {
        csv_path: csv_text(rows),
        markdown_path: markdown_text(rows, issues),
    }
    stale = [
        path
        for path, content in generated.items()
        if not write_or_check(path, content, args.check)
    ]

    if stale:
        for path in stale:
            print(
                f"stale inventory artifact: {path.relative_to(root)}", file=sys.stderr
            )
        return 1

    print(
        f"inventory: {len(rows)} items, {len(issues)} configuration finding(s), "
        f"mode={'check' if args.check else 'write'}"
    )
    if args.strict and issues:
        for issue in issues:
            print(f"configuration error: {issue}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

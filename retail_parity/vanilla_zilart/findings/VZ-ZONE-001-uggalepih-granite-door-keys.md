# VZ-ZONE-001 — Temple of Uggalepih Map 2 Granite-Door Key Requirements

## Identification

- **ID:** `VZ-ZONE-001`
- **Title:** Western Map 2 Granite Door incorrectly requires a Prelate Key
- **Expansion scope:** Rise of the Zilart
- **Area:** Temple of Uggalepih / doors / mission and quest navigation
- **Baseline status:** `INACCURATE`
- **Implementation state:** `IMPLEMENTED_AND_TEST_BACKED`
- **Implementation commit:** `620d69d7c0315f70066c3484e110bb5d9baade3d`
- **Validation commit:** `01bb2d6556df17fcb4e26851b9b9202adb445bdf`
- **Severity:** `MODERATE`
- **Confidence:** `HIGH`
- **Disposition:** `ASSISTANT_DIRECT`

## Expected retail behavior

Retail distinguishes two adjacent locked Granite Doors on Temple of Uggalepih Map 2:

- The western door, documented around I-10/E-8 depending on map presentation, consumes an Uggalepih Key and leads to the Ancient Verse of Uggalepih route used by Windurst Mission 9-2.
- The door immediately east, documented around J-10, consumes a Prelate Key and is used by the San d'Oria Mission 8-2 route.

A used key is consumed. The door can be opened from the interior side without another key.

## Baseline LandSandBoat behavior

At pinned baseline `242ab0d055dfb80396e7398b0dd7361b750c74e2`:

- `_mf8.lua` is at `!pos -11 -8 -99 159` and consumes a Prelate Key.
- `_mf9.lua` is at `!pos -60 -8 -99 159` and also consumes a Prelate Key.
- The doors share the same north-south coordinate; `_mf9` is west of `_mf8` because its X coordinate is lower.

This makes the western door request the wrong key.

## Entity mapping

Independent route documentation places:

- the Uggalepih-Key door west at I-10; and
- the Prelate-Key door east at J-10.

The source coordinates independently reproduce that west/east relationship:

- `_mf9`: X `-60` — western door — Uggalepih Key
- `_mf8`: X `-11` — eastern door — Prelate Key

This resolves the earlier ambiguity without an intermediate owner test.

## Evidence

- **Current source:**
  - `scripts/zones/Temple_of_Uggalepih/npcs/_mf8.lua`
  - `scripts/zones/Temple_of_Uggalepih/npcs/_mf9.lua`
  - `scripts/zones/Temple_of_Uggalepih/npcs/_mf6.lua`
- **Upstream tracking:** https://github.com/LandSandBoat/server/issues/864
- **Independent corroboration:**
  - https://www.bg-wiki.com/ffxi/Windurst_Mission_9-2
  - https://www.bg-wiki.com/ffxi/San_d%27Oria_Mission_8-2
  - https://ffxiclopedia.fandom.com/wiki/Uggalepih_Key
  - https://ffxiclopedia.fandom.com/wiki/Prelate_Key
  - https://ffxiclopedia.fandom.com/wiki/Moon_Reading

## Implemented correction

Branch: `retail-parity/fix-vz-zone-001`

Commit: `620d69d7c0315f70066c3484e110bb5d9baade3d`

Changes to `_mf9.lua`:

- Replaced `PRELATE_KEY` with `UGGALEPIH_KEY` for the trade requirement.
- Replaced the locked-door message parameter with `UGGALEPIH_KEY`.
- Updated the script header.
- Tightened the trade check to `npcUtil.tradeHasExactly` so unrelated extra items are not accepted with the key.

`_mf8.lua` remains the Prelate-Key door.

## Automated validation completed

`scripts/tests/zones/temple_of_uggalepih_doors.lua` exercises the real NPC
trade and trigger handlers through the Lua simulation harness. It proves:

1. `_mf9` accepts exactly one Uggalepih Key, consumes it, emits the
   key-break message with the Uggalepih Key parameter, and opens.
2. `_mf9` rejects a Prelate Key and rejects an Uggalepih Key accompanied by
   an extra item without consuming either item or opening.
3. `_mf9`'s locked-side message names the Uggalepih Key.
4. `_mf8` still accepts and consumes a Prelate Key, opens, and uses the
   Prelate Key in both break and locked messages.
5. Both doors open from their existing unlocked-side coordinate checks.

All five cases passed in the focused `xi_test` run. The full MSVC/Ninja Debug
build also passed.

## Remaining validation

The harness validates server-side animation state and message parameters, not
the client's rendered door timing or complete mission-route traversal. The
existing 6.5/11-second timing and Windurst 9-2/San d'Oria 8-2 route
presentation therefore remain client/live-retail-only candidates; no
intermediate owner test is requested.

## Dependencies and regression risk

- Windurst Mission 9-2.
- San d'Oria Mission 8-2.
- Uggalepih Key and Prelate Key acquisition/use expectations.
- Door-side coordinate checks and opening duration.

The correction is isolated to one NPC script and has low regression risk.

## Completion criteria

- [x] The western Map 2 door consumes an Uggalepih Key.
- [x] The eastern Map 2 door consumes a Prelate Key.
- [x] Both server handlers use the correct locked-message key parameter.
- [x] Incorrect/non-exact `_mf9` trades are rejected.
- [x] Server-side key consumption and opening behavior are automated.
- [ ] Client-rendered timing and full mission-route traversal are observed on
  live/client infrastructure.

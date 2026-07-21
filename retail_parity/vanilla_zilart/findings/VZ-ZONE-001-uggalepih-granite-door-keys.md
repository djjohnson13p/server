# VZ-ZONE-001 — Temple of Uggalepih Map 2 Granite-Door Key Requirements

## Identification

- **ID:** `VZ-ZONE-001`
- **Title:** Western Map 2 Granite Door incorrectly requires a Prelate Key
- **Expansion scope:** Rise of the Zilart
- **Area:** Temple of Uggalepih / doors / mission and quest navigation
- **Baseline status:** `INACCURATE`
- **Implementation state:** Corrected on `retail-parity/fix-vz-zone-001` at commit `620d69d7c0315f70066c3484e110bb5d9baade3d`
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

## Validation plan

Automated test infrastructure for this specific positional door interaction was not located through the connected repository index. Final client/server validation is deferred to the consolidated human-only stage rather than interrupting the audit.

Final validation should confirm:

1. `_mf9` rejects a Prelate Key and accepts exactly one Uggalepih Key.
2. The Uggalepih Key is consumed and the door opens for the existing timed interval.
3. `_mf8` continues to accept a Prelate Key.
4. Each door opens from its interior side without a key.
5. Windurst 9-2 and San d'Oria 8-2 routes remain traversable.

## Dependencies and regression risk

- Windurst Mission 9-2.
- San d'Oria Mission 8-2.
- Uggalepih Key and Prelate Key acquisition/use expectations.
- Door-side coordinate checks and opening duration.

The correction is isolated to one NPC script and has low regression risk.

## Completion criteria

- The western Map 2 door consumes an Uggalepih Key.
- The eastern Map 2 door consumes a Prelate Key.
- Both show the correct locked message and reject the incorrect key.
- Key consumption and door timing remain correct.
- Final route validation passes.

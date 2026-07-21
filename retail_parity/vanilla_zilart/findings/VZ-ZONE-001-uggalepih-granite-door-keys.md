# VZ-ZONE-001 — Temple of Uggalepih Map 2 Granite-Door Key Requirements

## Identification

- **ID:** `VZ-ZONE-001`
- **Title:** Two Map 2 Granite Doors are configured for the Prelate Key even though retail distinguishes an Uggalepih-Key door
- **Expansion scope:** Rise of the Zilart
- **Area:** Temple of Uggalepih / doors / mission and quest navigation
- **Status:** `INACCURATE`
- **Severity:** `MODERATE`
- **Confidence:** `MEDIUM`
- **Disposition:** `ASSISTANT_DIRECT`

## Expected retail behavior

Retail documentation distinguishes at least two locked Granite Doors in the relevant Temple of Uggalepih Map 2 route:

- An Uggalepih Key opens a Granite Door on Map 2 at E-8 and is consumed.
- A separate northern Granite Door on Map 2 uses a Prelate Key and consumes that key.

These doors participate in routes used by nation missions and other Temple content. The exact LandSandBoat entity corresponding to each mapped door must be confirmed in-game before editing.

## Current LandSandBoat behavior

At pinned baseline `242ab0d055dfb80396e7398b0dd7361b750c74e2`:

- `scripts/zones/Temple_of_Uggalepih/npcs/_mf8.lua` identifies a Granite Door at `!pos -11 -8 -99 159` and accepts only `xi.item.PRELATE_KEY`.
- `scripts/zones/Temple_of_Uggalepih/npcs/_mf9.lua` identifies a Granite Door at `!pos -60 -8 -99 159` and also accepts only `xi.item.PRELATE_KEY`.
- A different door, `_mf6.lua` at `!pos -208 -1.89 -20`, correctly accepts `xi.item.UGGALEPIH_KEY`, but its location does not resolve the apparent duplicate Prelate-Key configuration for the two adjacent Map 2 doors.
- Upstream issue `#864` reports that the first of the two relevant doors should require an Uggalepih Key and the second should require a Prelate Key.

## Difference

At least one of `_mf8` and `_mf9` appears to have the wrong required key. Both currently consume a Prelate Key, while independent retail references distinguish an Uggalepih-Key Map 2 door from a Prelate-Key Map 2 door.

The discrepancy is supported, but assigning the Uggalepih Key to `_mf8` or `_mf9` solely from filenames/coordinates would be premature. One route walk or map/entity check is required.

## Evidence

- **Current source:**
  - `scripts/zones/Temple_of_Uggalepih/npcs/_mf8.lua`
  - `scripts/zones/Temple_of_Uggalepih/npcs/_mf9.lua`
  - `scripts/zones/Temple_of_Uggalepih/npcs/_mf6.lua`
- **Upstream tracking:** https://github.com/LandSandBoat/server/issues/864
- **Independent corroboration:**
  - https://www.bg-wiki.com/ffxi/Windurst_Mission_9-2
  - https://ffxiclopedia.fandom.com/wiki/Uggalepih_Key
  - https://ffxiclopedia.fandom.com/wiki/Prelate_Key
- **Retail observation/test:** Required to map `_mf8` and `_mf9` to the first/southern versus northern retail doors and verify opening direction/timing.
- **Contradictory evidence or uncertainty:** Community pages use map-grid descriptions rather than server entity IDs, and the term “first door” depends on route direction.

## Reproduction

### Fork/server test

1. Place a character on both sides of `_mf8` and `_mf9` and record map position and route order.
2. Approach each locked side with no key and record the requested item message.
3. Trade an Uggalepih Key and Prelate Key separately to each door.
4. Confirm which door leads to the area documented for the Uggalepih Key and which is the northern Prelate-Key door.
5. Record key consumption, opening duration, and opening from the unlocked side.

### Retail comparison

1. Traverse the same Map 2 route on retail.
2. Record coordinates/map grid, door order, required key, consumption, message, and open timing.
3. Match each door to the LandSandBoat entity by position and route topology.

## Dependencies and regression risk

- Windurst Mission 9-2 and other mission/quest paths using Temple Map 2.
- Prelate Key and Uggalepih Key drop/use expectations.
- Door-side coordinate checks and open duration.
- Players opening a door for a party from either side.

The code change is low risk once the entity mapping is confirmed; changing the wrong entity would create a new progression defect.

## Proposed correction

After an in-game route check identifies the retail Uggalepih-Key door, change only that entity's trade and locked-message item from `PRELATE_KEY` to `UGGALEPIH_KEY`. Preserve the other door as Prelate-Key controlled. Retain one-use key consumption and verify retail opening timing.

## Implementation plan

- **Assistant-direct work:** Perform the entity mapping from available zone data/test results, edit the single Lua door script, and add a focused interaction test if the door test harness supports it.
- **Codex work:** Not required for the bounded correction; Codex may add an automated zone-door fixture if broader test infrastructure changes are needed.
- **Files likely affected:** One of `_mf8.lua` or `_mf9.lua`; optionally a focused test file.
- **Tests to add or extend:** Correct key accepted, incorrect key rejected, key consumed, locked-side message, unlocked-side opening, and open duration.
- **Human validation required:** One fork route test and preferably one retail comparison.
- **Rollback or configuration considerations:** None expected.

## Completion criteria

- The correct Map 2 door consumes an Uggalepih Key.
- The distinct Prelate-Key door still consumes a Prelate Key.
- Both reject the incorrect key and show the correct locked message.
- Opening direction and duration match retail observation.
- Mission/quest traversal through the affected route succeeds.

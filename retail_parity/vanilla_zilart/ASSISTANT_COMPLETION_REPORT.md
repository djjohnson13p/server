# Assistant-Stage Completion Report — Vanilla + Rise of the Zilart

## Result

The source-accessible assistant stage is complete.

The assistant audited the pinned LandSandBoat baseline through connected GitHub code search, direct file reads, current upstream issue review, selected official/public retail documentation, and repository-consistency tracing. It recorded eleven confirmed findings and implemented one bounded correction directly in the consolidated audit branch.

Codex must continue the exhaustive local-repository audit, implement the remaining findings, run builds/tests, discover additional discrepancies, and produce the final human-only queue.

## Repository state

- Upstream reference: `LandSandBoat/server`
- Working fork: `djjohnson13p/server`
- Pinned baseline: `242ab0d055dfb80396e7398b0dd7361b750c74e2`
- Consolidated audit branch: `retail-parity/vanilla-zilart-audit`
- Codex work branch: `retail-parity/codex-vanilla-zilart`
- Upstream pull requests: prohibited

## Confirmed findings

| ID | Summary | Baseline status |
|---|---|---|
| `VZ-SYS-001` | Ballista gameplay system absent beyond partial protocol/constants support | `MISSING` |
| `VZ-COMBAT-001` | Item additional-effect framework contains admitted wrong/incomplete behavior | `INACCURATE` |
| `VZ-ZONE-001` | Western Temple of Uggalepih Map 2 door used the wrong key | `INACCURATE` |
| `VZ-JOB-001` | Summoner Elemental Spirit stats and Light Spirit decisions use guessed/wrong behavior | `INACCURATE` |
| `VZ-CORE-001` | Call for Help only affects the current battle target | `INACCURATE` |
| `VZ-CORE-002` | Attack is deliberately blocked while fishing despite retail allowing it | `INACCURATE` |
| `VZ-JOB-002` | Shadowbind bypasses normal immunity/resistance handling and omits level/subjob behavior | `INACCURATE` |
| `VZ-ECON-001` | Fishing new-moon pattern incorrectly dispatches to the full-moon curve | `INACCURATE` |
| `VZ-ECON-002` | Waders are filtered out before their fishing bonus can execute | `INACCURATE` |
| `VZ-BF-001` | Ark Angel zero-delay weapon skills can spam fake/incorrect ready messages | `INACCURATE` |
| `VZ-ECON-003` | Moghancement: Region's 10% modifier is truncated to zero | `INACCURATE` |

## Assistant implementation completed

### `VZ-ZONE-001`

The consolidated audit branch contains commit `ed3bb6e3e59dbe482ebc58d44587576e0b035ab9`, which changes:

- `scripts/zones/Temple_of_Uggalepih/npcs/_mf9.lua`

The western door now requires exactly one Uggalepih Key, consumes it, and identifies the correct key in the locked message. `_mf8` remains the Prelate-Key door.

A separate implementation branch also preserves the same change at commit `620d69d7c0315f70066c3484e110bb5d9baade3d`, but Codex should use the consolidated audit branch as its parent.

## Areas inspected without a promoted finding

The following areas were inspected and either contained substantial implementation or lacked enough evidence for a confirmed discrepancy:

- Gardening lifecycle, yields, pot/day/moon/aura support, packets, SQL, and tests.
- Chocobo digging.
- Expeditionary Forces.
- Outpost supply runs, ownership, homepoint fees, city-to-outpost and outpost-to-city travel.
- HELM harvesting, excavation, logging, and mining logic/data.
- Guild rank-up, guild points, purchases, renouncement, and crafting rank quests.
- Core synthesis, HQ, desynthesis, skill-up, and material-loss paths.
- Rise of the Zilart mission sequence coverage from ZM1 through ZM17.
- Bastok Mission 6-2's current Gilgamesh interaction.
- Nation-changing opening-cutscene handling.
- Selbina/Mhaura arrival TODOs without a demonstrated player-visible failure.

These are not certified retail-equivalent. Codex must continue the audit locally and may create findings when deeper tracing/tests expose discrepancies.

## Stale or rejected leads

- The old nation-change issue is superseded by current immigration logic that tracks seen nations and initializes the opening cutscene.
- The `OnRaise` TODO about Moghancement: Experience is stale because death-loss calculation already applies `EXPERIENCE_RETAINED` and the Mog enhancement supplies that modifier.
- Historical `modules/era` TODOs were not mixed into the current-retail target unless they also affect active base behavior.
- Later-expansion job/merit/job-point TODOs were not assigned to Vanilla/Zilart merely because the job originated earlier.

## Assistant environment limitations

- No local repository clone or terminal build environment was available through the connected GitHub-only workflow.
- Automated C++, Lua, SQL, startup, formatter, and integration tests could not be executed by the assistant.
- The normal GitHub content update action requires complete file replacement. Large-file one-line changes were intentionally deferred rather than reconstructed unsafely from partial source reads.
- Repository-wide indexed search can miss dynamically referenced or unindexed paths; Codex must perform local `git grep`, filesystem inventory, and build/test discovery.
- Live FFXI retail/client captures were unavailable. Findings distinguish framework defects from unresolved numeric retail coefficients.

## Required Codex entry point

Read, in order:

1. `AGENTS.md`
2. `retail_parity/CODEX_MASTER_TASK.md`
3. `retail_parity/vanilla_zilart/AI_HANDOFF.md`
4. `retail_parity/vanilla_zilart/CODEX_BACKLOG.md`
5. `STATUS.md`, `WORKLOG.md`, and all finding files

Codex must verify inherited work, implement the prioritized backlog, complete the rest of the expansion audit, and continue autonomously until `COMPLETE`, `BLOCKED_HUMAN_ONLY`, or `FAILED_INFRASTRUCTURE`.

## Owner involvement

No owner action is requested during the Codex stage. Any remaining owner tasks must be consolidated into `HUMAN_ONLY_QUEUE.md` only after Codex exhausts all AI-capable work.

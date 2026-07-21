# VZ-JOB-002 — Ranger Shadowbind Uses an Incomplete Accuracy and Resistance Model

## Identification

- **ID:** `VZ-JOB-002`
- **Expansion scope:** Vanilla
- **Area:** Ranger / Shadowbind / ranged job ability
- **Baseline status:** `INACCURATE`
- **Severity:** `MODERATE`
- **Confidence:** `HIGH` for the implementation defect; exact retail formula remains unresolved
- **Implementation state:** `PARTIAL_CORRECTION_IMPLEMENTED`
- **Implementation commit:** `b0058b40ef4b71dfd7af2d24dbae7fcf8edfd7f4`

## Expected retail behavior

Shadowbind consumes appropriate ammunition and attempts to apply Bind while respecting target immunity, resistance traits, effect nullification, Ranger main/subjob behavior, relative target level, Shadowbind-specific accuracy, duration, and correct combat messaging.

The exact retail accuracy equation is not established by this finding. A correction must not blindly substitute a spell formula for a physical job ability.

## Baseline behavior

At pinned baseline `242ab0d055dfb80396e7398b0dd7361b750c74e2`:

- The ranged weapon and ammunition pairing was validated.
- Bind success used only a uniform random comparison against `BIND_MEVA` plus an existing-Bind check.
- Shared target-immunity, resistance-trait, and effect-nullification helpers were bypassed.
- The active source explicitly retained `TODO: Acc penalty for /RNG, acc vs. mob level?`.
- Ammunition was consumed through the ranged subsystem's `shouldUseAmmo` path.

## Correction implemented

The Shadowbind use path now requires all of the following before applying Bind:

- the target does not already have Bind;
- `isTargetImmune` reports that the target is not Bind-immune;
- `isTargetResistant` reports that no target trait blocks Bind;
- `isEffectNullified` reports that the effect is not nullified;
- the existing `BIND_MEVA` roll succeeds.

The current ammunition behavior, duration calculation, success/miss messages, and unresolved accuracy roll were preserved rather than replaced with guessed retail coefficients.

Files changed:

- `scripts/globals/job_utils/ranger.lua`

## Validation completed

- The commit diff is confined to `useShadowbind`.
- The three shared status-effect guard signatures match patterns used elsewhere in the pinned LandSandBoat source.
- Ammunition consumption remains after the success/failure branch and is unchanged.
- The resulting source was read back from GitHub and inspected.

## Remaining work

- Establish and implement `/RNG` accuracy behavior.
- Establish relative-level correction and any ranged-accuracy contribution.
- Determine whether `BIND_MEVA` is the correct terminal roll or should be replaced by a dedicated job-ability calculation.
- Confirm duration and partial-resist behavior.
- Confirm Recycle/ammunition-preservation behavior.
- Add automated tests for immunity, resistance traits, nullification, existing Bind, success/failure messaging, ammunition use, main/subjob, and relative level.
- Run Lua validation and a server build in a functioning local/CI environment.

## Completion criteria

- [x] Shadowbind respects target immunity.
- [x] Shadowbind respects status-resistance traits.
- [x] Shadowbind respects effect nullification.
- [x] Existing Bind and ammunition behavior remain intact.
- [ ] Main-job and subjob accuracy behavior is represented and tested.
- [ ] Relative-level behavior is represented when supported by evidence.
- [ ] Automated tests cover all guard, success, failure, and ammunition paths.
- [ ] Unresolved numeric retail coefficients are established or explicitly retained as final live-validation items.

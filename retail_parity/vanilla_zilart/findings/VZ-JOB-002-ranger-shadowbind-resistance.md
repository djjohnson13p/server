# VZ-JOB-002 — Ranger Shadowbind Uses an Incomplete Accuracy and Resistance Model

## Identification

- **ID:** `VZ-JOB-002`
- **Expansion scope:** Vanilla
- **Area:** Ranger / Shadowbind / ranged job ability
- **Baseline status:** `INACCURATE`
- **Severity:** `MODERATE`
- **Confidence:** `HIGH` for the implementation defect; exact retail formula remains unresolved
- **Implementation state:** `PARTIAL_CORRECTION_TEST_BACKED`
- **Implementation commit:** `b0058b40ef4b71dfd7af2d24dbae7fcf8edfd7f4`
- **Validation commit:** `3ef3475a9acb453fdb2ec54d68ced757ae5ded21`

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

## Automated validation completed

`scripts/tests/jobs/rng/abilities/shadowbind.lua` drives the real ability
packet/action path with an equipped Power Bow and Wooden Arrows. Nine focused
cases prove:

- success applies Bind, uses `IS_EFFECT`, and consumes one arrow;
- a controlled `BIND_MEVA` failure does not apply Bind, uses `JA_MISS`, and
  still consumes one arrow;
- existing Bind is not replaced;
- target immunity, resistance traits, and effect nullification each block
  Bind and use the miss message;
- the production Unlimited Shot/`shouldUseAmmo` path preserves the arrow and
  consumes Unlimited Shot;
- a level-39 Ranger cannot use Shadowbind;
- a level-40 Ranger subjob can use Shadowbind.

The test harness gained optional `sjob`/`slevel` spawn parameters so subjob
availability is exercised through the same action path rather than by calling
the Lua utility directly. All nine Lua cases passed, the Catch2 startup suite
passed, and the full MSVC/Ninja Debug build passed.

## Remaining work

- Establish and implement `/RNG` accuracy penalties, if any. Ability
  availability at Ranger subjob level 40 is now test-backed; accuracy is not.
- Establish relative-level correction and any ranged-accuracy contribution.
- Determine whether `BIND_MEVA` is the correct terminal roll or should be replaced by a dedicated job-ability calculation.
- Confirm duration and partial-resist behavior.
- Confirm retail Recycle behavior beyond the existing Unlimited Shot path.
- Add relative-level/accuracy tests only after their formulas are supported by
  repository evidence or reliable documentation.

## Completion criteria

- [x] Shadowbind respects target immunity.
- [x] Shadowbind respects status-resistance traits.
- [x] Shadowbind respects effect nullification.
- [x] Existing Bind and ammunition behavior remain intact.
- [x] Existing Bind, success/failure messages, ordinary ammo use, and
  Unlimited Shot preservation are automated.
- [x] Main-job/subjob level availability is represented and tested.
- [ ] Main-job and subjob accuracy differences are established.
- [ ] Relative-level behavior is represented when supported by evidence.
- [x] Automated tests cover the implemented guard, success, failure, and
  ammunition paths.
- [ ] Unresolved numeric retail coefficients are established or explicitly retained as final live-validation items.

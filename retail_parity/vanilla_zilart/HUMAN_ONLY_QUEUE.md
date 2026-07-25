# Human-Only Queue — Vanilla + Rise of the Zilart

Status: NOT_FINAL_ENGINEERING_CONTINUES

No gameplay, retail-capture, server-deployment, or manual test task is being assigned to the owner at this state.

The local Codex desktop environment, GitHub connectivity, MSVC toolchain,
CMake/Ninja configuration, full Debug build, and focused tests for all six
inherited corrections are validated. The remaining known engineering work is
still AI-capable, so it does not belong in a final human-only queue yet.

## Current AI stage

Codex must still:

- complete the five remaining known implementation findings;
- continue the exhaustive Vanilla/Zilart local-repository audit;
- run the available C++, Lua, SQL, unit, integration, startup, and build checks;
- update the findings and project reports.

## Provisional live-retail/client candidates

These items may become human-only after all remaining AI-capable engineering and automated validation are complete. They are recorded now only to prevent loss of context:

- Confirm Temple of Uggalepih rendered opening timing and complete Windurst
  9-2/San d'Oria 8-2 route traversal. Server-side mapping, side checks,
  messages, consumption, and opening state are automated.
- Confirm new-moon fishing curve coefficients and the exact Waders
  lucky-timing magnitude. Dispatch and reachability are automated.
- Confirm Moghancement: Region fractional rounding if retail differs from the
  test-backed current truncation.
- Confirm Call-for-Help claim color/radar, outside-player attackability,
  experience/drop suppression, and rendered client updates. Server scope,
  party/pet personal-enmity distinctions, boundaries, claim clearing, and
  message cardinality are automated.
- Measure Shadowbind main-job versus `/RNG` accuracy, target-level correction,
  duration/resist behavior, and Recycle rules beyond the automated Unlimited
  Shot path.
- Capture representative Ark Angel instant/zero-delay ready/use messages.
- Collect controlled item additional-effect accuracy, resistance, potency, and duration data by item family.
- Measure Elemental Spirit HP/MP/stat/weapon-damage scaling and Light Spirit decision behavior.
- Capture Ballista packet fields, current schedules/rules, and client-visible match behavior.

## Acceptance rule

No item above is considered an owner action until a future Codex pass:

1. completes the remaining repository audit and implementation;
2. adds and runs the available automated tests;
3. separates genuinely client/retail-only validation from work still possible in code or tooling;
4. changes this file to a final actionable state.

## Rejected intermediate requests

Per project policy, individual findings are not sent to the owner for testing during the audit. No upstream pull request may be opened or suggested.

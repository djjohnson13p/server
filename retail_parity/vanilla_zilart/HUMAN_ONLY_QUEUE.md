# Human-Only Queue — Vanilla + Rise of the Zilart

Status: NOT_FINAL_ENGINEERING_CONTINUES

No gameplay, retail-capture, server-deployment, or manual test task is being assigned to the owner at this state.

The local Codex desktop environment, GitHub connectivity, MSVC toolchain, CMake/Ninja configuration, and full Debug build are validated. The remaining engineering and automated tests are still AI-capable, so they do not belong in a final human-only queue yet.

## Current AI stage

Codex must first:

- add focused automated tests for the six inherited corrections;
- resolve any defects those tests expose;
- complete the five remaining known implementation findings;
- continue the exhaustive Vanilla/Zilart local-repository audit;
- run the available C++, Lua, SQL, unit, integration, startup, and build checks;
- update the findings and project reports.

## Provisional live-retail/client candidates

These items may become human-only after all remaining AI-capable engineering and automated validation are complete. They are recorded now only to prevent loss of context:

- Confirm the Temple of Uggalepih I-10/J-10 door mapping, side checks, message, consumption, and opening timing in the client.
- Confirm new-moon fishing curve coefficients and the exact Waders lucky-timing bonus.
- Confirm Moghancement: Region rounding for small influence awards.
- Confirm Call for Help multi-target claim color, outside-player access, experience/drop suppression, party/pet edge cases, and messages.
- Measure Shadowbind main-job versus `/RNG` accuracy, target-level correction, duration/resist behavior, and ammunition-preservation rules.
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

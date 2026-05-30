# Trader Armageddon Swarm

Stationeers IC10 script pack for the "Ultimate Trader Armageddon Swarm v9.0"
concept from the shared Grok answer. It packages the final answer as a normal
repo project with separate IC10 files, hardware notes, and the important setup
warnings.

The pack is intentionally overbuilt: four satellite dishes scan together, a
priority chip ranks contact types, fuel filter chips inspect trader data, and
support chips handle auto-calling, pad rotation, sound alerts, Morse telemetry,
and multi-dish stability.

## Hardware

| Pin | Device |
| --- | --- |
| `d0` | Primary Satellite Dish. |
| `d1` | Resume button. |
| `d2` | Reset button. |
| `d3` | Manual contact button. |
| `d4` | Priority dial, `0` to `12`. |
| `d5` | Shared status display or LED. |
| `d6` | Satellite Dish 2. |
| `d7` | Satellite Dish 3. |
| `d8` | Satellite Dish 4. |
| `d9` | Landing pad selector. |
| `d10` | Speaker or klaxon. |

Use medium or large satellite dishes. Wire all IC housings and devices to the
same data network.

## Scripts

| File | Purpose |
| --- | --- |
| `01_RadarSwarmScanner.ic10` | Scans with four dishes and locks the best contact. |
| `02_GodTierPriority.ic10` | Maps known trader type hashes to priority ranks. |
| `03_NuclearFuelFilter.ic10` | Stack-based FuelCan filter. Replace placeholders. |
| `04_EliteAutoCaller.ic10` | Calls strong filtered contacts with cooldown. |
| `05_SwarmOverlord.ic10` | Syncs `BestContactFilter` across all dishes. |
| `06_AutoPadSwarmSelector.ic10` | Rotates up to four landing pad slots. |
| `07_NuclearVoiceAlerts.ic10` | Plays state-based sound alerts. |
| `08_MorseCodeTelemetry.ic10` | Beeps `FUEL`, `DIV`, `FILT`, and count telemetry. |
| `09_AutoTradeExecutor.ic10` | Confirms fuel trades and counts successful calls. |
| `10_SignalFilterOverlord.ic10` | Adds average signal and angle stability filtering. |

## Install

1. Put each file on a separate IC10 chip.
2. Wire devices to the pins above.
3. Replace `FUEL_CAN1`, `FUEL_CAN2`, and `FUEL_CAN3` in scripts 3 and 9 with
   real prefab hashes from your save or reference source.
4. Set the priority dial:
   - `0` accepts any known priority.
   - `12` accepts only the Gas/Fuel trader hash from the Grok answer.
5. Turn on the IC housings. The scanner starts immediately.

## Status Values

| Value | Meaning |
| --- | --- |
| `1` | Scanner or radar lock active. |
| `3` | Deep stack confirmation hook. |
| `4` | Trader auto-called. |
| `5` | Swarm sync or pause state. |
| `6` | Pad rotation active. |
| `7` | Signal passed stability filter. |
| `9` | Fuel filter matched. |
| `10` | Auto-trade confirmation matched. |

`db Setting` is used as a session call counter by the auto-call and trade
scripts.

## Notes

- The fuel can hashes are placeholders from the Grok answer and must be
  replaced before relying on item-based filtering.
- Script lines are kept under 90 characters and each script is under 128 lines.
- The project is packaged from the last shared answer, then lightly reformatted
  into normal IC10 labels and branches so it can live cleanly in this repo.

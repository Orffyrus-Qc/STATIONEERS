# Proximity Transformer Control

Stationeers IC10 script for controlling a transformer with a proximity sensor
and an AUTO/MANUAL mode switch.

## Purpose

`PROXIMITY_TRANSFO.ic10` turns a named transformer on or off depending on the
selected mode:

- MANUAL mode keeps the transformer forced on.
- AUTO mode lets a named proximity sensor control the transformer.

This is useful when you want a transformer to stay off until a player or object
is detected near a powered area, while still keeping a manual override available.

## Required Labels

All labels are case-sensitive. The names inside `HASH("name")` must match the
in-game device labels exactly.

| Label | Device |
| --- | --- |
| `modeSwitch` | Logic Switch or Lever used for AUTO/MANUAL mode. |
| `PROXIMITY_SENSOR` | Proximity Sensor used in AUTO mode. |
| `TRANSFO_01` | Transformer to control. Large, small, and reversed small transformer variants are supported. |

## Modes

| Mode switch state | Mode | Transformer behavior |
| --- | --- | --- |
| Off | MANUAL | Transformer is forced on. |
| On | AUTO | Transformer follows the proximity sensor activation state. |

If the mode switch or lever is missing, the script defaults to MANUAL mode so
the transformer stays on. In AUTO mode, if the proximity sensor does not detect
anything, the transformer is turned off.

## Script Notes

- The script uses name/hash lookup, so no IC pins are required.
- It checks for both logic switch styles: `StructureLogicSwitch2` and
  `StructureLogicSwitch`.
- It writes the same on/off state to large, small, and reversed small
  transformer prefabs named `TRANSFO_01`.
- The loop sleeps for 1 second between checks to reduce IC load.

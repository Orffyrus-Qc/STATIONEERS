# Proximity Switch Control

Stationeers IC10 script for controlling a transformer with a proximity sensor,
an AUTO/MANUAL mode switch, and a switch status light.

## Purpose

`PROXIMITY_SWITCH.ic10` turns a named transformer on or off depending on the
selected mode:

- MANUAL mode keeps the transformer forced on and turns `activeLIGHT` off.
- AUTO mode lets a named proximity sensor control the transformer and turns
  `activeLIGHT` on.

This is useful when you want a transformer to stay off until a player or object
is detected near a powered area, while still keeping a manual override available.
The status light shows whether the switch is in AUTO mode.

## Required Labels

All labels are case-sensitive. The names inside `HASH("name")` must match the
in-game device labels exactly.

| Label | Device |
| --- | --- |
| `modeSwitch` | Logic Switch or Lever used for AUTO/MANUAL mode. |
| `PROXIMITY_SENSOR` | Proximity Sensor used in AUTO mode. |
| `TRANSFO_01` | Transformer to control. |
| `activeLIGHT` | Any supported light type used as the AUTO status light. |

## Modes

| Mode switch state | Mode | Transformer behavior | Light behavior |
| --- | --- | --- | --- |
| Off | MANUAL | Transformer is forced on. | `activeLIGHT` is off. |
| On | AUTO | Transformer follows proximity detection. | `activeLIGHT` is on. |

If the mode switch or lever is missing, the script defaults to MANUAL mode so
the transformer stays on and `activeLIGHT` stays off. In AUTO mode, if the
proximity sensor does not detect anything, the transformer is turned off.

## Supported Transformers

The script writes the same on/off state to these transformer prefabs when they
are named `TRANSFO_01`:

- `StructureTransformer`
- `StructureTransformerSmall`
- `StructureTransformerSmallReversed`

## Supported Lights

The script writes the switch state to these light prefabs when they are named
`activeLIGHT`:

- `StructureLight`
- `StructureWallLight`
- `StructureLightBattery`
- `StructureFlashingLight`
- `StructureLightFlashing`
- `StructureLightLong`
- `StructureLightLongAngled`
- `StructureLightLongWide`
- `StructureLightRound`
- `StructureLightRoundAngled`
- `StructureLightRoundSmall`
- `StructureGrowLight`
- `StructureDiode`

## Script Notes

- The script uses name/hash lookup, so no IC pins are required.
- It checks for both logic switch styles: `StructureLogicSwitch2` and
  `StructureLogicSwitch`.
- The status light follows the mode switch directly, not the transformer state.
- The loop sleeps for 1 second between checks to reduce IC load.

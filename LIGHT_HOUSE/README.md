# Light House Rotating Beam

`LIGHT_HOUSE.ic10` simulates a rotating lighthouse beam using 20 named lights
placed around 360 degrees. Each light is 18 degrees apart, from `LIGHT_01`
through `LIGHT_20`.

## Required Labels

All labels are case-sensitive. The name inside `HASH("name")` must match the
in-game device label exactly.

| Label | Device |
| --- | --- |
| `LIGHTHOUSE_SWITCH` | Logic Switch or Lever used to turn the system on and off. |
| `LIGHT_01` to `LIGHT_20` | The 20 lights around the lighthouse ring. |

## Behavior

When `LIGHTHOUSE_SWITCH` is on, the script reads its `Setting` and `Open` values
and advances one light every `0.6` seconds. With 20 lights, one full rotation
takes about 12 seconds. The beam keeps three adjacent lights on at a time so the
sweep feels closer to a real rotating lighthouse lens instead of a single hard
blinking dot.

When the switch is off, the script turns all named lights off and checks the
switch again once per second.

## Supported Light Prefabs

The script writes `On`, not `Power`. For Stationeers lights, `Power` is a
read-only output that reports whether the light is on and receiving power.

The script uses exact prefab hashes from the current Stationeers wiki for Kit
(Lights), LED, Diode Slide, and Grow Light variants. Flashing lights still use
prefab hash names:

| Prefab hash | Light type |
| --- | --- |
| `-1860064656` | Wall Light / Regular |
| `797794350` | Wall Light Long |
| `555215790` | Wall Light Wide Long / Long Wide |
| `1847265835` | Wall Light Long Angled |
| `-1306415132` | Wall Light Battery |
| `1514476632` | Light Round |
| `1592905386` | Light Round Angled |
| `1436121888` | Light Round Small |
| `1944485013` | LED |
| `576516101` | Diode Slide |
| `-1758710260` | Grow Light |
| `StructureFlashingLight` | Flashing Light |
| `StructureLightFlashing` | Light Flashing |

## Options

Change these values directly in `LIGHT_HOUSE.ic10`:

| Option | Default | Behavior |
| --- | --- | --- |
| `StepDelay` | `0.6` seconds | Time between each 18 degree step. |
| `BeamWidth` | `3` lights | Number of adjacent lights kept on. |
| `LightCount` | `20` | Number of named lights in the ring. |

## Setup Notes

Place the 20 lights clockwise or counter-clockwise and label them in order:
`LIGHT_01`, `LIGHT_02`, `LIGHT_03`, and so on through `LIGHT_20`. Put the IC
Housing, the switch or lever, and all lights on the same data network.

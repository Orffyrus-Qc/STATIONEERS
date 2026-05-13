# Light House Rotating Beam

`LIGHT_HOUSE.ic10` simulates a rotating lighthouse beam using 20 named
`StructureLightLongWide` lights placed around 360 degrees. Each light is 18
degrees apart, from `LIGHT_01` through `LIGHT_20`.

## Required Labels

All labels are case-sensitive. The name inside `HASH("name")` must match the
in-game device label exactly.

| Label | Device |
| --- | --- |
| IC pin `d0` | Logic Switch or Lever used to turn the system on and off. |
| `LIGHTHOUSE_SWITCH` | Optional fallback label for a Logic Switch or Lever if `d0` is not set. |
| `LIGHT_01` to `LIGHT_20` | The 20 lights around the lighthouse ring. |

## Behavior

When the switch is on, the script reads its `Setting` value and advances one
light every `0.6` seconds. With 20 lights, one full rotation takes about 12
seconds. The beam keeps three adjacent lights on at a time so the sweep feels
closer to a real rotating lighthouse lens instead of a single hard blinking dot.

When the switch is off, the script turns all named lights off and checks the
switch again once per second.

## Light Type

The script writes `On`, not `Power`. For Stationeers lights, `Power` is a
read-only output that reports whether the light is on and receiving power.

The active light type is set at the top of `LIGHT_HOUSE.ic10`:

```ic10
define lightType HASH("StructureLightLongWide")
```

Change only that line if you want to use another light prefab later.

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

For the most reliable switch behavior, assign the switch or lever to IC pin
`d0`. If `d0` is not assigned, the script falls back to searching for a switch
or lever named `LIGHTHOUSE_SWITCH`.

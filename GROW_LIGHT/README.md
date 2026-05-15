# Grow Light Cycle

Stationeers IC10 script for cycling grow lights and hydroponics stations on a
simple repeating timer.

## Purpose

`GROW_LIGHT.ic10` controls all `StructureGrowLight` and
`StructureHydroponicsStation` devices on the data network. When the IC boots, it
turns both device types on before entering the timed cycle. The cycle keeps them
on for 14 minutes, turns them off for 6 minutes, then repeats forever.

## Controlled Devices

The script uses prefab hash types, so devices do not need a matching in-game
label.

| Prefab type | Device |
| --- | --- |
| `StructureGrowLight` | All grow lights on the data network. |
| `StructureHydroponicsStation` | All hydroponics stations on the data network. |

## Behavior

The script:

1. Turns `StructureGrowLight` and `StructureHydroponicsStation` on when the IC starts.
2. Waits 840 seconds, or 14 minutes.
3. Turns `StructureGrowLight` and `StructureHydroponicsStation` off.
4. Waits 360 seconds, or 6 minutes.
5. Turns both device types on again and repeats the cycle.

## Options

Change these values directly in `GROW_LIGHT.ic10`:

| Option | Default | Behavior |
| --- | --- | --- |
| device types | `StructureGrowLight`, `StructureHydroponicsStation` | Prefab types controlled by the script. |
| on duration | `840` seconds | Time devices stay on. |
| off duration | `360` seconds | Time devices stay off. |

## Files

- `GROW_LIGHT.ic10` - prefab hash type version for grow lights and hydroponics
  stations.

# Grow Light Cycle

Stationeers IC10 script for cycling grow lights and hydroponics stations on a
simple repeating timer.

## Purpose

`GROW_LIGHT.ic10` controls all `StructureGrowLight` devices named `Grow Light`
and all `StructureHydroponicsStation` devices named `Hydroponic Station` on the
data network. When the IC boots, it turns both device groups on before entering
the timed cycle. The cycle keeps them on for 14 minutes, turns them off for 6
minutes, then repeats forever.

## Required Labels

All labels are case-sensitive. The name inside `HASH("name")` must match the
in-game device label exactly.

| Label | Device |
| --- | --- |
| `Grow Light` | One or more grow lights to cycle together. |
| `Hydroponic Station` | One or more hydroponics stations to cycle with the lights. |

## Behavior

The script:

1. Turns `Grow Light` grow lights and `Hydroponic Station` hydroponics stations
   on when the IC starts.
2. Waits 840 seconds, or 14 minutes.
3. Turns both device groups off.
4. Waits 360 seconds, or 6 minutes.
5. Turns both device groups on again and repeats the cycle.

## Options

Change these values directly in `GROW_LIGHT.ic10`:

| Option | Default | Behavior |
| --- | --- | --- |
| `Grow Light` | label | In-game grow light label controlled by the script. |
| `Hydroponic Station` | label | In-game hydroponics station label controlled by the script. |
| on duration | `840` seconds | Time lights stay on. |
| off duration | `360` seconds | Time lights stay off. |

## Files

- `GROW_LIGHT.ic10` - name/hash version for grow light and hydroponics station
  label groups.
- `FR-README.md` - French version of this README.

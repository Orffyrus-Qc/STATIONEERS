# Grow Light Cycle

Stationeers IC10 script for cycling grow lights on a simple repeating timer.

## Purpose

`GROW_LIGHT.ic10` controls grow lights named `GrowLight_1` on the data network.
When the IC boots, it turns the lights on before entering the timed cycle. The
cycle keeps the lights on for 14 minutes, turns them off for 6 minutes, then
repeats forever.

## Required Label

All labels are case-sensitive. The name inside `HASH("name")` must match the
in-game device label exactly.

| Label | Device |
| --- | --- |
| `GrowLight_1` | One or more grow lights to cycle together. |

## Behavior

The script:

1. Turns `GrowLight_1` on when the IC starts.
2. Waits 840 seconds, or 14 minutes.
3. Turns `GrowLight_1` off.
4. Waits 360 seconds, or 6 minutes.
5. Turns `GrowLight_1` on again and repeats the cycle.

## Options

Change these values directly in `GROW_LIGHT.ic10`:

| Option | Default | Behavior |
| --- | --- | --- |
| `GrowLight_1` | label | In-game grow light label controlled by the script. |
| on duration | `840` seconds | Time lights stay on. |
| off duration | `360` seconds | Time lights stay off. |

## Files

- `GROW_LIGHT.ic10` - name/hash version for one grow light label group.

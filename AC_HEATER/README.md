# AC Heater Follower

Stationeers IC10 script for using an Air Conditioner mode as a simple pipe
heater enable signal.

## Purpose

`AC_HEATER.ic10` watches the integer `Mode` of the `StructureAirConditioner`
that holds the IC10 chip, then mirrors that state to the pipe heater selected
on IC pin `d0`. When the Air Conditioner named `AC_HEATER` has Mode `1`, the
pipe heater turns on. When it returns to Mode `0`, the heater turns off.

This is useful when another controller already changes the Air Conditioner
between Idle and Active, and you want pipe heaters to follow that same control
state without using IC pins.

## Required Labels

All labels are case-sensitive. The names inside `HASH("name")` must match the
in-game device labels exactly.

| Label | Device |
| --- | --- |
| `AC_HEATER` | Air Conditioner that holds the IC10 chip. |
| `HEATER` | Pipe heater selected on IC pin `d0`. |

## Installation

1. Put the IC10 chip running `AC_HEATER.ic10` in the Air Conditioner named
   `AC_HEATER`.
2. Use the IC pin selector to set `d0` to the target `StructurePipeHeater`
   named `HEATER`.
3. Keep the Air Conditioner and pipe heater powered.

The script reads the Air Conditioner through `db` and writes the heater through
the guarded `d0` alias:

```ic10
l acMode db Mode
s HEATER On heaterOn
```

## Mode Behavior

| Air Conditioner `Mode` | Meaning | Heater state |
| --- | --- | --- |
| `0` | Idle | Off |
| `1` | Active | On |

The script rounds and clamps Air Conditioner `Mode` to an integer `0` or `1`
before writing that value to the heaters. It writes only when the requested
state changes. On boot, it forces one write so the heaters match the current
Air Conditioner mode.

## Notes

- The script controls the `StructurePipeHeater` selected on IC pin `d0`.
- If `d0` is unset or cannot write `On`, the heater write is skipped.
- Use one Air Conditioner named `AC_HEATER` for predictable behavior.
- The IC loop uses `yield`, so it checks every tick without a long sleep.

## Files

- `AC_HEATER.ic10` - pin script for AC mode to pipe heater control.

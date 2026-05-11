# AC Heater Follower

Stationeers IC10 script for using an Air Conditioner mode as a simple pipe
heater enable signal.

## Purpose

`AC_HEATER.ic10` watches the integer `Mode` of the `StructureAirConditioner`
that holds the IC10 chip, then mirrors that state to the pipe heater selected
on IC pin `d0`. Before writing, it checks that the heater's `NameHash` equals
`HASH("HEATER")`. When the Air Conditioner named `AC_HEATER` has Mode `1`, the
heater turns on. When it returns to Mode `0`, the heater turns off.

This is useful when another controller already changes the Air Conditioner
between Idle and Active, and you want pipe heaters to follow that same control
state without using IC pins.

## Required Labels

All labels are case-sensitive. The names inside `HASH("name")` must match the
in-game device labels exactly.

| Label | Device |
| --- | --- |
| `AC_HEATER` | Air Conditioner that holds the IC10 chip. |
| `HEATER` | Pipe heater selected on IC pin `d0`, validated by name hash. |

## Installation

1. Put the IC10 chip running `AC_HEATER.ic10` in the Air Conditioner named
   `AC_HEATER`.
2. Name the target `StructurePipeHeater` exactly `HEATER`.
3. Use the IC pin selector to set `d0` to that pipe heater.
4. Keep the Air Conditioner and pipe heater powered.

The script reads the Air Conditioner through `db`, validates the heater name
hash through `d0`, and writes the heater through that pin:

```ic10
l acMode db Mode
l heaterName heater NameHash
bne heaterName HEATER_NAME wait
s heater On heaterOn
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

- `HEATER_NAME` is defined as `HASH("HEATER")` in the script.
- The script skips the write if `d0` is not named `HEATER`.
- Use one Air Conditioner named `AC_HEATER` for predictable behavior.
- The IC loop uses `yield`, so it checks every tick without a long sleep.

## Files

- `AC_HEATER.ic10` - pin script with HEATER name-hash validation.

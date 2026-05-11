# AC Heater Follower

Stationeers IC10 script for using an Air Conditioner mode as a simple pipe
heater enable signal.

## Purpose

`AC_HEATER.ic10` watches the integer `Mode` of the `StructureAirConditioner`
that holds the IC10 chip, then mirrors that state to every
`StructurePipeHeater` on the same data network. When the Air Conditioner named
`AC_HEATER` has Mode `1`, the pipe heaters turn on. When it returns to Mode
`0`, the heaters turn off.

This is useful when another controller already changes the Air Conditioner
between Idle and Active, and you want pipe heaters to follow that same control
state without using IC pins.

## Required Labels

All labels are case-sensitive. The names inside `HASH("name")` must match the
in-game device labels exactly.

| Label | Device |
| --- | --- |
| `AC_HEATER` | Air Conditioner that holds the IC10 chip. |
| `HEATER` | Script constant for the `StructurePipeHeater` prefab hash. |

## Installation

1. Put the IC10 chip running `AC_HEATER.ic10` in the Air Conditioner named
   `AC_HEATER`.
2. Connect the Air Conditioner and all target pipe heaters to the same data
   network.
3. Put only the pipe heaters you want controlled on that same data network.
4. Keep the Air Conditioner and pipe heaters powered.

No IC housing pins are required. The script reads the host device with `db`
and writes to all pipe heaters by the `HEATER` prefab hash:

```ic10
l acMode db Mode
sb HEATER On heaterOn
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

- The script controls all `StructurePipeHeater` devices on the data network.
- Use a separate data network if other pipe heaters should not be controlled.
- Use one Air Conditioner named `AC_HEATER` for predictable behavior.
- The IC loop uses `yield`, so it checks every tick without a long sleep.

## Files

- `AC_HEATER.ic10` - name/hash script for AC mode to pipe heater control.

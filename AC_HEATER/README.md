# AC Heater Follower

Stationeers IC10 script for using an Air Conditioner mode as a simple pipe
heater enable signal.

## Purpose

`AC_HEATER.ic10` watches the `Mode` of a named `StructureAirConditioner` and
mirrors that state to every named `StructurePipeHeater` on the data network.
When the Air Conditioner named `AC_HEATER` is Active, all pipe heaters named
`HEATER` turn on. When the Air Conditioner returns to Idle, the heaters turn
off.

This is useful when another controller already changes the Air Conditioner
between Idle and Active, and you want pipe heaters to follow that same control
state without using IC pins.

## Required Labels

All labels are case-sensitive. The names inside `HASH("name")` must match the
in-game device labels exactly.

| Label | Device |
| --- | --- |
| `AC_HEATER` | Air Conditioner that holds the IC10 chip. |
| `HEATER` | One or more pipe heaters controlled together. |

## Installation

1. Put the IC10 chip running `AC_HEATER.ic10` in the Air Conditioner named
   `AC_HEATER`.
2. Connect the Air Conditioner and all target pipe heaters to the same data
   network.
3. Name every target `StructurePipeHeater` as `HEATER`.
4. Keep the Air Conditioner and pipe heaters powered.

No IC housing pins are required. The script uses name/hash batch logic:

```ic10
lbn acMode AC_TYPE AC_NAME Mode Maximum
sbn HEATER_TYPE HEATER_NAME On heaterOn
```

## Mode Behavior

| Air Conditioner `Mode` | Meaning | Heater state |
| --- | --- | --- |
| `0` | Idle | Off |
| `1` | Active | On |

The script writes to the heaters only when the requested state changes. On boot,
it forces one write so the heaters match the current Air Conditioner mode.

## Notes

- The script controls all `StructurePipeHeater` devices named `HEATER`.
- Use one Air Conditioner named `AC_HEATER` for predictable behavior.
- If multiple `AC_HEATER` devices exist, `Maximum` means any Active unit wins.
- The IC loop uses `yield`, so it checks every tick without a long sleep.
- Change `AC_NAME` or `HEATER_NAME` in the script if you rename devices.

## Files

- `AC_HEATER.ic10` - name/hash script for AC mode to pipe heater control.

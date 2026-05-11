# AC Heater Follower

Stationeers IC10 script for using the host Air Conditioner mode as a simple
pipe heater enable signal.

## Purpose

`AC_HEATER.ic10` watches the `Mode` of the `StructureAirConditioner` that holds
the IC10 chip and mirrors that state to every named `StructurePipeHeater` on the
data network. When the host Air Conditioner is Active, all pipe heaters named
`HEATER` turn on. When the Air Conditioner returns to Idle, the heaters turn
off.

This is useful when another controller already changes the Air Conditioner
between Idle and Active, and you want pipe heaters to follow that same control
state without using IC pins. The Air Conditioner no longer needs a specific
label.

## Required Labels

All labels are case-sensitive. The names inside `HASH("name")` must match the
in-game device labels exactly.

| Label | Device |
| --- | --- |
| `HEATER` | One or more pipe heaters controlled together. |

## Installation

1. Put the IC10 chip running `AC_HEATER.ic10` in the Air Conditioner to watch.
2. Connect that Air Conditioner and all target pipe heaters to the same data
   network.
3. Name every target `StructurePipeHeater` as `HEATER`.
4. Keep the Air Conditioner and pipe heaters powered.

No IC housing pins are required. The script reads the host device with `db` and
uses name/hash batch logic for the heaters:

```ic10
l acMode db Mode
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
- The Air Conditioner can have any label because its Mode is read through `db`.
- The IC loop uses `yield`, so it checks every tick without a long sleep.
- Change `HEATER_NAME` in the script if you rename the pipe heaters.

## Files

- `AC_HEATER.ic10` - host-AC script with name/hash pipe heater control.

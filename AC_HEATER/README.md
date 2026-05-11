# AC Heater Follower

Stationeers IC10 script for using the host Air Conditioner mode as a simple
pipe heater enable signal with a Celsius `TemperatureOutput2` safety lockout.

## Purpose

`AC_HEATER.ic10` watches the `Mode` and `TemperatureOutput2` of the
`StructureAirConditioner` that holds the IC10 chip. It converts
`TemperatureOutput2` from Kelvin to Celsius, then mirrors Active mode to every
named `StructurePipeHeater` on the data network unless the output temperature
is too high.

When the host Air Conditioner is Active, all pipe heaters named `HEATER` turn
on. If `TemperatureOutput2` rises above `200 C`, the heaters are forced off and
stay off until `TemperatureOutput2` falls to `180 C` or lower. When the Air
Conditioner returns to Idle, the heaters turn off.

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
l outputTempC db TemperatureOutput2
sub outputTempC outputTempC KELVIN_OFFSET
sbn HEATER_TYPE HEATER_NAME On heaterOn
```

## Mode Behavior

| Air Conditioner `Mode` | TemperatureOutput2 in Celsius | Heater state |
| --- | --- | --- |
| `0` Idle | Any value | Off |
| `1` Active | `180 C` or lower after lockout | On |
| `1` Active | Above `200 C` | Off and locked out |
| `1` Active | Between `180 C` and `200 C` | Keeps previous lock state |

The script writes to the heaters only when the requested state changes. On boot,
it forces one write so the heaters match the current Air Conditioner mode and
Celsius temperature lockout state.

## Options

Change these values directly in `AC_HEATER.ic10`:

| Option | Default | Behavior |
| --- | --- | --- |
| `TEMP_STOP_C` | `200` | Lock heaters off above this Celsius value. |
| `TEMP_RESUME_C` | `180` | Allow heaters again at or below this Celsius value. |
| `KELVIN_OFFSET` | `273.15` | Converts `TemperatureOutput2` to Celsius. |

## Notes

- The script controls all `StructurePipeHeater` devices named `HEATER`.
- The Air Conditioner can have any label because values are read through `db`.
- The 200/180 limits are Celsius values after conversion from Kelvin.
- The IC loop uses `yield`, so it checks every tick without a long sleep.
- Change `HEATER_NAME` in the script if you rename the pipe heaters.

## Files

- `AC_HEATER.ic10` - host-AC script with name/hash pipe heater control.

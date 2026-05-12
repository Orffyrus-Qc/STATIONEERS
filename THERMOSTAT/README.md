# Multi-Room Temperature Control

This folder contains a split IC10 temperature-control system for multiple
rooms. Each room gets its own thermostat IC made from modular console parts.
Separate loop-controller ICs maintain the shared hot and cold pipe loops.

## Files

- `THERMOSTAT.ic10` - per-room thermostat and radiator valve controller.
- `HEATING_LOOP.ic10` - hot closed-loop pipe controller.
- `COOLING_LOOP.ic10` - cold closed-loop pipe controller.

Each `.ic10` file is kept under 128 lines and 90 characters per line.

## Room Thermostat IC

The room thermostat reads a named room gas sensor, displays the current or
target temperature, and opens one radiator valve when the room needs heating or
cooling.

Required labels:

| Label | Device type | Purpose |
| --- | --- | --- |
| `SENSOR` | `StructureGasSensor` | Room temperature input. |
| `DISPLAY` | `ModularDeviceLEDdisplay2` | Temperature display. |
| `+` | `ModularDeviceUtilityButton2x2` | Increase target by 1 C. |
| `-` | `ModularDeviceUtilityButton2x2` | Decrease target by 1 C. |
| `HOT_DIGITAL_VALVE` | `StructureDigitalValve` | Hot radiator valve. |
| `COLD_DIGITAL_VALVE` | `StructureDigitalValve` | Cold radiator valve. |

Default values:

```ic10
define minTemp -59
define maxTemp 59
move target 22
move hyst 1.0
```

Heating demand opens `HOT_DIGITAL_VALVE`. Cooling demand opens
`COLD_DIGITAL_VALVE`. Both valves stay closed inside the deadband.

## Heating Loop IC

The heating loop IC keeps the hot closed pipe loop circulating with a turbo pump
named `HEATING_LOOP_PUMP`. It controls the devices named `HEATING` on that loop
from the named pipe analyzer.

Required labels:

| Label | Device type | Purpose |
| --- | --- | --- |
| `HEATING_ANALYZER` | `StructurePipeAnalysizer` | Hot loop temperature input. |
| `HEATING_LOOP_PUMP` | `StructureTurboVolumePump` | Hot loop circulation. |
| `HEATING` | Heating output devices | Hot loop heat source group. |

Supported `HEATING` outputs are `StructurePipeHeater`, `StructureVolumePump`,
`StructureTurboVolumePump`, `StructureActiveVent`, `StructurePoweredVentLarge`,
and `StructureAirConditioner`.

The hot loop turns `HEATING` off above 1000 C. It turns `HEATING` back on below
900 C.

## Cooling Loop IC

The cooling loop IC keeps the cold pipe loop circulating with a turbo pump named
`COOLING_LOOP_PUMP`. It controls the devices named `COOLING` on that loop from
the named pipe analyzer.

Required labels:

| Label | Device type | Purpose |
| --- | --- | --- |
| `COOLING_ANALYZER` | `StructurePipeAnalysizer` | Cold loop temperature input. |
| `COOLING_LOOP_PUMP` | `StructureTurboVolumePump` | Cold loop circulation. |
| `COOLING` | Cooling output devices | Cold loop cooling group. |

Supported `COOLING` outputs are `StructureVolumePump`, `StructureTurboVolumePump`,
`StructureActiveVent`, `StructurePoweredVentLarge`, and `StructureAirConditioner`.

The cold loop turns `COOLING` off below -100 C. It turns `COOLING` back on above
-90 C.

## Control Notes

Air conditioners are powered on once at boot and controlled with `Mode 0` or
`Mode 1`. Other supported output devices use `On 0` or `On 1`.

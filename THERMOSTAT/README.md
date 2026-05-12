# Thermostat Controller

The `THERMOSTAT.ic10` script is a room temperature controller for Stationeers. It reads the average temperature from gas sensors, shows the current or target temperature on an LED display, adjusts the target with named buttons, and controls named heating/cooling output groups with a hysteresis deadband.

## Files

- `THERMOSTAT.ic10` - hash-based IC10 thermostat script.

## Required Devices

The script uses prefab hashes, so the devices only need to be on the IC network. It does not require fixed `d0`, `d1`, or other pin assignments for the main devices. Heating and cooling outputs are separated by device name.

Device hashes used by the script:

- `StructureGasSensor` - temperature input. Multiple sensors are averaged.
- `ModularDeviceLEDdisplay2` - shows current or target temperature.
- `ModularDeviceUtilityButton2x2` - target temperature up/down buttons.
- `StructurePipeHeater` - heating output.
- `StructureTurboVolumePump` - heating or cooling output.
- `StructureActiveVent` - heating or cooling output.
- `StructurePoweredVentLarge` - heating or cooling output.
- `StructureAirConditioner` - heating or cooling output.

## Required Output Names

Rename heating output devices exactly:

```text
HEATING
```

Supported heating outputs are `StructurePipeHeater`, `StructureTurboVolumePump`, `StructureActiveVent`, `StructurePoweredVentLarge`, and `StructureAirConditioner`.

Rename cooling output devices exactly:

```text
COOLING
```

Supported cooling outputs are `StructureTurboVolumePump`, `StructureActiveVent`, `StructurePoweredVentLarge`, and `StructureAirConditioner`.

## Required Button Names

Both buttons use the same prefab hash, so the script identifies them by name. Rename the two utility buttons in-game exactly:

```text
+
-
```

`+` increases the target by 1 C. `-` decreases it by 1 C.

## Temperature Behavior

Default values near the top of the script:

```ic10
define minTemp  10
define maxTemp  35
```

The target temperature is clamped between `minTemp` and `maxTemp`. The default target at boot is 22 C.

The script uses this hysteresis value:

```ic10
move hyst 1.0
```

With the defaults, heating starts below target minus 1 C, cooling starts above target plus 1 C, and both outputs stay idle inside the deadband.

## Enable/Disable Options

Heating and cooling can be disabled independently near the top of `THERMOSTAT.ic10`:

```ic10
define enableHeating 1
define enableCooling 1
```

Set either value to `0` to keep that side off while the rest of the thermostat continues running.

## Air Conditioner Notes

Named air conditioners are powered on and switched to active mode only when their side is running:

```ic10
sbn airConditioner coolName Mode 0  # idle
sbn airConditioner coolName Mode 1  # active
```

The script sets cooling air conditioners to `minTemp + 273.15` and heating air conditioners to `maxTemp + 273.15`, because the AC setting is stored in kelvin.

## Display Behavior

Normally the LED display shows the rounded current temperature in Celsius. Pressing either target button shows the rounded target temperature and refreshes the display timer.

Button presses use a short `pressLock` timer instead of a strict previous-state edge check. If the IC samples the button release, the lock resets immediately. If it misses the release, the lock expires on its own, which makes repeated taps more reliable.

## Customization

Change these values in `THERMOSTAT.ic10` to tune the behavior:

- `minTemp` - minimum target temperature and AC setpoint floor.
- `maxTemp` - maximum target temperature.
- `showTime` - target-display timer value refreshed by button presses.
- `pressLock` - short lockout after each accepted button press.
- `enableHeating` - set to `0` to disable heating outputs.
- `enableCooling` - set to `0` to disable cooling outputs.
- `move target 22` - boot target temperature.
- `move hyst 1.0` - heating/cooling deadband size.

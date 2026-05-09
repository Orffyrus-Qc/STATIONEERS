# Thermostat Controller

The `THERMOSTAT.ic10` script is a room temperature controller for Stationeers. It reads the average temperature from gas sensors, shows the current or target temperature on an LED display, adjusts the target with named buttons, and controls pipe heaters plus air conditioners with a hysteresis deadband.

## Files

- `THERMOSTAT.ic10` - hash-based IC10 thermostat script.

## Required Devices

The script uses prefab hashes, so the devices only need to be on the IC network. It does not require fixed `d0`, `d1`, or other pin assignments for the main devices.

Device hashes used by the script:

- `StructureGasSensor` - temperature input. Multiple sensors are averaged.
- `ModularDeviceLEDdisplay2` - shows current or target temperature.
- `ModularDeviceUtilityButton2x2` - target temperature up/down buttons.
- `StructurePipeHeater` - heating output.
- `StructureAirConditioner` - cooling output.

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

## Air Conditioner Notes

The air conditioner is left powered with `On 1`, then started and stopped with `Mode`:

```ic10
sb cooler Mode 0  # idle
sb cooler Mode 1  # active
```

The script also sets the air conditioner's `Setting` to `minTemp + 273.15`, because the AC setting is stored in kelvin. With the default `minTemp` of 10 C, the AC setting is written as 283.15 K.

## Display Behavior

Normally the LED display shows the rounded current temperature in Celsius. After pressing either target button, it briefly shows the rounded target temperature before returning to the current temperature.

## Customization

Change these values in `THERMOSTAT.ic10` to tune the behavior:

- `minTemp` - minimum target temperature and AC setpoint floor.
- `maxTemp` - maximum target temperature.
- `move target 22` - boot target temperature.
- `move hyst 1.0` - heating/cooling deadband size.

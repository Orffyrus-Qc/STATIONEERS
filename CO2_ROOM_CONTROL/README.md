# CO2 Room Control

`CO2_ROOM_CONTROL.ic10` keeps a room near a target CO2 percentage using a room
gas sensor, one pump that adds CO2, one pump that removes room gas, a console
LED2 display, and `+` / `-` buttons.

## Setup

Label the room devices:

| Label | Device type | Purpose |
| --- | --- | --- |
| `CO2_SENSOR` | `StructureGasSensor` | Reads room `RatioCarbonDioxide`. |
| `CO2_DISPLAY` | `ModularDeviceLEDdisplay2` | Shows current or target CO2 percent. |
| `+` | `ModularDeviceUtilityButton2x2` | Raises the target by `0.1%`. |
| `-` | `ModularDeviceUtilityButton2x2` | Lowers the target by `0.1%`. |
| `CO2_ADD_PUMP` | Volume pump or turbo pump | Adds CO2 to the room. |
| `CO2_REMOVE_PUMP` | Volume pump or turbo pump | Removes gas from the room. |

The add pump should move CO2 from your CO2 storage pipe into the room, usually
through a passive vent. The remove pump should move room atmosphere out to your
waste or scrubber pipe, also usually through a passive vent.

## Behavior

Default values:

```ic10
define TARGET_START 2
define TARGET_MIN 0.1
define TARGET_MAX 20
define TARGET_STEP 0.1
define HYSTERESIS 0.2
define PUMP_RATE 10
```

The gas sensor reports CO2 as a `0..1` ratio. The script converts it to percent
for control and display.

When room CO2 is below `target - 0.2%`, the add pump turns on. When room CO2 is
above `target + 0.2%`, the remove pump turns on. Inside that band, both pumps
stay off.

Pressing `+` or `-` changes the target and shows the target value on the LED2
display for a few IC cycles. Otherwise, the display shows the current CO2
percentage rounded to one decimal place.

If the sensor is missing or unreadable, both pumps turn off and the display
shows `-1`.

## Notes

This controls CO2 ratio only. It will also change room pressure while adding or
removing gas, so use a separate pressure controller if the room pressure must
stay inside a tight band.

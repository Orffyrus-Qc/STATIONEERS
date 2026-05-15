# Europa Room Pressure

`EUROPA_ROOM_PRESSURE.ic10` keeps a room near `101 kPa` using one named gas
sensor and any mix of:

- `StructureActiveVent`
- `StructurePoweredVent`
- `StructurePoweredVentLarge`

## Setup

Label the room gas sensor:

| Label | Device type | Purpose |
| --- | --- | --- |
| `EUROPA_ROOM_PRESSURE_SENSOR` | `StructureGasSensor` | Room pressure input. |

Label every vent controlled by this IC:

| Label | Device type | Purpose |
| --- | --- | --- |
| `EUROPA_ROOM_PRESSURE` | `StructureActiveVent` | Adds/removes gas. |
| `EUROPA_ROOM_PRESSURE` | `StructurePoweredVent` | Adds/removes gas. |
| `EUROPA_ROOM_PRESSURE` | `StructurePoweredVentLarge` | Adds/removes gas. |

The IC can be installed anywhere on the same data network as the sensor and
vents. It uses batch reads and writes by prefab hash and label, so pins are not
required.

## Behavior

Default values:

```ic10
define TARGET_PRESSURE 101
define PRESSURE_BAND 0.5
```

When pressure drops below `100.5 kPa`, the vents switch to outward mode
(`Mode 0`) and add gas to the room until the sensor reads `101 kPa`.

When pressure rises above `101.5 kPa`, the vents switch to inward mode
(`Mode 1`) and remove gas from the room until the sensor reads `101 kPa`.

Inside the pressure band, the script keeps the current correction running only
until it reaches the target, then turns all controlled vents off.

## Vent Notes

Active vents reset `PressureExternal` and `PressureInternal` when their mode
changes, so the script writes mode first and then rewrites the pressure limits.
For active vents, the pipe-side limit is `0 kPa` while filling the room and
`50000 kPa` while draining the room.

Powered vents do not have an internal pipe-pressure limiter. If inward mode can
overpressurize your pipe network, add a pipe-side safety controller or analyzer
to that network.

# CO2 Batch Reactor

`CO2_BATCH_REACTOR.ic10` makes small CO2 batches by filling an isolated burn
chamber with CH4 and O2, pulsing a named igniter, then pumping the result into a
CO2 storage tank.

## Setup

Label the devices:

| Label | Device type | Purpose |
| --- | --- | --- |
| `CO2_REACTOR_SENSOR` | `StructureGasSensor` or `StructurePipeAnalysizer` | Reads chamber pressure, gas ratios, and combustion state. |
| `CO2_TANK_SENSOR` | `StructureGasSensor` or `StructurePipeAnalysizer` | Reads storage tank pressure. |
| `CH4_PUMP` | Volume pump or turbo volume pump | Adds CH4 to the burn chamber. |
| `O2_PUMP` | Volume pump or turbo volume pump | Adds O2 to the burn chamber. |
| `CO2_OUTPUT_PUMP` | Volume pump or turbo volume pump | Moves finished gas from the chamber to storage. |
| `CO2_IGNITER` | `StructureIgniter` | Starts combustion after the chamber is filled. |

The three pumps can be `StructureVolumePump` or `StructureTurboVolumePump`. The
script writes to both prefab hashes, so only the matching named device will
respond.

## Behavior

Default values:

```ic10
define TARGET_CH4_KPA 10
define TARGET_O2_KPA 5
define EMPTY_KPA 1
define TANK_MAX_KPA 9000
define INPUT_PUMP_RATE 5
define OUTPUT_PUMP_RATE 10
```

The IC starts by emptying the chamber into the storage line. It then fills the
chamber to about `10 kPa` CH4 and `5 kPa` O2, using partial pressure from the
chamber sensor so the batch stays proportional even as total pressure changes.

After filling, the IC pulses `CO2_IGNITER`, waits for `Combustion` to end, and
pumps the finished gas to the CO2 tank until the chamber falls below `1 kPa`.
If the tank sensor reads above `9000 kPa`, the output pump stays off until tank
pressure drops.

## Notes

The current IC10 logic database exposes CH4/Methane as `RatioVolatiles`. If your
game build only accepts `RatioMethane`, replace `RatioVolatiles` in the script.

Keep the burn chamber small and isolated. The script controls pump `On` and
`Setting`; set turbo pump direction and mode on the pump itself if needed.

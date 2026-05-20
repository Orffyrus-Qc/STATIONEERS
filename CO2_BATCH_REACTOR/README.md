# CO2 Batch Reactor

`CO2_BATCH_REACTOR.ic10` and `CO2_BATCH_REACTOR_EXHAUST.ic10` make small CO2
batches by filling an isolated burn chamber with CH4 and O2, pulsing a named
igniter, then pumping the result into a CO2 storage tank. The work is split
across two ICs so each script stays within the 128-line IC10 limit.

## Setup

Label the devices:

| Label | Device type | Purpose |
| --- | --- | --- |
| `CO2_REACTOR_SENSOR` | `StructureGasSensor` or `StructurePipeAnalysizer` | Reads chamber pressure, gas ratios, and combustion state. |
| `CO2_TANK_SENSOR` | `StructureGasSensor` or `StructurePipeAnalysizer` | Reads storage tank pressure. |
| `CO2_REACTOR_PHASE` | `StructureLogicMemory` | Shared phase signal between the fill/spark IC and the exhaust IC. |
| `CH4_VALVE` | `StructureDigitalValve` | Adds CH4 to the burn chamber. |
| `O2_VALVE` | `StructureDigitalValve` | Adds O2 to the burn chamber. |
| `CO2_OUTPUT_PUMP` | Volume pump or turbo volume pump | Moves chamber gas into the CO2 storage line. |
| `CO2_IGNITER` | `StructureIgniter` | Starts combustion after the chamber is filled. |

Load `CO2_BATCH_REACTOR.ic10` into one IC housing and
`CO2_BATCH_REACTOR_EXHAUST.ic10` into a second IC housing on the same data
network as the shared Logic Memory.

The output pump can be `StructureVolumePump` or `StructureTurboVolumePump`. The
exhaust IC keeps it as the default emptying step before filling can begin.

## Behavior

Default values:

```ic10
define TARGET_CH4_KPA 2
define TARGET_O2_KPA 1
define EMPTY_KPA 0.25
define TANK_MAX_KPA 9000
define OUTPUT_PUMP_RATE 10
```

The fill/spark IC starts by requesting exhaust mode so the exhaust IC can empty
the chamber into the storage line through `CO2_OUTPUT_PUMP`. It then opens
`CH4_VALVE` and `O2_VALVE` only until the chamber reaches about `2 kPa` CH4 and
`1 kPa` O2, using partial pressure from the chamber sensor so the batch stays
proportional even as total pressure changes.

After filling, the fill/spark IC pulses `CO2_IGNITER`, waits for `Combustion`
to end, then writes exhaust mode to `CO2_REACTOR_PHASE`. The exhaust IC runs
the CO2 output pump until the chamber falls below `0.25 kPa`, then
writes ready mode so the next batch can start. If the tank sensor reads above
`9000 kPa`, the output pump stays off until tank pressure drops.

`CO2_REACTOR_PHASE` values are `0` ready/empty, `1` fill/spark/burn, and `2`
exhaust.

## Notes

The script reads CH4/Methane as `RatioMethane`.

Keep the burn chamber small and isolated. The scripts control valve `On`, output
pump `On`, and output pump `Setting`.
If a very small chamber still breaks nearby windows, lower `TARGET_CH4_KPA` and
`TARGET_O2_KPA` together to keep the same 2:1 gas ratio.

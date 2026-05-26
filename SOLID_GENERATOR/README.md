# Solid Generator Control

Stationeers IC10 scripts for automatically starting and stopping a solid fuel
generator based on battery charge level.

## Purpose

These scripts monitor up to five batteries and control one solid fuel generator.
When the average charge of the connected or labeled batteries falls to the
configured start level, the generator turns on. When the average charge rises to
the configured stop level, the generator turns off.

This is useful for a backup power setup where the generator should only burn
fuel when stored battery power is low.

## Script Variants

| File | Setup style | Best for |
| --- | --- | --- |
| `SOLID_GENERATOR_Pin.ic10` | IC housing pins | Small setups where the generator and batteries can be wired directly to the IC. |
| `SOLID_GENERATOR_Name.ic10` | Device labels and hashes | Larger data networks where you prefer labels instead of IC screws. |

Both scripts use the same default charge thresholds:

| Option | Default | Behavior |
| --- | --- | --- |
| `StartCharge` | `0.05` | Turn the generator on when average battery charge is at or below 5 percent. |
| `StopCharge` | `0.15` | Turn the generator off when average battery charge is at or above 15 percent. |
| `LoopDelay` | `2` | Wait 2 seconds between checks. |

If the average battery charge is between the start and stop values, the script
keeps the previous generator state. This prevents rapid on/off switching.

## Pin Version

Use `SOLID_GENERATOR_Pin.ic10` when you want to assign devices through IC
housing screws.

| Pin | Device |
| --- | --- |
| `d0` | Solid fuel generator. |
| `d1` | Optional first battery. |
| `d2` | Optional second battery. |
| `d3` | Optional third battery. |
| `d4` | Optional fourth battery. |
| `d5` | Optional fifth battery. |

### Pin Setup

1. Put the IC10 chip in an IC housing.
2. Set pin `d0` to the solid fuel generator.
3. Set pins `d1` through `d5` to the batteries you want to monitor.
4. Leave unused battery pins unset.
5. Keep the IC housing, generator, and batteries on the same powered data
   network.

The script skips any battery pin that is not set. If no batteries are connected,
the generator is forced off.

## Name/Hash Version

Use `SOLID_GENERATOR_Name.ic10` when you want the script to find devices by
their in-game labels. No IC housing pins are required.

All labels are case-sensitive. The names inside `HASH("name")` must match the
in-game device labels exactly.

| Label | Device |
| --- | --- |
| `Generator` | Preferred solid fuel generator label. |
| `SOLID_GENERATOR` | Alternate solid fuel generator label. |
| `BATTERY_1` | Optional first battery. |
| `BATTERY_2` | Optional second battery. |
| `BATTERY_3` | Optional third battery. |
| `BATTERY_4` | Optional fourth battery. |
| `BATTERY_5` | Optional fifth battery. |

### Name/Hash Setup

1. Put the IC10 chip in an IC housing connected to the same data network as the
   generator and batteries.
2. Name the generator `Generator` or `SOLID_GENERATOR`.
3. Name each battery you want to monitor from `BATTERY_1` through `BATTERY_5`.
4. Leave unused battery labels out of the setup.
5. Keep the IC housing, generator, and batteries powered.

The script checks both normal and large batteries for each battery label. It
also supports both `StructureSolidFuelGenerator` and the older
`StructureCoalGenerator` device hash for the generator.

## Behavior

Each loop, the selected script:

1. Reads the `Ratio` value from every configured battery it can find.
2. Averages only the batteries that are present.
3. Turns the generator on when the average charge is at or below `StartCharge`.
4. Turns the generator off when the average charge is at or above `StopCharge`.
5. Keeps the previous generator state while charge is between those thresholds.
6. Turns the generator off if no batteries are found.
7. Waits `LoopDelay` seconds, then repeats.

## Tuning

Change these values near the top of either script:

```ic10
define StartCharge 0.05
define StopCharge 0.15
define LoopDelay 2
```

For example, setting `StartCharge` to `0.20` and `StopCharge` to `0.80` makes
the generator start at 20 percent average charge and stop at 80 percent average
charge.

## Notes

- The generator control output writes to the generator `On` setting.
- The scripts average battery `Ratio`, so mixed battery sizes may not represent
  total stored energy exactly.
- The name/hash version controls the first matching generator label it finds.
- Avoid giving multiple unrelated devices the same battery labels.
- If the generator pin or label is missing, the scripts wait and try again on
  the next loop.

## Files

- `SOLID_GENERATOR_Name.ic10` - name/hash version with optional battery labels.
- `SOLID_GENERATOR_Pin.ic10` - pin version using `d0` for the generator and
  `d1` through `d5` for batteries.

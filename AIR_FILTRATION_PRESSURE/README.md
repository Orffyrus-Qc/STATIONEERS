# Air Filtration Pressure Safety

Stationeers IC10 script that forces named air filtration units (`StructureFiltration`)
to Idle mode whenever a watched device's `PressureOutput2` exceeds 15 MPa, with
hysteresis to prevent rapid cycling.

## Purpose

`AIR_FILTRATION_PRESSURE.ic10` watches `PressureOutput2` of the device that
contains the IC10 chip. When that pressure rises above 15 MPa, every
`StructureFiltration` unit named `FILTRATION` on the data network is forced
to Mode 0 (Idle) and kept there until `PressureOutput2` falls to 14.5 MPa
or lower.

This is a pure safety interlock. While the pressure is safe, the script does
nothing and lets whatever normally controls your filtration units (levers,
consoles, other ICs, etc.) operate them. When over-pressure is detected, it
takes over and forces idle on the whole named group.

Typical use: put the chip inside a gas tank or other device on the common
output line of several filtration units. If the shared output side gets too
pressurized, all the filtration units feeding it are safely idled.

## Required Labels

All labels are case-sensitive. The names inside `HASH("name")` must match the
in-game device labels exactly.

| Label       | Device                                      |
| ----------- | ------------------------------------------- |
| `FILTRATION` | One or more air filtration units to protect. |

## Installation

1. Insert the IC10 chip running `AIR_FILTRATION_PRESSURE.ic10` into any device
   that reports the pressure you care about on `PressureOutput2` (gas tank on
   the output manifold, powered vent, pipe sensor, or even inside one of the
   filtration units themselves).
2. Connect the host device and all target filtration units to the same data
   network.
3. Name every filtration unit you want protected as `FILTRATION`.
4. Keep everything powered.

No IC housing pins are required. The script reads the host via `db` and uses
batch name/hash writes:

```ic10
l outputPress db PressureOutput2
sbn FILTRATION_TYPE FILTRATION_NAME Mode 0
```

## Behavior

| Host `PressureOutput2` | Filtration state                  |
| ---------------------- | --------------------------------- |
| Above 15 MPa           | Forced to Mode 0 (Idle)           |
| 14.5 MPa or lower      | Script does nothing (normal control) |
| Between 14.5–15 MPa    | Keeps previous lock state (hysteresis) |

The script only writes to the filtration units while the safety lock is engaged.
Once pressure is safe again, it stops sending commands and returns full control
to your regular systems.

## Options

Change these values directly in `AIR_FILTRATION_PRESSURE.ic10`:

| Option            | Default   | Behavior                                              |
| ----------------- | --------- | ----------------------------------------------------- |
| `PRESSURE_STOP`   | 15000000  | Force idle when `PressureOutput2` exceeds this (Pa).  |
| `PRESSURE_RESUME` | 14500000  | Release lock and stop forcing at or below this (Pa).  |

Values are in Pascals. 15 MPa = 15 000 000 Pa.

## Notes

- The script controls all `StructureFiltration` devices named `FILTRATION`.
- The device holding the IC can have any label (values read through `db`).
- Use `PressureOutput2` on the host device that best represents the "output"
  pressure you want to protect (often the downstream tank or manifold).
- The IC loop uses `yield`, so it checks every tick.
- Change `FILTRATION_NAME` in the script if you prefer a different label for
  your filtration units (e.g. `AIR_FILTRATION`).
- This script is complementary to gas-based filtration control scripts. It only
  acts on pressure, regardless of what gases are present.

## Files

- `AIR_FILTRATION_PRESSURE.ic10` - pressure safety interlock for named filtration units.

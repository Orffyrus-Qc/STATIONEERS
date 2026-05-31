# Air Filtration Pressure Safety

Stationeers IC10 script that forces named air filtration units (`StructureFiltration`)
to Idle and named Ice Crushers (`StructureIceCrusher`) off whenever a watched
device's `PressureOutput2` exceeds 15 MPa, with hysteresis to prevent rapid cycling.

## Purpose

`AIR_FILTRATION_PRESSURE.ic10` watches `PressureOutput2` of the device the IC10
chip is installed in (read via `db`). When pressure rises above 15 MPa (15,000 kPa),
it does the following while the safety lock is active:

- Directly forces the host device (via `db`) into safe state (`Mode 0` + `On 0`)
- Forces all named `StructureFiltration` units (label `FILTRATION`) to `Mode 0`
- Forces all named `StructureIceCrusher` units (label `CRUSHER`) to `On 0`

The safe state is held (with hysteresis) until pressure drops to 14.5 MPa or lower.

Typical use: put the chip inside a gas tank on the common output line of
filtration units + crushers. If the shared output side gets too pressurized,
the filtration units are idled and the crushers are turned off to prevent
further pressure buildup.

## Required Labels

All labels are case-sensitive. The names inside `HASH("name")` must match the
in-game device labels exactly.

| Label     | Device (optional) |
| --------- | ----------------- |
| `CRUSHER` | Additional Ice Crushers you want to shut down over the network (the host device this chip is in is always protected directly via `db`). |

## Installation

1. Insert the IC10 chip running `AIR_FILTRATION_PRESSURE.ic10` into any device
   that reports the pressure you care about on `PressureOutput2` (gas tank on
   the output manifold, powered vent, pipe sensor, or even inside one of the
   filtration units themselves).
2. Connect the host device and all target filtration units to the same data
   network.
3. (Optional) Name Ice Crushers you want shut down as `CRUSHER`.
4. Keep everything powered.

The script always protects the device it is installed in via direct `db` writes.
The `CRUSHER` label is only needed if you want to control additional crushers over the network.

No IC housing pins are required. The script reads pressure from the host device
using `db` and controls both the host + named devices on the network:

```ic10
l outputPress db PressureOutput2
s db Mode 0
s db On 0
sbn FILTRATION_TYPE FILTRATION_NAME Mode 0
sbn CRUSHER_TYPE CRUSHER_NAME On 0
```

## Behavior

| Host `PressureOutput2` | Filtration + Crusher state                  |
| ---------------------- | ------------------------------------------- |
| Above 15 MPa           | Filtration → Mode 0 (Idle), Crusher → On 0  |
| 14.5 MPa or lower      | Script does nothing (normal control)        |
| Between 14.5–15 MPa    | Keeps previous lock state (hysteresis)      |

The script only writes while the safety lock is engaged.
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

- The script always directly controls the device it is installed in via `db`
  (sets `Mode 0` + `On 0`).
- It also shuts down **all** named `StructureFiltration` (label `FILTRATION`)
  and `StructureIceCrusher` (label `CRUSHER`) devices on the data network.
- Pressure values are in **Pascals** (15,000 kPa = 15,000,000 Pa).
- The device holding the IC can have any label.
- Best placed in a device that sees the critical output pressure you want to
  protect (tank, filtration unit, etc.).
- The IC loop uses `yield`, so it checks every tick.
- You can change `FILTRATION_NAME` and `CRUSHER_NAME` at the top of the script
  if you use different labels.

## Files

- `AIR_FILTRATION_PRESSURE.ic10` - pressure safety interlock for named filtration units and ice crushers.

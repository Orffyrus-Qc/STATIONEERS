# Air Filtration Pressure Safety

Stationeers IC10 script that forces named air filtration units (`StructureFiltration`)
to Idle and named Ice Crushers (`StructureIceCrusher`) off whenever a watched
device's pressure reaches 15 MPa, then restores them when pressure falls to
14.5 MPa or lower.

## Purpose

`AIR_FILTRATION_PRESSURE.ic10` watches the device the IC10 chip is installed in
(read via `db`). It reads `PressureOutput2` first, then falls back to `Pressure`
for tank/sensor-style hosts. When pressure reaches 15 MPa (15,000 kPa), it does
the following while the safety lock is active:

- Forces the host device to `Mode 0` via `db`, if the host supports `Mode`
- Forces all named `StructureFiltration` units (label `FILTRATION`) to `Mode 0`
- Forces all named `StructureIceCrusher` units (label `CRUSHER`) to `On 0`

The safe state is held (with hysteresis) until pressure drops to 14.5 MPa or
lower. On that release transition, the script restores the host to `Mode 1`
if supported, named `FILTRATION` units to `Mode 1`, and named `CRUSHER` units
to `On 1`.

Typical use: put the chip inside a gas tank on the common output line of
filtration units + crushers. If the shared output side gets too pressurized,
the filtration units are idled and the crushers are turned off to prevent
further pressure buildup.

## Required Labels

All labels are case-sensitive. The names inside `HASH("name")` must match the
in-game device labels exactly.

| Label     | Device (optional) |
| --------- | ----------------- |
| `FILTRATION` | Filtration units you want idled over the network. |
| `CRUSHER` | Ice Crushers you want shut down over the network. |

## Installation

1. Insert the IC10 chip running `AIR_FILTRATION_PRESSURE.ic10` into any device
   that reports the pressure you care about on `PressureOutput2` or `Pressure`
   (gas tank on the output manifold, pipe sensor, or a filtration unit).
2. Connect the host device, target filtration units, and target crushers to the
   same data network.
3. Name Filtration units you want idled as `FILTRATION`.
4. (Optional) Name Ice Crushers you want shut down as `CRUSHER`.
5. Keep everything powered.

The script tries to protect and restore the device it is installed in via
guarded `db` `Mode` writes. If that host does not support `Mode`, the script
skips direct host writes and still controls the named devices on the network.

No IC housing pins are required. The script reads pressure from the host device
using `db` and controls both the host + named devices on the network:

```ic10
bdnvl db PressureOutput2 readPressure
l outputPress db PressureOutput2
j checkPressure
readPressure:
bdnvl db Pressure applySafety
l outputPress db Pressure
checkPressure:
bdnvs db Mode skipHostMode
s db Mode 0
skipHostMode:
sbn FILTRATION_TYPE FILTRATION_NAME Mode 0
sbn CRUSHER_TYPE CRUSHER_NAME On 0

# On lock release:
bdnvs db Mode skipHostActive
s db Mode 1
skipHostActive:
sbn FILTRATION_TYPE FILTRATION_NAME Mode 1
sbn CRUSHER_TYPE CRUSHER_NAME On 1
```

## Behavior

| Host pressure        | Filtration + Crusher state             |
| -------------------- | -------------------------------------- |
| 15 MPa or higher     | Filtration -> Mode 0, Crusher -> On 0  |
| 14.5 MPa or lower    | Lock releases, Mode 1 and On 1 restored |
| Between 14.5-15 MPa  | Keeps previous lock state (hysteresis) |

The script writes idle/off while the safety lock is engaged, then writes
active/on once when the lock releases. While pressure is safe and no lock
transition happens, it does nothing.

## Options

Change these values directly in `AIR_FILTRATION_PRESSURE.ic10`:

| Option            | Default   | Behavior                                              |
| ----------------- | --------- | ----------------------------------------------------- |
| `PRESSURE_STOP`   | 15000   | Force idle when watched pressure reaches this (kPa).  |
| `PRESSURE_RESUME` | 14500   | Release lock and stop forcing at or below this (kPa). |

Values are in kPa. 15 MPa = 15,000 kPa.

## Notes & Troubleshooting

**Most common reasons it appears "not working":**

- Your system pressure never actually reaches 15,000 kPa (15 MPa). This is a
  very high pressure (150 bar). Normal gas systems often run at 100-500 kPa.
- Devices are not labeled **exactly** `FILTRATION` and `CRUSHER`
  (case-sensitive, use the Labeler tool).
- The IC and the target devices are not on the same Data Network.
- The thresholds were copied from an older version as `15000000` and `14500000`.
  IC10 pressure logic uses kPa, so those values should be `15000` and `14500`.

**Host device note**: We only write `Mode 0` to the host via `db` when the host
supports `Mode`, and write `Mode 1` back on lock release. We do not write
`On 0` to the host. This is safer when the IC is installed inside a
`StructureFiltration` because setting `On=0` can stop the running script.

- Pressure values are in **kPa**.
- The script uses `bge` so it triggers at the exact stop value.
- You can change the two `NAME` defines at the top if you use different labels.

## Debug Tip

Wire a small light or LED to pin `d0`. Turn the light on when the lock is active
so you can visually confirm the script detects high pressure.

## Files

- `AIR_FILTRATION_PRESSURE.ic10` - pressure safety interlock for named
  filtration units and ice crushers.

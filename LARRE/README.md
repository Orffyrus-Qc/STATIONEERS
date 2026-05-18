# LArRE Hydroponics Patrol

`LARRE_HYDROPONICS.ic10` controls one named LArRE Dock (Hydroponics) without
using IC device pins. It moves through a configured grow-station range, samples
the hydroponics proxy slot under each station, and uses dedicated seed/crop chute
stations so LArRE can keep the line running automatically.

In short, LArRE patrols your hydroponics rail line and handles simple tray
maintenance. It visits each configured grow station, checks the tray below it,
then picks seeds from a seed export bin, plants empty trays, harvests seeds and
crops, and drops output into chute bins when the tray needs attention.

## Required Label and Stations

All labels are case-sensitive. The name inside `HASH("name")` must match the
in-game device label exactly.

| Label | Device type | Purpose |
| --- | --- | --- |
| `Station` | `StructureLarreDockHydroponics` | LArRE Dock (Hydroponics) controlled by the script. |

The IC can be installed anywhere on the same data network as the LArRE dock. It
uses batch reads and writes by prefab hash and label, so pins are not required.

Only the LArRE Dock (Hydroponics) needs this label. Do not name every rail
station `Station`, `Station1`, or similar for this script. Rail stops are
selected by their numeric station index through the dock's `Setting` value.

Default station layout:

| Role | Default station | Physical station target | Purpose |
| --- | --- | --- | --- |
| Grow trays | `0` through `5` | Hydroponics trays/devices | LArRE plants, harvests, and clears crops. |
| Seed import bin | `6` | Chute Import Bin | LArRE drops harvested seeds into the seed chute network. |
| Seed export bin | `7` | Chute Export Bin | LArRE picks seeds up from the seed chute network before planting. |
| Crops export bin | `8` | Chute Import Bin | LArRE drops crops or cleared dead plants into the output chute network. |

The crops export station uses a Chute Import Bin because LArRE is placing items
into the chute network. The name describes the station's job from the
greenhouse point of view.

## Behavior

Default grow-station range and bin stations:

```ic10
define FIRST_GROW_STATION 0
define LAST_GROW_STATION 5
define SEED_IMPORT_STATION 6
define SEED_EXPORT_STATION 7
define CROPS_EXPORT_STATION 8
```

For each grow station, the script writes the station number to `Setting`, waits
until LArRE is idle, then reads slot `255` on the named hydroponics dock.

The automatic cycle:

1. Empty tray: LArRE visits the seed export bin, picks up a seed if available,
   returns to the tray, and plants it.
2. Seeding plant: LArRE harvests the seed and drops it into the seed import bin.
3. Mature plant: LArRE harvests the crop and drops it into the crops export bin.
4. Dead plant: LArRE clears the tray and drops the dead plant into the crops
   export bin.

For chute handoff stations:

- Chute Import Bin = LArRE drops items into the chute network.
- Chute Export Bin = LArRE can pick items up from the chute network.

Pulsing `Activate` tells LArRE to use the claw at the current station. If it is
holding crops or seeds and there is a Chute Import Bin under the station, it
should place or drop the item into that bin.

After the final station, the script waits 10 seconds and starts the patrol again.

## Options

Change these values directly in `LARRE_HYDROPONICS.ic10`:

| Option | Default | Behavior |
| --- | --- | --- |
| `LARRE_NAME` | `HASH("Station")` | In-game label for the LArRE Dock (Hydroponics). |
| `FIRST_GROW_STATION` | `0` | First grow tray station index to visit. |
| `LAST_GROW_STATION` | `5` | Last grow tray station index to visit. |
| `SEED_IMPORT_STATION` | `6` | Station with the Chute Import Bin where LArRE drops harvested seeds. |
| `SEED_EXPORT_STATION` | `7` | Station with the Chute Export Bin where LArRE picks seeds up for planting. |
| `CROPS_EXPORT_STATION` | `8` | Station with the Chute Import Bin where LArRE drops crops and dead plants. |
| `ACTION_SETTLE_SECONDS` | `2` | Delay after a claw action before checking idle again. |
| `LOOP_PAUSE_SECONDS` | `10` | Delay between patrol loops. |

## Files

- `LARRE_HYDROPONICS.ic10` - name/hash version for one LArRE Dock (Hydroponics).

# LArRE Hydroponics Patrol

`LARRE_HYDROPONICS.ic10` controls one named LArRE Dock (Hydroponics) without
using IC device pins. It moves through a configured grow-station range, samples
the hydroponics proxy slot under each station, and uses dedicated seed/crop chute
stations so LArRE can keep the line running automatically.

In short, LArRE patrols your hydroponics rail line and handles simple tray
maintenance. It visits each configured grow station, checks the tray below it,
then picks seeds from the seed import station, plants empty trays, harvests seeds
and crops, and drops output into chute bins when the tray needs attention.

## Required Label and Stations

All labels are case-sensitive. The name inside `HASH("name")` must match the
in-game device label exactly.

| Label | Device type | Purpose |
| --- | --- | --- |
| `LArRE` | `StructureLarreDockHydroponics` | LArRE Dock (Hydroponics) controlled by the script. |

The IC can be installed anywhere on the same data network as the LArRE dock. It
uses batch reads and writes by prefab hash and label, so pins are not required.

Only the LArRE Dock (Hydroponics) needs this label. Do not name every rail
station `Station`, `Station1`, or similar for this script. Rail stops are
selected by their numeric station index through the dock's `Setting` value.

Default station layout:

| Role | Default station | Physical station target | Purpose |
| --- | --- | --- | --- |
| Grow trays | `0` through `15` | Hydroponics trays/devices | LArRE plants, harvests, and clears crops. |
| Seed import station | `16` | Chute Export Bin | LArRE picks seeds up from the seed chute network before planting. |
| Seed export station | `17` | Chute Import Bin | LArRE drops harvested seeds into the seed chute network. |
| Crops export bin | `18` | Chute Import Bin | LArRE drops crops or cleared dead plants into the output chute network. |

The seed import station uses a Chute Export Bin because LArRE is taking seeds
out of the chute network. The seed export and crops export stations use Chute
Import Bins because LArRE is placing items into the chute network. These names
describe each station's job from the greenhouse point of view.

## Behavior

Default grow-station range and bin stations:

```ic10
define FIRST_GROW_STATION 0
define LAST_GROW_STATION 15
define SEED_IMPORT_STATION 16
define SEED_EXPORT_STATION 17
define CROPS_EXPORT_STATION 18
```

For each grow station, the script writes the station number to `Setting`, waits
until LArRE is idle, then reads slot `255` on the named hydroponics dock.

The automatic cycle:

1. Empty tray: LArRE visits the seed import station, picks up a seed if available,
   returns to the tray, and plants it.
2. Mature plant without ready seeds: LArRE waits and does not harvest yet.
3. Seeding plant: LArRE harvests the seed, drops it into the seed export station,
   then returns and harvests the crop if the plant is mature.
4. Dead plant: LArRE clears the tray and drops the dead plant into the crops
   export bin.

For chute handoff stations:

- Chute Import Bin = LArRE drops items into the chute network.
- Chute Export Bin = LArRE can pick items up from the chute network.

Pulsing `Activate` tells LArRE to use the claw at the current station. If it is
holding crops or seeds and there is a Chute Import Bin under the station, it
should place or drop the item into that bin.

The script uses the `Seeding` slot value to avoid harvesting crops too early.
`Seeding` must be greater than `0` before LArRE harvests the plant, so it waits
for seeds to be ready before taking the crop.

This does not require a second IC or direct batch reads from
`StructureHydroponicsTrayData`. The Hydroponics LArRE dock reads the tray under
the current station through slot `255`. A separate tray-data IC is only useful if
you want to pre-scan many trays while LArRE is moving somewhere else.

After the final station, the script waits 10 seconds and starts the patrol again.

## Options

Change these values directly in `LARRE_HYDROPONICS.ic10`:

| Option | Default | Behavior |
| --- | --- | --- |
| `LARRE_NAME` | `HASH("LArRE")` | In-game label for the LArRE Dock (Hydroponics). |
| `FIRST_GROW_STATION` | `0` | First grow tray station index to visit. |
| `LAST_GROW_STATION` | `15` | Last grow tray station index to visit. |
| `SEED_IMPORT_STATION` | `16` | Station with the Chute Export Bin where LArRE picks seeds up for planting. |
| `SEED_EXPORT_STATION` | `17` | Station with the Chute Import Bin where LArRE drops harvested seeds. |
| `CROPS_EXPORT_STATION` | `18` | Station with the Chute Import Bin where LArRE drops crops and dead plants. |
| `ACTION_SETTLE_SECONDS` | `2` | Delay after a claw action before checking idle again. |
| `LOOP_PAUSE_SECONDS` | `10` | Delay between patrol loops. |

## Files

- `LARRE_HYDROPONICS.ic10` - name/hash version for one LArRE Dock (Hydroponics).
- `FR-README.md` - French version of this README.

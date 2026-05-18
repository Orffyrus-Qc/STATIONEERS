# LArRE Hydroponics Patrol

`LARRE_HYDROPONICS.ic10` controls one named LArRE Dock (Hydroponics) without
using IC device pins. It moves through a configured station range, samples the
hydroponics proxy slot under each station, and activates the claw only when a
tray needs work.

In short, LArRE patrols your hydroponics rail line and handles simple tray
maintenance. It visits each configured station, checks the tray below it, then
plants from carried seeds, harvests mature or seeding plants, or clears dead
plants when the tray needs attention.

## Required Label

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

## Behavior

Default station range:

```ic10
define FIRST_STATION 0
define LAST_STATION 5
```

For each station, the script writes the station number to `Setting`, waits until
LArRE is idle, then reads slot `255` on the named hydroponics dock.

The claw activates when:

1. The tray is empty, so LArRE can plant if it is carrying seeds.
2. The plant is mature.
3. The plant is seeding.
4. The plant is dead or fully damaged.

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
| `FIRST_STATION` | `0` | First station index to visit. |
| `LAST_STATION` | `5` | Last station index to visit. |
| `ACTION_SETTLE_SECONDS` | `2` | Delay after a claw action before checking idle again. |
| `LOOP_PAUSE_SECONDS` | `10` | Delay between patrol loops. |

## Files

- `LARRE_HYDROPONICS.ic10` - name/hash version for one LArRE Dock (Hydroponics).

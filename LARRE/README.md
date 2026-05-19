# LArRE Hydroponics Patrol

This branch tests a multi-IC LArRE hydroponics system. `LARRE_BRAIN.ic10`
decides what should happen at each station, `LARRE_DRIVER.ic10` moves or
activates the LArRE Dock (Hydroponics), and `LARRE_EXPORT_BIN.ic10` keeps the
seed/crop chute import bins sending items into the chute network. The optional
`LARRE_CHUTE_STACKER_CONTROL.ic10` helper uses separate `START` and `STOP`
buttons to turn the named seed supply export bin on and off, `MANUAL` to send one
stacker clear pulse, and `AUTO` to repeat the stacker clear pulse on a timer.
`LARRE_POWER_LEVER.ic10` lets a Big Lever or Flip Cover Switch named
`LArRE_SWITCH` turn the LArRE Dock on/off.

The split leaves more room for future behavior while keeping each IC script
under the 128-line IC10 limit.

## Setup

Load the scripts into standard IC housings on the same data network:

| Script | Role |
| --- | --- |
| `LARRE_BRAIN.ic10` | Patrols the grow stations and sends inspect/action commands. |
| `LARRE_DRIVER.ic10` | Moves LArRE, pulses the claw, and reports slot status. |
| `LARRE_EXPORT_BIN.ic10` | Closes occupied seed/crop chute import bins so items enter the chute network. |
| `LARRE_CHUTE_STACKER_CONTROL.ic10` | Toggles the named seed supply export bin and clears all stackers from utility buttons. |
| `LARRE_POWER_LEVER.ic10` | Mirrors a Big Lever or Flip Cover Switch named `LArRE_SWITCH` to the LArRE Dock `On` state. |

No IC device pins are used. The brain and driver communicate through named Logic
Memory devices on the cable network, so this version works with normal IC
housings and does not depend on stacked-IC shared stack behavior or `db:1
Channel` network writes. The export-bin and chute/stacker helper ICs are
independent and only need access to their labeled devices on the same cable
network.

## Required Label and Stations

All labels are case-sensitive. The name inside `HASH("name")` must match the
in-game device label exactly.

| Label | Device type | Purpose |
| --- | --- | --- |
| `LArRE` | `StructureLarreDockHydroponics` | LArRE Dock (Hydroponics). |
| `LArRE_SWITCH` | Optional `ModularDeviceBigLever` or `ModularDeviceFlipCoverSwitch` | Power control that turns the LArRE Dock on/off. |
| `SEED_SUPPLYER` | `StructureChuteExportBin` | Chute Export Bin controlled by the START and STOP buttons. |
| `SEED_EXPORT_BIN` | Chute Import Bin | Bin under station `17` where LArRE drops harvested seeds. |
| `CROP_EXPORT_BIN` | Chute Import Bin | Bin under station `18` where LArRE drops crops and dead plants. |
| `START` | `ModularDeviceUtilityButton2x2` | Sets `SEED_SUPPLYER` `On` to `1`. |
| `STOP` | `ModularDeviceUtilityButton2x2` | Sets `SEED_SUPPLYER` `On` to `0`. |
| `MANUAL` | `ModularDeviceUtilityButton2x2` | Sends one clear pulse to all stackers. |
| `AUTO` | `ModularDeviceUtilityButton2x2` | Toggles automatic stacker clearing every `300` seconds. |
| `Vider` | `ModularDeviceLabelDiode3` | Auto-mode indicator; yellow off, blue on. |
| `Empileurs` | `ModularDeviceLabelDiode3` | Auto-mode indicator; yellow off, blue on. |
| `Planter` | `ModularDeviceLabelDiode3` | `SEED_SUPPLYER` indicator; red off, green on. |

`LARRE_CHUTE_STACKER_CONTROL.ic10` controls the `StructureChuteExportBin` named
`SEED_SUPPLYER` by prefab/name hash. It still clears every `StructureStacker`
and `StructureStackerReverse` on the IC's data network by prefab hash, so those
stackers do not need individual labels. It also colors `ModularDeviceLabelDiode3`
status labels: `Vider` and `Empileurs` are yellow when auto mode is off and blue
when it is on; `Planter` is red when `SEED_SUPPLYER` is off (`On` = `0`) and
green when it is on (`On` = `1`).

Add these eight Logic Memory devices on the same data network:

| Label | Purpose |
| --- | --- |
| `LARRE_BUS_REQ` | Request id from brain to driver. |
| `LARRE_BUS_TARGET` | Target station index. |
| `LARRE_BUS_CMD` | Command: `1` = inspect, `2` = action. |
| `LARRE_BUS_DONE` | Completed request id from driver to brain. |
| `LARRE_BUS_OCCUPIED` | Last `Occupied` status from slot `255`. |
| `LARRE_BUS_MATURE` | Last `Mature` status from slot `255`. |
| `LARRE_BUS_SEEDING` | Last `Seeding` status from slot `255`. |
| `LARRE_BUS_DAMAGE` | Last `Damage` status from slot `255`. |

Only the LArRE Dock (Hydroponics) needs the `LArRE` label for the patrol ICs.
Do not name every rail station `Station`, `Station1`, or similar for this
system. Rail stops are selected by their numeric station index through the
dock's `Setting` value.
If using `LARRE_POWER_LEVER.ic10`, label the LArRE Dock `LArRE` and label the
Big Lever or Flip Cover Switch `LArRE_SWITCH`; the IC separates them by
prefab/name hash, so no pins are needed.

Default station layout:

| Role | Default station | Physical station target | Purpose |
| --- | --- | --- | --- |
| Grow trays | `0` through `15` | Hydroponics trays/devices | LArRE plants, harvests, and clears crops. |
| Seed import station | `16` | Chute Export Bin | LArRE picks seeds up from the seed chute network before planting. |
| Seed export station | `17` | Chute Import Bin labeled `SEED_EXPORT_BIN` | LArRE drops harvested seeds into the seed chute network. |
| Crops export bin | `18` | Chute Import Bin labeled `CROP_EXPORT_BIN` | LArRE drops crops or cleared dead plants into the output chute network. |

The seed import station uses a Chute Export Bin because LArRE is taking seeds
out of the chute network. The seed export and crops export stations use Chute
Import Bins because LArRE is placing items into the chute network.
`LARRE_EXPORT_BIN.ic10` watches those two import bins. Empty bins stay open; once
an item appears in slot `0`, the script closes the bin so it sends the item into
the chute network.

## Logic Memory Protocol

The brain writes commands to named Logic Memory devices, and the driver writes
completion/status values back to the same bus:

| Memory label | Owner | Meaning |
| --- | --- | --- |
| `LARRE_BUS_REQ` | Brain | Request id. Incremented for every command. |
| `LARRE_BUS_TARGET` | Brain | Target station index. |
| `LARRE_BUS_CMD` | Brain | Command: `1` = inspect, `2` = action. |
| `LARRE_BUS_DONE` | Driver | Completed request id. |
| `LARRE_BUS_OCCUPIED` | Driver | `Occupied` value from slot `255`. |
| `LARRE_BUS_MATURE` | Driver | `Mature` value from slot `255`. |
| `LARRE_BUS_SEEDING` | Driver | `Seeding` value from slot `255`. |
| `LARRE_BUS_DAMAGE` | Driver | `Damage` value from slot `255`. |

Restart both ICs after loading so the bus memories reset before the driver starts
processing requests.

## Behavior

Default grow-station range and bin stations:

```ic10
define FIRST_GROW_STATION 0
define LAST_GROW_STATION 15
define SEED_IMPORT_STATION 16
define SEED_EXPORT_STATION 17
define CROPS_EXPORT_STATION 18
```

The automatic cycle:

1. Empty tray: LArRE visits the seed import station, picks up a seed if
   available, returns to the tray, and plants it.
2. Mature plant without ready seeds: LArRE waits and does not harvest yet.
3. Seeding plant: LArRE harvests the seed, drops it into the seed export
   station, then returns and keeps harvesting crops until the plant has no ready
   fruit left.
4. Dead plant: LArRE clears the tray and always drops the dead plant into the
   crops export bin.
5. Export bins: the export-bin IC closes occupied seed/crop import bins to push
   dropped items into the chute network, then reopens them when empty.
6. Chute/stacker helper: pressing `START` sets the powered Chute Export Bin
   named `SEED_SUPPLYER` `On` value to `1`, and it stays on until `STOP` sets
   `On` to `0`. Pressing `MANUAL` sends one clear pulse to all normal/reversed
   stackers. Pressing `AUTO` toggles auto mode; while auto mode is on, the same
   stacker clear pulse is sent every 300 seconds. `Vider` and `Empileurs` show
   auto mode, while `Planter` shows the current `SEED_SUPPLYER` `On` state.
7. Power lever helper: `LARRE_POWER_LEVER.ic10` reads `Open` from the
   `ModularDeviceBigLever` named `LArRE_SWITCH`. For the
   `ModularDeviceFlipCoverSwitch` named `LArRE_SWITCH`, it requires both `Open`
   and `On` to be true. It writes the combined state to the LArRE Dock named
   `LArRE`. Either control active keeps LArRE powered; all present controls off
   turns it off.

The system uses the `Seeding` slot value to avoid harvesting crops too early.
`Seeding` must be greater than `0` before LArRE harvests the plant, so it waits
for seeds to be ready before taking the crop.

## Options

Change these values directly in the scripts:

| Option | Script | Default | Behavior |
| --- | --- | --- | --- |
| `LARRE_NAME` | `LARRE_DRIVER.ic10` | `HASH("LArRE")` | In-game label for the LArRE Dock (Hydroponics). |
| `LARRE_NAME` | `LARRE_POWER_LEVER.ic10` | `HASH("LArRE")` | In-game label for the LArRE Dock (Hydroponics). |
| `SWITCH_NAME` | `LARRE_POWER_LEVER.ic10` | `HASH("LArRE_SWITCH")` | Shared label for the Big Lever or Flip Cover Switch power control. |
| `FIRST_GROW_STATION` | `LARRE_BRAIN.ic10` | `0` | First grow tray station index to visit. |
| `LAST_GROW_STATION` | `LARRE_BRAIN.ic10` | `15` | Last grow tray station index to visit. |
| `SEED_IMPORT_STATION` | `LARRE_BRAIN.ic10` | `16` | Station with the Chute Export Bin where LArRE picks seeds up for planting. |
| `SEED_EXPORT_STATION` | `LARRE_BRAIN.ic10` | `17` | Station with the Chute Import Bin where LArRE drops harvested seeds. |
| `CROPS_EXPORT_STATION` | `LARRE_BRAIN.ic10` | `18` | Station with the Chute Import Bin where LArRE drops crops and dead plants. |
| `ACTION_SETTLE_SECONDS` | `LARRE_DRIVER.ic10` | `2` | Delay after a claw action before checking idle again. |
| `LOOP_PAUSE_SECONDS` | `LARRE_BRAIN.ic10` | `10` | Delay between patrol loops. |
| `SEED_EXPORT_BIN` | `LARRE_EXPORT_BIN.ic10` | `HASH("SEED_EXPORT_BIN")` | Chute Import Bin label for harvested seeds. |
| `CROP_EXPORT_BIN` | `LARRE_EXPORT_BIN.ic10` | `HASH("CROP_EXPORT_BIN")` | Chute Import Bin label for crops and dead plants. |
| `SEED_SUPPLYER` | `LARRE_CHUTE_STACKER_CONTROL.ic10` | `HASH("SEED_SUPPLYER")` | Chute Export Bin label controlled by the START and STOP buttons. |
| `START_BUTTON` | `LARRE_CHUTE_STACKER_CONTROL.ic10` | `HASH("START")` | Utility button label for setting the seed supply export bin `On` value to `1`. |
| `STOP_BUTTON` | `LARRE_CHUTE_STACKER_CONTROL.ic10` | `HASH("STOP")` | Utility button label for setting the seed supply export bin `On` value to `0`. |
| `MANUAL_BUTTON` | `LARRE_CHUTE_STACKER_CONTROL.ic10` | `HASH("MANUAL")` | Utility button label for the manual stacker clear pulse. |
| `AUTO_BUTTON` | `LARRE_CHUTE_STACKER_CONTROL.ic10` | `HASH("AUTO")` | Utility button label for automatic stacker-clearing mode. |
| `VIDER_DIODE` | `LARRE_CHUTE_STACKER_CONTROL.ic10` | `HASH("Vider")` | Auto-mode label diode. |
| `EMPILEUR_DIODE` | `LARRE_CHUTE_STACKER_CONTROL.ic10` | `HASH("Empileurs")` | Auto-mode label diode. |
| `PLANTER_DIODE` | `LARRE_CHUTE_STACKER_CONTROL.ic10` | `HASH("Planter")` | `SEED_SUPPLYER` state label diode. |
| `BLUE`, `GREEN`, `RED`, `YELLOW` | `LARRE_CHUTE_STACKER_CONTROL.ic10` | `0`, `2`, `4`, `5` | Stationeers data-network color values used by the label diodes. |
| `AUTO_INTERVAL_SECONDS` | `LARRE_CHUTE_STACKER_CONTROL.ic10` | `300` | Delay between automatic stacker clear pulses while auto mode is on. |
| `STACKER_CLEAR_SECONDS` | `LARRE_CHUTE_STACKER_CONTROL.ic10` | `1` | Time to hold the stacker clear pulse active. |
| `POLL_SECONDS` | `LARRE_CHUTE_STACKER_CONTROL.ic10` | `0.25` | Button polling interval. |

## Files

- `LARRE_BRAIN.ic10` - decision and patrol IC.
- `LARRE_DRIVER.ic10` - LArRE movement/action IC.
- `LARRE_EXPORT_BIN.ic10` - seed/crop chute import bin control IC.
- `LARRE_CHUTE_STACKER_CONTROL.ic10` - START and STOP seed supply export bin control plus MANUAL/AUTO stacker clear helper IC.
- `LARRE_POWER_LEVER.ic10` - Big Lever or Flip Cover Switch to LArRE Dock power helper IC.
- `FR-README.md` - French version of this README.

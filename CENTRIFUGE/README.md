# Centrifuge Auto Eject

Stationeers IC10 script for automatically ejecting centrifuges when they enter
an error state.

## Purpose

`CENTRIFUGE.ic10` watches named centrifuges on the data network. When a
centrifuge reports `Error`, the script opens it so the reagents can eject. It
keeps the centrifuge open while the reagent amount is above the threshold, then
closes it once the centrifuge is mostly empty.

This helps stop centrifuges from flashing open and closed while they still have
material to eject.

## Required Labels

All labels are case-sensitive. The names inside `HASH("name")` must match the
in-game device labels exactly.

| Label | Device |
| --- | --- |
| `Centrifuge1` | First centrifuge to monitor. |
| `Centrifuge2` | Second centrifuge to monitor. |

To add more centrifuges, add another `define centN HASH("CentrifugeN")` line
near the top of the script, then copy one full centrifuge block and update the
number.

## Behavior

For each configured centrifuge, the script:

1. Reads the `Error`, `Reagents`, and `Open` values.
2. Starts opening the centrifuge if it is in error.
3. Keeps the centrifuge open while it is already ejecting and still has
   reagents above the threshold.
4. Closes the centrifuge when the reagent amount drops to `5` or lower.
5. Repeats every 5 seconds.

## Batch Mode Note

The script uses `Maximum` as the `lbn` batch mode. For boolean values like
`Error` and `Open`, this means any matching centrifuge reporting `1` will return
`1`. This is safer than `Average` if more than one device accidentally uses the
same label.

## Options

Change these values directly in `CENTRIFUGE.ic10`:

| Option | Default | Behavior |
| --- | --- | --- |
| `Centrifuge1` | label | In-game label for the first centrifuge. |
| `Centrifuge2` | label | In-game label for the second centrifuge. |
| reagent threshold | `5` | Centrifuge closes when `Reagents` is `5` or lower. |
| loop delay | `5` seconds | Time between checks. |

## Files

- `CENTRIFUGE.ic10` - name/hash version for multiple labeled centrifuges.

# Garage Door Control

Stationeers IC10 script for controlling a named garage or hangar door from two
buttons, with optional composite-door locking and klaxon warning sounds.

## Purpose

`GARAGE_DOOR.ic10` reads an interior and exterior button. A new button press
opens the configured door if it is closed, or manually closes it if it is open.
When open, the script starts an auto-close timer, can play warning and closing
klaxon modes, then closes the door after the configured tick count.

The script can also keep a named composite door powered and closed. This is
useful when the composite door is used as a safety lock or access barrier near
the garage door.

## Required Labels

All labels are case-sensitive. The names inside `HASH("name")` must match the
in-game device labels exactly.

| Label | Device |
| --- | --- |
| `GDOOR_B` | Garage or hangar door controlled when `USE_DOOR` is `1`. |
| `CDOOR_B` | Composite door controlled when `USE_COMP` is `1`. |
| `Button_GDoorB_INT` | Interior logic button. |
| `Button_GDoorB_EXT` | Exterior logic button. |
| `KLAXON_GDOOR_B` | Klaxon used when `USE_ALARM` is `1`. |

## Options

Change these values near the top of `GARAGE_DOOR.ic10`:

| Option | Default | Behavior |
| --- | --- | --- |
| `USE_DOOR` | `0` | Set to `1` to control the garage door. |
| `USE_ALARM` | `0` | Set to `1` to enable klaxon warning sounds. |
| `USE_COMP` | `1` | Set to `1` to keep the composite door powered and closed. |
| `AUTO_CLOSE_TICKS` | `60` | Timer value used before auto-closing. |
| `WARNING_TICKS` | `45` | Timer value used before warning mode. |
| `CLOSING_TICKS` | `55` | Timer value used before closing mode. |
| `ALARM_VOLUME` | `100` | Klaxon volume written at startup. |

## Behavior

The script:

1. Initializes the enabled door, composite door, and alarm devices.
2. Keeps the composite door closed if `USE_COMP` is enabled.
3. Keeps the garage door powered if `USE_DOOR` is enabled.
4. Reads the interior and exterior button `Setting` values.
5. Toggles the garage door only on a new button press.
6. Starts an auto-close timer while the garage door is open.
7. Optionally plays warning and closing klaxon modes before auto-close.
8. Turns the alarm off while the door is closed.

## Files

- `GARAGE_DOOR.ic10` - name/hash version for the configured door, buttons, and
  optional klaxon.

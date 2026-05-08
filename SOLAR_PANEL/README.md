# Solar Panel Tracking

Stationeers IC10 script for automatically aiming normal and reinforced solar
panels from a daylight sensor.

## Purpose

`SOLAR_PANEL.ic10` reads the horizontal and vertical angles from a daylight
sensor, converts those values to solar panel angles, and writes the same
orientation to every normal and reinforced solar panel on the data network.

The script also includes optional helpers for maintenance and door control:

- Maintenance mode parks all panels flat until the maintenance button is pressed
  again.
- Auto-door mode forces a connected door closed on every loop.

Both helpers are disabled by default and can be enabled directly in the script.

## IC Pins

| Pin | Device |
| --- | --- |
| `d0` | Daylight sensor used for solar tracking. |
| `d1` | Optional automatic door. Used only when `ENABLE_AUTO_DOOR` is set to `1`. |
| `d2` | Optional maintenance button, using `StructureLogicButton`. Used only when `ENABLE_MAINTENANCE` is set to `1`. |

## Options

Change these values near the top of `SOLAR_PANEL.ic10`:

| Option | Default | Behavior |
| --- | --- | --- |
| `ENABLE_MAINTENANCE` | `0` | Set to `1` to let button `d2` toggle maintenance mode. |
| `ENABLE_AUTO_DOOR` | `0` | Set to `1` to force door `d1` closed every loop. |

## Behavior

During normal operation, the script:

1. Optionally checks the maintenance button.
2. Optionally closes the connected door.
3. Reads `Horizontal` and `Vertical` from the daylight sensor.
4. Calculates the matching solar panel horizontal and vertical angles.
5. Writes those angles to all `StructureSolarPanel` and
   `StructureSolarPanelReinforced` devices.

In maintenance mode, the script sets all tracked panels to horizontal `0` and
vertical `0`, then keeps them parked until the maintenance button is pressed
again.

## Supported Panels

- `StructureSolarPanel`
- `StructureSolarPanelReinforced`

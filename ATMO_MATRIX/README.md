# AtmoMatrix Room Gas Manager

`ATMO_MATRIX` is a starter multi-IC atmosphere system for Stationeers rooms.
It lets a modular console select a preset room atmosphere, then lets a per-room
controller purge unsafe transitions, dose the selected gas, and use nitrogen as
the pressure pad gas.

## Files

- `ATMO_MATRIX_CONSOLE.ic10` - console preset selector. It writes the selected
  preset to a logic memory named `ATM_MODE`.
- `ATMO_MATRIX_ROOM.ic10` - per-room atmosphere controller. It reads
  `ATM_MODE`, reads the room gas sensor, controls gas input valves, and runs
  the purge vent when a combustible O2/volatiles transition is unsafe.

Each room should have its own isolated automation network or unique copied
labels. The default labels assume one console/room network.

## Presets

| Mode | Console value | Goal | Default control targets |
| --- | ---: | --- | --- |
| Human breathable | `100` on display, `1` in memory | O2 + N2 room air | 100 kPa total, at least 22 kPa O2, N2 pad |
| Zrilian breathable | `200` on display, `2` in memory | Methane + N2 room air | 100 kPa total, at least 22 kPa methane, N2 pad |
| Greenhouse optimal | `300` on display, `3` in memory | CO2-fed plant room | 80 kPa total, at least 5 kPa CO2, N2 pad |

Greenhouse values are intentionally conservative for common crops. Adjust
`targetGreen` and `co2Min` in `ATMO_MATRIX_ROOM.ic10` for specific plants or
for a greenhouse that shares atmosphere with humans.

## Console IC Setup

Required labels:

| Label | Device type | Purpose |
| --- | --- | --- |
| `HUMAN` | `ModularDeviceUtilityButton2x2` | Select human breathable mode. |
| `ZRILIAN` | `ModularDeviceUtilityButton2x2` | Select Zrilian breathable mode. |
| `GREENHOUSE` | `ModularDeviceUtilityButton2x2` | Select greenhouse mode. |
| `ATM_DISPLAY` | `ModularDeviceLEDdisplay2` | Shows `100`, `200`, or `300`. |
| `ATM_MODE` | `StructureLogicMemory` | Shared preset memory read by room ICs. |

## Room IC Setup

Required labels:

| Label | Device type | Purpose |
| --- | --- | --- |
| `ATM_SENSOR` | `StructureGasSensor` | Room gas pressure and gas ratios. |
| `ATM_MODE` | `StructureLogicMemory` | Preset value from the console. |
| `ATM_PURGE` | `StructureActiveVent` | Purges room gas to waste/outside. |
| `ATM_O2_IN` | `StructureDigitalValve` | Oxygen input. |
| `ATM_CH4_IN` | `StructureDigitalValve` | Methane input for Zrilians. |
| `ATM_CO2_IN` | `StructureDigitalValve` | Carbon dioxide input. |
| `ATM_N2_IN` | `StructureDigitalValve` | Nitrogen pressure pad input. |

The script sets `ATM_PURGE Mode 1` at boot. If your vent is installed facing the
opposite direction, flip the vent or change that boot value after testing.

## Safety Behavior

The room IC purges before allowing oxygen and fuels to share the room. It
purges when:

- room pressure is above the preset maximum;
- both oxygen and methane/hydrogen are above `2 kPa` partial pressure;
- the target mode needs methane while oxygen is above `2 kPa`;
- the target mode needs oxygen or greenhouse gas while methane/hydrogen is above
  `2 kPa`.

Purge continues until oxygen and methane/hydrogen are below `0.5 kPa` partial
pressure or until the room reaches the target pressure after an overpressure
purge.

## Notes

- Nitrogen is the only pad gas. The IC opens `ATM_N2_IN` when pressure is below
  the preset target and the selected breathing/growing gas is already adequate.
- Oxygen, methane, and CO2 valves only add their gas when the corresponding
  partial pressure is below the preset minimum.
- Keep combustible room transitions behind airlocks, blast doors, or reinforced
  frames if the room can ever contain both oxygen and fuel gas.
- The March 19, 2026 Gases Update renamed Volatiles to Methane and added
  Hydrogen as a separate gas. This script uses `RatioMethane` for Zrilian room
  dosing and includes `RatioHydrogen` in the purge safety check.

## Reference Values

The default values use current public Stationeers reference guidance:

- Human air is commonly defined as 75 percent nitrogen and 25 percent oxygen,
  and humans need at least about 16 kPa oxygen partial pressure to breathe.
- Zrilians breathe methane and exhale nitrous oxide, so their living spaces
  should be separated from oxygen rooms.
- Common plants need 25-200 kPa atmosphere, trace CO2, very low pollutant or
  methane contamination, and grow fastest around 50-100 kPa and 20-30 C.

Sources:

- <https://stationeers-wiki.com/Air>
- <https://stationeers-wiki.com/Zrilian>
- <https://stationeers-wiki.com/Methane>
- <https://stationeers-wiki.com/Hydrogen>
- <https://stationeers-wiki.com/Template:Hydroponics>
- <https://stationeers-wiki.com/Kit_(Active_Vent)>
- <https://steamdb.info/patchnotes/22406008/>

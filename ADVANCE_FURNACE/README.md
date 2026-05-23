# Advanced Furnace Automation

Stationeers IC10 scripts for automating an Advanced Furnace. This pack handles
recipe selection, target temperature and pressure memories, LED target displays,
start/stop control, furnace input/output control, hot and cold gas switching,
fuel mixing, ignition, gas-mode indicator lights, and automatic ejection for
selected finished products.

## How It Works

The automation is built around named devices and logic memories on the data
network. Recipe scripts read a recipe dial, write the selected target
temperature and pressure ranges into memories, and store the selected recipe
hash. The furnace IO script reads those targets and adjusts the Advanced Furnace
input and output to heat, cool, fill, trim, or vent.

A shared gas-mode memory chooses whether the input line is supplied by hot gas or
cold gas. The gas switching script purges the line before each mode change, and
the light script displays the active gas mode.

## Scripts

| Script | Purpose |
| --- | --- |
| `RECIPES_Selector.ic10` | Selects which recipe IC housing is active: metal, alloy, or superalloy. Supports normal and compact IC housings. |
| `RECIPES_Metal.ic10` | Writes recipe targets for copper, gold, iron, lead, nickel, silicon, and silver. |
| `RECIPES_Alloy.ic10` | Writes recipe targets for steel, electrum, solder, constantan, and invar. |
| `RECIPES_SuperAlloy.ic10` | Writes recipe targets for astroloy, hastelloy, inconel, waspaloy, and stellite. |
| `SETTING_IO.ic10` | Main furnace controller. Reads recipe targets, controls furnace input/output, selects hot or cold gas mode, vents over safe pressure, and forces input off when stopped. |
| `START_STOP.ic10` | Mirrors `START_STOP_SWITCH` into `memStartStop`, controls the auto-mode light, and keeps the stopped furnace locked with input off/output at 10. |
| `IGNITION.ic10` | Activates Advanced Furnace ignition every loop below 270 K while `START_STOP_SWITCH` or `IGN` is on. The indicator display is optional. |
| `SwitchGas_HotCold.ic10` | Controls hot, cold, and purge pumps. It fills the selected gas line to 4.5-5 MPa by default, and purges only when changing gas mode. |
| `SwitchGas_LIGHT.ic10` | Displays active gas mode with red and green indicator lights. |
| `FUEL_MIXER.ic10` | Sets the fuel mixer to 66 percent input 1, toggles the mixer based on fuel pressure, and cycles hot/cold ice crushers with the configured pressure hysteresis. |
| `EJECTER.ic10` | Opens the Advanced Furnace when selected alloy or superalloy recipes complete. Some basic metal recipes are included but commented out. |

## Required Labels

All labels are case-sensitive. The names inside `HASH("name")` must match the
in-game device labels exactly.

### Furnace And Automation

- `ADVANCED_FURNACE`
- `START_STOP_SWITCH` (`StructureLogicSwitch2` or `ModularDeviceBigLever`)
- `IGN` (`ModularDeviceBigLever`)
- `memStartStop`
- `AUTO_MODE_ON_FLASHING_LIGHT`

Optional ignition display:

- `IGNITION` (`ModularDeviceLabelDiode3`)

### Recipe Selection

- `SELECTOR_DIAL`
- `RECIPE_DIAL`
- `RECIPES_Metal`
- `RECIPES_Alloy`
- `RECIPES_SuperAlloy`

### Recipe Memories And Displays

- `MEM_TEMP+`
- `MEM_TEMP-`
- `MEM_PRESS+`
- `MEM_PRESS-`
- `MEM_HASH`
- `LED_TEMP+`
- `LED_TEMP-`
- `LED_PRESS+`
- `LED_PRESS-`

### Hot And Cold Gas Switching

- `memSwitchGas_HotCold`
- `HOT_PUMP`
- `COLD_PUMP`
- `PURGE_PUMP`
- `HotCold_BUTTON`
- `FUEL_INPUT_ANALYZER`
- `HOT_GAS_LIGHT`
- `COLD_GAS_LIGHT`

### Fuel And Gas Supply

- `FUEL_MIXER`
- `FUEL_ANALYZER`
- `COLD_ANALYZER`
- `HOT_ANALYZER`
- `COLD_CRUSHER`
- `HOT_CRUSHER`

## Notes

- `Description.txt` contains a longer English and French description of the
  script pack.
- The recipe scripts share the same memory and LED labels so only the active
  recipe category needs to write the current target values.
- `EJECTER.ic10` is intentionally conservative: several recipe checks are
  present but commented out until you want automatic ejection for those outputs.

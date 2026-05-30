# STATIONEERS

Stationeers IC10 scripts and logic reference files.

## Stationeers Dedicated Server Installer

The `STATIONEERS_SERVER/` folder contains a Windows batch installer for a
modded Stationeers dedicated server. It self-elevates through UAC, installs or
updates SteamCMD and the dedicated server, installs BepInEx and
StationeersLaunchPad, downloads the configured Workshop mods, writes
`modconfig.xml`, and launches the server.

See `STATIONEERS_SERVER/README.md` for requirements, generated files, security
notes, mod IDs, and launch settings.

## TerraformingMod Maintenance

The `TerraformingMod-maintained/` folder contains the maintained Stationeers
TerraformingMod fork, including the release DLL under
`TerraformingMod-maintained/dist/` and the server-only debug command/config mode
for fast atmosphere testing.

See `TerraformingMod-maintained/README.md` for build notes, install location,
and debug commands such as `preset breathable`, `status`, and `reset`.

## Advanced Furnace Automation

The `ADVANCE_FURNACE/` folder contains an IC10 script pack for automating an
Advanced Furnace. It covers recipe selection, temperature and pressure targets,
start/stop control, furnace input/output control, hot/cold gas switching, fuel
mixing, ignition, indicator lights, and automatic ejection for selected products.

See `ADVANCE_FURNACE/README.md` for setup labels and a script-by-script
breakdown.

## Centrifuge Auto Eject

The `CENTRIFUGE/` folder contains an IC10 script that watches multiple named
centrifuges and automatically opens any centrifuge that enters an error state.
Once opened, it keeps the centrifuge ejecting until the reagent amount drops
below the configured threshold, then closes it again.

See `CENTRIFUGE/README.md` for required labels, setup notes, and behavior.

## Garage Door Control

The `GARAGE_DOOR/` folder contains an IC10 script for controlling a named garage
or hangar door from interior and exterior buttons. It can keep a composite door
closed as a safety barrier and optionally play klaxon warning sounds before
closing.

See `GARAGE_DOOR/README.md` for labels, feature toggles, and timing values.

## Grow Light Cycle

The `GROW_LIGHT/` folder contains an IC10 script that cycles named grow lights
on a timer. It turns the lights on when the IC boots, keeps them on for 14
minutes, turns them off for 6 minutes, then repeats.

See `GROW_LIGHT/README.md` for the required label and timing notes.

## LArRE Hydroponics Patrol

The `LARRE/` folder contains an experimental multi-IC script set that controls
one named LArRE Dock (Hydroponics) without IC device pins. One IC patrols grow
stations and sends commands, the driver IC moves LArRE and reports tray status,
one helper IC sends dropped seeds/crops from chute import bins into the chute
network, another optional helper controls the named `SEED_SUPPLYER` chute export
bin from separate START and STOP buttons and stacker clear pulses from
MANUAL/AUTO buttons with label-diode status colors, and a small power helper
mirrors a Big Lever or Flip Cover Switch named `LArRE_SWITCH` to the LArRE Dock
`On` state.

See `LARRE/README.md` for the required labels, bin station layout, station range
options, helper buttons, power lever, and patrol behavior.

## Light House Rotating Beam

The `LIGHT_HOUSE/` folder contains an IC10 script that simulates a rotating
lighthouse beam with 20 named `StructureLightLongWide` lights arranged around
360 degrees. It supports an IC pin switch or lever on `d0`, with a named
`LIGHTHOUSE_SWITCH` fallback.

See `LIGHT_HOUSE/README.md` for labels, switch setup, and timing options.

## Thermostat Controller

The `THERMOSTAT/` folder contains a multi-room temperature-control script pack.
Each room thermostat controls hot/cold radiator digital valves, while separate
ICs maintain the hot and cold closed pipe loops.

See `THERMOSTAT/README.md` for the script list, required labels, clamp values,
and hot/cold loop hysteresis behavior.

## AtmoMatrix Room Gas Manager

The `ATMO_MATRIX/` folder contains a starter multi-IC room atmosphere system.
A modular console selects human breathable, Zrilian breathable, or greenhouse
presets. Per-room ICs read the selected preset, purge unsafe oxygen and fuel-gas
transitions, dose the selected gas, and use nitrogen as the pressure pad gas.

See `ATMO_MATRIX/README.md` for setup labels, preset targets, and safety
behavior.

## Europa Room Pressure

The `EUROPA_ROOM_PRESSURE/` folder contains an IC10 script that keeps a room at
101 kPa from a named gas sensor. It controls named `StructureActiveVent`,
`StructurePoweredVent`, and `StructurePoweredVentLarge` devices, switching them
between outward and inward mode as needed.

See `EUROPA_ROOM_PRESSURE/README.md` for labels, pressure band behavior, and
vent safety notes.

## CO2 Room Control

The `CO2_ROOM_CONTROL/` folder contains an IC10 script that keeps a room near an
adjustable CO2 percentage using a named gas sensor, one volume pump to add CO2,
one volume pump to remove room gas, a console LED2 display, and `+` / `-`
buttons.

See `CO2_ROOM_CONTROL/README.md` for labels, target range, pump behavior, and
pressure notes.

## CO2 Batch Reactor

The `CO2_BATCH_REACTOR/` folder contains a two-IC script pair that fills a small
isolated chamber through CH4/O2 digital valves, pulses a named igniter, waits for
combustion to finish, and pumps the resulting gas mix into a storage tank.

See `CO2_BATCH_REACTOR/README.md` for labels, the shared phase memory, digital
valves, output pump emptying, batch sizing, and tank pressure safety behavior.

## AC Heater Follower

The `AC_HEATER/` folder contains an IC10 script that uses the Air Conditioner
holding the IC chip as the control state for pipe heaters. When that host Air
Conditioner Mode is Active, all `HEATER` StructurePipeHeater devices turn on,
unless `TemperatureOutput2` is above `200 C`; heaters resume at `180 C` or
lower after converting that output temperature to Celsius.

See `AC_HEATER/README.md` for labels, mode behavior, temperature lockout, and
setup notes.

## Solid Generator Control

The `SOLID_GENERATOR/` folder contains IC10 scripts that control a solid fuel
generator from battery charge level. The generator turns on when the average
battery charge drops below the configured start level, and turns off when the
average battery charge rises above the configured stop level.

Files:

- `SOLID_GENERATOR_Name.ic10` - name/hash version. It finds a generator labeled
  `Generator` or `SOLID_GENERATOR`, then checks optional batteries labeled
  `BATTERY_1` through `BATTERY_5`.
- `SOLID_GENERATOR_Pin.ic10` - pin version. Set IC pin `d0` to the generator and
  pins `d1` through `d5` to the batteries you want to monitor.

The battery start/stop levels can be adjusted directly in the scripts by
changing `StartCharge` and `StopCharge`. The current defaults start the
generator below 5 percent charge and stop it above 15 percent charge.

## Proximity Switch Control

The `PROXIMITY_SWITCH/` folder contains `PROXIMITY_SWITCH.ic10`, an IC10 script
that controls a transformer with a proximity sensor and an AUTO/MANUAL mode
switch. MANUAL mode forces the transformer on and turns `activeLIGHT` off. AUTO
mode lets the proximity sensor control the transformer and turns `activeLIGHT`
on.

See `PROXIMITY_SWITCH/README.md` for required labels, supported lights, and mode
behavior.

## Solar Panel Tracking

The `SOLAR_PANEL/` folder contains an IC10 script that aims normal and
reinforced solar panels from a daylight sensor. It also includes optional
maintenance parking and optional auto-door closing features that can be enabled
in the script.

See `SOLAR_PANEL/README.md` for pin setup, configurable options, and supported
panel types.

## Trader Armageddon Swarm

The `TRADER_ARMAGEDDON_SWARM/` folder contains a 10-chip trader satellite dish
script pack built from a shared Grok answer. It coordinates four satellite
dishes, priority filtering, fuel item hash filtering, auto-calling, landing pad
rotation, status alerts, Morse telemetry, and multi-dish signal stability.

See `TRADER_ARMAGEDDON_SWARM/README.md` for pin setup, script roles, status
values, and the placeholder fuel hash notes.

## IC10 Logic Database

The `logic-db/` folder contains a Codex-oriented Stationeers IC10 logic database generated from Stationeers wiki/reference material verified on 2026-05-06.
The `stationeers_ic10_codex_db.json` and `stationeers_ic10_codex_chunks.jsonl`
files can be given to an AI as reference material to help build your own
Stationeers IC10 scripts. Use the JSON file as the full database, or the JSONL
chunks when you want smaller reference pieces for prompts and retrieval.

Files:

- `stationeers_ic10_codex_db.json` - full IC10 logic database.
- `stationeers_ic10_codex_chunks.jsonl` - smaller retrieval chunks for prompts and script generation.
- `manifest.codex.json` - database metadata and file counts.
- `build_stationeers_logic_db.ps1` - script used to rebuild the database.

## Markup Language

The `markup-language/` folder contains editor support files for working with Stationeers IC10 scripts.

The `markup-language/Notepad++/` folder contains a Notepad++ user-defined language file named `userDefineLang.xml`. It adds IC10 syntax highlighting for `.ic10` files in Notepad++.

The `markup-language/TextMate/` folder contains `ic10.tmLanguage.json`, a TextMate grammar adapted from the Notepad++ language file and the IC10 logic database.

GitHub syntax highlighting for `.ic10` files is limited by GitHub Linguist. This repo maps IC10 scripts to GitHub's closest built-in `Assembly` highlighter through `.gitattributes`, but exact IC10 highlighting would require IC10 support to be added upstream to GitHub Linguist.

See `markup-language/Notepad++/README.md` for the Windows install path and setup notes.

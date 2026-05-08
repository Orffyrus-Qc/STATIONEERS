# STATIONEERS

Stationeers IC10 scripts and logic reference files.

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

## Grow Light Cycle

The `GROW_LIGHT/` folder contains an IC10 script that cycles named grow lights
on a timer. It turns the lights on when the IC boots, keeps them on for 14
minutes, turns them off for 6 minutes, then repeats.

See `GROW_LIGHT/README.md` for the required label and timing notes.

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

## Proximity Transformer Control

The `PROXIMITY_TRANSFO/` folder contains an IC10 script that controls a
transformer with a proximity sensor and an AUTO/MANUAL mode switch. MANUAL mode
forces the transformer on, while AUTO mode turns the transformer on only when
the named proximity sensor is active.

See `PROXIMITY_TRANSFO/README.md` for required labels and mode behavior.

## Solar Panel Tracking

The `SOLAR_PANEL/` folder contains an IC10 script that aims normal and
reinforced solar panels from a daylight sensor. It also includes optional
maintenance parking and optional auto-door closing features that can be enabled
in the script.

See `SOLAR_PANEL/README.md` for pin setup, configurable options, and supported
panel types.

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

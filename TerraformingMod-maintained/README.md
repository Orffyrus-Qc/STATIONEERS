# TerraformingMod Maintenance

Maintained inside the main Stationeers repository:

https://github.com/Orffyrus-Qc/STATIONEERS/tree/main/TerraformingMod-maintained

This repository is an attempt to continue maintaining Elmotrix's Stationeers TerraformingMod so it works with the current version of the game.

The original project is by Elmotrix: https://github.com/Elmotrix/TerraformingMod

## Current Status

- Updated project references to resolve against a local Stationeers install.
- Ported compile-time API changes for current Stationeers assemblies.
- Built against the Stationeers install at `C:\Program Files (x86)\Steam\steamapps\common\Stationeers`.
- Release DLL is staged under `dist/BepInEx/plugins/TerraformingMod/`.
- Added a server-only debug command/config mode for disposable saves. It is disabled by default and is controlled through the BepInEx config.

Runtime testing in a disposable save is still recommended before using this on an important world.

## Debug Command Mode

Debug commands are intended for fast terraforming tests without waiting through normal gameplay progression. Enable them only on a server or disposable test save.

Config file:

`BepInEx/config/net.elmo.stationeers.Terraforming.cfg`

Required config:

```ini
[Testing]
EnableTestCommands = true
ChangeMultiplier = 1
CommandPollSeconds = 1
StatusPollSeconds = 5
```

Command file:

`BepInEx/config/TerraformingMod.TestCommands.txt`

The server consumes this file automatically. Create it again whenever you want to run another command batch.

Useful commands:

```txt
status
preset breathable
preset co2
add O2 10
set CO2 0.5
temp 293.15
multiplier 1000
reset
```

Results and atmosphere diagnostics are written to:

`BepInEx/config/TerraformingMod.TestStatus.txt`

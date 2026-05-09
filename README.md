# TerraformingMod Maintenance

This private repository is an attempt to continue maintaining Elmotrix's Stationeers TerraformingMod so it works with the current version of the game.

The original project is by Elmotrix: https://github.com/Elmotrix/TerraformingMod

## Current Status

- Updated project references to resolve against a local Stationeers install.
- Ported compile-time API changes for current Stationeers assemblies.
- Built against the Stationeers install at `C:\Program Files (x86)\Steam\steamapps\common\Stationeers`.
- Release DLL is staged under `dist/BepInEx/plugins/TerraformingMod/`.

Runtime testing in a disposable save is still recommended before using this on an important world.

# `-file start` Configuration Reference

This file documents the configurable part of this server launch line:

```bat
-file start "FlipsieModPack" Mars2 Normal DefaultStartCommunity MarsSpawnRoundRobin ^
```

Reference source: [Stationeers Community Wiki - Dedicated Server Guide](https://stationeers-wiki.com/Dedicated_Server_Guide).

The values below are based on the post-September-2025 dedicated server startup
format. The community wiki world table was marked verified in January 2026 and
the page was last edited on February 28, 2026. Stationeers updates can change
world IDs or start IDs, so if a value stops working, check the current server
logs and the dedicated server guide.

## Syntax

```text
-file start <stationname> [worldid] [difficulty] [startcondition] [startlocation]
```

Argument order matters:

1. `stationname`
2. `worldid`
3. `difficulty`
4. `startcondition`
5. `startlocation`

You cannot skip optional arguments in the middle. For example, if you want to
set a start location, you must also provide `worldid`, `difficulty`, and
`startcondition`.

## What Each Argument Means

### `stationname`

Required. This is the save/station name.

Use quotes if the name contains spaces:

```bat
-file start "My Friends Server" Mars2 Normal DefaultStart MarsSpawnCanyonOverlook ^
```

The current installer uses:

```text
FlipsieModPack
```

### `worldid`

Optional when loading an existing save, but required if the server needs to
create a new world.

Examples:

```text
Mars2
Lunar
Europa3
MimasHerschel
Vulcan
Venus
```

### `difficulty`

Optional. Defaults to `Normal` when omitted.

Known difficulty IDs:

- `Creative`
- `Easy`
- `Normal`
- `Stationeer`

### `startcondition`

Optional. Defaults to that world's default starting condition when omitted.

Start conditions define the initial start/crate scenario. Each world uses its
own ID names except Lunar and Mars, which share the generic names.

### `startlocation`

Optional. Defaults to `DefaultStartLocation` when omitted.

Start locations define where players spawn on a new world. The current script
uses a round-robin Mars spawn so new players can be distributed through the
available Mars start locations:

```text
MarsSpawnRoundRobin
```

The dedicated server guide also notes that random-location IDs may exist in the
form `<WorldID>Random`. Prefer the explicit location IDs or round-robin IDs
below unless you have verified a random ID on your current server build.

## Important Behavior

`-file start` first tries to load the latest save for `stationname`. If a save
already exists, the server loads it. It only creates a new world with the
specified `worldid`, `difficulty`, `startcondition`, and `startlocation` when it
cannot find an existing save for that station name.

That means changing `Mars2` to `Europa3`, for example, will not convert an
existing `FlipsieModPack` save into Europa. To start a new world, use a new
station name or move/delete the existing save.

## Current Script Configuration

```bat
-file start "FlipsieModPack" Mars2 Normal DefaultStartCommunity MarsSpawnRoundRobin ^
```

This means:

- Save/station name: `FlipsieModPack`
- World: Mars, using world ID `Mars2`
- Difficulty: `Normal`
- Start condition: `DefaultStartCommunity`
- Start location behavior: `MarsSpawnRoundRobin`

## World IDs, Start Conditions, And Start Locations

### Lunar

World ID:

```text
Lunar
```

Difficulties:

```text
Creative, Easy, Normal, Stationeer
```

Start conditions:

```text
DefaultStart
DefaultStartCommunity
Brutal
BrutalCommunity
```

Start locations:

```text
LunarSpawnCraterVesper
LunarSpawnMontesUmbrarum
LunarSpawnCraterNox
LunarSpawnMonsArcanus
LunarSpawnRoundRobin
```

Example:

```bat
-file start "MyLunarSave" Lunar Normal DefaultStart LunarSpawnCraterVesper ^
```

### Mars

World ID:

```text
Mars2
```

Difficulties:

```text
Creative, Easy, Normal, Stationeer
```

Start conditions:

```text
DefaultStart
DefaultStartCommunity
Brutal
BrutalCommunity
```

Start locations:

```text
MarsSpawnCanyonOverlook
MarsSpawnButchersFlat
MarsSpawnFindersCanyon
MarsSpawnHellasCrags
MarsSpawnDonutFlats
MarsSpawnRoundRobin
```

Example:

```bat
-file start "MyMarsSave" Mars2 Normal DefaultStartCommunity MarsSpawnRoundRobin ^
```

### Europa

World ID:

```text
Europa3
```

Difficulties:

```text
Creative, Easy, Normal, Stationeer
```

Start conditions:

```text
EuropaDefault
EuropaDefaultCommunity
EuropaBrutal
EuropaBrutalCommunity
```

Start locations:

```text
EuropaSpawnIcyBasin
EuropaSpawnGlacialChannel
EuropaSpawnBalgatanPass
EuropaSpawnFrigidHighlands
EuropaSpawnTyreValley
EuropaSpawnRoundRobin
```

Example:

```bat
-file start "MyEuropaSave" Europa3 Stationeer EuropaDefaultCommunity EuropaSpawnRoundRobin ^
```

### Mimas

World ID:

```text
MimasHerschel
```

Difficulties:

```text
Creative, Easy, Normal, Stationeer
```

Start conditions:

```text
MimasDefault
MimasDefaultCommunity
MimasBrutal
MimasBrutalCommunity
```

Start locations:

```text
MimasSpawnCentralMesa
MimasSpawnHarrietCrater
MimasSpawnCraterField
MimasSpawnDustBowl
MimasSpawnRoundRobin
```

Example:

```bat
-file start "MyMimasSave" MimasHerschel Normal MimasDefault MimasSpawnCentralMesa ^
```

### Vulcan

World ID:

```text
Vulcan
```

Difficulties:

```text
Creative, Easy, Normal, Stationeer
```

Start conditions:

```text
VulcanDefault
VulcanDefaultCommunity
VulcanBrutal
VulcanBrutalCommunity
```

Start locations:

```text
VulcanSpawnVestaValley
VulcanSpawnEtnasFury
VulcanSpawnIxionsDemise
VulcanSpawnTitusReach
VulcanSpawnRoundRobin
```

Example:

```bat
-file start "MyVulcanSave" Vulcan Stationeer VulcanBrutal VulcanSpawnTitusReach ^
```

### Venus

World ID:

```text
Venus
```

Difficulties:

```text
Creative, Easy, Normal, Stationeer
```

Start conditions:

```text
VenusDefault
VenusDefaultCommunity
VulcanBrutal
VulcanBrutalCommunity
```

Note: the dedicated server guide lists Venus brutal starts with the Vulcan
brutal IDs. This looks odd, but it is intentional in the current public guide.

Start locations:

```text
VenusSpawnGaiaValley
VenusSpawnDaisyValley
VenusSpawnFaithValley
VenusSpawnDuskValley
VenusSpawnRoundRobin
```

Example:

```bat
-file start "MyVenusSave" Venus Stationeer VenusDefaultCommunity VenusSpawnRoundRobin ^
```

## Tutorial World IDs

The dedicated server guide also lists these tutorial map IDs:

| Tutorial | World ID |
| --- | --- |
| Inventory Tutorial | `Tutorial1` |
| Connection Tutorial | `Tutorial2` |
| Atmospherics Tutorial | `Tutorial3` |
| Airlocks Tutorial | `Airlock` |
| Furnace Tutorial | `FurnaceBasics` |
| Manufacturing Tutorial | `Manufacturing` |

These are tutorial maps, not normal survival dedicated-server starts. Use them
only if you specifically want to test or host a tutorial map.

## Common Templates

### Load Or Create With World Only

Uses default difficulty, start condition, and start location for that world:

```bat
-file start "MySaveName" Mars2 ^
```

### Full Mars Community Start

```bat
-file start "MySaveName" Mars2 Normal DefaultStartCommunity MarsSpawnRoundRobin ^
```

### Hard Mars Start

```bat
-file start "MySaveName" Mars2 Stationeer Brutal MarsSpawnCanyonOverlook ^
```

### Easy Lunar Start

```bat
-file start "MySaveName" Lunar Easy DefaultStart LunarSpawnCraterVesper ^
```

### Stationeer Europa Community Start

```bat
-file start "MySaveName" Europa3 Stationeer EuropaDefaultCommunity EuropaSpawnRoundRobin ^
```

### Brutal Vulcan Start

```bat
-file start "MySaveName" Vulcan Stationeer VulcanBrutal VulcanSpawnRoundRobin ^
```

## Editing The Batch File

In `STATIONEERS_SERVER_v1.7.bat`, replace only this part unless you also want to
change ports, passwords, server visibility, or other `-settings` values:

```bat
-file start "FlipsieModPack" Mars2 Normal DefaultStartCommunity MarsSpawnRoundRobin ^
```

For example, to switch the default script to Europa:

```bat
-file start "FlipsieModPack_Europa" Europa3 Normal EuropaDefaultCommunity EuropaSpawnRoundRobin ^
```

Using a new station name, such as `FlipsieModPack_Europa`, avoids accidentally
loading the existing Mars save.

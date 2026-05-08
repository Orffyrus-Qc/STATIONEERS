# Stationeers Dedicated Server Installer

This folder contains a Windows installer and launcher for a modded Stationeers
dedicated server.

Files:

- `STATIONEERS_SERVER_v1.7.bat` - main installer and launcher.
- `stationeers_mod_installer.ps1` - helper script that downloads workshop mods,
  copies them into the server folder, writes `modconfig.xml`, and adds mod-name
  comments when Steam metadata is available.

## Requirements

- Windows.
- PowerShell.
- Internet access for SteamCMD, GitHub release downloads, and Steam Workshop
  metadata.
- Administrator approval through Windows UAC. The batch file checks this at
  startup and reopens itself as Administrator when needed.
- Enough disk space for SteamCMD, the Stationeers Dedicated Server, BepInEx,
  StationeersLaunchPad, and all configured Workshop mods.

## How To Run

1. Keep `STATIONEERS_SERVER_v1.7.bat` and `stationeers_mod_installer.ps1` in the
   same folder.
2. Edit the server password and auth secret in your local copy before running.
   The public GitHub version uses placeholders:
   - `CHANGE_ME_SERVER_PASSWORD`
   - `CHANGE_ME_SERVER_AUTH_SECRET`
3. Double-click `STATIONEERS_SERVER_v1.7.bat`.
4. Approve the Windows UAC prompt when it appears.
5. Let the installer complete. The server launches automatically at the end.

Do not commit real server passwords or auth secrets to the public repository.

## What The Batch Script Does

`STATIONEERS_SERVER_v1.7.bat` performs the full server setup from the folder it
is run from.

It starts by checking whether it is already running as Administrator. If it is
not elevated, it tells the user that admin rights are required, opens a Windows
UAC prompt, launches a new elevated copy of itself, and exits the original
non-admin instance.

After elevation, it creates and uses these local paths beside the batch file:

- `steamcmd/` - SteamCMD installation and Workshop download cache.
- `STATIONEERS_DEDICATED/` - Stationeers dedicated server installation.
- `STATIONEERS_DEDICATED/mods/` - local mod install folder.
- `STATIONEERS_DEDICATED/BepInEx/` - BepInEx install folder.
- `STATIONEERS_DEDICATED/BepInEx/plugins/` - StationeersLaunchPad plugin folder.

The main install flow has five stages:

1. Install SteamCMD if `steamcmd/steamcmd.exe` is missing.
2. Install or update the Stationeers Dedicated Server through SteamCMD using app
   ID `600760`.
3. Download and install the latest Windows x64 BepInEx release and the latest
   StationeersLaunchPad server release.
4. Download the configured Steam Workshop mods for Stationeers app ID `544550`
   and copy them into `STATIONEERS_DEDICATED/mods/Workshop_<mod id>/`.
5. Create `modconfig.xml`, run the PowerShell helper to rebuild it with mod-name
   comments, restore the read-only attribute, and launch the dedicated server.

## Workshop Mods

The installer currently downloads and installs these Workshop IDs:

- `3505115682`
- `3143388055`
- `3592775931`
- `3619985558`
- `3465059322`
- `3505169479`
- `3502709750`
- `3481457290`
- `3478434324`
- `3448887548`
- `3435393295`
- `3404482913`
- `3323200151`
- `3216721104`
- `3140312772`
- `3140312559`
- `3037993961`

The batch file and PowerShell helper both contain the same mod list. If you add
or remove mods, update both files so the SteamCMD download list, local mod copy
step, and generated `modconfig.xml` stay in sync.

## Generated Files

The installer may create or update these files:

- `steamcmd/steamcmd.exe`
- `steamcmd/steamapps/workshop/content/544550/<mod id>/`
- `STATIONEERS_DEDICATED/modconfig.xml`
- `STATIONEERS_DEDICATED/installed_mod_names.txt`
- `STATIONEERS_DEDICATED/BepInEx_installed_asset_name.txt`
- `STATIONEERS_DEDICATED/StationeersLaunchPad_installed_asset_name.txt`

`modconfig.xml` is intentionally set back to read-only after the helper script
finishes.

## Default Server Launch Settings

At the end of the install, the batch file launches
`rocketstation_DedicatedServer.exe` with these defaults:

- Save name: `FlipsieModPack`
- World: `Mars2`
- Difficulty: `Normal`
- Start condition: `DefaultStartCommunity`
- Spawn mode: `MarsSpawnRoundRobin`
- Bind address: `0.0.0.0`
- Game port: `27016`
- Update port: `27015`
- Max players: `10`
- Autosave: enabled
- Autopause: enabled
- Save interval: `300`
- UPNP: disabled
- Steam P2P: disabled

Adjust the launch settings at the bottom of `STATIONEERS_SERVER_v1.7.bat` before
running if you want a different world, save, port, visibility, player count, or
server name.

For the possible `-file start` world, difficulty, start condition, and spawn
location values, see `FILE_START_CONFIGS.md`.

## Troubleshooting

- If SteamCMD download or update fails, rerun the batch file. The server update
  step retries up to five times automatically.
- If BepInEx or StationeersLaunchPad cannot be found, check GitHub release
  availability and your network connection.
- If Workshop mods are missing, make sure SteamCMD can download Workshop content
  for app ID `544550`.
- If the server executable is missing, the Stationeers Dedicated Server install
  did not complete successfully.
- If Windows blocks file writes or modconfig changes, confirm that the elevated
  UAC prompt was approved.

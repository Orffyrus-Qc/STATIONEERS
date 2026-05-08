@echo off
setlocal EnableExtensions EnableDelayedExpansion
title STATIONEERS FULL INSTALLER

goto :MAIN


REM =========================================================
REM FUNCTION: InstallMod
REM =========================================================
:InstallMod
set "MOD_ID=%~1"
set "SRC_DIR=%WORKSHOP_DIR%\%MOD_ID%"
set "DST_DIR=%MODS_DIR%\Workshop_%MOD_ID%"

if not exist "%SRC_DIR%" (
    echo [WARNING] Missing mod %MOD_ID%
    set "MISSING_ANY=1"
    exit /b 0
)

echo [OK] Found mod %MOD_ID%

if exist "%DST_DIR%" (
    rmdir /s /q "%DST_DIR%"
)

robocopy "%SRC_DIR%" "%DST_DIR%" /E /R:2 /W:1 /NFL /NDL /NJH /NJS /NC /NS >nul
if %ERRORLEVEL% GEQ 8 (
    echo [ERROR] Failed to copy mod %MOD_ID%
    exit /b 1
)

set "COPIED_ANY=1"
echo [OK] Installed Workshop_%MOD_ID%
exit /b 0


REM =========================================================
REM FUNCTION: WriteLockedModConfig
REM =========================================================
:WriteLockedModConfig
if exist "%SERVER_MODCONFIG%" (
    attrib -R "%SERVER_MODCONFIG%" >nul 2>&1
    del /f /q "%SERVER_MODCONFIG%" >nul 2>&1
)

(
    echo ^<?xml version="1.0"?^>
    echo ^<ModConfig xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"^>
    echo   ^<Core Enabled="true"^>
    echo     ^<Path /^>
    echo   ^</Core^>
    echo   ^<Local Enabled="true"^>
    echo     ^<Path Value="./mods/Workshop_3505115682" /^>
    echo   ^</Local^>
    echo   ^<Local Enabled="true"^>
    echo     ^<Path Value="./mods/Workshop_3143388055" /^>
    echo   ^</Local^>
    echo   ^<Local Enabled="true"^>
    echo     ^<Path Value="./mods/Workshop_3592775931" /^>
    echo   ^</Local^>
    echo   ^<Local Enabled="true"^>
    echo     ^<Path Value="./mods/Workshop_3619985558" /^>
    echo   ^</Local^>
    echo   ^<Local Enabled="true"^>
    echo     ^<Path Value="./mods/Workshop_3465059322" /^>
    echo   ^</Local^>
    echo   ^<Local Enabled="true"^>
    echo     ^<Path Value="./mods/Workshop_3505169479" /^>
    echo   ^</Local^>
    echo   ^<Local Enabled="true"^>
    echo     ^<Path Value="./mods/Workshop_3502709750" /^>
    echo   ^</Local^>
    echo   ^<Local Enabled="true"^>
    echo     ^<Path Value="./mods/Workshop_3481457290" /^>
    echo   ^</Local^>
    echo   ^<Local Enabled="true"^>
    echo     ^<Path Value="./mods/Workshop_3478434324" /^>
    echo   ^</Local^>
    echo   ^<Local Enabled="true"^>
    echo     ^<Path Value="./mods/Workshop_3448887548" /^>
    echo   ^</Local^>
    echo   ^<Local Enabled="true"^>
    echo     ^<Path Value="./mods/Workshop_3435393295" /^>
    echo   ^</Local^>
    echo   ^<Local Enabled="true"^>
    echo     ^<Path Value="./mods/Workshop_3404482913" /^>
    echo   ^</Local^>
    echo   ^<Local Enabled="true"^>
    echo     ^<Path Value="./mods/Workshop_3323200151" /^>
    echo   ^</Local^>
    echo   ^<Local Enabled="true"^>
    echo     ^<Path Value="./mods/Workshop_3216721104" /^>
    echo   ^</Local^>
    echo   ^<Local Enabled="true"^>
    echo     ^<Path Value="./mods/Workshop_3140312772" /^>
    echo   ^</Local^>
    echo   ^<Local Enabled="true"^>
    echo     ^<Path Value="./mods/Workshop_3140312559" /^>
    echo   ^</Local^>
    echo   ^<Local Enabled="true"^>
    echo     ^<Path Value="./mods/Workshop_3037993961" /^>
    echo   ^</Local^>
    echo ^</ModConfig^>
) > "%SERVER_MODCONFIG%"

if not exist "%SERVER_MODCONFIG%" exit /b 1

attrib +R "%SERVER_MODCONFIG%" >nul 2>&1
exit /b 0


REM =========================================================
REM MAIN
REM =========================================================
:MAIN
echo.
echo ================================================
echo   STATIONEERS DEDICATED SERVER FULL INSTALLER
echo ================================================
echo.
pause

set "BASE_DIR=%~dp0"
cd /d "%BASE_DIR%"

set "SERVER_APP_ID=600760"
set "WORKSHOP_APP_ID=544550"

set "SERVER_ROOT=%BASE_DIR%STATIONEERS_DEDICATED"
set "MODS_DIR=%SERVER_ROOT%\mods"
set "BEPINEX_FOLDER=%SERVER_ROOT%\BepInEx"
set "PLUGIN_FOLDER=%BEPINEX_FOLDER%\plugins"
set "SERVER_MODCONFIG=%SERVER_ROOT%\modconfig.xml"

set "BEPINEX_VERSION_FILE=%SERVER_ROOT%\BepInEx_installed_asset_name.txt"
set "SLP_VERSION_FILE=%SERVER_ROOT%\StationeersLaunchPad_installed_asset_name.txt"

set "STEAMCMD_DIR=%BASE_DIR%steamcmd"
set "STEAMCMD_EXE=%STEAMCMD_DIR%\steamcmd.exe"
set "STEAMCMD_ZIP=%TEMP%\steamcmd.zip"
set "STEAMCMD_SCRIPT=%TEMP%\stationeers_mods.txt"
set "WORKSHOP_DIR=%STEAMCMD_DIR%\steamapps\workshop\content\%WORKSHOP_APP_ID%"

set "MAX_ATTEMPTS=5"
set "attempt=1"
set "COPIED_ANY=0"
set "MISSING_ANY=0"

if not exist "%STEAMCMD_DIR%" mkdir "%STEAMCMD_DIR%"
if not exist "%SERVER_ROOT%" mkdir "%SERVER_ROOT%"
if not exist "%MODS_DIR%" mkdir "%MODS_DIR%"

echo Base folder   : %BASE_DIR%
echo Server folder : %SERVER_ROOT%
echo SteamCMD dir  : %STEAMCMD_DIR%
echo.

echo ================================================
echo [1/5] Installing SteamCMD if needed
echo ================================================
echo.

if exist "%STEAMCMD_EXE%" (
    echo [OK] SteamCMD already installed.
) else (
    echo [INFO] Downloading SteamCMD...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Invoke-WebRequest -UseBasicParsing -Uri 'https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip' -OutFile '%STEAMCMD_ZIP%'"
    if errorlevel 1 (
        echo [ERROR] Failed to download SteamCMD zip.
        pause
        exit /b 1
    )

    echo [INFO] Extracting SteamCMD...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Expand-Archive -Path '%STEAMCMD_ZIP%' -DestinationPath '%STEAMCMD_DIR%' -Force"
    if errorlevel 1 (
        echo [ERROR] Failed to extract SteamCMD.
        pause
        exit /b 1
    )

    if not exist "%STEAMCMD_EXE%" (
        echo [ERROR] steamcmd.exe not found after extraction.
        pause
        exit /b 1
    )

    del "%STEAMCMD_ZIP%" >nul 2>&1
    echo [OK] SteamCMD installed.
)

echo.
echo ================================================
echo [2/5] Installing or updating Stationeers server
echo ================================================
echo.

:UPDATE_LOOP
echo Attempt %attempt% of %MAX_ATTEMPTS%...

"%STEAMCMD_EXE%" +force_install_dir "%SERVER_ROOT%" +login anonymous +app_update %SERVER_APP_ID% validate +quit

if errorlevel 1 (
    echo [WARNING] SteamCMD returned an error on attempt %attempt%.
    if %attempt% LSS %MAX_ATTEMPTS% (
        timeout /t 3 >nul
        set /a attempt+=1
        goto UPDATE_LOOP
    ) else (
        echo [ERROR] Server update failed after %MAX_ATTEMPTS% attempts.
        pause
        exit /b 1
    )
)

echo [OK] Stationeers Dedicated Server installed or updated.
echo.

echo ================================================
echo [3/5] Installing or updating BepInEx and LaunchPad
echo ================================================
echo.

echo [3.1] Checking latest BepInEx...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$response = Invoke-RestMethod -Uri 'https://api.github.com/repos/BepInEx/BepInEx/releases/latest' -UseBasicParsing; $asset = $response.assets | Where-Object { $_.name -like '*win_x64*.zip' } | Select-Object -First 1; if ($asset) { $asset.name + '|' + $asset.browser_download_url } else { 'ERROR|ERROR' }" > "%TEMP%\temp_bepinex_info.txt"

set "BE_INFO="
set /p BE_INFO=<"%TEMP%\temp_bepinex_info.txt"
del "%TEMP%\temp_bepinex_info.txt" >nul 2>&1

for /f "tokens=1,2 delims=|" %%A in ("%BE_INFO%") do (
    set "BE_NAME=%%A"
    set "BE_URL=%%B"
)

if "%BE_URL%"=="ERROR" (
    echo [ERROR] Could not find BepInEx win_x64 asset.
    pause
    exit /b 1
)

set "INSTALLED_BE_NAME="
if exist "%BEPINEX_VERSION_FILE%" set /p INSTALLED_BE_NAME=<"%BEPINEX_VERSION_FILE%"

set "SKIP_BEPINEX=0"
if exist "%BEPINEX_FOLDER%" if /I "%INSTALLED_BE_NAME%"=="%BE_NAME%" set "SKIP_BEPINEX=1"

if "%SKIP_BEPINEX%"=="1" (
    echo [OK] BepInEx already up to date.
) else (
    echo [INFO] Downloading BepInEx...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Invoke-WebRequest -Uri '%BE_URL%' -OutFile 'BepInEx.zip' -UseBasicParsing"
    if errorlevel 1 (
        echo [ERROR] Failed to download BepInEx.
        pause
        exit /b 1
    )

    echo [INFO] Extracting BepInEx...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Expand-Archive -Path 'BepInEx.zip' -DestinationPath '%SERVER_ROOT%' -Force"
    if errorlevel 1 (
        echo [ERROR] Failed to extract BepInEx.
        pause
        exit /b 1
    )

    del "BepInEx.zip" >nul 2>&1
    > "%BEPINEX_VERSION_FILE%" echo %BE_NAME%
    echo [OK] BepInEx installed.
)

echo.
echo [3.2] Checking latest StationeersLaunchPad...

if not exist "%PLUGIN_FOLDER%" mkdir "%PLUGIN_FOLDER%"

powershell -NoProfile -ExecutionPolicy Bypass -Command "$response = Invoke-RestMethod -Uri 'https://api.github.com/repos/StationeersLaunchPad/StationeersLaunchPad/releases/latest' -UseBasicParsing; $asset = $response.assets | Where-Object { $_.name -like '*server*.zip' } | Select-Object -First 1; if ($asset) { $asset.name + '|' + $asset.browser_download_url } else { 'ERROR|ERROR' }" > "%TEMP%\temp_slp_info.txt"

set "SLP_INFO="
set /p SLP_INFO=<"%TEMP%\temp_slp_info.txt"
del "%TEMP%\temp_slp_info.txt" >nul 2>&1

for /f "tokens=1,2 delims=|" %%A in ("%SLP_INFO%") do (
    set "SLP_NAME=%%A"
    set "SLP_URL=%%B"
)

if "%SLP_URL%"=="ERROR" (
    echo [ERROR] Could not find StationeersLaunchPad server asset.
    pause
    exit /b 1
)

set "INSTALLED_SLP_NAME="
if exist "%SLP_VERSION_FILE%" set /p INSTALLED_SLP_NAME=<"%SLP_VERSION_FILE%"

set "SKIP_SLP=0"
if exist "%PLUGIN_FOLDER%" if /I "%INSTALLED_SLP_NAME%"=="%SLP_NAME%" set "SKIP_SLP=1"

if "%SKIP_SLP%"=="1" (
    echo [OK] StationeersLaunchPad already up to date.
) else (
    echo [INFO] Downloading StationeersLaunchPad...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Invoke-WebRequest -Uri '%SLP_URL%' -OutFile 'StationeersLaunchPad.zip' -UseBasicParsing"
    if errorlevel 1 (
        echo [ERROR] Failed to download StationeersLaunchPad.
        pause
        exit /b 1
    )

    echo [INFO] Extracting StationeersLaunchPad...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Expand-Archive -Path 'StationeersLaunchPad.zip' -DestinationPath '%PLUGIN_FOLDER%' -Force"
    if errorlevel 1 (
        echo [ERROR] Failed to extract StationeersLaunchPad.
        pause
        exit /b 1
    )

    del "StationeersLaunchPad.zip" >nul 2>&1
    > "%SLP_VERSION_FILE%" echo %SLP_NAME%
    echo [OK] StationeersLaunchPad installed.
)

echo.
echo ================================================
echo [4/5] Downloading workshop mods
echo ================================================
echo.

(
    echo @ShutdownOnFailedCommand 0
    echo @NoPromptForPassword 1
    echo force_install_dir "%STEAMCMD_DIR%"
    echo login anonymous
	echo workshop_download_item %WORKSHOP_APP_ID% 3505115682
    echo workshop_download_item %WORKSHOP_APP_ID% 3143388055
	echo workshop_download_item %WORKSHOP_APP_ID% 3592775931
    echo workshop_download_item %WORKSHOP_APP_ID% 3619985558
    echo workshop_download_item %WORKSHOP_APP_ID% 3465059322
    echo workshop_download_item %WORKSHOP_APP_ID% 3505169479
    echo workshop_download_item %WORKSHOP_APP_ID% 3502709750
    echo workshop_download_item %WORKSHOP_APP_ID% 3481457290
    echo workshop_download_item %WORKSHOP_APP_ID% 3478434324
    echo workshop_download_item %WORKSHOP_APP_ID% 3448887548
    echo workshop_download_item %WORKSHOP_APP_ID% 3435393295
    echo workshop_download_item %WORKSHOP_APP_ID% 3404482913
    echo workshop_download_item %WORKSHOP_APP_ID% 3323200151
    echo workshop_download_item %WORKSHOP_APP_ID% 3216721104
    echo workshop_download_item %WORKSHOP_APP_ID% 3140312772
    echo workshop_download_item %WORKSHOP_APP_ID% 3140312559
    echo workshop_download_item %WORKSHOP_APP_ID% 3037993961
    echo quit
) > "%STEAMCMD_SCRIPT%"

"%STEAMCMD_EXE%" +runscript "%STEAMCMD_SCRIPT%"

if not exist "%WORKSHOP_DIR%" (
    echo [ERROR] Workshop folder not found:
    echo %WORKSHOP_DIR%
    pause
    exit /b 1
)

call :InstallMod 3505115682
call :InstallMod 3143388055
call :InstallMod 3592775931
call :InstallMod 3619985558
call :InstallMod 3465059322
call :InstallMod 3505169479
call :InstallMod 3502709750
call :InstallMod 3481457290
call :InstallMod 3478434324
call :InstallMod 3448887548
call :InstallMod 3435393295
call :InstallMod 3404482913
call :InstallMod 3323200151
call :InstallMod 3216721104
call :InstallMod 3140312772
call :InstallMod 3140312559
call :InstallMod 3037993961

echo.
echo ================================================
echo [5/5] Creating locked modconfig.xml and launching
echo ================================================
echo.

call :WriteLockedModConfig
if errorlevel 1 (
    echo [ERROR] Failed to create modconfig.xml
    pause
    exit /b 1
)

echo [OK] Created modconfig.xml:
echo %SERVER_MODCONFIG%
echo.
type "%SERVER_MODCONFIG%"
echo.

REM ------------------------------------------------------------------------------------------
REM --  calling ps1 script to comment mod into modconfig.xml and managing read only access  --
REM ------------------------------------------------------------------------------------------
setlocal
cd /d "%~dp0"

set "MODCONFIG=.\STATIONEERS_DEDICATED\modconfig.xml"

echo [INFO] Removing read-only attribute on modconfig.xml if present...
if exist "%MODCONFIG%" (
    attrib -r "%MODCONFIG%"
)

echo [INFO] Running PowerShell installer...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0stationeers_mod_installer.ps1"

set "EXITCODE=%errorlevel%"
echo.
echo [INFO] Installer exit code: %EXITCODE%

if NOT "%EXITCODE%"=="0" (
    echo [ERROR] Installer failed. Skipping read-only restore.
    pause
    exit /b %EXITCODE%
)

echo [INFO] Setting modconfig.xml back to read-only...
if exist "%MODCONFIG%" (
    attrib +r "%MODCONFIG%"
)

echo [INFO] Done.
REM ---------------------------------------------------------------------------------------
REM ---------------------------------------------------------------------------------------

cd /d "%SERVER_ROOT%"

if not exist "rocketstation_DedicatedServer.exe" (
    echo [ERROR] rocketstation_DedicatedServer.exe not found.
    pause
    exit /b 1
)

rocketstation_DedicatedServer.exe -batchmode -nographics ^
-settingspath "settings.xml" ^
-file start "FlipsieModPack" Mars2 Normal DefaultStartCommunity MarsSpawnRoundRobin ^
-settings ^
StartLocalHost true ^
LocalIpAddress 0.0.0.0 ^
GamePort 27016 ^
UpdatePort 27015 ^
ServerName "Sabnanic's and friends Server" ^
ServerVisible true ^
ServerMaxPlayers 10 ^
AutoSave true ^
AutoPauseServer true ^
SaveInterval 300 ^
ServerPassword "CHANGE_ME_SERVER_PASSWORD" ^
ServerAuthSecret "CHANGE_ME_SERVER_AUTH_SECRET" ^
UPNPEnabled false ^
UseSteamP2P false

echo.
echo DONE
pause
exit /b 0
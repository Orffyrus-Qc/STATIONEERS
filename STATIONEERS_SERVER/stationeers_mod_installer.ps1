$ErrorActionPreference = "Stop"

# ===== PATHS (RELATIVE) =====
$BaseDir = Split-Path -Parent $MyInvocation.MyCommand.Path

$SteamCmd = Join-Path $BaseDir "steamcmd\steamcmd.exe"
$ServerRoot = Join-Path $BaseDir "STATIONEERS_DEDICATED"
$Dedicated = Join-Path $ServerRoot ""
$Mods = Join-Path $Dedicated "mods"
$ModConfig = Join-Path $Dedicated "modconfig.xml"
$NamesFile = Join-Path $Dedicated "installed_mod_names.txt"

$AppId = "544550"

# ===== MOD LIST =====
$ModIds = @(
"3505115682","3143388055","3592775931","3619985558","3465059322",
"3505169479","3502709750","3481457290","3478434324",
"3448887548","3435393295","3404482913","3323200151",
"3216721104","3140312772","3140312559","3037993961"
)

# ===== CHECK =====
if (!(Test-Path $SteamCmd)) {
    throw "steamcmd.exe not found: $SteamCmd"
}

New-Item -ItemType Directory -Force -Path $Mods | Out-Null

$SteamRoot = Split-Path $SteamCmd -Parent

# ===== DOWNLOAD =====
Write-Host "Downloading mods..."

$script = @(
"@ShutdownOnFailedCommand 1",
"@NoPromptForPassword 1",
"force_install_dir `"$SteamRoot`"",
"login anonymous"
)

foreach ($id in $ModIds) {
    $script += "workshop_download_item $AppId $id"
}

$script += "quit"

$tmp = Join-Path $env:TEMP "steamcmd_script.txt"
$script | Set-Content $tmp -Encoding ASCII

& $SteamCmd +runscript $tmp

# ===== COPY =====
Write-Host "Installing mods..."

foreach ($id in $ModIds) {
    $src = Join-Path $SteamRoot "steamapps\workshop\content\$AppId\$id"
    $dst = Join-Path $Mods "Workshop_$id"

    if (!(Test-Path $src)) {
        throw "Missing mod $id"
    }

    Remove-Item $dst -Recurse -Force -ErrorAction SilentlyContinue
    Copy-Item $src $dst -Recurse -Force
}

# ===== CREATE MODCONFIG =====
Write-Host "Creating modconfig.xml..."

$xml = New-Object System.Text.StringBuilder

$xml.AppendLine('<?xml version="1.0"?>') | Out-Null
$xml.AppendLine('<ModConfig xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">') | Out-Null
$xml.AppendLine('  <Core Enabled="true"><Path /></Core>') | Out-Null

foreach ($id in $ModIds) {
    $xml.AppendLine("  <Local Enabled=""true"">") | Out-Null
    $xml.AppendLine("    <Path Value=""./mods/Workshop_$id"" />") | Out-Null
    $xml.AppendLine("  </Local>") | Out-Null
}

$xml.AppendLine('</ModConfig>') | Out-Null

[IO.File]::WriteAllText($ModConfig, $xml.ToString(), (New-Object Text.UTF8Encoding($false)))

# ===== WORKSHOP METADATA =====
Write-Host "Fetching mod names..."

$body = @{ itemcount = $ModIds.Count }
for ($i=0;$i -lt $ModIds.Count;$i++) {
    $body["publishedfileids[$i]"] = $ModIds[$i]
}

$map = @{}

try {
    $resp = Invoke-RestMethod -Uri "https://api.steampowered.com/ISteamRemoteStorage/GetPublishedFileDetails/v1/" -Method Post -Body $body

    foreach ($item in $resp.response.publishedfiledetails) {
        $map[$item.publishedfileid] = $item.title
    }
} catch {
    Write-Host "WARNING: Could not fetch names"
}

# ===== ADD COMMENTS =====
[xml]$doc = Get-Content $ModConfig

foreach ($node in @($doc.ModConfig.Local)) {
    $id = ($node.Path.Value -replace '.*_(\d+)', '$1')

    $name = if ($map.ContainsKey($id)) { $map[$id] } else { "UNKNOWN" }

    $comment = $doc.CreateComment(" [$id] $name ")
    $doc.ModConfig.InsertBefore($comment, $node) | Out-Null
}

$doc.Save($ModConfig)

# ===== SAVE LIST =====
$lines = foreach ($id in $ModIds) {
    "$id`t$($map[$id])"
}

$lines | Set-Content $NamesFile -Encoding UTF8

Write-Host ""
Write-Host "SUCCESS"
Write-Host "modconfig.xml created"

# -------------------------------------------------------------
# install-cli.ps1 - Registriert den globalen Terminal-Befehl 'uniplugin' (Windows).
# Aufruf (einmalig, im geklonten Devteam-vibecodes):
#   powershell -ExecutionPolicy Bypass -File .\install-cli.ps1
# Danach in einem NEUEN Terminal:  uniplugin update
# -------------------------------------------------------------
$ErrorActionPreference = "Stop"

$repo = $PSScriptRoot
if (-not $repo -and $MyInvocation.MyCommand.Path) { $repo = Split-Path -Parent $MyInvocation.MyCommand.Path }
if (-not $repo) { $repo = (Get-Location).Path }

if (-not (Test-Path (Join-Path $repo "uniplugin.ps1"))) {
    Write-Host "FEHLER: uniplugin.ps1 nicht gefunden in $repo."
    Write-Host "Bitte im geklonten Ordner 'Devteam-vibecodes' ausfuehren."
    exit 1
}

# bin-Verzeichnis auf User-Ebene (kein Admin noetig)
$bin = Join-Path $env:USERPROFILE ".local\bin"
New-Item -ItemType Directory -Force -Path $bin | Out-Null

# Shim 'uniplugin.cmd' -> ruft die Repo-uniplugin.ps1 und reicht alle Argumente weiter (%*)
$shim = Join-Path $bin "uniplugin.cmd"
$content = "@echo off`r`npowershell -ExecutionPolicy Bypass -File `"$repo\uniplugin.ps1`" %*`r`n"
[System.IO.File]::WriteAllText($shim, $content, (New-Object System.Text.UTF8Encoding($false)))
Write-Host "Befehl angelegt: $shim  ->  $repo\uniplugin.ps1"

# bin auf den User-PATH legen (persistent), falls noch nicht drin
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
if (-not $userPath) { $userPath = "" }
if ($userPath -notlike "*$bin*") {
    $newPath = ($userPath.TrimEnd(';') + ";" + $bin).TrimStart(';')
    [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
    Write-Host "PATH (User) ergaenzt um: $bin"
    Write-Host "WICHTIG: ein NEUES Terminal oeffnen, damit der PATH greift."
} else {
    Write-Host "PATH enthaelt $bin bereits."
}

Write-Host ""
Write-Host "Fertig. In einem NEUEN Terminal testen:"
Write-Host "  uniplugin version"
Write-Host "  uniplugin update"

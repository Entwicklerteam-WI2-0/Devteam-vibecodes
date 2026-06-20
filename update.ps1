# -------------------------------------------------------------
# update.ps1 - Team-OS auf den neuesten Stand bringen (Windows / PowerShell)
# Aufruf:  powershell -ExecutionPolicy Bypass -File update.ps1
# Macht:   git pull (neuester Stand) + setup.ps1 erneut ausfuehren
#          (Anweisung/Skills/Commands global in ~/.claude auffrischen).
#          Zeigt Version  alt -> neu.
# -------------------------------------------------------------
$ErrorActionPreference = "Stop"

$scriptDir = $PSScriptRoot
if (-not $scriptDir -and $MyInvocation.MyCommand.Path) { $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path }
if (-not $scriptDir) { $scriptDir = (Get-Location).Path }
Set-Location -Path $scriptDir

if (-not (Test-Path (Join-Path $scriptDir ".git"))) {
    Write-Host "FEHLER: Das ist kein Git-Repo ($scriptDir)."
    Write-Host "Bitte aus dem geklonten Ordner 'Devteam-vibecodes' starten:"
    Write-Host "  powershell -ExecutionPolicy Bypass -File .\update.ps1"
    exit 1
}

$verFile = Join-Path $scriptDir "VERSION"
$oldVer = if (Test-Path $verFile) { (Get-Content $verFile -Raw).Trim() } else { "unbekannt" }
Write-Host "Team-OS Update startet in: $scriptDir"
Write-Host "Aktuelle Version: $oldVer"

Write-Host "Hole neuesten Stand (git pull) ..."
git -c pull.rebase=false pull --autostash origin master

$newVer = if (Test-Path $verFile) { (Get-Content $verFile -Raw).Trim() } else { "unbekannt" }
Write-Host "Neue Version: $newVer"

Write-Host "Frische Anweisung/Skills/Commands auf (setup.ps1) ..."
& powershell -ExecutionPolicy Bypass -File (Join-Path $scriptDir "setup.ps1")

Write-Host ""
Write-Host "Update fertig:  $oldVer -> $newVer"
Write-Host "Hinweis: Claude Code neu starten, damit neue Skills/Commands geladen werden."
Write-Host "Kimi/Codex-Nutzer: zusaetzlich das jeweilige Setup erneut ausfuehren (setup-kimi.ps1 / setup-codex.ps1)."

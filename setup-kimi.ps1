# -------------------------------------------------------------
# setup-kimi.ps1 - Team-Skills fuer Kimi Code CLI installieren (Windows)
# Aufruf:  powershell -ExecutionPolicy Bypass -File .\setup-kimi.ps1
# Macht:   kopiert .claude/skills/*/SKILL.md -> ~/.kimi/skills/
#          Kimi Code liest diesen Pfad nativ (gleiches SKILL.md-Format).
# -------------------------------------------------------------
$ErrorActionPreference = "Stop"

# Skript-/Repo-Verzeichnis robust ermitteln (auch bei leerem $PSScriptRoot)
$scriptDir = $PSScriptRoot
if (-not $scriptDir -and $MyInvocation.MyCommand.Path) {
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
}
if (-not $scriptDir) { $scriptDir = (Get-Location).Path }

$src = Join-Path $scriptDir ".claude/skills"
if (-not (Test-Path $src)) {
    $alt = Join-Path (Get-Location).Path ".claude/skills"
    if (Test-Path $alt) { $scriptDir = (Get-Location).Path; $src = $alt }
}

if (-not (Test-Path $src)) {
    Write-Host "FEHLER: .claude/skills/ nicht gefunden (gesucht in: $scriptDir)."
    Write-Host "Bitte im geklonten Ordner 'Devteam-vibecodes' ausfuehren (ggf. vorher 'git pull')."
    exit 1
}

$dest = Join-Path $env:USERPROFILE ".kimi-code/skills"
New-Item -ItemType Directory -Force -Path $dest | Out-Null
Write-Host "Installiere Team-Skills fuer Kimi Code -> $dest"

$count = 0
Get-ChildItem -Path $src -Directory | ForEach-Object {
    $skillFile = Join-Path $_.FullName "SKILL.md"
    if (Test-Path $skillFile) {
        $target = Join-Path $dest $_.Name
        New-Item -ItemType Directory -Force -Path $target | Out-Null
        Copy-Item $skillFile (Join-Path $target "SKILL.md") -Force
        Write-Host "  + $($_.Name)"
        $count++
    }
}

Write-Host ""
Write-Host "Fertig: $count Skills installiert in $dest"
Write-Host "Kimi Code findet sie automatisch (Brand-Pfad ~/.kimi-code/skills/)."
Write-Host "Aufruf im Chat z.B.:  /skill:tdd-workflow"
Write-Host ""
Write-Host "Hinweis: Globale Anweisung (claude-sync.md), Hooks und die Slash-Commands"
Write-Host "         /start und /setup nutzen in Kimi ein anderes Format und folgen"
Write-Host "         als spezialisierte Iteration (siehe erinnerung/stand.md)."

# -------------------------------------------------------------
# setup.ps1 - Einmal-Setup Team-OS (Windows / PowerShell)
# Aufruf:  powershell -ExecutionPolicy Bypass -File setup.ps1
# Macht:   geteilte Agent-Config claude-sync.md -> globale ~/.claude/CLAUDE.md
# -------------------------------------------------------------
$ErrorActionPreference = "Stop"

# Skript-Verzeichnis robust ermitteln (auch wenn $PSScriptRoot leer ist,
# z.B. bei Copy-Paste in die Konsole statt Start via -File).
$scriptDir = $PSScriptRoot
if (-not $scriptDir -and $MyInvocation.MyCommand.Path) {
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
}
if (-not $scriptDir) { $scriptDir = (Get-Location).Path }

# claude-sync.md neben dem Skript suchen; sonst im aktuellen Verzeichnis.
$source = Join-Path $scriptDir "claude-sync.md"
if (-not (Test-Path $source)) {
    $alt = Join-Path (Get-Location).Path "claude-sync.md"
    if (Test-Path $alt) { $scriptDir = (Get-Location).Path; $source = $alt }
}

if (-not (Test-Path $source)) {
    Write-Host "FEHLER: claude-sync.md nicht gefunden (gesucht in: $scriptDir)."
    Write-Host "Bitte pruefen:"
    Write-Host "  1) Du bist im geklonten Ordner 'Devteam-vibecodes'."
    Write-Host "  2) 'git pull' ausgefuehrt (Datei muss im Repo liegen)."
    Write-Host "  3) Start als Datei:  powershell -ExecutionPolicy Bypass -File .\setup.ps1"
    Write-Host "     (NICHT den Skript-Inhalt in die Konsole kopieren.)"
    exit 1
}

Set-Location -Path $scriptDir
Write-Host "Team-OS-Setup startet in: $scriptDir"

$claudeDir = Join-Path $env:USERPROFILE ".claude"
$target    = Join-Path $claudeDir "CLAUDE.md"

# 1) ~/.claude sicherstellen
if (-not (Test-Path $claudeDir)) {
    New-Item -ItemType Directory -Path $claudeDir | Out-Null
    Write-Host "Verzeichnis erstellt: $claudeDir"
}

# 2) Geteilte Agent-Config global aktivieren (claude-sync.md -> ~/.claude/CLAUDE.md)
if (-not (Test-Path $target)) {
    Copy-Item $source $target
    Write-Host "Globale CLAUDE.md aus claude-sync.md erstellt: $target"
} else {
    $backup = "$target.bak"
    Copy-Item $target $backup -Force
    Write-Host "HINWEIS: ~/.claude/CLAUDE.md existiert bereits - wird NICHT ueberschrieben."
    Write-Host "  Backup angelegt: $backup"
    Write-Host "  Team-Config uebernehmen/aktualisieren? -> Copy-Item `"$source`" `"$target`""
}

Write-Host ""
Write-Host "Fertig. Naechste Schritte:"
Write-Host "  1) Ordner in VS Code oeffnen"
Write-Host "  2) 'claude' im integrierten Terminal starten"
Write-Host "  3) Projekt einmal 'vertrauen', dann '/start' tippen"
Write-Host "  4) Fuer die Produktcode-Arbeit zusaetzlich das Arbeitsrepo 'Alarmsystem-Dev' klonen + dessen Setup ausfuehren."

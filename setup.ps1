# ──────────────────────────────────────────────────────────────
# setup.ps1 — Einmal-Setup Team-OS (Windows / PowerShell)
# Aufruf:  powershell -ExecutionPolicy Bypass -File setup.ps1
# Macht:   geteilte Agent-Config claude-sync.md -> globale ~/.claude/CLAUDE.md
# ──────────────────────────────────────────────────────────────
$ErrorActionPreference = "Stop"
Set-Location -Path $PSScriptRoot
Write-Host "Team-OS-Setup startet in: $(Get-Location)"

$source    = Join-Path $PSScriptRoot "claude-sync.md"
$claudeDir = Join-Path $env:USERPROFILE ".claude"
$target    = Join-Path $claudeDir "CLAUDE.md"

if (-not (Test-Path $source)) {
    throw "claude-sync.md nicht gefunden in $PSScriptRoot — falscher Ordner?"
}

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

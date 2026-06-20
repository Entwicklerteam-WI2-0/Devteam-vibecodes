# -------------------------------------------------------------
# setup.ps1 - Einmal-Setup Team-OS (Windows / PowerShell)
# Aufruf:  powershell -ExecutionPolicy Bypass -File setup.ps1
# Macht (globale ~/.claude/CLAUDE.md, 4 Faelle):
#   - fehlt          -> claude-sync.md WIRD die globale CLAUDE.md (voll, inline)
#   - hat Import     -> nur ~/.claude/team-os-g2.md auffrischen
#   - Team-Vollkopie -> CLAUDE.md in-place aktualisieren (Backup)
#   - persoenlich    -> team-os-g2.md anlegen + additiver @import-Block (Backup)
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
$teamFile  = Join-Path $claudeDir "team-os-g2.md"
$import    = "@~/.claude/team-os-g2.md"
$begin     = "<!-- TEAM-OS-G2 BEGIN - verwaltet von setup, nicht editieren -->"
$end       = "<!-- TEAM-OS-G2 END -->"

# 1) ~/.claude sicherstellen
if (-not (Test-Path $claudeDir)) {
    New-Item -ItemType Directory -Path $claudeDir | Out-Null
    Write-Host "Verzeichnis erstellt: $claudeDir"
}

# UTF-8 ohne BOM fuer generierte/angehaengte Dateien
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$block = (@($begin, $import, $end) -join "`n") + "`n"

# 2) Globale CLAUDE.md gemaess 4 Faellen behandeln (idempotent):
#    Fall 1  fehlt           -> claude-sync.md WIRD die CLAUDE.md (voll, inline)
#    Fall 2  hat Import       -> nur team-os-g2.md auffrischen (bereits erweitert)
#    Fall 3  Team-Vollkopie   -> CLAUDE.md in-place aktualisieren (inline-Mitglied, Re-Run)
#    Fall 4  persoenlich      -> team-os-g2.md anlegen + Import-Block anhaengen
$heading = "Globale Agenten-Anweisung (Team-OS G2)"

if (-not (Test-Path $target)) {
    # Fall 1: keine globale CLAUDE.md -> claude-sync.md wird sie (voll, inline)
    Copy-Item $source $target -Force
    Write-Host "Keine globale CLAUDE.md gefunden -> claude-sync.md als globale CLAUDE.md gesetzt: $target"
} else {
    $content = [System.IO.File]::ReadAllText($target, [System.Text.Encoding]::UTF8)
    if ($content -like "*$import*") {
        # Fall 2: bereits erweitertes Mitglied -> nur Team-Anweisung auffrischen
        Copy-Item $source $teamFile -Force
        Write-Host "Import bereits vorhanden -> team-os-g2.md aufgefrischt (CLAUDE.md unangetastet): $teamFile"
    } elseif ($content -like "*$heading*") {
        # Fall 3: CLAUDE.md IST eine Team-OS-Vollkopie -> in-place aktualisieren
        Copy-Item $target "$target.bak" -Force
        Copy-Item $source $target -Force
        Write-Host "Team-OS-Vollkopie erkannt -> CLAUDE.md in-place aktualisiert (Backup: $target.bak)."
    } else {
        # Fall 4: persoenliche CLAUDE.md -> behalten; Team-Anweisung als eigene Datei + Import anhaengen
        Copy-Item $source $teamFile -Force
        Copy-Item $target "$target.bak" -Force
        $newContent = $content.TrimEnd("`r", "`n") + "`n`n" + $block
        [System.IO.File]::WriteAllText($target, $newContent, $utf8NoBom)
        Write-Host "Persoenliche CLAUDE.md beibehalten; team-os-g2.md angelegt + Import angehaengt (Backup: $target.bak)."
    }
}

# 4) Skills GLOBAL installieren -> in JEDEM Repo verfuegbar (auch Alarmsystem-Dev),
#    nicht nur wenn man in diesem Tooling-Repo sitzt.
$skillsSrc = Join-Path $scriptDir ".claude/skills"
$skillsDst = Join-Path $claudeDir "skills"
if (Test-Path $skillsSrc) {
    $scount = 0
    Get-ChildItem -Path $skillsSrc -Directory | ForEach-Object {
        $skillFile = Join-Path $_.FullName "SKILL.md"
        if (Test-Path $skillFile) {
            $t = Join-Path $skillsDst $_.Name
            New-Item -ItemType Directory -Force -Path $t | Out-Null
            Copy-Item $skillFile (Join-Path $t "SKILL.md") -Force
            $scount++
        }
    }
    Write-Host "Skills global installiert: $scount -> $skillsDst"
}

# 5) Commands GLOBAL installieren (/start, /setup ueberall verfuegbar)
$cmdSrc = Join-Path $scriptDir ".claude/commands"
$cmdDst = Join-Path $claudeDir "commands"
if (Test-Path $cmdSrc) {
    New-Item -ItemType Directory -Force -Path $cmdDst | Out-Null
    $ccount = 0
    Get-ChildItem -Path $cmdSrc -Filter *.md -File | ForEach-Object {
        Copy-Item $_.FullName (Join-Path $cmdDst $_.Name) -Force
        $ccount++
    }
    Write-Host "Commands global installiert: $ccount -> $cmdDst"
}

Write-Host ""
Write-Host "Fertig. Naechste Schritte:"
Write-Host "  1) Ordner in VS Code oeffnen"
Write-Host "  2) 'claude' im integrierten Terminal starten"
Write-Host "  3) Projekt einmal 'vertrauen', dann '/start' tippen"
Write-Host "  4) Fuer die Produktcode-Arbeit zusaetzlich das Arbeitsrepo 'Alarmsystem-Dev' klonen + dessen Setup ausfuehren."

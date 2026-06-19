# -------------------------------------------------------------
# setup.ps1 - Einmal-Setup Team-OS (Windows / PowerShell)
# Aufruf:  powershell -ExecutionPolicy Bypass -File setup.ps1
# Macht:   - claude-sync.md  -> eigene Datei ~/.claude/team-os-g2.md
#          - ADDITIVER @import-Block in ~/.claude/CLAUDE.md (nie ueberschreiben)
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

# 2) Team-Anweisung als EIGENE Datei (eine Quelle; bei jedem Lauf aktualisiert)
Copy-Item $source $teamFile -Force
Write-Host "Team-Anweisung aktualisiert: $teamFile"

# 3) Import in die globale CLAUDE.md - ADDITIV, nie ueberschreiben (idempotent)
if (-not (Test-Path $target)) {
    [System.IO.File]::WriteAllText($target, $block, $utf8NoBom)
    Write-Host "Globale CLAUDE.md angelegt mit Team-Import: $target"
} else {
    $content = [System.IO.File]::ReadAllText($target, [System.Text.Encoding]::UTF8)
    if ($content -like "*$import*") {
        Write-Host "Team-Import bereits vorhanden in CLAUDE.md - nichts zu tun."
    } elseif ($content -like "*Globale Agenten-Anweisung (Team-OS G2)*") {
        # Frueherer Stand: claude-sync.md wurde direkt hineinkopiert -> auf Import umstellen.
        Copy-Item $target "$target.bak" -Force
        [System.IO.File]::WriteAllText($target, $block, $utf8NoBom)
        Write-Host "Alte Direktkopie erkannt -> auf Import umgestellt (Backup: $target.bak)."
    } else {
        # Persoenliche CLAUDE.md vorhanden -> nur den Block anhaengen, Inhalt bleibt.
        Copy-Item $target "$target.bak" -Force
        $newContent = $content.TrimEnd("`r", "`n") + "`n`n" + $block
        [System.IO.File]::WriteAllText($target, $newContent, $utf8NoBom)
        Write-Host "Persoenliche CLAUDE.md beibehalten; Team-Import angehaengt (Backup: $target.bak)."
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

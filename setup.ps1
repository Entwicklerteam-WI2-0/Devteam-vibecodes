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
$uniDir    = Join-Path $claudeDir "skills/uni"   # Skills-Dir-Plugin -> Namespace uni: (kollisionsfrei neben ecc:)

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

# 4) Skills als 'uni'-Plugin GLOBAL installieren -> Namespace uni: (kollisionsfrei neben ecc:).
#    Migration: alte FLACHE Team-Skill-Installationen entfernen (sonst Dubletten bei ECC-Nutzern).
$skillsSrc = Join-Path $scriptDir ".claude/skills"
if (Test-Path $skillsSrc) {
    New-Item -ItemType Directory -Force -Path (Join-Path $uniDir ".claude-plugin") | Out-Null
    New-Item -ItemType Directory -Force -Path (Join-Path $uniDir "skills")        | Out-Null
    New-Item -ItemType Directory -Force -Path (Join-Path $uniDir "commands")      | Out-Null
    $pluginJson = @'
{
  "name": "uni",
  "version": "1.0.0",
  "description": "Team-OS G2 Skills & Commands - Namespace uni: (kollisionsfrei neben ecc:)",
  "skills": ["./skills/"],
  "commands": ["./commands/"]
}
'@
    [System.IO.File]::WriteAllText((Join-Path $uniDir ".claude-plugin/plugin.json"), $pluginJson, $utf8NoBom)
    $scount = 0
    Get-ChildItem -Path $skillsSrc -Directory | ForEach-Object {
        $skillFile = Join-Path $_.FullName "SKILL.md"
        if (Test-Path $skillFile) {
            $name = $_.Name
            $t = Join-Path $uniDir "skills/$name"
            New-Item -ItemType Directory -Force -Path $t | Out-Null
            Copy-Item $skillFile (Join-Path $t "SKILL.md") -Force
            # Migration: evtl. vorhandene ALTE flache Installation desselben Skills entfernen
            $oldFlat = Join-Path $claudeDir "skills/$name"
            if (($name -ne "uni") -and (Test-Path $oldFlat)) { Remove-Item -Recurse -Force $oldFlat }
            $scount++
        }
    }
    Write-Host "Skills als uni-Plugin installiert: $scount -> $uniDir\skills  (Aufruf: uni:<skill>)"
}

# 5) Commands installieren: 'start' ins uni-Plugin (-> uni:start);
#    setup/update bleiben GLOBAL (muessen vor dem Plugin nutzbar sein).
$cmdSrc = Join-Path $scriptDir ".claude/commands"
$cmdDst = Join-Path $claudeDir "commands"
if (Test-Path $cmdSrc) {
    New-Item -ItemType Directory -Force -Path $cmdDst | Out-Null
    New-Item -ItemType Directory -Force -Path (Join-Path $uniDir "commands") | Out-Null
    $ccount = 0
    Get-ChildItem -Path $cmdSrc -Filter *.md -File | ForEach-Object {
        if ($_.Name -eq "start.md") {
            Copy-Item $_.FullName (Join-Path $uniDir "commands/start.md") -Force
            $oldStart = Join-Path $cmdDst "start.md"   # Migration: altes flaches /start entfernen
            if (Test-Path $oldStart) { Remove-Item -Force $oldStart }
        } else {
            Copy-Item $_.FullName (Join-Path $cmdDst $_.Name) -Force
        }
        $ccount++
    }
    Write-Host "Commands installiert: setup/update global -> $cmdDst ; start -> uni:start"
}

# 6) Fact-Forcing-Gate (Hook) installieren: Skript spiegeln + settings.json additiv mergen.
$hooksSrc = Join-Path $scriptDir ".claude/hooks"
$hooksDst = Join-Path $claudeDir "hooks"
$settings = Join-Path $claudeDir "settings.json"
$gateSrc  = Join-Path $hooksSrc "fact-forcing-gate.js"
if (Test-Path $gateSrc) {
    New-Item -ItemType Directory -Force -Path $hooksDst | Out-Null
    Copy-Item $gateSrc (Join-Path $hooksDst "fact-forcing-gate.js") -Force
    $gateDst = Join-Path $hooksDst "fact-forcing-gate.js"
    $hookCmd = 'node "' + $gateDst + '"'
    if (Test-Path $settings) { Copy-Item $settings "$settings.bak" -Force }
    # Merge per node (korrektes JSON, kein PSCustomObject-Rekonstruktions-Risiko)
    $mergeJs = @'
const fs=require("fs"), p=process.argv[1], cmd=process.argv[2];
let s={}; try{ s=JSON.parse(fs.readFileSync(p,"utf8")); }catch(e){ s={}; }
s.hooks=s.hooks||{}; const pre=Array.isArray(s.hooks.PreToolUse)?s.hooks.PreToolUse:[];
const keep=pre.filter(e=>!(e&&Array.isArray(e.hooks)&&e.hooks.some(h=>h&&typeof h.command==="string"&&h.command.includes("fact-forcing-gate.js"))));
const mk=m=>({matcher:m,hooks:[{type:"command",command:cmd,timeout:5}]});
s.hooks.PreToolUse=keep.concat([mk("Bash"),mk("Edit|Write|MultiEdit")]);
fs.writeFileSync(p, JSON.stringify(s,null,2));
'@
    $tmpJs = Join-Path $env:TEMP "uni-merge-settings.js"
    [System.IO.File]::WriteAllText($tmpJs, $mergeJs, $utf8NoBom)
    & node $tmpJs $settings $hookCmd
    Remove-Item -Force $tmpJs -ErrorAction SilentlyContinue
    Write-Host "Fact-Forcing-Gate installiert -> $gateDst ; settings.json gemergt (Backup: $settings.bak, falls vorhanden)."
}

Write-Host ""
Write-Host "Fertig. Naechste Schritte:"
Write-Host "  1) Ordner in VS Code oeffnen"
Write-Host "  2) 'claude' im integrierten Terminal starten"
Write-Host "  3) Projekt einmal 'vertrauen', dann 'uni:start' tippen (beim 1. Mal startet das Rollen-Bootstrap)"
Write-Host "  4) Fuer die Produktcode-Arbeit zusaetzlich das Arbeitsrepo 'Alarmsystem-Dev' klonen + dessen Setup ausfuehren."

# -------------------------------------------------------------
# setup-codex.ps1 - Team-OS fuer OpenAI Codex CLI einrichten (Windows)
# Aufruf:  powershell -ExecutionPolicy Bypass -File .\setup-codex.ps1
# Macht:
#   1) claude-sync.md            -> $CODEX_HOME\AGENTS.md   (globaler System-Prompt)
#   2) .claude/skills/*/SKILL.md -> $CODEX_HOME\skills\<name>\SKILL.md  (nativ, Auto-Trigger)
#   3) je Skill ein Command      -> $CODEX_HOME\prompts\<name>.md       (explizit per /prompts:<name>)
#   4) Skills-Feature aktivieren -> codex --enable skills (falls codex installiert)
#
# Codex liest AGENTS.md und SKILL.md nativ (gleiches Format wie Claude Code/Kimi).
# -------------------------------------------------------------
$ErrorActionPreference = "Stop"

# --- Repo-/Skript-Verzeichnis robust ermitteln -------------------------------
$scriptDir = $PSScriptRoot
if (-not $scriptDir -and $MyInvocation.MyCommand.Path) {
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
}
if (-not $scriptDir) { $scriptDir = (Get-Location).Path }

$sync = Join-Path $scriptDir "claude-sync.md"
$src  = Join-Path $scriptDir ".claude/skills"
if ((-not (Test-Path $sync)) -or (-not (Test-Path $src))) {
    $altSync = Join-Path (Get-Location).Path "claude-sync.md"
    $altSrc  = Join-Path (Get-Location).Path ".claude/skills"
    if ((Test-Path $altSync) -and (Test-Path $altSrc)) {
        $scriptDir = (Get-Location).Path; $sync = $altSync; $src = $altSrc
    }
}

if ((-not (Test-Path $sync)) -or (-not (Test-Path $src))) {
    Write-Host "FEHLER: claude-sync.md oder .claude/skills/ nicht gefunden (gesucht in: $scriptDir)."
    Write-Host "Bitte im geklonten Ordner 'Devteam-vibecodes' ausfuehren (ggf. vorher 'git pull')."
    exit 1
}

# --- Codex-Home bestimmen -----------------------------------------------------
if ($env:CODEX_HOME) { $codexHome = $env:CODEX_HOME } else { $codexHome = Join-Path $env:USERPROFILE ".codex" }
$skillsDir  = Join-Path $codexHome "skills"
$promptsDir = Join-Path $codexHome "prompts"
$agents     = Join-Path $codexHome "AGENTS.md"
New-Item -ItemType Directory -Force -Path $skillsDir  | Out-Null
New-Item -ItemType Directory -Force -Path $promptsDir | Out-Null

Write-Host "Team-OS-Setup fuer Codex startet."
Write-Host "  Repo:       $scriptDir"
Write-Host "  Codex-Home: $codexHome"
Write-Host ""

# --- UTF-8 ohne BOM fuer generierte/angehaengte Dateien ----------------------
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

# --- 1) Globaler System-Prompt: Team-Block in AGENTS.md (ADDITIV) ------------
# Codex garantiert keinen @import-Include in AGENTS.md -> Team-Inhalt wird als
# markierter Block inline gefuehrt; vorhandene AGENTS.md bleibt erhalten.
$codexBegin = "<!-- TEAM-OS-G2 BEGIN - verwaltet von setup-codex, nicht editieren -->"
$codexEnd   = "<!-- TEAM-OS-G2 END -->"
$syncText   = [System.IO.File]::ReadAllText($sync, [System.Text.Encoding]::UTF8)
$teamBlock  = $codexBegin + "`n" + $syncText.TrimEnd("`r", "`n") + "`n" + $codexEnd + "`n"

if (-not (Test-Path $agents)) {
    [System.IO.File]::WriteAllText($agents, $teamBlock, $utf8NoBom)
    Write-Host "[1/3] Globaler System-Prompt angelegt: $agents"
} else {
    $existing = [System.IO.File]::ReadAllText($agents, [System.Text.Encoding]::UTF8)
    if ($existing -like "*$codexBegin*") {
        # Alten Team-Block entfernen, frischen anhaengen (Re-Run aktualisiert den Inhalt).
        $pattern = [regex]::Escape($codexBegin) + "[\s\S]*?" + [regex]::Escape($codexEnd)
        $rest = ([regex]::Replace($existing, $pattern, "")).TrimEnd("`r", "`n")
        if ($rest.Length -gt 0) { $rest = $rest + "`n`n" }
        [System.IO.File]::WriteAllText($agents, $rest + $teamBlock, $utf8NoBom)
        Write-Host "[1/3] Team-Block in AGENTS.md aktualisiert: $agents"
    } else {
        # Persoenliche AGENTS.md vorhanden -> Block anhaengen, Inhalt bleibt.
        Copy-Item $agents "$agents.bak" -Force
        $rest = $existing.TrimEnd("`r", "`n") + "`n`n"
        [System.IO.File]::WriteAllText($agents, $rest + $teamBlock, $utf8NoBom)
        Write-Host "[1/3] Persoenliche AGENTS.md beibehalten; Team-Block angehaengt (Backup: $agents.bak)."
    }
}

# Mirror statt additiv: zuvor vom Team installierte Skills/Prompts entfernen, die es in der Quelle NICHT MEHR gibt.
# Manifest-gestuetzt -> persoenliche Codex-Skills/Prompts des Users bleiben unangetastet.
$cmanifest = Join-Path $skillsDir ".team-os-installed"
$teamSet = @()
Get-ChildItem -Path $src -Directory -ErrorAction SilentlyContinue | ForEach-Object { if (Test-Path (Join-Path $_.FullName "SKILL.md")) { $teamSet += $_.Name } }
if (Test-Path $cmanifest) {
    Get-Content -LiteralPath $cmanifest | ForEach-Object {
        $old = $_.Trim()
        if ($old -and ($teamSet -notcontains $old)) {
            Remove-Item -Recurse -Force (Join-Path $skillsDir $old) -ErrorAction SilentlyContinue
            Remove-Item -Force (Join-Path $promptsDir ($old + ".md")) -ErrorAction SilentlyContinue
            Write-Host "  entfernt (nicht mehr in der Quelle): $old"
        }
    }
}

# --- 2) + 3) Skills nativ kopieren + Command-Wrapper erzeugen -----------------
$count = 0
Get-ChildItem -Path $src -Directory | ForEach-Object {
    $skillFile = Join-Path $_.FullName "SKILL.md"
    if (Test-Path $skillFile) {
        $name = $_.Name

        # 2) nativer Skill (byte-genaue Kopie -> kein Encoding-Risiko)
        $target = Join-Path $skillsDir $name
        New-Item -ItemType Directory -Force -Path $target | Out-Null
        Copy-Item $skillFile (Join-Path $target "SKILL.md") -Force

        # 3) description aus dem Frontmatter lesen (UTF-8)
        $desc = ""
        foreach ($line in (Get-Content -LiteralPath $skillFile -Encoding UTF8)) {
            if ($line -match '^description:\s*(.*)$') { $desc = $Matches[1]; break }
        }
        $desc = $desc -replace '"', "'"
        if ([string]::IsNullOrWhiteSpace($desc)) { $desc = "Team-Skill $name" }

        # Command-Wrapper bauen (einfache Quotes -> keine Interpolation, $ARGUMENTS bleibt literal)
        $lines = @(
            '---',
            ('description: "' + $desc + '"'),
            '---',
            '',
            ('Aktiviere den Team-Skill **' + $name + '** und befolge ihn vollstaendig fuer die aktuelle Aufgabe.'),
            '',
            ('Die Skill-Definition liegt in `~/.codex/skills/' + $name + '/SKILL.md`. Ist der Skill nicht bereits automatisch geladen, lies diese Datei zuerst und arbeite dann strikt nach ihren Anweisungen. Antworte auf Deutsch.'),
            '',
            'Zusaetzlicher Kontext/Argumente: $ARGUMENTS'
        )
        $content = ($lines -join "`n") + "`n"
        [System.IO.File]::WriteAllText((Join-Path $promptsDir "$name.md"), $content, $utf8NoBom)

        Write-Host "  + $name"
        $count++
    }
}
Write-Host "[2/3] $count Skills nativ installiert -> $skillsDir"
[System.IO.File]::WriteAllText($cmanifest, (($teamSet | Sort-Object -Unique) -join "`n") + "`n", $utf8NoBom)
Write-Host "[3/3] $count Commands erzeugt        -> $promptsDir  (Aufruf: /prompts:<name>  oder / tippen und auswaehlen)"
Write-Host ""

# --- 4) Skills-Feature aktivieren --------------------------------------------
$codexCmd = Get-Command codex -ErrorAction SilentlyContinue
if ($codexCmd) {
    & codex --enable skills 2>$null | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Skills-Feature aktiviert (codex --enable skills)."
    } else {
        Write-Host "HINWEIS: 'codex --enable skills' fehlgeschlagen - bitte einmal manuell ausfuehren."
    }
} else {
    Write-Host "HINWEIS: 'codex' nicht im PATH. Nach der Codex-Installation einmal ausfuehren:"
    Write-Host "         codex --enable skills"
}

Write-Host ""
Write-Host "Fertig. Naechste Schritte:"
Write-Host "  1) Ordner in VS Code oeffnen, 'codex' im Terminal starten, Projekt 'vertrauen'."
Write-Host "  2) Skills triggern primaer AUTOMATISCH (Aufgabe beschreiben). Explizit optional: /prompts:tdd-workflow"
Write-Host "  3) Der globale System-Prompt (claude-sync.md) gilt jetzt in jeder Codex-Session."
Write-Host "  4) Fuer die Produktcode-Arbeit zusaetzlich 'Alarmsystem-Dev' klonen (hat eigene AGENTS.md)."
Write-Host "  5) HINWEIS: Das Fact-Forcing-Gate (Tool-Block) laeuft auf Claude Code und Kimi Code. Auf Codex gilt nur die Text-Guidance aus AGENTS.md (kein blockierender Hook)."

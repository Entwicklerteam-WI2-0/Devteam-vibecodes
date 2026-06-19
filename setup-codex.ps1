# -------------------------------------------------------------
# setup-codex.ps1 - Team-OS fuer OpenAI Codex CLI einrichten (Windows)
# Aufruf:  powershell -ExecutionPolicy Bypass -File .\setup-codex.ps1
# Macht:
#   1) claude-sync.md            -> $CODEX_HOME\AGENTS.md   (globaler System-Prompt)
#   2) .claude/skills/*/SKILL.md -> $CODEX_HOME\skills\<name>\SKILL.md  (nativ, Auto-Trigger)
#   3) je Skill ein Command      -> $CODEX_HOME\prompts\<name>.md       (explizit per /<name>)
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

# --- 1) Globaler System-Prompt: claude-sync.md -> AGENTS.md -------------------
if (Test-Path $agents) {
    Copy-Item $agents "$agents.bak" -Force
    Write-Host "HINWEIS: vorhandene AGENTS.md gesichert -> $agents.bak"
}
Copy-Item $sync $agents -Force
Write-Host "[1/3] Globaler System-Prompt gesetzt: $agents"

# --- UTF-8 ohne BOM fuer generierte Dateien ----------------------------------
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

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
Write-Host "[3/3] $count Commands erzeugt        -> $promptsDir  (Aufruf: /<name>)"
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
Write-Host "  2) Skills laufen automatisch (Auto-Trigger) ODER explizit per Command, z.B.:  /tdd-workflow"
Write-Host "  3) Der globale System-Prompt (claude-sync.md) gilt jetzt in jeder Codex-Session."
Write-Host "  4) Fuer die Produktcode-Arbeit zusaetzlich 'Alarmsystem-Dev' klonen (hat eigene AGENTS.md)."

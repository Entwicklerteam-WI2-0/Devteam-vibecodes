# -------------------------------------------------------------
# setup-kimi.ps1 - Team-OS fuer Kimi Code CLI einrichten (Windows)
# Aufruf:  powershell -ExecutionPolicy Bypass -File .\setup-kimi.ps1
# Macht:
#   1) .claude/skills/*/SKILL.md -> $KIMI_CODE_HOME\skills\<name>\SKILL.md   (nativ, /skill:<name>)
#   2) .claude/commands/*.md     -> $KIMI_CODE_HOME\skills\<name>\SKILL.md   (Kimi hat KEIN
#                                   Command-Verzeichnis -> Commands werden Skills: /skill:start)
#   3) claude-sync.md            -> $KIMI_CODE_HOME\AGENTS.md  (fehlt -> WIRD AGENTS.md; sonst additiv)
#   4) .claude/hooks/fact-forcing-gate.js -> $KIMI_CODE_HOME\hooks\ + config.toml verdrahten
#                                   (Kimi-Hooks sind Claude-kompatibel: PreToolUse blockable,
#                                    deny via stdout-JSON; das Gate-Skript ist harness-agnostisch.)
#   Kimi liest ~/.kimi-code/ nativ (gleiches SKILL.md-Format).
# -------------------------------------------------------------
$ErrorActionPreference = "Stop"

$scriptDir = $PSScriptRoot
if (-not $scriptDir -and $MyInvocation.MyCommand.Path) {
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
}
if (-not $scriptDir) { $scriptDir = (Get-Location).Path }

$src    = Join-Path $scriptDir ".claude/skills"
$cmdSrc = Join-Path $scriptDir ".claude/commands"
$sync   = Join-Path $scriptDir "claude-sync.md"
if (-not (Test-Path $src)) {
    $alt = Join-Path (Get-Location).Path ".claude/skills"
    if (Test-Path $alt) {
        $scriptDir = (Get-Location).Path; $src = $alt
        $cmdSrc = Join-Path $scriptDir ".claude/commands"; $sync = Join-Path $scriptDir "claude-sync.md"
    }
}

if ((-not (Test-Path $src)) -or (-not (Test-Path $sync))) {
    Write-Host "FEHLER: .claude/skills/ oder claude-sync.md nicht gefunden (gesucht in: $scriptDir)."
    Write-Host "Bitte im geklonten Ordner 'Devteam-vibecodes' ausfuehren (ggf. vorher 'git pull')."
    exit 1
}

if ($env:KIMI_CODE_HOME) { $kimiHome = $env:KIMI_CODE_HOME } else { $kimiHome = Join-Path $env:USERPROFILE ".kimi-code" }
$kskills = Join-Path $kimiHome "skills"
$kagents = Join-Path $kimiHome "AGENTS.md"
New-Item -ItemType Directory -Force -Path $kskills | Out-Null
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
Write-Host "Team-OS-Setup fuer Kimi Code -> $kimiHome"

# Mirror statt additiv: zuvor vom Team installierte Skills entfernen, die es in der Quelle NICHT MEHR gibt.
# Manifest-gestuetzt -> persoenliche Kimi-Skills des Users bleiben unangetastet.
$kmanifest = Join-Path $kskills ".team-os-installed"
$teamSet = @()
Get-ChildItem -Path $src -Directory -ErrorAction SilentlyContinue | ForEach-Object { if (Test-Path (Join-Path $_.FullName "SKILL.md")) { $teamSet += $_.Name } }
if (Test-Path $cmdSrc) { Get-ChildItem -Path $cmdSrc -Filter *.md -File | ForEach-Object { $teamSet += $_.BaseName } }
if (Test-Path $kmanifest) {
    Get-Content -LiteralPath $kmanifest | ForEach-Object {
        $old = $_.Trim()
        if ($old -and ($teamSet -notcontains $old)) {
            Remove-Item -Recurse -Force (Join-Path $kskills $old) -ErrorAction SilentlyContinue
            Write-Host "  entfernt (nicht mehr in der Quelle): $old"
        }
    }
}

# 1) Skills nativ
$count = 0
Get-ChildItem -Path $src -Directory | ForEach-Object {
    $sf = Join-Path $_.FullName "SKILL.md"
    if (Test-Path $sf) {
        $t = Join-Path $kskills $_.Name
        New-Item -ItemType Directory -Force -Path $t | Out-Null
        Copy-Item $sf (Join-Path $t "SKILL.md") -Force
        $count++
    }
}
Write-Host "[1/4] $count Skills installiert -> $kskills  (Aufruf: /skill:<name>)"

# 2) Commands als Skills (Kimi hat kein Command-Verzeichnis)
$ccount = 0
if (Test-Path $cmdSrc) {
    Get-ChildItem -Path $cmdSrc -Filter *.md -File | ForEach-Object {
        $base  = $_.BaseName
        $lines = Get-Content -LiteralPath $_.FullName -Encoding UTF8
        $desc  = ""
        foreach ($ln in $lines) { if ($ln -match '^description:\s*(.*)$') { $desc = $Matches[1]; break } }
        $desc = $desc -replace '"', "'"
        if ([string]::IsNullOrWhiteSpace($desc)) { $desc = "Team-Command $base" }
        # Body ohne fuehrendes Frontmatter
        $body = $lines
        if ($lines.Count -gt 0 -and $lines[0].Trim() -eq '---') {
            $endIdx = -1
            for ($i = 1; $i -lt $lines.Count; $i++) { if ($lines[$i].Trim() -eq '---') { $endIdx = $i; break } }
            if ($endIdx -ge 1) { $body = $lines[($endIdx + 1)..($lines.Count - 1)] }
        }
        $content = "---`nname: $base`ndescription: `"$desc`"`n---`n`n" + ($body -join "`n") + "`n"
        $t = Join-Path $kskills $base
        New-Item -ItemType Directory -Force -Path $t | Out-Null
        [System.IO.File]::WriteAllText((Join-Path $t "SKILL.md"), $content, $utf8NoBom)
        $ccount++
    }
}
[System.IO.File]::WriteAllText($kmanifest, (($teamSet | Sort-Object -Unique) -join "`n") + "`n", $utf8NoBom)
Write-Host "[2/4] $ccount Commands als Skills installiert  (Aufruf: /skill:start, /skill:setup)"

# 3) Globale Anweisung -> AGENTS.md, 4 Faelle (idempotent, Kimi inline; kein @import):
#    Fall 1  fehlt           -> claude-sync.md WIRD die AGENTS.md (voll, inline)
#    Fall 2  hat Team-Block   -> Block auffrischen (bereits erweitert)
#    Fall 3  Team-Vollkopie   -> AGENTS.md in-place aktualisieren (Backup)
#    Fall 4  persoenlich      -> Team-Block anhaengen (Backup)
$kb = "<!-- TEAM-OS-G2 BEGIN - verwaltet von setup-kimi, nicht editieren -->"
$ke = "<!-- TEAM-OS-G2 END -->"
$heading = "Globale Agenten-Anweisung (Team-OS G2)"
$syncText  = [System.IO.File]::ReadAllText($sync, [System.Text.Encoding]::UTF8)
$teamBlock = $kb + "`n" + $syncText.TrimEnd("`r", "`n") + "`n" + $ke + "`n"

if (-not (Test-Path $kagents)) {
    # Fall 1: keine AGENTS.md -> claude-sync.md wird sie (voll, inline)
    Copy-Item $sync $kagents -Force
    Write-Host "[3/4] Keine AGENTS.md gefunden -> claude-sync.md als AGENTS.md gesetzt: $kagents"
} else {
    $existing = [System.IO.File]::ReadAllText($kagents, [System.Text.Encoding]::UTF8)
    if ($existing -like "*$kb*") {
        # Fall 2: bereits erweitert -> Team-Block ersetzen/auffrischen
        $pattern = [regex]::Escape($kb) + "[\s\S]*?" + [regex]::Escape($ke)
        $rest = ([regex]::Replace($existing, $pattern, "")).TrimEnd("`r", "`n")
        if ($rest.Length -gt 0) { $rest = $rest + "`n`n" }
        [System.IO.File]::WriteAllText($kagents, $rest + $teamBlock, $utf8NoBom)
        Write-Host "[3/4] Team-Block in AGENTS.md aufgefrischt: $kagents"
    } elseif ($existing -like "*$heading*") {
        # Fall 3: AGENTS.md IST eine Team-OS-Vollkopie -> in-place aktualisieren
        Copy-Item $kagents "$kagents.bak" -Force
        Copy-Item $sync $kagents -Force
        Write-Host "[3/4] Team-OS-Vollkopie erkannt -> AGENTS.md in-place aktualisiert (Backup: $kagents.bak)."
    } else {
        # Fall 4: persoenliche AGENTS.md -> behalten, Team-Block anhaengen
        Copy-Item $kagents "$kagents.bak" -Force
        $rest = $existing.TrimEnd("`r", "`n") + "`n`n"
        [System.IO.File]::WriteAllText($kagents, $rest + $teamBlock, $utf8NoBom)
        Write-Host "[3/4] Persoenliche AGENTS.md beibehalten; Team-Block angehaengt (Backup: $kagents.bak)."
    }
}

# 4) Fact-Forcing-Gate deployen (Kimi config.toml verdrahten, idempotent).
#    Kimis Hook-System ist Claude-kompatibel (PreToolUse blockbar, deny via stdout-JSON);
#    das bestehende, harness-agnostische Gate-Skript wird unverändert weitergenutzt.
#    Quelle der Hook-Semantik: offizielle Kimi-Code-Doku (customization/hooks).
$gateSrc = Join-Path $scriptDir ".claude/hooks/fact-forcing-gate.js"
if (Test-Path $gateSrc) {
    $khooks  = Join-Path $kimiHome "hooks"
    $kconfig = Join-Path $kimiHome "config.toml"
    New-Item -ItemType Directory -Force -Path $khooks | Out-Null
    Copy-Item $gateSrc (Join-Path $khooks "fact-forcing-gate.js") -Force
    # Forward-Slashes fuer TOML (Node akzeptiert sie auf allen Plattformen; Backslashes
    # wuerden in basic-TOML-strings als Escape gelten -> literal string mit "..." drum ist sicher).
    $kimiHomeFw = $kimiHome -replace '\\','/'
    $gateCmd    = "node `"$kimiHomeFw/hooks/fact-forcing-gate.js`""
    $hb = "# TEAM-OS-G2 HOOKS BEGIN - verwaltet von setup-kimi, nicht editieren"
    $he = "# TEAM-OS-G2 HOOKS END"
    $hookBlock = @"
$hb
[[hooks]]
event = "PreToolUse"
matcher = "Bash"
command = '$gateCmd'
timeout = 5

[[hooks]]
event = "PreToolUse"
matcher = "Edit|Write|MultiEdit"
command = '$gateCmd'
timeout = 5
$he
"@
    if (-not (Test-Path $kconfig)) {
        [System.IO.File]::WriteAllText($kconfig, $hookBlock + "`n", $utf8NoBom)
        Write-Host "[4/4] config.toml angelegt + Fact-Forcing-Gate verdrahtet: $kconfig"
    } else {
        $existing = [System.IO.File]::ReadAllText($kconfig, [System.Text.Encoding]::UTF8)
        if ($existing -like "*$hb*") {
            # Block bereits vorhanden -> zwischen Markern ersetzen (idempotent)
            $pattern = [regex]::Escape($hb) + "[\s\S]*?" + [regex]::Escape($he)
            $rest = ([regex]::Replace($existing, $pattern, "")).TrimEnd("`r", "`n")
            if ($rest.Length -gt 0) { $rest = $rest + "`n`n" }
            [System.IO.File]::WriteAllText($kconfig, $rest + $hookBlock + "`n", $utf8NoBom)
            Write-Host "[4/4] Fact-Forcing-Gate in bestehender config.toml aufgefrischt: $kconfig"
        } else {
            # Persoenliche config.toml -> behalten, Block anhaengen (Backup)
            Copy-Item $kconfig "$kconfig.bak" -Force
            $rest = $existing.TrimEnd("`r", "`n") + "`n`n"
            [System.IO.File]::WriteAllText($kconfig, $rest + $hookBlock + "`n", $utf8NoBom)
            Write-Host "[4/4] Persoenliche config.toml beibehalten; Fact-Forcing-Gate angehaengt (Backup: $kconfig.bak)."
        }
    }
} else {
    Write-Host "[4/4] WARNUNG: .claude/hooks/fact-forcing-gate.js nicht gefunden - kein Kimi-Gate deployt."
}

Write-Host ""
Write-Host "Fertig. Kimi findet Skills + Anweisung automatisch (KIMI_CODE_HOME)."
Write-Host "Aufruf z.B.:  /skill:tdd-workflow   -   Session-Start:  /skill:start"
Write-Host "Fact-Forcing-Gate: als PreToolUse-Hook in config.toml verdrahtet (Bash + Edit/Write/MultiEdit)."
Write-Host "Verifikation: in Kimi '/hooks' zeigt die geladenen Hooks. Steuerung via User-Env"
Write-Host "  UNI_GATE_OFF=off oder UNI_DISABLED_HOOKS=uni:pre:bash:fact-force,uni:pre:edit-write:fact-force."
Write-Host "Hinweis: Kimi fuehrt Hooks fail-open aus (Doku) - das Gate ist Coaching, keine alleinige Safety-Barriere."

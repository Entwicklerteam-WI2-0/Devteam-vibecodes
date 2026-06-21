# Implementierungs-Plan: Fact-Forcing-Gate als vendored Feature (Team-OS G2)

> **Ziel (3 Sätze):** Wir portieren ECCs Fact-Forcing-Gate als **ein einziges, selbst-enthaltenes Node-Skript** in dieses Repo und rollen es über die Setup-Skripte an alle Team-Mitglieder aus — **ohne jede Abhängigkeit vom fragilen `ecc@ecc`-Plugin**. Das Gate blockiert auf Claude Code (a) das **erste Bash-Kommando pro Session** und (b) den **ersten Edit/Write pro Datei**, bis konkrete Fakten genannt wurden (exit-2 + stderr-Block-Semantik bzw. JSON-`permissionDecision: deny`), und läuft unter **eigenem, ecc-unabhängigem Namespace** (`UNI_GATE_*`), sodass es nicht mit dem installierten ECC-Plugin kollidiert. Kimi/Codex erhalten — gemäß verifizierter Harness-Realität — die **ehrlich benannte, degradierte Variante**, nicht die volle Tool-Blockade.
>
> **Toolkit-Version-Stempel:** v1.4.0

---

## Wichtige Vorab-Regeln für Kimi (verbindlich, bevor du irgendetwas anfasst)

1. **Source-of-Truth-Pflicht:** Wo dieser Plan einen Befund als **UNVERIFIED** markiert, **rufst du zuerst die Live-Quelle ab** (offizielle Doku / GitHub) und richtest deine Umsetzung exakt daran aus — **nie aus dem Gedächtnis**. Betrifft v. a. Kimi/Codex-Hook-Semantik (Abschnitt E). Quelle nicht abrufbar → STOPP, melden, nachfragen.
2. **Git-Freigabe (claude-sync.md §7):** **Kein** Push, PR, Merge, Force-Push oder destruktiver Git-Befehl **ohne explizite Freigabe durch Lucas**. Du arbeitest auf einem **Feature-Branch**, committest lokal, und **wartest** vor Push/PR auf Freigabe (Abschnitt F).
3. **Reihenfolge einhalten:** Arbeite C1 → C2 → C3 → C4 → C5 strikt der Reihe nach ab. Erst nach grünen Akzeptanztests (Abschnitt D) gehst du zu C5 (Doku/Version).
4. **Deutsch** für alle erzeugten Doku-Artefakte. Der Gate-**Botschaftstext** bleibt jedoch **wortgleich englisch** wie in der ECC-Vorlage (die Akzeptanztests prüfen exakte englische Strings).
5. **Keine ecc-Dateien anfassen.** Du baust einen unabhängigen Klon. `~/.claude/plugins/**` und ECC-Interna bleiben unberührt.

---

## A. Was die Vorlage tut (Faktenlage aus Recon — echte Hook-IDs/Pfade)

Die ECC-Vorlage ist **ein PreToolUse-Hook**, vollständig in `gateguard-fact-force.js`. Drei Sub-Gates:

| Sub-Gate | ECC-Hook-ID | Matcher | Trigger | State-Key |
|---|---|---|---|---|
| Routine-Bash (1×/Session) | `pre:bash:gateguard-fact-force` | `Bash` | erstes nicht-destruktives Bash-Kommando der Session | `__bash_session__` |
| Destruktiv-Bash (pro Kommando) | `pre:bash:gateguard-fact-force` | `Bash` | jedes destruktive Kommando (Tokenizer) | `__destructive__` + sha256hex16 |
| Edit/Write/MultiEdit (pro Datei) | `pre:edit-write:gateguard-fact-force` | `Edit\|Write\|MultiEdit` | erste Berührung einer Datei | `<file_path>` |

**Kernmechanik (verifiziert):**
- **Deny-Signal NIE über exit 2 im ECC-Original**, sondern über stdout-JSON `{ hookSpecificOutput: { hookEventName: "PreToolUse", permissionDecision: "deny", permissionDecisionReason: "<msg>" } }` mit `exitCode: 0`. *(Für unseren Standalone-Port nutzen wir die JSON-deny-Variante 1:1 — sie ist die offiziell dokumentierte, robuste Blockier-Variante und vermeidet die exit-1-vs-exit-2-Falle. Siehe C1.)*
- **State** in `~/.gateguard/state-{sessionKey}.json`, Format `{ checked: string[], last_active: number }`, atomar (tmp + rename), Session-Timeout **30 min**, Read-Heartbeat **60 s**, Stale-Prune **60 min** bei Modul-Load, Cap **500** `checked`-Einträge (`__bash_session__` muss Prune überleben).
- **Session-Key-Priorität:** `data.session_id` > `data.sessionId` > `data.session.id` > `CLAUDE_SESSION_ID` > `ECC_SESSION_ID` > Hash(`transcript_path`) `tx-…` > Hash(`CLAUDE_PROJECT_DIR`/cwd) `proj-…`.
- **Subagent-Bypass:** `agent_id`/`parent_tool_use_id`/`parentToolUseId` (nicht-leerer String) → Edit/Write/MultiEdit ohne Gate durch; **Bash bleibt gegated**.
- **Ausnahmen:** `.claude/settings*.json`-Pfade nie gegated; Read-only-Git-Allowlist (`git status|diff|log|show HEAD:<path-ohne-Separator>|branch --show-current|rev-parse`).
- **Einzige Code-Abhängigkeit innerhalb der Gate-Logik:** `../lib/shell-substitution.js` (drei reine Funktionen `extractCommandSubstitutions`, `extractSubshellGroups`, `extractBraceGroups`). Plugin-Bootstrap/`CLAUDE_PLUGIN_ROOT`/`run-with-flags.js`/`bash-hook-dispatcher.js` liegen **außerhalb** der Gate-Logik und sind im Standalone-Port **vollständig entfernbar**.
- **ECC-Env-Flags:** `ECC_GATEGUARD=off`/`GATEGUARD_DISABLED=1` (Kill-Switch), `ECC_DISABLED_HOOKS`, `ECC_HOOK_PROFILE=minimal` (silent), `GATEGUARD_BASH_ROUTINE_DISABLED`, `GATEGUARD_STATE_DIR`, `GATEGUARD_BASH_EXTRA_DESTRUCTIVE`.

> **UNVERIFIED:** Der Plan stützt sich auf die Recon-**Zeilennummern/Funktionsnamen** der ECC-Quelle, nicht auf einen frischen Blick in die installierte ECC-Datei. Kimi liest vor dem Port die installierte Vorlage einmal real (Pfad unter `~/.claude/plugins/cache/ecc/ecc/2.0.0/scripts/hooks/gateguard-fact-force.js` bzw. `…/scripts/lib/shell-substitution.js`) und übernimmt **den realen Quellcode verbatim** für die zu inlinenden Teile. Existiert die Datei dort nicht → STOPP und Lucas fragen (kein Nachbau aus dem Gedächtnis).

---

## B. Zielarchitektur im Repo (Dateibaum)

```
Devteam-vibecodes/
├─ .claude/
│  ├─ hooks/
│  │  ├─ fact-forcing-gate.js     # NEU  — Standalone-Port (Node, nur crypto/fs/path)
│  │  └─ README.md                # GEÄNDERT — Hook aus "geplant" → "aktiv (Claude Code only)"
│  ├─ settings.json               # GEÄNDERT — 2 PreToolUse-Einträge ergänzt (SessionStart bleibt)
│  └─ skills/ …                    # unverändert
├─ tests/
│  └─ fact-forcing-gate.test.js   # NEU  — Akzeptanztests (Node built-in test runner)
├─ setup.sh                       # GEÄNDERT — Schritt 6: hooks/ + settings.json-Merge (Claude/Mac-Linux)
├─ setup.ps1                      # GEÄNDERT — Schritt 6: hooks/ + settings.json-Merge (Claude/Windows)
├─ setup-kimi.sh / .ps1           # GEÄNDERT — degradierte Variante (siehe C4)
├─ setup-codex.sh / .ps1          # GEÄNDERT — degradierte Variante (siehe C4)
├─ CLAUDE.md                      # GEÄNDERT — Kopplungs-Karte + Versionsstempel
├─ claude-sync.md                 # GEÄNDERT — §6.2 (Hook jetzt aktiv) + Versionsstempel
├─ README.md / ONBOARDING.md / … # GEÄNDERT — nur Versionsstempel (Sweep, C5)
└─ VERSION                        # GEÄNDERT — 1.3.0 → 1.4.0
```

**Unverändert:** `update.sh`/`update.ps1` (sie chainen in `setup.*` → neue Deploy-Logik läuft automatisch mit). Kein `~/.claude/hooks/`-Mechanismus existiert in Claude Code von Haus aus — Hooks werden in `settings.json` als `command`-String referenziert; wir deployen das **Skript** an einen stabilen Pfad und referenzieren es per absolutem Pfad.

---

## C. Schritt-für-Schritt-Implementierung

### C1 — Standalone-Hook-Skript `.claude/hooks/fact-forcing-gate.js`

**Aktion:** NEUE Datei. Selbst-enthalten, nur Node-Builtins `crypto`, `fs`, `path`. Keine `require('../lib/...')`, kein `CLAUDE_PLUGIN_ROOT`, kein Bootstrap.

#### C1.1 stdin-Contract (gelesene Felder)
JSON von stdin (Claude-Code-PreToolUse-Payload). Genutzt:
- `tool_name` (case-insensitiv → `Edit`/`Write`/`MultiEdit`/`Bash`)
- `tool_input.file_path` (Edit/Write), `tool_input.edits[].file_path` (MultiEdit), `tool_input.command` (Bash)
- `session_id` / `sessionId` / `session.id` (Session-Key)
- `transcript_path` / `transcriptPath` (Fallback-Key)
- `agent_id` / `agentId` / `parent_tool_use_id` / `parentToolUseId` (Subagent-Erkennung)

Nicht genutzt: `cwd`, `user_id`, Output-Felder. Nicht-passende Tools → pass-through.

#### C1.2 Modi & Logik (verbatim aus der realen ECC-Quelle übernehmen)
Kimi kopiert die Funktionskörper **byte-genau** aus der installierten `gateguard-fact-force.js` (siehe A-UNVERIFIED) und inlinet die drei Funktionen aus `shell-substitution.js`. Übernommen werden **unverändert**:
- `resolveSessionKey`, `getStateFile`, State-Load/Save (atomar, EPERM/EEXIST-Branch für Windows), Stale-Prune-IIFE, Heartbeat, 500-Cap mit `__bash_session__`-Erhalt, Concurrent-Read-Merge-Write.
- `isDestructiveBash` inkl. Shell-Words-Tokenizer (Quotes, `$()`, Backticks, `(...)`, `{ …; }`, Pipes/Chains), Read-only-Git-Allowlist, `isClaudeSettingsPath`, `isSubagentInvocation`.
- Die vier Botschafts-Funktionen (Text **wortgleich** belassen, siehe C1.4) — mit **einer** Anpassung an die Recovery-Hinweise (C1.5).
- Die `run(raw)`-Funktion-Struktur (Edit/Write/MultiEdit-Pfad, Bash-Pfad, `denyResult`, `allowWithStateWarning`).

#### C1.3 Eigener Namespace statt ECC-Env (HARTE VORGABE — Kollisionsfreiheit)
**Ersetze in der kopierten Logik alle ECC-Env-Reads durch UNI-Pendants.** Damit das Gate **nie** auf ECC-Flags reagiert und ECC nie auf unsere — beide Plugins können parallel laufen, jeder mit eigenem Schalter:

| ECC-Original | UNI-Standalone (verwenden) | Wirkung |
|---|---|---|
| `ECC_GATEGUARD` | `UNI_GATE_OFF` | Werte `0/false/off/disabled/disable` → Gate komplett aus, pass-through, **kein** State |
| `GATEGUARD_DISABLED` | `UNI_GATE_DISABLED` | exakt `"1"` → Gate aus (Legacy-Stil, nur exakter String `1`) |
| `ECC_DISABLED_HOOKS` | `UNI_DISABLED_HOOKS` | komma-separiert; Hook-IDs `uni:pre:bash:fact-force` / `uni:pre:edit-write:fact-force` |
| `ECC_HOOK_PROFILE=minimal` | `UNI_HOOK_PROFILE` | `minimal` → silent; sonst aktiv (Default aktiv) |
| `GATEGUARD_BASH_ROUTINE_DISABLED` | `UNI_GATE_BASH_ROUTINE_DISABLED` | `1/true/on/yes/enabled/enable` → nur Routine-Bash-Gate aus, Destruktiv bleibt |
| `GATEGUARD_STATE_DIR` | `UNI_GATE_STATE_DIR` | State-Dir-Override |
| `GATEGUARD_BASH_EXTRA_DESTRUCTIVE` | `UNI_GATE_BASH_EXTRA_DESTRUCTIVE` | zusätzliche Destruktiv-Regex |

**State-Verzeichnis (eigener Pfad, kollisionsfrei zu ECCs `~/.gateguard/`):**
`UNI_GATE_STATE_DIR` || `path.join(HOME || USERPROFILE || '/tmp', '.uni-gate')`. → Standardpfad `~/.uni-gate/state-{sessionKey}.json`. **Niemals** `~/.gateguard/` verwenden (das gehört ECC).

**Hook-IDs umbenannt** (im Botschaftstext-Recovery-Hinweis und in `UNI_DISABLED_HOOKS`-Checks): Bash-Pfad nutzt `uni:pre:bash:fact-force`, Edit/Write-Pfad nutzt `uni:pre:edit-write:fact-force`. Da **eine** Datei beide Tool-Familien bedient, wählt der Code die zu prüfende Hook-ID anhand `tool_name`.

> **Doppel-Feuern vermieden, weil:** ECCs Hook prüft `ECC_*`-Flags und schreibt in `~/.gateguard/`; unser Hook prüft `UNI_*`-Flags und schreibt in `~/.uni-gate/`. **Getrennte Env-Namespaces + getrennte State-Dirs = kein gemeinsamer Zustand, keine gegenseitige Beeinflussung.** Falls beide registriert sind, feuern beide unabhängig (das ist akzeptabel und gewollt: der User kann jeden einzeln abschalten). Der Default-Deploy registriert nur **unseren** Hook in `settings.json`; ECC bringt seine Hooks über sein Plugin mit. Wer Doppelung vermeiden will, schaltet einen per dessen Env-Flag ab.

#### C1.4 Botschaftstext (wortgleich englisch — Tests prüfen exakte Strings)
- **routineBashMsg():**
  `[Fact-Forcing Gate]\n\nBefore the first Bash command this session, present these facts:\n\n1. The current user request in one sentence\n2. What this specific command verifies or produces\n\nPresent the facts, then retry the same operation.`
  Recovery-Hinweis muss die **Bash-Hook-ID** `uni:pre:bash:fact-force` nennen und darf die Edit-Write-ID **nicht** enthalten.
- **destructiveBashMsg():**
  `[Fact-Forcing Gate]\n\nDestructive command detected. Before running, present:\n\n1. List all files/data this command will modify or delete\n2. Write a one-line rollback procedure\n3. Quote the user current instruction verbatim\n\nPresent the facts, then retry the same operation.`
  **Kein** Escape-Hatch-Hinweis (sicherheitsbewusst, `includeRecoveryHint: false`).
- **editGateMsg(filePath):** beginnt `[Fact-Forcing Gate]\n\nBefore editing {filePath}, present these facts:…`, muss `import/require` enthalten.
- **writeGateMsg(filePath):** beginnt `[Fact-Forcing Gate]\n\nBefore creating {filePath}, present these facts:…`, muss `creating` und `call this new file` enthalten.

**Pfad-Sanitisierung beibehalten:** `\n`/`\r` in `file_path` → Leerzeichen; Unicode-Bidi-Override (U+202E etc.) strippen; sichtbarer Dateiname bleibt.

#### C1.5 Recovery-/Escape-Hatch-Text (auf UNI-Namespace umschreiben)
Edit/Write/MultiEdit-Denials hängen den Recovery-Hinweis an — **mit UNI-Flags** statt ECC:
`Recovery: if the gate is blocking setup or repair work, run this session with \`UNI_GATE_OFF=off\` or add \`uni:pre:edit-write:fact-force\` to \`UNI_DISABLED_HOOKS\`.`
→ Edit/Write-Denial-Reason MUSS `UNI_GATE_OFF` **und** `UNI_DISABLED_HOOKS` enthalten (Tests 16). Destruktiv-Bash-Denial enthält **keinen** Escape-Hatch.

#### C1.6 Exit-Codes & Output-Protokoll (HARTE VORGABE: Block-Semantik)
**Deny** = stdout-JSON `{ hookSpecificOutput: { hookEventName: "PreToolUse", permissionDecision: "deny", permissionDecisionReason: "<msg>" } }`, **exitCode 0**. Das ist die offiziell dokumentierte Block-Variante (verifiziert: Claude-Code-Hooks-Doku, `permissionDecision deny` als JSON-stdout-Alternative zu exit 2).
**Allow** = raw input unverändert auf stdout, exitCode 0.
**State-Persist-Fehler** = `allowWithStateWarning()`: stderr `[Fact-Forcing Gate] GateGuard state could not be persisted…` (String muss `GateGuard state could not be persisted` enthalten — Test 3b), exitCode 0, **fail-open** (Aktion erlaubt).
**Malformed JSON** = input unverändert echoen, exitCode 0.

> **Hinweis (Claude-Code-exit-Falle):** Wir nutzen **bewusst** die JSON-deny-Variante (exit 0), **nicht** exit 2. Grund: exit 1 ist auf Claude Code non-blocking; die exit-2-Variante würde stderr als Reason zurückspielen, ist aber fehleranfälliger im Zusammenspiel mit dem stdout-Pass-through. Die JSON-Variante ist deterministisch und 1:1 aus der ECC-Vorlage übernommen.

#### C1.7 main()-Block (ersetzt `module.exports = { run }`)
Am Dateiende:
```js
let raw = '';
process.stdin.setEncoding('utf8');
process.stdin.on('data', c => raw += c);
process.stdin.on('end', () => {
  const result = run(raw);
  if (result && typeof result === 'object') {
    if (result.stderr) process.stderr.write(result.stderr);
    if (typeof result.stdout === 'string') process.stdout.write(result.stdout);
    else process.stdout.write(typeof raw === 'string' ? raw : '');
    process.exitCode = Number.isInteger(result.exitCode) ? result.exitCode : 0;
  } else {
    process.stdout.write(typeof result === 'string' ? result : raw);
  }
});
```
`activeStateFile` zu Beginn jedes `run()` auf `null` zurücksetzen (wie im Original).

#### C1.8 Geltungsbereich-Sicherheit
Der Hook ist global registriert (feuert in **jedem** Repo). Das ist akzeptabel: er ist überall sinnvoll (Fact-Forcing vor Bash/Edit). Er macht **keine** repo-spezifischen Annahmen. Keine Marker-Datei nötig. Dokumentiere diese Entscheidung in `hooks/README.md` (C5).

---

### C2 — Verdrahtung in `.claude/settings.json` (Repo-Quelle)

**Aktion:** GEÄNDERT. SessionStart-Hinweis **bleibt**; zwei `PreToolUse`-Einträge ergänzen. Der `command`-Pfad zeigt auf das **deployte** Skript (absoluter Pfad; Setup ersetzt den Platzhalter beim Ausrollen — siehe C3). In der **Repo-Quelle** verwenden wir den Platzhalter `__UNI_HOOKS_DIR__`, den die Setup-Skripte beim Kopieren durch den realen absoluten Pfad ersetzen.

Ziel-Inhalt `.claude/settings.json`:
```json
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          { "type": "command", "command": "echo \"Tipp: mit /uni:start beginnen - laedt Stand, Regeln und Git-Status.\"" }
        ]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          { "type": "command", "command": "node \"__UNI_HOOKS_DIR__/fact-forcing-gate.js\"", "timeout": 5 }
        ]
      },
      {
        "matcher": "Edit|Write|MultiEdit",
        "hooks": [
          { "type": "command", "command": "node \"__UNI_HOOKS_DIR__/fact-forcing-gate.js\"", "timeout": 5 }
        ]
      }
    ]
  }
}
```
**Begründung:** Zwei separate Matcher-Einträge (statt Dispatcher-Kette) — exakt das von Recon empfohlene Standalone-Wiring. `timeout: 5` wie im ECC-Original.

> **Wichtig:** Diese Repo-`settings.json` ist **Quelle** für das Setup-Merge, nicht die User-Datei. Der Platzhalter `__UNI_HOOKS_DIR__` darf **nie** in eine User-`settings.json` gelangen — die Setup-Skripte ersetzen ihn (C3).

---

### C3 — Setup-Skripte erweitern (Claude Code: `setup.sh` + `setup.ps1`)

Beide Skripte bekommen einen **neuen Schritt 6** (nach Commands). Aufgaben: (a) `~/.claude/hooks/` anlegen, (b) `fact-forcing-gate.js` dorthin spiegeln, (c) die beiden PreToolUse-Einträge **additiv** in die **vorhandene** `~/.claude/settings.json` mergen (idempotent, Backup, ohne fremde Hooks/Keys zu zerstören).

**Ziel-Pfade:** Skript → `~/.claude/hooks/fact-forcing-gate.js`; Settings-Merge → `~/.claude/settings.json`. Der absolute Hooks-Pfad ersetzt `__UNI_HOOKS_DIR__`.

**Merge-Strategie (idempotent, additiv):**
1. Hooks-Skript kopieren (überschreiben ist ok — Mirror, Quelle gewinnt).
2. Existiert `~/.claude/settings.json` nicht → minimal anlegen mit nur unseren zwei PreToolUse-Einträgen.
3. Existiert sie → **lesen, parsen**, Backup `.bak` anlegen, `hooks.PreToolUse` sicherstellen (Array), **vorhandene UNI-Einträge zuerst entfernen** (Erkennung: `command` enthält `fact-forcing-gate.js`), **dann** die zwei frischen UNI-Einträge anhängen. Fremde Einträge (ECC, SessionStart, user-eigene) bleiben unangetastet. Zurückschreiben.
   → Idempotent: Re-Run entfernt die eigenen alten und setzt sie neu (kein Duplikat-Aufbau).

#### C3.1 `setup.sh` — neuer Schritt 6 (Bash, nutzt `node` für robustes JSON-Merge)
Nach dem Commands-Block (vor dem abschließenden `echo`) einfügen:
```bash
# 6) Fact-Forcing-Gate (Hook) installieren: Skript spiegeln + settings.json additiv mergen.
HOOKS_SRC="$SCRIPT_DIR/.claude/hooks"
HOOKS_DST="$CLAUDE_DIR/hooks"
SETTINGS="$CLAUDE_DIR/settings.json"
if [ -f "$HOOKS_SRC/fact-forcing-gate.js" ]; then
  mkdir -p "$HOOKS_DST"
  cp "$HOOKS_SRC/fact-forcing-gate.js" "$HOOKS_DST/fact-forcing-gate.js"
  # settings.json additiv mergen (node = portables, korrektes JSON; kein jq-Zwang)
  HOOK_CMD="node \"$HOOKS_DST/fact-forcing-gate.js\""
  [ -f "$SETTINGS" ] && cp "$SETTINGS" "$SETTINGS.bak"
  node -e '
    const fs=require("fs"), p=process.argv[1], cmd=process.argv[2];
    let s={}; try{ s=JSON.parse(fs.readFileSync(p,"utf8")); }catch(e){ s={}; }
    s.hooks=s.hooks||{}; const pre=Array.isArray(s.hooks.PreToolUse)?s.hooks.PreToolUse:[];
    const keep=pre.filter(e=>!(e&&Array.isArray(e.hooks)&&e.hooks.some(h=>h&&typeof h.command==="string"&&h.command.includes("fact-forcing-gate.js"))));
    const mk=m=>({matcher:m,hooks:[{type:"command",command:cmd,timeout:5}]});
    s.hooks.PreToolUse=keep.concat([mk("Bash"),mk("Edit|Write|MultiEdit")]);
    fs.writeFileSync(p, JSON.stringify(s,null,2));
  ' "$SETTINGS" "$HOOK_CMD"
  echo "Fact-Forcing-Gate installiert -> $HOOKS_DST/fact-forcing-gate.js ; settings.json gemergt (Backup: $SETTINGS.bak, falls vorhanden)."
fi
```
**Begründung:** `node` ist garantiert vorhanden (das Gate-Skript braucht es ohnehin). JSON-Merge per `node` ist korrekter/robuster als `sed`/`jq`. `keep`-Filter = idempotent. `.bak` nur wenn Datei existierte.

#### C3.2 `setup.ps1` — neuer Schritt 6 (PowerShell-Mirror, `$utf8NoBom` nutzen)
Nach dem Commands-Block einfügen:
```powershell
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
```
**Begründung:** Wir nutzen `node` auch unter Windows fürs Merge — vermeidet die PS-5.1-`ConvertFrom-Json`→`PSCustomObject`-Rekonstruktionsfalle (Recon-Risiko). Absoluter Pfad statt `~` (Recon-Risiko: `~` wird von PowerShell nicht expandiert).

> **Update-Pfad:** `update.sh`/`update.ps1` chainen in `setup.*` → der neue Schritt 6 läuft bei `/update` automatisch. **Keine** Änderung an den Update-Skripten nötig (verifiziert).

---

### C4 — Kimi/Codex-Degradation (ehrliche Grenze)

**Harness-Realität (Recon, verifiziert wo möglich):**
- **Claude Code:** voller PreToolUse-Block (Primärziel). ✅
- **Kimi Code CLI:** Hooks-System **Beta** (v1.28.0), Changelog behauptet exit-2-Blocking + PreToolUse, aber **per-Event-stderr-Semantik öffentlich nicht voll dokumentiert** → **UNVERIFIED**.
- **Codex CLI:** PreToolUse dokumentiert, aber **„intercepts only simple shell calls"** + Instabilität nach Updates → **unzureichend** für ein Gate, das alle Tool-Typen fangen muss.

**Entscheidung:** Tool-Hook-Enforcement bleibt **Claude-Code-only**. Kimi und Codex bekommen **keinen** Tool-Hook deployt (kein verlässlicher Block). Stattdessen:

#### C4.1 Codex (`setup-codex.sh` + `setup-codex.ps1`)
**Deploy:** ein **SessionStart-Reminder** als zusätzliche Zeile im Team-Block der `AGENTS.md` ist bereits durch `claude-sync.md` abgedeckt — **keine** Code-Änderung nötig, aber **ein zusätzlicher Hinweis-Satz** im Abschluss-Echo der Codex-Setup-Skripte, dass das Fact-Forcing-Gate auf Codex **nicht als Tool-Block** läuft. Konkret: nach dem letzten `echo`/`Write-Host` eine Zeile ergänzen:
- `setup-codex.sh`: `echo "  5) HINWEIS: Das Fact-Forcing-Gate (Tool-Block) ist Claude-Code-only. Auf Codex gilt nur die Text-Guidance aus AGENTS.md (kein blockierender Hook)."`
- `setup-codex.ps1`: analoges `Write-Host`.

> **Optional (nur falls Lucas es ausdrücklich will, NICHT im Default-Scope):** ECC-Muster eines Git-`pre-commit`-Hooks (commit-time, nicht tool-time). Da das **schwächer** ist (bypass-bar, fängt nicht den Tool-Call) und außerhalb des hier definierten Scopes, **baut Kimi das nicht**, sondern benennt es nur als offenen Punkt (Abschnitt E).

#### C4.2 Kimi (`setup-kimi.sh` + `setup-kimi.ps1`)
**Deploy:** **kein** Tool-Hook (Beta + UNVERIFIED). Nur ein **Hinweis-Satz** im Abschluss-Echo, analog Codex:
- `setup-kimi.sh`/`.ps1`: Zeile ergänzen: „HINWEIS: Das Fact-Forcing-Gate (Tool-Block) ist Claude-Code-only. Kimis Hooks-System ist Beta und hier nicht als Enforcement verdrahtet; auf Kimi gilt nur die Text-Guidance aus AGENTS.md."

> **Begründung:** Recon zeigt: ECC selbst liefert **keinen** Kimi-Adapter und für Codex nur Git-Level-Hooks — ein klares Signal, dass Tool-Hooks dort nicht enforcement-tauglich sind. Wir spiegeln diese ehrliche Einschätzung, statt einen still versagenden Hook zu deployen.

---

### C5 — Doku / Drift / Version

#### C5.1 `.claude/hooks/README.md` (GEÄNDERT)
- `fact-forcing-gate` aus der Tabelle „Geplante Pflicht-Hooks" **entfernen** und einen neuen Abschnitt **„Aktive Hooks"** anlegen:
  > ## Aktive Hooks
  > | Hook | Typ | Matcher | Zweck | Harness |
  > |---|---|---|---|---|
  > | `fact-forcing-gate` | PreToolUse | `Bash` / `Edit\|Write\|MultiEdit` | erzwingt Faktennennung vor erstem Bash-Kommando (Session) und erster Datei-Berührung; Deny via `permissionDecision:deny` (exit 0) | **Claude Code only** |
- Schluss-Notiz aktualisieren: statt „nur ein harmloser SessionStart-Hinweis aktiv" → „SessionStart-Hinweis **und** das Fact-Forcing-Gate (Claude Code) aktiv; restliche Enforcement-Hooks weiterhin Phase 2."
- Ergänzen: eigener Namespace `UNI_GATE_*`, State in `~/.uni-gate/`, kollisionsfrei zu ECCs `~/.gateguard/`; Escape-Hatch `UNI_GATE_OFF=off` / `UNI_DISABLED_HOOKS`; **Kimi/Codex: kein Tool-Block** (degradiert).

#### C5.2 `CLAUDE.md` — Kopplungs-Karte (GEÄNDERT, exakt diese Zeilen)
Folgende Zeilen der Kopplungs-Karte mitziehen:
1. **„Hook-Status (aktiv vs. geplant)"** — Source of Truth bleibt `.claude/settings.json` + `.claude/hooks/README.md`; in der Mirror-Spalte (`README` · `claude-sync.md §6.2` · `CLAUDE.md`) ergänzen, dass das Fact-Forcing-Gate jetzt **aktiv (Claude Code only)** ist. Auslöser „Hook scharfschalten" trifft zu.
2. **„Install-Pfade & Setup-Flow"** — Source of Truth = die 6 `setup*`-Skripte; ergänzen, dass `setup.sh`/`setup.ps1` jetzt zusätzlich `~/.claude/hooks/` + `settings.json`-Merge ausrollen.
3. **„VERSION / Tags"** — Bump auf 1.4.0 (siehe C5.4).
4. **„Toolkit-Version-Stempel"** — Sweep über alle versionierten Docs (C5.5).
Zusätzlich im Fließtext von `CLAUDE.md` (Abschnitt 0, „aktiv ist nur ein SessionStart-Hinweis") die Aussage aktualisieren, dass nun auch das Fact-Forcing-Gate aktiv ist (Claude Code only).

#### C5.3 `claude-sync.md` §6.2 (GEÄNDERT)
Den Satz „**Stand jetzt ist nur ein harmloser SessionStart-Hinweis aktiv.**" ersetzen durch eine Formulierung, die das Fact-Forcing-Gate als **erste aktive Enforcement** benennt — **Claude-Code-only**, eigener `UNI_GATE_*`-Namespace, Kimi/Codex weiterhin nur Text-Guidance. Die restlichen geplanten Hooks (RB-01-Guard, Secret-Scan, OpenAPI-Diff, Format/Lint, Test-Gate) bleiben Phase 2.

#### C5.4 `VERSION` (GEÄNDERT)
`1.3.0` → `1.4.0` (Minor: additive Feature-Erweiterung, SemVer).

#### C5.5 Versionsstempel-Pflicht-Sweep (GEÄNDERT — alle versionierten Docs auf v1.4.0)
Footer `Toolkit-Version: vX.Y.Z` in **allen** versionierten Dokumenten auf **v1.4.0** setzen:
`README.md` · `CLAUDE.md` · `claude-sync.md` · `Skill-Plan.md` · `Skillanleitung.md` · `gemeinsam/Skills.md` · `abteilung-backend-entwickler/Skills.md` · `abteilung-reviewer-tester/Skills.md` · `ONBOARDING.md` · `erinnerung/README.md` · `Seam-Sync-Fragenkatalog.md` · **dieses Plan-Dokument**.
**Historie NICHT anfassen:** `erinnerung/stand.md`, `erinnerung/journal/`, `Entscheidungslog-*` (append-only, kein rückwirkender Stempel).

#### C5.6 Git-Tag (erst nach Freigabe, Abschnitt F)
Nach Merge: `git tag -a v1.4.0 -m "feat: vendored Fact-Forcing-Gate (Claude Code)" && git push origin v1.4.0` — **nur nach expliziter Freigabe durch Lucas.**

---

## D. Akzeptanz-/Verifikationstests

### D1 — Automatisierte Akzeptanztests `tests/fact-forcing-gate.test.js`
NEUE Datei, Node built-in test runner (`node --test`). Jeder Test ruft das Skript als Subprozess mit JSON über stdin auf (frisches `UNI_GATE_STATE_DIR` pro Test via temp-Dir), prüft Exit-Code und stdout-JSON. **Aus den Recon-Test-Specs abgeleitet** (die wichtigsten — Kimi portiert mindestens diese, idealerweise alle 64 sinngemäß):

| # | Eingabe | Erwartung |
|---|---|---|
| 1 | `{tool_name:"Edit",tool_input:{file_path:"/src/app.js",old_string:"foo",new_string:"bar"}}`, frischer State | exit 0, stdout-JSON `permissionDecision==="deny"`, Reason enthält `Fact-Forcing Gate`, `import/require`, `/src/app.js` |
| 2 | gleiche Edit nochmal (gleicher Session-Key) | exit 0, **kein** `permissionDecision:"deny"` (pass-through) |
| 3 | `{tool_name:"Write",tool_input:{file_path:"/src/new.js",content:"…"}}`, frisch | deny, Reason enthält `creating` + `call this new file` |
| 3b | `UNI_GATE_STATE_DIR` = existierende **Datei** (kein Dir), Write | **kein** deny; stderr enthält `GateGuard state could not be persisted` (fail-open) |
| 4 | `{tool_name:"Bash",tool_input:{command:"rm -rf /important/data"}}` | 1. Call deny (Reason: `Destructive` + `rollback`); 2. Call (gleich) allow |
| 6 | `{command:"git commit --amend --no-edit"}` | deny, `Destructive` + `rollback` |
| 7 | `{command:"git push --force origin feature"}` | deny, `Destructive` |
| 8 | `{command:"ls -la"}` 1./2. Call | 1. deny (Routine, Reason enthält `current user request` + Hook-ID `uni:pre:bash:fact-force`); 2. allow |
| 9 | State `last_active: now-31min`, `checked:["some.js","__bash_session__"]`, Edit `some.js` | deny (Timeout-Reset) |
| 10 | `{tool_name:"Read",tool_input:{file_path:"/src/app.js"}}` | exit 0, **kein** deny (pass-through) |
| 11 | `file_path:"/src/app.js\ninjected"` Edit | deny, Reason enthält `/src/app.js`, **kein** roher `\n`, **kein** `injected`-Anhang |
| 12 | env `UNI_DISABLED_HOOKS="uni:pre:edit-write:fact-force"`, Edit | **kein** deny, kein hookSpecificOutput |
| 13 | env `UNI_GATE_OFF=off`, Write | pass-through (`tool_name==="Write"`), **State-Datei existiert nicht** |
| 14 | env `UNI_GATE_DISABLED="1"`, Bash | pass-through, **keine** State-Datei |
| 15 | env `UNI_GATE_DISABLED="true"` (nicht `"1"`), Bash | **deny** (Routine) — `true` deaktiviert NICHT |
| 16 | Write-Denial-Reason | enthält `UNI_GATE_OFF` **und** `UNI_DISABLED_HOOKS` |
| 17 | Routine-Bash-Denial-Reason | enthält `uni:pre:bash:fact-force`, **nicht** `uni:pre:edit-write:fact-force` |
| 18 | Destruktiv-Bash-Denial-Reason | enthält `Destructive command detected`, **nicht** `UNI_GATE_OFF` |
| 19/20 | MultiEdit edits `[multi-a.js, multi-b.js]` | erst a deny, dann b deny, dann Full-MultiEdit allow |
| 25 | Edit auf `…/.claude/settings.json` | **kein** deny |
| 26 | `{command:"git status --short"}` | **kein** deny (Read-only-Git) |
| 27 | `{command:"git status && rm -rf /tmp/demo"}` | deny (Destruktiv in Chain) |
| 29 | `{ not valid json` | exit 0, stdout == Input (echo) |
| 40 | Edit mit `agent_id:"a-1"` | **kein** deny; gleiche Edit ohne agent_id → deny |
| 43 | Routine-Bash mit `agent_id` | deny (Bash bleibt gegated trotz Subagent) |
| 45 | `git push -f`, `rm -fr`, `rm -r -f`, `rm --recursive --force`, `git reset HEAD --hard`, `git clean -fd` | je deny `Destructive` |
| 47 | `git commit -m 'fix: rm -rf race'` | allow (quoted literal) |
| 48 | `git push --force-with-lease --force-if-includes origin main` | allow |
| 49 | `git push --force --force-if-includes origin main` | deny |
| 57 | env `UNI_GATE_BASH_ROUTINE_DISABLED=1`, `ls -la` | allow (Routine aus) |
| 58 | env `UNI_GATE_BASH_ROUTINE_DISABLED=1`, `rm -rf /x` | deny `Destructive` (Destruktiv bleibt) |
| 60 | env `UNI_GATE_BASH_EXTRA_DESTRUCTIVE='supabase\s+db\s+reset'`, `supabase db reset --linked` | deny `Destructive` |

**Lauf:** `node --test tests/` → alle grün. **Begründung:** Diese Tests decken die load-bearing Invarianten ab (Deny-Allow-Zyklus, State, Tokenizer, Env-Flags im UNI-Namespace, Subagent, Sanitisierung, fail-open).

### D2 — Manueller Verifikationslauf (in einer echten Claude-Code-Session, nach Setup)
1. `bash setup.sh` (bzw. `setup.ps1`) ausführen → prüfen: `~/.claude/hooks/fact-forcing-gate.js` existiert; `~/.claude/settings.json` enthält die zwei PreToolUse-Einträge; `.bak` angelegt; **fremde Hooks (ECC/SessionStart) noch da**.
2. Claude Code **neu starten** (Hooks laden pro Session), `/hooks` zeigt die zwei neuen PreToolUse-Einträge.
3. Im Chat ein erstes Bash-Kommando anstoßen → **Gate feuert, blockt, zeigt** `[Fact-Forcing Gate] … present these facts …`.
4. Die geforderten Fakten nennen, **Retry** desselben Kommandos → **geht durch**.
5. Eine Datei erstmals editieren → Gate feuert (`Before editing … import/require …`); nach Faktennennung Retry → durch.
6. `UNI_GATE_OFF=off` setzen, neue Session → Gate feuert **nicht** (Escape-Hatch verifiziert).
7. ECC-Koexistenz: prüfen, dass ECCs eigene Hooks (falls aktiv) unverändert weiterlaufen und **kein** gemeinsamer State (`~/.gateguard/` vs. `~/.uni-gate/`) entsteht.

---

## E. Risiken & offene Punkte (inkl. aller UNVERIFIED — vor Implementierung gegen Live-Quelle prüfen)

1. **UNVERIFIED — ECC-Quellcode-Details:** Plan stützt sich auf Recon-Zeilennummern/Funktionsnamen. **Kimi liest die installierte `gateguard-fact-force.js` + `shell-substitution.js` real** und übernimmt die zu inlinenden Teile verbatim. Datei nicht auffindbar → STOPP.
2. **UNVERIFIED — Kimi-Hook-Semantik (Beta):** exit-2/stderr-Verhalten pro Event nicht öffentlich voll dokumentiert. **Vor jedem Versuch, auf Kimi zu enforcen**, Live-Doku (`kimi-cli/.../customization/hooks`) prüfen. Plan-Default: **kein** Kimi-Tool-Hook → kein Risiko, aber ehrlich als Lücke benennen.
3. **UNVERIFIED — Codex Tool-Interception:** offiziell „only simple shell calls" + Update-Instabilität (#21639). Default: **kein** Codex-Tool-Hook. Git-pre-commit-Fallback bewusst **nicht** im Scope (nur als offener Punkt notiert).
4. **settings.json-Merge ist der fragilste Schritt:** User-Datei kann ECC-/eigene Hooks enthalten. Mitigation: `node`-basiertes additives Merge (read-parse-inject-write) + `.bak` + idempotenter `keep`-Filter. **Niemals** überschreiben.
5. **`~`-Expansion auf Windows:** `settings.json`-`command` muss **absoluten** Pfad nutzen (kein `~`). Mitigation: Setup ersetzt `__UNI_HOOKS_DIR__` durch `$env:USERPROFILE`-basierten Absolutpfad.
6. **Globaler Geltungsbereich:** Hook feuert in **jedem** Repo, auch hier (nicht nur im Arbeitsrepo). Bewusst akzeptiert (überall sinnvoll); in `hooks/README.md` dokumentiert. Wer hier nicht möchte: `UNI_GATE_OFF=off`.
7. **Parallel-Sessions / State-Race:** gleicher Session-Key bei gleichem cwd ohne `transcript_path`. Mitigation = atomares rename + Read-Merge-Write (aus Original). `CLAUDE_SESSION_ID` setzen, wenn Parallelbetrieb häufig.
8. **exit-1-Falle:** Niemals exit 1 auf Fehlerpfaden (auf Claude Code non-blocking). Wir nutzen durchgängig exit 0 + JSON-deny / fail-open.
9. **Kimi/Codex müssen Setup manuell re-runnen** nach Update (update.sh chained nur Claude). Im Abschluss-Echo bereits vermerkt; erneut in README betonen.
10. **Versionsstempel-Pflicht:** 11+ Docs — fehlt einer, gilt als Bug. Sweep-Liste in C5.5 vollständig abarbeiten.

---

## F. Definition of Done + Git/Freigabe-Schritte

**DoD:**
- [ ] `.claude/hooks/fact-forcing-gate.js` existiert, selbst-enthalten (nur `crypto/fs/path`), **keine** `require('../lib/...')`, **kein** `CLAUDE_PLUGIN_ROOT`, **UNI_GATE_***-Namespace, State in `~/.uni-gate/`.
- [ ] `tests/fact-forcing-gate.test.js` vorhanden; `node --test tests/` **alle grün** (mind. die Tabelle in D1).
- [ ] `.claude/settings.json` (Repo) hat SessionStart **plus** zwei PreToolUse-Einträge mit `__UNI_HOOKS_DIR__`-Platzhalter.
- [ ] `setup.sh` + `setup.ps1`: Schritt 6 deployt Skript + merged `settings.json` **additiv, idempotent, mit Backup**; manueller Lauf (D2 Schritt 1) bestätigt: fremde Hooks bleiben erhalten.
- [ ] `setup-kimi.*` + `setup-codex.*`: Degradations-Hinweis ergänzt (kein Tool-Hook).
- [ ] Manueller Verifikationslauf D2 (Gate feuert beim ersten Bash, blockt, zeigt Botschaft; nach Faktennennung Retry durch) **bestanden** und kurz dokumentiert.
- [ ] `hooks/README.md`, `CLAUDE.md`-Kopplungs-Karte (4 Zeilen + Fließtext), `claude-sync.md §6.2` aktualisiert.
- [ ] `VERSION` = 1.4.0; Versionsstempel-Sweep (C5.5) komplett.
- [ ] ECC-Koexistenz geprüft: getrennte Env-Flags + getrennte State-Dirs, kein Doppel-State.

**Git/Freigabe (claude-sync.md §7 — STRIKT):**
1. Feature-Branch anlegen: `git checkout -b feat/fact-forcing-gate` (kein direkter `master`).
2. Arbeiten, **lokal** committen (Conventional Commits, z. B. `feat: vendored Fact-Forcing-Gate (Claude Code) + setup deploy`). **Nicht** pushen.
3. Tests + manuelle Verifikation grün.
4. **STOPP — Freigabe einholen:** Lucas explizit fragen, bevor `git push`, **PR**, oder Merge. Erst nach „ja":
   `git push -u origin feat/fact-forcing-gate` → PR mit Beschreibung + Test-Plan (D1/D2).
5. Nach Merge **und** Freigabe: Tag `v1.4.0` setzen + pushen (C5.6).
6. **Nach jeder Änderung auf Claude-Code-User-Ebene** (settings.json/Hooks): den Skill **`ecc-guard`** anwenden und prüfen, dass ECC weiterhin „GESUND" meldet (unser Hook darf ECC nicht beschädigt haben). Erst dann „fertig" melden.

---
*Plan erstellt vom Systemarchitekten für Agent „Kimi" · Source-of-Truth für Use-Case-Fakten bleibt `Alarmsystem-Dev` · Toolkit-Version: v1.4.0.*

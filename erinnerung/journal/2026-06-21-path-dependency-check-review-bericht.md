# Review-Bericht: Path- / Dependency-Check Skill-Dateien

**Datum:** 2026-06-21  
**Ziel:** Alle Skill-Dateien im Repo auf interne Pfad- und Abhängigkeitsreferenzen prüfen; falsche/veraltete Pfade oder Referenzen korrigieren.  
**Scope:** `Devteam-vibecodes` (Team-OS-Toolkit für G2)  
**Ausführender:** Kimi Code CLI (automatisiert)  
**Branch-Basis:** `fix/fact-forcing-gate-windows-wiring` @ `8e811f1`

---

## 1. Geprüfte Bereiche

| Bereich | Was geprüft wurde | Werkzeug/Methode |
|---|---|---|
| Skill-Zusammenfassungen | `README.md`, `Skill-Plan.md`, `gemeinsam/Skills.md`, `abteilung-backend-entwickler/Skills.md`, `abteilung-reviewer-tester/Skills.md` | `grep` auf `uni:` / `ecc:` / tote Skills |
| Echte Skill-Dateien | Alle `SKILL.md` unter `.claude/skills/` | `grep` auf interne Pfade und Skill-Referenzen |
| Commands | `.claude/commands/start.md` | Manuelle Lesung |
| Hook-Deployment | `.claude/settings.json`, `.claude/hooks/*`, `setup.sh`, `setup.ps1`, `update.sh`, `update.ps1` | Manuelle Code-Analyse + Test |
| Setup-Hilfsskripte | `setup-kimi.sh`, `setup-codex.sh`, `setup-kimi.ps1`, `setup-codex.ps1` | Stichproben |

---

## 2. Befunde

### 2.1 Skill-Referenzen in Zusammenfassungen — KORREKT

- Alle internen Team-Skills werden konsistent als `uni:<name>` referenziert.
- Mapping `uni:<name>` → existierendes Verzeichnis `.claude/skills/<name>/` ist vollständig.
- `uni:start` ist bewusst kein Skill-Verzeichnis, sondern ein Command (`commands/start.md`), der über das `uni`-Plugin als Skill bereitgestellt wird.

### 2.2 Externe `ecc:`-Referenzen — KORREKT (keine Änderung nötig)

- `ecc:configure-ecc` und `ecc:hookify` in `gemeinsam/Skills.md` / `Skill-Plan.md` sind bewusste Verweise auf das externe ECC-Plugin.
- `Entscheidungslog-Lucas/Lucas-Entscheidungslog.md` erklärt, dass `uni:` kollisionsfrei neben `ecc:` existiert.

### 2.3 Tote / Deprecated Referenzen — NICHT GEFUNDEN

- Keine Referenzen auf `grill-me`, `ck`, `init`, `configure-ecc` als `uni:` oder interne Pfade in den Skill-Dateien.
- `grill-me` war zuvor aus `Skill-Plan.md` und `README.md` entfernt worden (nicht deployt).

### 2.4 Hook-Deployment — INKONSISTENZ GEFUNDEN UND BEHOBEN

**Problem:**
- Der HEAD-Commit `8e811f1` führte `.claude/hooks/merge-settings.js` und `.claude/hooks/pretooluse.template.json` ein.
- `setup.sh` und `setup.ps1` nutzten diese neuen Dateien aber **nicht**; sie enthielten weiterhin identische Inline-Node-Merge-Skripte.
- `.claude/settings.json` enthielt weiterhin `PreToolUse`-Einträge mit `__UNI_HOOKS_DIR__`-Platzhalter, obwohl diese laut neuer Architektur ins `pretooluse.template.json` gehören.
- `setup.sh` hatte zudem zwei Bugs im Inline-Skript:
  - `hooksDir.replace(/\//g, "/")` war syntaktisch fehlerhaft.
  - Der `stderr.write`-String war im Here-Dokument gebrochen (Literal-Newline statt `\n`).

**Risiko:**
- Doppelte Pflege der Merge-Logik in sh + ps1.
- Inkonsistente Quelle für PreToolUse (mal `.claude/settings.json`, mal `pretooluse.template.json`).
- `setup.sh` wäre auf Linux/macOS mit dem HEAD-Stand fehlgeschlagen.

---

## 3. Durchgeführte Änderungen

### 3.1 `.claude/settings.json`
- `PreToolUse`-Block entfernt.
- Enthält jetzt ausschließlich den `SessionStart`-Hinweis.
- Ist damit die korrekte Quelle für SessionStart im Merge.

### 3.2 `.claude/hooks/pretooluse.template.json`
- Unverändert (bereits korrekt im HEAD).
- Enthält die beiden `PreToolUse`-Einträge mit `__UNI_HOOKS_DIR__`-Platzhalter.
- Ist jetzt die korrekte Quelle für PreToolUse im Merge.

### 3.3 `.claude/hooks/merge-settings.js`
- Unverändert (bereits korrekt im HEAD).
- Liest `<user-settings.json> <preToolUse-template.json> <repo-settings.json> <hooks-dir>`.
- Ersetzt `__UNI_HOOKS_DIR__` durch absoluten Forward-Slash-Pfad.
- Fügt SessionStart aus Repo + PreToolUse aus Template idempotent in User-Settings ein.

### 3.4 `setup.sh`
- Inline-Node-Skript entfernt.
- Kopiert jetzt zusätzlich `merge-settings.js` nach `~/.claude/hooks/`.
- Prüft Vorhandensein von `fact-forcing-gate.js`, `settings.json`, `pretooluse.template.json` **und** `merge-settings.js`.
- Ruft `node "$HOOKS_DST/merge-settings.js" "$SETTINGS" "$PRETOOLUSE_TEMPLATE" "$SETTINGS_REPO" "$HOOKS_DST"` auf.

### 3.5 `setup.ps1`
- Inline-Node-Skript entfernt.
- Kopiert zusätzlich `merge-settings.js` nach `~/.claude/hooks/`.
- Prüft Vorhandensein aller vier Dateien.
- Ruft `node $mergeJs $settings $preToolUseTemplate $settingsRepo $hooksDst` auf.

### 3.6 `update.sh` / `update.ps1`
- Keine Änderung nötig; beide rufen nur `setup.sh` bzw. `setup.ps1` auf und profitieren damit von der Korrektur.

---

## 4. Validation

### 4.1 Automatisierter Test

```bash
node --test tests/setup-wiring.test.js
```

**Ergebnis:**
- `setup.ps1 erzeugt valide settings.json mit SessionStart + PreToolUse` → ✅ PASS
- `setup.sh erzeugt valide settings.json mit SessionStart + PreToolUse` → ⏭️ SKIP (Windows-Umgebung)

### 4.2 Manuelle `setup.sh`-Prüfung (Git Bash auf Windows)

```bash
TMP_HOME=$(mktemp -d)
HOME="$TMP_HOME" bash setup.sh
# exit: 0
```

**Ergebnis:**
- `~/.claude/settings.json` enthält korrekt:
  - `SessionStart` mit Hinweis auf `/uni:start`
  - `PreToolUse` mit zwei Matchern (`Bash`, `Edit|Write|MultiEdit`)
  - Absolute Forward-Slash-Pfade zu `fact-forcing-gate.js`
- Backup `~/.claude/settings.json.bak` angelegt.

### 4.3 Diff-Übersicht

Geänderte Dateien im Working Tree:

```
M .claude/settings.json
M setup.ps1
M setup.sh
```

Keine Änderungen an:
- `.claude/hooks/merge-settings.js`
- `.claude/hooks/pretooluse.template.json`
- `.claude/hooks/fact-forcing-gate.js`
- Skill-Dateien unter `.claude/skills/`

---

## 5. Empfehlungen für das Review

1. **Fokus des Reviews:** Hook-Deployment-Architektur (`setup.sh`/`setup.ps1` + `merge-settings.js` + `pretooluse.template.json` + `.claude/settings.json`).
2. **Kritisch prüfen:**
   - Werden `merge-settings.js` und `pretooluse.template.json` von beiden Setup-Skripten korrekt referenziert?
   - Ist `.claude/settings.json` wirklich frei von `PreToolUse` und `__UNI_HOOKS_DIR__`?
   - Funktioniert `setup.sh` auf einem echten Linux/macOS-System?
3. **Nice-to-have:** Der Test `tests/setup-wiring.test.js` überspringt `setup.sh` auf Windows. Auf einem Linux-Runner sollte der Bash-Test aktiv laufen.
4. **Nicht im Scope dieses Checks:** Use-Case-Fakten aus `Alarmsystem-Dev`, Coding-Style der Skill-Inhalte, API-Contract.

---

## 6. Offene Punkte

- Keine.

---

## 7. Fazit

Der Path-/Dependency-Check ist abgeschlossen. Die wesentliche Korrektur betraf die Konsistenz des Hook-Deployments: `setup.sh` und `setup.ps1` verwenden jetzt gemeinsam die bereits eingeführten Hilfsdateien `merge-settings.js` und `pretooluse.template.json`, und `.claude/settings.json` dient ausschließlich als Quelle für den `SessionStart`-Hinweis. Alle geprüften Skill-Referenzen sind korrekt; es wurden keine toten oder falsch aufgelösten Abhängigkeiten gefunden.

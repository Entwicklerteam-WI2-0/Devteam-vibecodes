# Onboarding — In 3 Schritten startklar (Team-OS)

> Ziel: vom blanken Rechner zur fertig konfigurierten Agenten-Umgebung — **ohne** manuelles Gefummel.
> Funktioniert auf **macOS** und **Windows**. Dies ist das **Werkzeug-Repo** (Vibecoding-Stack); der
> Produktcode liegt getrennt im Arbeitsrepo `Alarmsystem-Dev`.

## Schritt 1 — Claude Code installieren (einmalig)
Folge der offiziellen Anleitung für die Claude-Code-CLI. Test: `claude --version` zeigt eine Version.

## Schritt 2 — Vibecoding-Stack klonen
```bash
git clone <REPO-URL-von-Lucas>
cd Devteam-vibecodes
```

## Schritt 3 — Setup ausführen
**macOS:**
```bash
bash setup.sh
```
**Windows (PowerShell):**
```powershell
powershell -ExecutionPolicy Bypass -File setup.ps1
```
Das Skript legt die geteilte Agent-Config als `~/.claude/team-os-g2.md` ab und bindet sie via
`@import`-Block in die globale `~/.claude/CLAUDE.md` ein — die **globale, höchste Anweisung**, die in jeder
Session und jedem Repo gilt. Eine vorhandene persönliche `CLAUDE.md` wird **nicht** überschrieben: ihr
Inhalt bleibt, der Team-Block wird nur ergänzt (Backup wird angelegt).

## Schritt 3 (Variante) — Kimi Code statt Claude Code
Nutzt du **Kimi Code** statt Claude Code, führe stattdessen aus:
```bash
bash setup-kimi.sh                                        # macOS / Linux
powershell -ExecutionPolicy Bypass -File .\setup-kimi.ps1 # Windows
```
Das installiert die **Skills** nach `~/.kimi-code/skills/` (Aufruf `/skill:<name>`), die **globale Anweisung**
nach `~/.kimi-code/AGENTS.md` (additiv) und die **Commands als Skills** — Kimi hat kein Command-Verzeichnis,
daher wird `/start` zu **`/skill:start`** und `/setup` zu `/skill:setup`.

## Schritt 3 (Variante) — Codex CLI statt Claude Code
Nutzt du die **Codex CLI** (OpenAI/ChatGPT): **erst Codex installieren** (`codex --version` muss laufen),
dann denselben Ein-Befehl-Flow:
```bash
bash setup-codex.sh                                        # macOS / Linux
powershell -ExecutionPolicy Bypass -File .\setup-codex.ps1 # Windows
```
Ein Lauf erledigt alles: `claude-sync.md` **additiv** als Team-Block in `~/.codex/AGENTS.md` (globaler
System-Prompt; vorhandene `AGENTS.md` bleibt), alle Skills → `~/.codex/skills/` (nativ), je Skill ein
Command → `~/.codex/prompts/` (Aufruf **`/prompts:<name>`** oder `/` tippen und auswählen), und aktiviert
das Skills-Feature (`codex --enable skills`). War `codex` beim Setup noch nicht installiert, führe danach
**einmal** `codex --enable skills` aus. Dann `codex` starten, „Projekt vertrauen" — Skills laufen
primär automatisch (Aufgabe beschreiben) oder explizit per `/prompts:<name>`.

## Danach — arbeiten
1. Ordner in **VS Code** öffnen.
2. Im integrierten Terminal **`claude`** starten.
3. Beim ersten Mal **„Projekt vertrauen"** bestätigen.
4. **`/start`** tippen → Stand, Regeln und Git-Status werden geladen.

Das Setup installiert Skills + Commands **global** (`~/.claude/skills/` + `~/.claude/commands/`) — sie greifen
in **jedem** Repo (auch `Alarmsystem-Dev`), nicht nur hier. Du musst nichts einzeln einrichten.

## Für die Produktcode-Arbeit
Zum Bauen am eigentlichen System zusätzlich das **Arbeitsrepo** `Alarmsystem-Dev` klonen und dessen
eigenes Setup ausführen — dort liegt der Code samt projekt-spezifischer `CLAUDE.md` (Schwellenwerte,
Anforderungen, Phasen).

## Aktuell bleiben (Updates)
Das Toolkit ist **versioniert** (`VERSION` + Git-Tags, SemVer, **seit v1.0.0**). Von Zeit zu Zeit den
neuesten Stand holen — ein Befehl im geklonten `Devteam-vibecodes`:
```bash
bash update.sh                                         # macOS / Linux
powershell -ExecutionPolicy Bypass -File .\update.ps1  # Windows
```
Holt den neuesten Stand (`git pull`) und führt das Setup erneut aus (frischt `team-os-g2.md`, Skills und
Commands auf, zeigt **Version alt → neu**). Danach **Claude Code neu starten**, damit neue Skills/Commands
geladen werden. In Claude Code geht das nach dem ersten Setup auch per Slash-Command **`/update`**.
(Details: README, Abschnitt „Aktualisieren & Versionierung".)

---

### Wenn etwas klemmt
- **`claude` kennt `/start` nicht** → du bist im falschen Ordner; ins geklonte `Devteam-vibecodes` wechseln.
- **Globale CLAUDE.md kam nicht an** → prüfen, ob `~/.claude/CLAUDE.md` existiert; ggf. `claude-sync.md`
  manuell dorthin kopieren (siehe Skript-Ausgabe).
- **Sonst:** Lucas fragen — nicht raten.

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
Das Skript rollt die geteilte Agent-Config `claude-sync.md` nach `~/.claude/CLAUDE.md` aus — die
**globale, höchste Anweisung**, die in jeder Session und jedem Repo gilt. Eine vorhandene globale
`CLAUDE.md` wird **nicht** überschrieben (Backup wird angelegt).

## Schritt 3 (Variante) — Kimi Code statt Claude Code
Nutzt du **Kimi Code** statt Claude Code, führe stattdessen aus:
```bash
bash setup-kimi.sh                                        # macOS / Linux
powershell -ExecutionPolicy Bypass -File .\setup-kimi.ps1 # Windows
```
Das kopiert die Team-Skills nach `~/.kimi/skills/` (Kimi liest dasselbe `SKILL.md`-Format nativ).
Aufruf im Chat via `/skill:<name>`. Globale Anweisung, Hooks und die Commands `/start`/`/setup` nutzen
in Kimi ein anderes Format und folgen als spätere, spezialisierte Iteration.

## Danach — arbeiten
1. Ordner in **VS Code** öffnen.
2. Im integrierten Terminal **`claude`** starten.
3. Beim ersten Mal **„Projekt vertrauen"** bestätigen.
4. **`/start`** tippen → Stand, Regeln und Git-Status werden geladen.

Die Skills, Befehle und Standard-Checks kommen **automatisch aus dem Repo** — du musst nichts einzeln einrichten.

## Für die Produktcode-Arbeit
Zum Bauen am eigentlichen System zusätzlich das **Arbeitsrepo** `Alarmsystem-Dev` klonen und dessen
eigenes Setup ausführen — dort liegt der Code samt projekt-spezifischer `CLAUDE.md` (Schwellenwerte,
Anforderungen, Phasen).

---

### Wenn etwas klemmt
- **`claude` kennt `/start` nicht** → du bist im falschen Ordner; ins geklonte `Devteam-vibecodes` wechseln.
- **Globale CLAUDE.md kam nicht an** → prüfen, ob `~/.claude/CLAUDE.md` existiert; ggf. `claude-sync.md`
  manuell dorthin kopieren (siehe Skript-Ausgabe).
- **Sonst:** Lucas fragen — nicht raten.

# Stand — Team-OS (Vibecoding-Stack)

**Stand:** 2026-06-18 · **Pflege:** Lucas (Systemarchitekt)

## Woran wird gearbeitet
Aufbau des **Vibecoding-Stacks als eigenständige, vom Arbeitsrepo getrennte Agenten-Heimat**.
Die Tooling-Infrastruktur (zuvor nur im Code-Repo `Alarmsystem-Dev`) wurde hierher übernommen und
**projektneutral generalisiert**, sodass sie im Vibecoding-Stack funktioniert.

## Erledigt
- **`claude-sync.md`** geschrieben — globale, höchste Agenten-Anweisung (Operating Mode = beaufsichtigender
  Coach, Workflow-/Supervisions-Gates, Conventions, Sicherheit, Tooling-Entscheidungen). Use-Case-Fakten
  bewusst ausgelagert ins Arbeitsrepo.
- **`.claude/`-Config** angelegt: `settings.json` (SessionStart-Hinweis), `commands/start.md`,
  `commands/setup.md`, `hooks/README.md` (Hooks-Blueprint).
- **Setup-Skripte** `setup.ps1`/`setup.sh` generalisiert (kein Python/`uv`): rollen `claude-sync.md`
  → globale `~/.claude/CLAUDE.md` aus (idempotent, mit Backup-Guard).
- **`ONBOARDING.md`** + `erinnerung/`-System auf diesen Stack umgeschrieben.
- **Erinnerungs-System** (aus `PLAN-erinnerung-system.md`) umgesetzt: Tages-Journal `erinnerung/journal/<YYYY-MM-DD>.md`
  (append-only), neuer Skill **`erinnerung-update`** (Schreibteil, WP8), `/start` liest nur (kein fetch) +
  zieht heutiges/letztes Journal, `erinnerung/README.md` neu, Git-Ausnahme für `erinnerung/` in `claude-sync.md` §7
  und `git-workflow`. **Status: lokal, uncommittet — wartet auf Lucas-Review/Freigabe.**

## Als Nächstes
- README-Pflege: Vibecoding-README um „Setup & Onboarding" erweitern; Arbeitsrepo-README anpassen
  (Commit/Push nur nach Freigabe durch Lucas).
- **Enforcement-Hooks** (RB-01-Guard, Secret-Scan, Size, Format-Lint, Test-Gate) als Shell-Skripte
  verdrahten (Phase 2 — Team-Infra).
- Use-case-spezifische Workflow-Skills aus dem `Skill-Plan.md` bauen.

## Offen / Blocker
- Sync-Mechanismus für **`.claude/`-Config-Updates** über Member hinweg (aktuell: nur `claude-sync.md`
  via `setup` global; Commands/Hooks liegen repo-lokal).
- `AGENTS.md`/`Agents-gpt-gemini.md` als **generische Vorlage** im Stack — optional, niedrige Prio.

## Vertagt — Multi-Harness (spätere, spezialisierte Iteration)
Der Stack wird **zunächst nur für Claude Code** gebaut — die **meisten Member nutzen Claude**.
**Kimi-CLI / Codex** werden **später spezialisiert nachiteriert**, nicht jetzt. Grundlage dafür:
- Die geteilte Anweisung (`claude-sync.md`) ist **harness-neutral** → portierbar (Claude→`~/.claude/CLAUDE.md`,
  Codex→`AGENTS.md`, Kimi→Config noch zu verifizieren).
- **ECC-Skills/Hooks/Commands bleiben Claude-Code-spezifisch** — auf Kimi/Codex nicht verfügbar; daher
  bleibt Claude der **empfohlene** Standard (Qualitäts-/Methodentreue-Absicherung, vgl. `Entscheidungslog-Toolkit.md`).

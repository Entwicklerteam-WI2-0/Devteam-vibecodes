# Stand — Team-OS (Vibecoding-Stack)

**Stand:** 2026-06-21 · **Pflege:** Lucas (Systemarchitekt)

## Woran wird gearbeitet
Ausbau des **Vibecoding-Stacks als eigenständige, vom Arbeitsrepo getrennte Agenten-Heimat**. Fokus derzeit auf **Nutzerfreundlichkeit** (User Manual) und **ausführbaren Skills** (statt reiner Methodik-Doku).

## Erledigt
- **`claude-sync.md`** geschrieben — globale, höchste Agenten-Anweisung (Operating Mode = beaufsichtigender
  Coach, Workflow-/Supervisions-Gates, Conventions, Sicherheit, Tooling-Entscheidungen). Use-Case-Fakten
  bewusst ausgelagert ins Arbeitsrepo.
- **`.claude/`-Config** angelegt: `settings.json` (SessionStart-Hinweis), `commands/start.md`,
  `commands/setup.md`, `hooks/README.md` (Hooks-Blueprint).
- **Setup-Skripte** `setup.ps1`/`setup.sh` generalisiert (kein Python/`uv`): rollen `claude-sync.md`
  → globale `~/.claude/CLAUDE.md` aus (idempotent, mit Backup-Guard).
- **`ONBOARDING.md`** + `erinnerung/`-System auf diesen Stack umgeschrieben.
- **Erinnerungs-System** umgesetzt: Tages-Journal `erinnerung/journal/<YYYY-MM-DD>.md`
  (append-only), Skill **`erinnerung-update`** (Schreibteil, WP8), `/start` liest nur (kein fetch) +
  zieht heutiges/letztes Journal, `erinnerung/README.md` neu, Git-Ausnahme für `erinnerung/` in `claude-sync.md` §7
  und `git-workflow`.
- **`USERMANUAL.md`** angelegt — deutsches Manual für Nicht-Techies mit Intro, Komponenten-Erklärungen und Glossar.
- **Skills ausführbar gemacht:**
  - `santa-loop`: adversariales Dual-Review mit zwei unabhängigen Subagenten + Konvergenz-Moderator.
  - `review-pr`: DoD-gegateter PR-Review-Orchestrator mit konkreten Tool-Calls.
  - `verification-loop`: konkrete Verifikation des kritischen Pfads (Tests, Schwellen, Coverage, Randfälle).
  - `pmai-shaping`: interaktiver Shaping-Workflow mit Frame → R → S → Fit Check → Slicing.
- **Release v1.5.1** gepusht: Versionsstempel-Sync in allen versionierten Docs, Git-Tag `v1.5.1` gesetzt.
- **`.gitattributes`** erweitert: `.md`, `.json`, `.yaml`, `.yml` explizit auf LF normalisiert.
- **Entscheidungslog** aktualisiert: Eintrag für v1.5.1 in `Entscheidungslog-Lucas/Lucas-Entscheidungslog.md`.

## Als Nächstes
- Verbleibende **MEDIUM-priorisierte Skills** ausführbarer machen (z. B. `code-review`, `security-scan`, `e2e-testing`, `feature-dev`, `plan`).
- **Enforcement-Hooks** (RB-01-Guard, Secret-Scan, Size, Format-Lint, Test-Gate) als Shell-Skripte
  verdrahten (Phase 2 — Team-Infra).
- Sync-Mechanismus für **`.claude/`-Config-Updates** über Member hinweg (aktuell: nur `claude-sync.md`
  via `setup` global; Commands/Hooks liegen repo-lokal).

## Offen / Blocker
- Fertige **Hook-Artefakte + `/install-hooks`-Command** ins Repo (siehe Entscheidungslog 2026-06-20).
- **Stack-Lock** (Python/FastAPI final?) blockt die stack-abhängigen Hooks (`format-lint`/`test-gate`/`openapi-diff`).

## Vertagt — Multi-Harness (spätere, spezialisierte Iteration)
Der Stack wird **zunächst nur für Claude Code** gebaut — die **meisten Member nutzen Claude**.
**Kimi-CLI / Codex** werden **später spezialisiert nachiteriert**, nicht jetzt. Grundlage dafür:
- Die geteilte Anweisung (`claude-sync.md`) ist **harness-neutral** → portierbar (Claude→`~/.claude/CLAUDE.md`,
  Codex→`AGENTS.md`, Kimi→Config noch zu verifizieren).
- **ECC-Skills/Hooks/Commands bleiben Claude-Code-spezifisch** — auf Kimi/Codex nicht verfügbar; daher
  bleibt Claude der **empfohlene** Standard (Qualitäts-/Methodentreue-Absicherung, vgl. `Entscheidungslog-Lucas/Entscheidungslog-Toolkit.md`).

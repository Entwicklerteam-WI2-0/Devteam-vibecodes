# .claude/hooks — Standards als Hooks (erzwungen, nicht erhofft)

Standalone-Skripte, die von `.claude/settings.json` referenziert werden. **Standalone**, damit sie
portabel bleiben (z. B. nach Codex mit reiner Config-Übersetzung). Pflegt: Lucas (Systemarchitekt).

> **Geltungsbereich:** Die Hooks greifen global in **jedem** Repo, sobald `setup.sh`/`setup.ps1` sie
> in `~/.claude/settings.json` verdrahtet hat. Sie entfalten ihre primäre Wirkung im **Arbeitsrepo**
> (`Alarmsystem-Dev`), wo der Produktcode liegt. Dieser Vibecoding-Stack ist ihre **Pflege-/Quell-Heimat**.

## Aktive Hooks

| Hook | Typ | Matcher | Zweck | Harness |
|---|---|---|---|---|
| `fact-forcing-gate` | PreToolUse | `Bash` / `Edit\|Write\|MultiEdit` | Erzwingt Faktennennung vor dem ersten Bash-Kommando (pro Session) und vor der ersten Berührung einer Datei; Deny via `permissionDecision: deny` (exit 0). | **Claude Code only** |

**Details zum `fact-forcing-gate`:**
- Eigener Namespace `UNI_GATE_*` und eigener State-Pfad `~/.uni-gate/` — kollisionsfrei neben ECCs `~/.gateguard/`.
- Escape-Hatches: `UNI_GATE_OFF=off` (komplett aus) oder `uni:pre:bash:fact-force` / `uni:pre:edit-write:fact-force` in `UNI_DISABLED_HOOKS`.
- Auf **Kimi Code** und **Codex CLI** läuft kein Tool-Hook-Enforcement — dort gilt nur die Text-Guidance aus `AGENTS.md`/`claude-sync.md`.

## Geplante Pflicht-Hooks (Phase 2 — noch zu bauen)
| Hook | Typ | Zweck |
|---|---|---|
| `rb01-guard` | PreToolUse (Write/Edit) | blockt Routen mit `release\|freigabe\|sperr\|aktor\|control` → **RB-01** automatisch |
| `secret-scan` | PreToolUse / PreCommit | verhindert Secrets an der Quelle |
| `size-guard` | PreToolUse (Write) | Dateigröße < 800 Z., Funktion < 50 Z. |
| `german-check` | PostToolUse | Artefakte auf Deutsch |
| `format-lint` | PostToolUse (Write/Edit) | Formatter + Linter des jeweiligen Stacks (z. B. `ruff` im Python-Arbeitsrepo) |
| `openapi-diff` | Stop / CI | meldet Änderungen am eingefrorenen Contract |
| `test-gate` | Stop | Testlauf des jeweiligen Stacks muss grün sein |

> Stand jetzt: **SessionStart-Hinweis** plus das **Fact-Forcing-Gate** (Claude Code only) in `settings.json` aktiv. Die übrigen Enforcement-Hooks werden erst verdrahtet, **nachdem** die Stack-Umgebung im Arbeitsrepo bei allen steht (sonst laufen sie ins Leere). Ergänzend serverseitig: GitHub **Branch Protection** (PR-Pflicht, kein `main`-Push).

*Toolkit-Version: v1.4.1*

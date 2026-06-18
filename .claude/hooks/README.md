# .claude/hooks — Standards als Hooks (erzwungen, nicht erhofft)

Standalone-Skripte, die von `.claude/settings.json` referenziert werden. **Standalone**, damit sie
portabel bleiben (z. B. nach Codex mit reiner Config-Übersetzung). Pflegt: Lucas (Systemarchitekt).

> **Geltungsbereich:** Die Enforcement-Hooks unten greifen auf **Code-Arbeit** — sie entfalten ihre
> Wirkung im **Arbeitsrepo** (`Alarmsystem-Dev`), wo der Produktcode liegt. Dieser Vibecoding-Stack
> ist ihre **Pflege-/Quell-Heimat**; aktiv ist hier nur der harmlose SessionStart-Hinweis.

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

> Stand jetzt: nur ein harmloser **SessionStart-Hinweis** in `settings.json` aktiv. Die obigen
> Enforcement-Hooks werden erst verdrahtet, **nachdem** die Stack-Umgebung im Arbeitsrepo bei allen steht
> (sonst laufen sie ins Leere). Ergänzend serverseitig: GitHub **Branch Protection** (PR-Pflicht, kein `main`-Push).

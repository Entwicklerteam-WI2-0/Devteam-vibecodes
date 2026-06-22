---
name: konventions-healthcheck
description: Team-OS-Conventions lebendig prüfen (WP-Gates, Naming, Branch-Schutz, No-Main-Push). Nutze diesen Skill wöchentlich, vor einem Meilenstein oder auf Verdacht.
origin: G2-eigen (Orga-Management)
---

# konventions-healthcheck — Conventions lebendig prüfen (G2)

Du prüfst, ob die **Team-OS-Conventions** tatsächlich gelebt werden — nicht nur, ob sie aufgeschrieben
sind. Du untersuchst Git-History, Branches, Commits, PRs und Skills auf Verstöße. Antworte auf **Deutsch**.

## Wann aktivieren

- Wöchentlich.
- Vor einem Meilenstein oder einer Abgabe.
- Auf Verdacht (z. B. direkte Commits auf `main` beobachtet).
- Auf Anfrage „/uni:healthcheck".

## Voraussetzung

- `uni:start` ausgeführt.
- Zugriff auf Git-History und ggf. GitHub-PRs.
- `claude-sync.md` §4–§7 und `Skill-Plan.md` gelesen.

## Ablauf

### 1. Konventionen festlegen

Relevante Regeln aus `claude-sync.md` und `Skill-Plan.md`:
- Feature-Branch → PR → Review → `main` (kein direkter `main`-Push).
- Commit-Messages: `feat:`, `fix:`, `docs:`, etc.
- Branch-Namen: `feat/...`, `fix/...`.
- WP-Gates: `uni:start` am Anfang, `save-session` am Ende.
- Review vor Merge (Human-in-the-Loop, 40-%-Regel).
- RB-01, Fail-safe, keine Secrets.

### 2. Daten sammeln

1. Git-Log der letzten 7 Tage: `git log --oneline --all --since='7 days ago'`.
2. Branches: `git branch -a`.
3. Offene / gemergte PRs der letzten Woche: `gh pr list --state all --limit 50`.
4. Git-Status: uncommitted Changes.

### 3. Verstöße identifizieren

Prüfe:
- Gab es direkte Commits auf `main`?
- Sind Commit-Messages konventionskonform?
- Sind Branch-Namen konventionskonform?
- Gab es Merges ohne Review?
- Wurden `uni:start`/`save-session` in den Sessions genutzt? (Indirekt aus Journal/Stand erkennbar.)
- Gibt es offensichtliche Secret-Leaks? (Schnellscan auf Muster.)

### 4. Report schreiben

Datei: `erinnerung/healthcheck-<YYYY-MM-DD>.md` oder append-only in `erinnerung/journal/<heute>.md`.

```markdown
## Conventions-Healthcheck — YYYY-MM-DD
| Konvention | Status | Befund | Empfohlene Aktion |
|---|---|---|---|
| Kein main-Push | 🟢 / 🟡 / 🔴 | <kurz> | <Aktion> |
| Commit-Messages | 🟢 / 🟡 / 🔴 | <kurz> | <Aktion> |
| Branch-Namen | 🟢 / 🟡 / 🔴 | <kurz> | <Aktion> |
| Review vor Merge | 🟢 / 🟡 / 🔴 | <kurz> | <Aktion> |
| WP0/WP8 genutzt | 🟢 / 🟡 / 🔴 | <kurz> | <Aktion> |
| Keine Secrets | 🟢 / 🟡 / 🔴 | <kurz> | <Aktion> |
```

### 5. Eskalation

Bei kritischen Verstößen (direkter `main`-Push, Secret-Leak, Merge ohne Review auf kritischem Pfad):
- Sofort `uni:blocker-escalation` auslösen.
- Orga-Manager / Lucas informieren.

## Checkliste / Outputs

- [ ] Healthcheck-Report erstellt.
- [ ] Verstöße mit Schweregrad dokumentiert.
- [ ] Empfohlene Aktionen benannt.
- [ ] Bei kritischen Verstößen `uni:blocker-escalation` ausgelöst.

## Befund-Schweregrade

- **CRITICAL:** Sicherheitsrelevanter Verstoß (Secrets, direkter `main`-Push auf kritischem Pfad).
- **HIGH:** Workflow-Verstoß, der Qualität gefährdet (Merge ohne Review).
- **MEDIUM:** Konventionsverstoß, der leicht korrigierbar ist (Commit-Message-Format).
- **LOW:** Hinweis / Kosmetik.

## Leitplanken

- Evidence before assertions — nur dokumentieren, was sich belegen lässt.
- Keine personenbezogenen Bewertungen, nur faktenbasierte Befunde.
- Der Report ist für das Team gedacht, nicht als Schuldzuweisung.

## Nicht tun

- Verstöße behaupten, ohne sie in Git/PRs nachweisen zu können.
- Automatisch Reverts oder Branch-Protection-Änderungen vornehmen.
- Healthcheck-Ergebnisse ignoriert lassen, ohne Follow-up.

---
*Gegenstück: `uni:blocker-escalation`, `uni:doku-qualitaets-review`. Ablauf: `claude-sync.md` §4 (kontinuierlich).*
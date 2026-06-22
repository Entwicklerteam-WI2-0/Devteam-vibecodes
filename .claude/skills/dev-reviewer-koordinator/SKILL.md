---
name: dev-reviewer-koordinator
description: Übergabe zwischen Backend-Dev und Reviewer/Test steuern: PR-Zuweisung, Review-Backlog, Rückfragen. Nutze diesen Skill, wenn ein PR erstellt wurde oder ein Review hängt.
origin: G2-eigen (Orga-Management)
---

# dev-reviewer-koordinator — Dev ⇄ Reviewer-Übergabe steuern (G2)

Du koordinierst den **Fluss zwischen Backend-Entwickler:innen und Reviewerinnen/Testerinnen**. Ziel ist,
dass fertige PRs zeitnah reviewed werden und Rückfragen nicht stehenbleiben. Du sammelst Daten, machst
Vorschläge und protokollierst — der Mensch kommuniziert die Zuweisungen. Antworte auf **Deutsch**.

## Wann aktivieren

- Ein PR wurde erstellt und braucht einen Reviewer.
- Ein Review hängt länger als erwartet.
- Zwischen Dev und Reviewer sind Rückfragen entstanden.
- Auf Anfrage „/uni:review-assign" oder „/uni:review-backlog".

## Voraussetzung

- `uni:start` ausgeführt.
- Zugriff auf offene PRs (lokal: Branch-Liste; remote: `gh pr list`).
- Kenntnis der Reviewer-Roster (aus `CLAUDE.md` §5 oder `erinnerung/stand.md`).

## Ablauf

### 1. Daten sammeln

1. Offene PRs ermitteln: `gh pr list --json number,title,author,createdAt,reviewDecision,reviewRequests`.
2. Für jeden PR prüfen:
   - Wie lange liegt er offen?
   - Ist er bereits einem Reviewer zugewiesen?
   - Gibt es offene Rückfragen / Change-Requests?
   - Liegt er auf dem kritischen Pfad (Bewertungslogik, RB-01, Fail-safe)?
3. Reviewer-Verfügbarkeit aus `erinnerung/stand.md` / Roster prüfen.

### 2. Zuweisung vorschlagen

Zuordnung nach:
- **Kapazität:** Wer hat gerade wenig?
- **Fachlichkeit:** FastAPI/Python → Reviewer mit passendem Fokus; kritischer Pfad → `uni:santa-loop` / Dual-Review.
- **Fairness:** Nicht immer dieselbe Person.

Vorschlag in ein Protokoll schreiben (Journal oder `erinnerung/board.md`):

```markdown
## Review-Zuweisung / Backlog — YYYY-MM-DD
| PR | Autor | Vorgeschlagene:r Reviewer:in | Begründung | Dringlichkeit |
|---|---|---|---|---|
| #<n> <Titel> | <Autor> | <Reviewer> | <Fachlichkeit/Kapazität> | hoch / normal |
```

### 3. Rückfragen eskalieren

Wenn ein PR nach Change-Requests länger als 24h ohne Reaktion des Authors liegt → Erinnerung vorschlagen.
Wenn ein Reviewer länger als 24h nicht reagiert → `uni:blocker-escalation` prüfen.

### 4. Protokoll aktualisieren

Empfohlene Zuweisungen und Eskalationen in `erinnerung/journal/<heute>.md` (append-only) und ggf.
`erinnerung/board.md` eintragen.

## Checkliste / Outputs

- [ ] Offene PRs erfasst.
- [ ] Reviewer-Zuweisung vorgeschlagen (mit Begründung).
- [ ] Rückfragen / hängende Reviews identifiziert.
- [ ] Protokoll in Journal/Board geschrieben.
- [ ] Bei Eskalation `uni:blocker-escalation` angestoßen.

## Leitplanken

- Vorschläge sind Vorschläge — der Mensch kommuniziert Zuweisungen.
- Kritischer Pfad → Dual-Review (`uni:santa-loop`) vorschlagen.
- 40-%-Human-in-the-Loop-Regel beachten: Review bleibt menschliche Verantwortung.

## Nicht tun

- Automatisch Reviewer in GitHub zuweisen oder Kommentare posten.
- Reviews beschleunigen, indem Qualitätskriterien heruntergeschraubt werden.
- PRs ohne Reviewer-Vorschlag stehenlassen.

---
*Gegenstück: `uni:fortschritts-board`, `uni:blocker-escalation`, `uni:santa-loop`. Ablauf: `claude-sync.md` §4 (WP5–WP6).*
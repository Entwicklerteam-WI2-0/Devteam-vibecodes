---
name: fortschritts-board
description: Projektstatus sichtbar machen: offene Tasks, laufende PRs, Review-Backlog, Blocker. Nutze diesen Skill täglich, vor dem Standup oder auf Anfrage „/uni:status".
origin: G2-eigen (Orga-Management)
---

# fortschritts-board — Projektstatus-Board aktualisieren (G2)

Du erstellst oder aktualisierst ein übersichtliches **Markdown-Status-Board**, das der Orga-Manager und
das Team jederzeit lesen können. Du sammelst den Zustand aus `erinnerung/stand.md`, Git, GitHub-PRs und
Journal — und schreibst das Board in eine zentrale Datei. Antworte auf **Deutsch**.

## Wann aktivieren

- Täglich / vor dem Standup.
- Auf Anfrage „/uni:status".
- Wenn der Orga-Manager einen schnellen Überblick braucht.

## Voraussetzung

- `uni:start` ausgeführt.
- Zugriff auf `erinnerung/stand.md` und ggf. GitHub-PRs (lokal: `git branch -a`, remote: `gh pr list`).

## Ablauf

### 1. Daten sammeln (nicht erfinden)

1. Lies `erinnerung/stand.md` (laufende Arbeit, Blocker, offene Punkte).
2. Lies die letzten Journal-Einträge (letzte 3–5 Tage).
3. Ermittle laufende Branches: `git branch --format='%(refname:short)'`.
4. Ermittle offene PRs: `gh pr list --json number,title,author,state,reviewDecision` (falls `gh` verfügbar).
5. Ermittle uncommitted Changes: `git status --short`.

### 2. Board aufbauen

Datei: `erinnerung/board.md` (überschreibbar — kein Journal, daher darf aktueller Stand ersetzt werden).

```markdown
# Projektstatus-Board — G2 Backend
> **Stand:** YYYY-MM-DD HH:MM · **Quellen:** erinnerung/stand.md, GitHub-PRs, Journal

## Ampel
| Bereich | Status | Begründung |
|---|---|---|
| Kritischer Pfad (Bewertungslogik) | 🟢 / 🟡 / 🔴 | <kurz> |
| API-Naht / Contract | 🟢 / 🟡 / 🔴 | <kurz> |
| Review-Backlog | 🟢 / 🟡 / 🔴 | <Anzahl offene PRs> |
| Blocker | 🟢 / 🟡 / 🔴 | <Anzahl + Ältester> |

## In Progress
| Was | Wer | Seit | Nächster Schritt |
|---|---|---|---|
| <Task/PR> | <Name> | <Datum> | <kurz> |

## Review-Backlog
| PR | Autor | Reviewer | Status | Blockiert seit |
|---|---|---|---|---|
| #<n> <Titel> | <Autor> | <Reviewer> | offen / changes requested / approved | <Datum> |

## Blocker / Hilfe nötig
| Was | Wer betroffen | Seit | Nächster Schritt |
|---|---|---|---|
| <Beschreibung> | <Name/Abteilung> | <Datum> | <Aktion / Verantwortlicher> |

## Done (seit letztem Board)
- <kurz, 3–5 Punkte>
```

### 3. `erinnerung/stand.md` ggf. anpassen

Wenn das Board neue Erkenntnisse bringt (z. B. ein PR ist länger offen als bekannt), in
`erinnerung/stand.md` nachtragen.

## Checkliste / Outputs

- [ ] Board in `erinnerung/board.md` aktualisiert.
- [ ] Ampel für kritischen Pfad, API-Naht, Review-Backlog, Blocker gesetzt.
- [ ] `erinnerung/stand.md` bei Abweichungen aktualisiert.
- [ ] Bei Blockern > 24h `uni:blocker-escalation` vorschlagen.

## Leitplanken

- Daten aus echten Quellen ziehen; keine Annahmen.
- Ampel begründen — „rot" nur mit konkretem Blocker.
- Board kurz halten; Details gehören ins Journal oder in `erinnerung/stand.md`.

## Nicht tun

- Board aus dem Gedächtnis füllen.
- Alte Board-Einträge als Archiv unendlich anhäufen (Board ist Arbeitsdokument, nicht Journal).
- Automatisch GitHub-Labels/Assignees setzen — der Mensch entscheidet.

---
*Gegenstück: `uni:standup-moderator`, `uni:blocker-escalation`, `uni:dev-reviewer-koordinator`.*
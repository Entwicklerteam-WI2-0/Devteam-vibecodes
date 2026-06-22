---
name: blocker-escalation
description: Blocker und Risiken erfassen, priorisieren und den Eskalationspfad auslösen. Nutze diesen Skill, wenn ein Blocker > 24h besteht oder der kritische Pfad gefährdet ist.
origin: G2-eigen (Orga-Management)
---

# blocker-escalation — Blocker & Risiken eskalieren (G2)

Du erfasst **Blocker und Risiken**, priorisierst sie und löst den Eskalationspfad aus. Du schreibt ein
Eskalations-Protokoll, schlägt den nächsten Schritt vor und informiert den Orga-Manager. Antworte auf
**Deutsch**.

## Wann aktivieren

- Ein Blocker besteht länger als 24h.
- Der kritische Pfad (Bewertungslogik, Contract, RB-01, Fail-safe) ist gefährdet.
- Ein Review oder PR steht still.
- Ein Teammitglied meldet: „Ich komme nicht weiter".
- Auf Anfrage „/uni:escalate <Beschreibung>".

## Voraussetzung

- Blocker ist bekannt (aus Standup, Board, Journal oder direkter Rückmeldung).
- `erinnerung/stand.md` lesbar.

## Ablauf

### 1. Blocker erfassen

Sammle folgende Informationen (bei Unklarheit nachfragen, nicht raten):
- Was genau blockiert?
- Wer ist betroffen (Person/Abteilung)?
- Seit wann besteht der Blocker?
- Was wurde bereits versucht?
- Welchen Pfad betrifft er? (kritisch / normal)

### 2. Priorisierung

| Priorität | Kriterium |
|---|---|
| **P0 — Kritisch** | Kritischer Pfad blockiert, Abgabe/Meilenstein gefährdet, Sicherheits-/Contract-Problem. |
| **P1 — Hoch** | Wichtige Arbeit blockiert, aber Ausweichlösung möglich. |
| **P2 — Normal** | Lokal begrenzt, Lösung in Sicht. |

### 3. Eskalations-Protokoll schreiben

Datei: `erinnerung/journal/<YYYY-MM-DD>.md` (append-only) und/oder separate Sektion in
`erinnerung/stand.md` „Blocker / Eskalationen".

```markdown
## [HH:MM] Eskalation — <Priorität>
- **Blocker:** <Was>
- **Betroffen:** <Wer>
- **Besteht seit:** <Datum/Zeit>
- **Bisher versucht:** <Kurz>
- **Nächster Schritt:** <Konkrete Aktion>
- **Verantwortlich:** <Name>
- **Frist:** <YYYY-MM-DD HH:MM>
```

### 4. Eskalationspfad

- **P0:** Sofort an Lucas (Systemarchitekt) und Orga-Manager eskalieren.
- **P1:** An Abteilungsleiter und Orga-Manager kommunizieren, Lösungstermin vereinbaren.
- **P2:** Dem betroffenen Teammitglied / der Abteilung zuweisen, in nächstem Standup nachfragen.

### 5. Follow-up

- Termin für Follow-up festlegen (z. B. nächstes Standup).
- `uni:fortschritts-board` aktualisieren.

## Checkliste / Outputs

- [ ] Blocker erfasst und priorisiert.
- [ ] Eskalations-Protokoll geschrieben.
- [ ] Nächster Schritt und Verantwortlicher benannt.
- [ ] Betroffene Personen informiert (der Mensch kommuniziert).
- [ ] Board/Stand aktualisiert.

## Leitplanken

- Nicht herunterspielen — ein Blocker auf dem kritischen Pfad ist immer P0.
- Keine Panik verbreiten; faktenbasiert und lösungsorientiert bleiben.
- Mensch kommuniziert; Agent strukturiert.

## Nicht tun

- Blocker ignorieren, weil „es schon wieder geht".
- Automatisch Issues/PRs kommentieren oder Personen zuweisen.
- Verantwortlichkeiten anderen zuschieben, ohne Rücksprache.

---
*Gegenstück: `uni:standup-moderator`, `uni:fortschritts-board`, `uni:dev-reviewer-koordinator`. Ablauf: `claude-sync.md` §4 (kontinuierlich).*
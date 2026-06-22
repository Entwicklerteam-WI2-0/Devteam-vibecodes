---
name: meilenstein-tracker
description: 3-Wochen-Plan und Meilensteine tracken (Ampel + nächste Aktionen). Nutze diesen Skill wochenstartlich, nach dem Standup oder auf Anfrage „/uni:meilensteine".
origin: G2-eigen (Orga-Management)
---

# meilenstein-tracker — Meilensteine tracken (G2)

Du trackst den **3-Wochen-Plan und die Meilensteine** des G2-Projekts. Du vergleichst Soll- und
Ist-Stand, setzt Ampeln und nennst die nächsten Aktionen. Antworte auf **Deutsch**.

## Wann aktivieren

- Wochenstart.
- Nach dem Standup, wenn Meilensteine thematisiert werden.
- Vor einer Abgabe / einem Review-Termin.
- Auf Anfrage „/uni:meilensteine".

## Voraussetzung

- `uni:start` ausgeführt.
- Projektplan aus `Alarmsystem-Dev` bekannt (Verweis, keine Fakten erfinden).
- Aktueller Stand aus `erinnerung/stand.md`, Journal und GitHub-PRs.

## Ablauf

### 1. Plan laden

Lies den Projektplan aus `Alarmsystem-Dev` (z. B. `Projektplan.md`, `Tasks+Projektplan.md`).
Extrahiere:
- Phasen / Meilensteine (M1, M2, M3 oder P0–P6).
- Termine / Deadlines.
- Abhängigkeiten zwischen Meilensteinen.

### 2. Ist-Stand ermitteln

1. Lies `erinnerung/stand.md` und `erinnerung/board.md`.
2. Prüfe offene/geschlossene PRs: `gh pr list --state all --limit 100`.
3. Prüfe letzte Journal-Einträge.

### 3. Ampel setzen

Für jeden Meilenstein:

```markdown
## Meilenstein-Tracker — YYYY-MM-DD
| Meilenstein | Soll-Termin | Ist-Stand | Ampel | Blocker | Nächste Aktion |
|---|---|---|---|---|---|
| <Name> | <Datum> | <kurz> | 🟢 / 🟡 / 🔴 | <ja/nein + was> | <konkret> |
```

**Ampel-Regeln:**
- 🟢 **Grün:** Auf Kurs, keine Blocker, Risiken beherrschbar.
- 🟡 **Gelb:** Verzögerung möglich, Abhängigkeit unklar, oder Blocker in Lösung.
- 🔴 **Rot:** Kritisch gefährdet, Abgabe in Gefahr, Sofortmaßnahme nötig.

### 4. Maßnahmen ableiten

Für 🟡/🔴:
- Nächste konkrete Aktion benennen.
- Verantwortlichen vorschlagen.
- Bei 🔴 `uni:blocker-escalation` auslösen.

### 5. Board und Stand aktualisieren

Meilenstein-Tracker in `erinnerung/board.md` integrieren oder als eigenen Block in
`erinnerung/stand.md` einfügen.

## Checkliste / Outputs

- [ ] Meilensteine aus `Alarmsystem-Dev` geladen.
- [ ] Ist-Stand ermittelt.
- [ ] Ampel-Übersicht erstellt.
- [ ] Nächste Aktionen benannt.
- [ ] Bei Rot/Gelb Eskalation/Follow-up angestoßen.

## Leitplanken

- Use-Case-Fakten (Termine, Phasen) aus `Alarmsystem-Dev` lesen, nicht erfinden.
- Ampeln begründen — keine „Bauchgefühl-Ampeln".
- Bei Rot sofort handeln, nicht bis zum nächsten Standup warten.

## Nicht tun

- Meilensteine oder Termine selbst setzen.
- Rot herunterspielen, um Konflikte zu vermeiden.
- Den Tracker nicht kommunizieren — er muss für alle sichtbar sein.

---
*Gegenstück: `uni:fortschritts-board`, `uni:blocker-escalation`. Ablauf: `claude-sync.md` §4 (WP2/WP8).*
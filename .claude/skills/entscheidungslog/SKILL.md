---
name: entscheidungslog
description: Persönliches Entscheidungslog des Entwicklers anlegen und pflegen (G2) — eigene technische Entscheidungen mit Begründung und Alternativen dokumentieren. Bewertungsrelevant (Nachvollziehbarkeit, 40 % Einzelleistung). Nutze diesen Skill bei jeder eigenen nennenswerten Entscheidung und am Session-Ende.
origin: G2-eigen (Use-Case-Skill, kein ECC-Fork)
---

# entscheidungslog — persönliches Entscheidungslog (G2)

Du hilfst der Person, ihr **persönliches** Entscheidungslog anzulegen und laufend zu pflegen. Antworte
auf **Deutsch**. Das Log weist die **eigene Einzelleistung** nach und zahlt direkt auf das benotete
Kriterium **„Nachvollziehbarkeit"** ein (40 % Einzelleistung).

## Wann aktivieren
- Bei jeder **eigenen** nennenswerten technischen Entscheidung (Ansatz, Datenmodell, Bibliothek,
  Bewertungs-Parametrisierung, verworfene Alternative).
- Spätestens **am Session-Ende** (zusammen mit `save-session`) — Tageseinträge nachtragen.

## Anlegen (erstes Mal)
Lege die persönliche Datei mit Kopf an. **Ablageort** gemäß Team-Konvention im Code-Repo
`Alarmsystem-Dev` (z. B. `Team-Organisation+Regeln.md` / `03-abgaben/`) — **nicht erfinden**, im Zweifel
mit Lucas/Team abstimmen. Dateiname mit eigenem Namen, z. B. `entscheidungslog-<name>.md`.

```markdown
# Persönliches Entscheidungslog — <Vorname Nachname> (G2)
> Eigene technische Entscheidungen + Begründung. Bewertungsrelevant (Nachvollziehbarkeit).
```

## Pflegen (pro Entscheidung ein Eintrag)
```markdown
## 2026-06-18 — <Kurztitel der Entscheidung>
- **Kontext/Task:** P#.# · Anf-ID (FA-/NF-/RB-/K-)
- **Entscheidung:** was wurde gewählt?
- **Begründung:** warum? (belegbasiert — Fakten aus `Alarmsystem-Dev`, nicht raten)
- **Alternativen:** was wurde erwogen und warum verworfen?
- **Ergebnis/Status:** umgesetzt / offen / später korrigiert (auch Fehlentscheidungen ehrlich festhalten)
```
Datum im Format `YYYY-MM-DD`. Neueste Einträge oben oder unten — konsistent bleiben.

## Abgrenzung
- **Persönliches** Log (deine Beiträge) ≠ **zentrales** Entscheidungslogbuch des Teams.
- `architecture-decision-records` liefert die ADR-Struktur als Rohstoff; **dieser** Skill ist dein
  laufendes, persönliches Log. Konsolidierung/Doku-Sync über `update-docs`.

## Leitplanken
- **Ehrlich:** auch verworfene Ansätze und Korrekturen festhalten (das zeigt Verständnis).
- **Belegbasiert:** Bezug zu Anf-IDs/Tasks; keine erfundenen Begründungen.
- Deutsch; **keine Secrets**, keine personenbezogenen Bewertungen anderer.

## Nicht tun
- Entscheidungen erst kurz vor Abgabe „rekonstruieren". Alternativen weglassen. Log mit dem zentralen
  Team-Logbuch verwechseln. Ablageort raten statt abzustimmen.

---
*ADR-Struktur: `architecture-decision-records`. Doku-Sync: `update-docs`. Session-Ende: `save-session`. Fakten: `Alarmsystem-Dev`.*

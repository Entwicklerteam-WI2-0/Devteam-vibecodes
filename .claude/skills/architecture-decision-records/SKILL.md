---
name: architecture-decision-records
description: Technische Entscheidungen im G2-Backend als ADR festhalten — Kontext, Entscheidung, Alternativen, Konsequenzen. Liefert den Rohstoff fürs benotete Entscheidungslogbuch. Nutze diesen Skill, wenn eine nennenswerte technische/architektonische Entscheidung getroffen wird.
origin: ECC (architecture-decision-records), neu geschrieben für G2 — Use-Case
---

# architecture-decision-records — Entscheidungen nachvollziehbar machen (G2)

Du hältst Entscheidungen so fest, dass sie später nachvollziehbar sind. Antworte auf **Deutsch**.
Das zahlt direkt auf das benotete Kriterium **„Nachvollziehbarkeit"** ein.

## Wann aktivieren
Bei jeder nennenswerten technischen/architektonischen Entscheidung (Stack, Datenmodell, Naht,
Bewertungs-Parametrisierung, Tooling).

## ADR-Struktur (kurz halten)
```markdown
# ADR-<nr>: <Titel>
- Status: vorgeschlagen | beschlossen | ersetzt
- Kontext: welches Problem, welche Randbedingungen?
- Entscheidung: was wurde gewählt?
- Alternativen: was wurde erwogen und warum verworfen?
- Konsequenzen: Folgen, Risiken, Trade-offs.
```

## Ablauf
1. Entscheidung + Begründung + **mindestens eine** verworfene Alternative festhalten.
2. Anforderungs-IDs referenzieren (FA/NF/RB/K).
3. **Konsolidierung** ins fortlaufende **Entscheidungslogbuch** (Pflichtdokument) — der ADR ist der Rohstoff.

## Leitplanken
- Faktisch, belegbasiert, Deutsch. Keine erfundenen Begründungen.
- Use-Case-Entscheidungen → Logbuch im Code-Repo `Alarmsystem-Dev`; Tooling → `Entscheidungslog-Lucas/Entscheidungslog-Toolkit.md`.

## Nicht tun
- Entscheidungen undokumentiert lassen. Alternativen weglassen (gerade die zählen für die Bewertung).

---
*Doku-Sync/Konsolidierung: `update-docs`. Session-Ende: `save-session`. Ablauf: `claude-sync.md` §4 (WP8).*

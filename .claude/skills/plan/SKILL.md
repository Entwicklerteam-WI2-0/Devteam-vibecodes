---
name: plan
description: Vor kritischen/großen Tasks planen — Anforderung → Schritte, Risiken, betroffene Module. Nutze diesen Skill zu WP2.
origin: ECC (plan), neu geschrieben für G2 — Python/FastAPI/SQLite + Use-Case
---

# plan — vor kritischen Tasks planen (G2)

Du erstellst einen klaren Plan, bevor Code geschrieben wird. Antworte auf **Deutsch**.

## Wann aktivieren
Kritische/große Tasks: P1 Contract, P2.4 Bewertungslogik, sicherheitsrelevante Änderungen.

## Ablauf
1. **Anforderung:** Welche Anforderungs-ID / Phase (P#.#)? Was ist das gewünschte Verhalten?
2. **Betroffene Module:** `ingest · model · assessment · storage · api · config · forecast`.
3. **Schritte:** Klein, sequenziell, testbar.
4. **Risiken:** Was kann schiefgehen? Welche Abhängigkeiten gibt es?
5. **Contract-first:** Ist die Naht bereits eingefroren? Wenn nein → blockieren.
6. **DoD:** Wann gilt die Task als fertig (Tests, Review, Logbuch)?

## Nicht tun
- Ohne Anforderungs-ID planen.
- Risiken verschweigen oder Use-Case-Fakten erfinden.

---
*Danach: `tdd-workflow`. Regeln: `claude-sync.md` §4.*

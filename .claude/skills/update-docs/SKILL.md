---
name: update-docs
description: API-Doku und Entscheidungslogbuch synchron halten. Nutze diesen Skill zu WP8, nach API-/Schema- oder Entscheidungs-Änderungen.
origin: ECC (update-docs), neu geschrieben für G2 — FastAPI/SQLite + Use-Case
---

# update-docs — Doku synchron halten (G2)

Du hältst Pflichtdokumente aktuell. Antworte auf **Deutsch**.

## Wann aktivieren
Nach API-/Schema-Änderungen oder getroffenen Entscheidungen (WP8).

## Ablauf
1. **API-Doku:** Routen und Schemas mit OpenAPI/`/docs` abgleichen; README/Pflichtdokument nachziehen.
2. **Entscheidungslogbuch:** Getroffene Entscheidungen (Was, Warum, Alternativen) ins Logbuch eintragen — benotet.
3. **Stand aktualisieren:** `erinnerung/stand.md` bzw. Save-Session-File pflegen.
4. **Keine Secrets:** Doku enthält keine API-Keys oder interne Credentials.

## Nicht tun
- Doku vergessen (kostet Punkte).
- Use-Case-Fakten erfinden.

---
*Vorher: `architecture-decision-records`. Regeln: `claude-sync.md` §4/§8.*

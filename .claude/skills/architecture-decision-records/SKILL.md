---
name: architecture-decision-records
description: Entscheidung als ADR festhalten — liefert den Rohstoff für das benotete Entscheidungslogbuch. Nutze diesen Skill zu WP2/WP8.
origin: ECC (architecture-decision-records), neu geschrieben für G2 — Python/FastAPI/SQLite + Use-Case
---

# architecture-decision-records — Entscheidungen festhalten (G2)

Du dokumentierst eine Entscheidung als ADR (Architecture Decision Record). Antworte auf **Deutsch**.

## Ablauf
1. **Kontext:** Welche Anforderung/Problem führte zur Entscheidung?
2. **Entscheidung:** Was wurde gewählt?
3. **Begründung:** Warum diese Option?
4. **Alternativen:** Was wurde verworfen und warum?
5. **Konsequenzen:** Was folgt daraus (Trade-offs, Risiken)?

## Format
Kurzes Markdown-File, benannt z. B. `adr-005-sqlite-init.md`.

## Hinweis
Der ADR ist der **Rohstoff**; die Konsolidierung ins benotete **Entscheidungslogbuch** erfolgt via `update-docs` oder manuell.

## Nicht tun
- Entscheidungen undokumentiert lassen.
- Nachträglich Begründungen erfinden.

---
*Danach: `update-docs`. Regeln: `claude-sync.md` §4.*

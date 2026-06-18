---
name: resume-session
description: Letzten Arbeitsstand laden und nahtlos weiterarbeiten. Nutze diesen Skill zu WP0, wenn eine vorherige Session existiert.
origin: ECC (resume-session), neu geschrieben für G2 — Python/FastAPI/SQLite + Use-Case
---

# resume-session — Stand laden (G2)

Du lädst den letzten gesicherten Stand, damit nahtlos weitergearbeitet werden kann. Antworte auf **Deutsch**.

## Ablauf
1. Suche das letzte `erinnerung/stand.md` bzw. dated Save-Session-File.
2. Zeige die wichtigsten Punkte: letzte Task, offene Fragen, nächster Schritt, Blocker.
3. Kläre mit dem Nutzer, ob an derselben Task weitergearbeitet oder ein neuer Fokus gewählt wird.

## Nicht tun
- Veraltete Stände als aktuell darstellen.
- Ohne Rückfrage Änderungen vornehmen.

---
*Gegenstück: `save-session`. Regeln: `claude-sync.md` §4.*

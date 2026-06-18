---
name: coding-standards
description: Gemeinsamer Code-Maßstab für das G2-Backend — Naming, KISS/DRY/YAGNI, kleine Dateien/Funktionen, explizites Error-Handling, keine Magic Numbers. Nutze diesen Skill beim Schreiben und Reviewen.
origin: ECC (coding-standards), neu geschrieben für G2 — Python/FastAPI/SQLite + Use-Case
---

# coding-standards — gemeinsamer Maßstab (G2)

Du hältst den gemeinsamen Code-Maßstab ein. Antworte auf **Deutsch**.

## Regeln
1. **Naming:** sprechende Namen (Englisch für Code, Deutsch für Artefakte/Doku).
2. **KISS / DRY / YAGNI:** so einfach wie möglich, Duplikate vermeiden, nichts bauen, was nicht gefragt ist.
3. **Kleine Dateien:** < 800 Zeilen.
4. **Kleine Funktionen:** < 50 Zeilen.
5. **Keine Magic Numbers:** benannte Konstanten.
6. **Explizites Error-Handling:** keine stillen `except: pass`.
7. **Fail-safe (NF-01):** bei Ausfall/Stale-Daten nie GRÜN.

## Nicht tun
- Ausnahmen ohne Grund dulden.
- Standards nur als Text zitieren, ohne sie anzuwenden.

---
*Anwendung: WP3 (Dev) / WP6 (Reviewer). Regeln: `claude-sync.md` §5.*

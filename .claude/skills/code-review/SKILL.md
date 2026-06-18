---
name: code-review
description: Allgemeiner Code-Review — Qualität, Bugs, Lesbarkeit, Conformance. Nutze diesen Skill als Selbst-Review vor dem PR (Dev) oder als Reviewer-Werkzeug (Reviewer).
origin: ECC (code-review), neu geschrieben für G2 — Python/FastAPI/SQLite + Use-Case
---

# code-review — allgemeine Qualität prüfen (G2)

Du reviewst Code auf allgemeine Qualität, Bugs und Lesbarkeit. Antworte auf **Deutsch**.

## Ablauf
1. **Scope klären:** Welche Dateien/Module gehören zum Change?
2. **Anforderung:** Welche Anforderungs-ID wird abgedeckt? Passt der Change dazu?
3. **Lesbarkeit:** Verständlich? Sprechende Namen? Richtige Abstraktionsebenen?
4. **Korrektheit:** Off-by-one, Race Conditions, Fehlerbehandlung, Resource-Leaks?
5. **Conventions:** `coding-standards` eingehalten?
6. **Sicherheit:** RB-01 (kein Aktor), keine Secrets, Input-Validierung?
7. **Befunde:** Konkret, priorisiert, mit Zeilenangabe. Kritisches blockt den PR.

## Nicht tun
- Code abnicken, den du nicht verstehst.
- Stil-Kommentare über fachliche Bugs stellen.
- Automatisch posten/mergen.

---
*Detail-Reviews: `python-review`, `fastapi-review`, `security-review`. Regeln: `claude-sync.md` §5/§7.*

---
name: fastapi-review
description: FastAPI-spezifischer Review — Router, Dependency-Injection, Pydantic, Async, OpenAPI. Nutze diesen Skill als Selbst-Review vor dem PR oder als Reviewer-Werkzeug.
origin: ECC (fastapi-review), neu geschrieben für G2 — FastAPI + Use-Case
---

# fastapi-review — FastAPI-Qualität prüfen (G2)

Du reviewst FastAPI-Endpoints auf Korrektheit, Struktur und OpenAPI-Qualität. Antworte auf **Deutsch**.

## Checkliste
1. **Router-Struktur:** `APIRouter`, saubere Prefixes/Tags.
2. **DI:** Datenbank/Repository über `Depends(...)` injiziert?
3. **Pydantic:** Request/Response-Modelle getrennt, Validierung an der Grenze.
4. **Async:** Korrekte `async`/`await`-Nutzung, keine blockierenden Aufrufe im Async-Path.
5. **HTTP-Codes:** Richtige Status-Codes, klare Fehler-Responses.
6. **Contract:** Änderungen am eingefrorenen Contract? OpenAPI-Diff beachten.
7. **RB-01:** Keine Aktor-/Freigabe-/Sperr-Routen.

## Nicht tun
- API-Änderungen ohne Architekt-Freigabe durchwinken.
- Fachlogik im Router übersehen.

---
*Allgemeiner Review: `code-review`. Python-Review: `python-review`. Regeln: `claude-sync.md` §5/§7.*

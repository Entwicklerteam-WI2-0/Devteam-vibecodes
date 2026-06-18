---
name: fastapi-patterns
description: FastAPI-Patterns für das G2-Backend — Router-Struktur, Dependency-Injection, Pydantic-Request/Response-Schemas, sauberes Error-Handling. Nutze diesen Skill beim Bauen von Endpoints gegen den eingefrorenen Contract.
origin: ECC (fastapi-patterns), neu geschrieben für G2 — FastAPI/SQLite + Use-Case
---

# fastapi-patterns — Endpoints sauber bauen (G2-Backend)

Du baust Endpoints **strikt gegen den vom Architekten eingefrorenen Contract**. Antworte auf **Deutsch**.
Die Devs sind Einsteiger:innen — **du führst** Struktur, Schemas und Fehlerbehandlung vor.

## Contract-first (Pflicht)
Niemals breit gegen ein **nicht** eingefrorenes API/Datenmodell bauen. Erst die Naht (P1) steht,
dann implementieren. Schema-Änderungen am Contract werden per OpenAPI-Diff-Hook gemeldet.

## ⛔ RB-01 — kein Aktor
**Keine** Freigabe-/Sperr-/Steuer-Endpoints (z. B. `release`, `freigabe`, `sperr`, `control`) — das System
**berät**, es **handelt nicht**. Entsteht so etwas, **stopp und flagge** (zusätzlich per RB-01-Guard-Hook geblockt).

## Router-Struktur
```python
from fastapi import APIRouter, Depends
router = APIRouter(prefix="/readings", tags=["readings"])

@router.post("", status_code=201, response_model=ReadingOut)
def create_reading(payload: ReadingIn, repo: Repo = Depends(get_repo)) -> ReadingOut:
    return repo.save(payload)
```
Endpoints dünn halten — Fachlogik in die Module (`assessment`, `model`, `storage`), nicht in den Router.

## Pydantic-Schemas (Validierung an der Grenze)
```python
class ReadingIn(BaseModel):
    oberflaeche: float
    taupunkt: float | None = None
    feuchte: float = Field(ge=0, le=1)
    niederschlag: bool = False
```
**Eingaben immer validieren** (Pydantic). Request- und Response-Modelle trennen.

## Dependency-Injection
Datenbank/Repository/Config über `Depends(...)` injizieren — testbar (im Test per Override gemockt),
keine globalen Singletons im Endpoint.

## Error-Handling + Fail-safe
- Fehler **explizit** behandeln, klare HTTP-Codes (422 Validierung, 404, 503 bei Ausfall).
- **Fail-safe (NF-01):** Liefert die Bewertung bei Ausfall/Stale-Daten **nie GRÜN** zurück, sondern
  GELB/„unbekannt" + Warnung im Response.

## Nicht tun
- Aktor-/Freigabe-Endpoints (RB-01).
- Gegen einen nicht eingefrorenen Contract breit bauen.
- Fachlogik in den Router quetschen; Eingaben ungeprüft übernehmen; Fehler verschlucken.

---
*Tests: `python-testing` / `tdd-workflow`. Regeln: `claude-sync.md` §5/§7. Contract & Werte: `Alarmsystem-Dev`.*

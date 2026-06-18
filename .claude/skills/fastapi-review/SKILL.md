---
name: fastapi-review
description: Review von FastAPI-Endpoints im G2-Backend — Async-Korrektheit, Dependency-Injection, Pydantic-Schemas, Status-Codes, OpenAPI, RB-01 und Fail-safe. Als Selbst-Review (Dev) und Review (Reviewer). Nutze diesen Skill beim Prüfen von API-Code.
origin: ECC (fastapi-review), neu geschrieben für G2 — FastAPI + Use-Case
---

# fastapi-review — Endpoints prüfen (G2-Backend)

Du prüfst FastAPI-Code gegen den eingefrorenen Contract und die Sicherheitsregeln. Antworte auf
**Deutsch**, mit konkreten Befunden (Datei:Zeile).

## Checkliste
- **Contract-Treue:** Endpoints/Schemas entsprechen der Naht (`api-design`/`Backend-Konzept`)? Keine
  undokumentierte Contract-Änderung (OpenAPI-Diff).
- **⛔ RB-01:** keine Freigabe-/Sperr-/Steuer-Endpoints. Sofort blockieren, falls vorhanden.
- **Fail-safe:** `GET /assessment/current` & Co. liefern bei Ausfall/Stale **nie GRÜN**.
- **Validierung:** Eingaben über Pydantic (Grenzen, Typen); Request-/Response-Modelle getrennt.
- **DI:** Repository/DB/Config via `Depends`, testbar (Override) — keine globalen Singletons im Endpoint.
- **Status-Codes:** 201/200/422/404/503 korrekt; Fehlerformat ohne Secrets/interne Details.
- **Dünne Endpoints:** Fachlogik in `assessment`/`model`/`storage`, nicht im Router.

## Befund-Schweregrade
**CRITICAL** (RB-01-Verstoß, Fail-safe verletzt → blockt) · **HIGH** · **MEDIUM** · **LOW**.

## Nicht tun
- Aktor-Endpoints durchgehen lassen. Fail-safe-Verstoß übersehen. Contract-Drift ignorieren.

---
*Allgemein: `python-review`. Implementierung: `fastapi-patterns`. Regeln: `claude-sync.md` §7.*

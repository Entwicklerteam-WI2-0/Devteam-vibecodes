---
name: api-design
description: REST-API-Design der Naht — Resource-Naming, Status-Codes, Response-Envelope, Fehlerformat, Versionierung. Nutze diesen Skill zu WP2/WP3.
origin: ECC (api-design), neu geschrieben für G2 — FastAPI + Use-Case
---

# api-design — REST-Naht definieren (G2)

Du entwirfst oder prüfst die REST-API-Naht. Antworte auf **Deutsch**. DRI ist der Architekt; Devs implementieren gegen den eingefrorenen Contract.

## Prinzipien
1. **Resource-Naming:** Substantive, Plural, Hierarchie (`/readings`, `/assessments/current`).
2. **Status-Codes:** 201 Created, 200 OK, 400 Bad Request, 422 Validation, 404 Not Found, 503 Service Unavailable.
3. **Response-Envelope:** konsistentes JSON-Format, z. B. `{ "data": ..., "meta": ... }` oder reines Resource-JSON.
4. **Fehlerformat:** `{ "detail": "..." }` oder `{ "error": { "code": "...", "message": "..." } }` — einheitlich.
5. **Versionierung:** Von Beginn an berücksichtigen (z. B. `/v1/...`).
6. **Contract-first:** Änderungen nur nach Architekt-Freigabe; OpenAPI-Diff beachten.

## Nicht tun
- Aktor-/Freigabe-/Sperr-Routen vorschlagen (RB-01).
- Den Contract ohne Freigabe ändern.

---
*Danach: `fastapi-patterns`. Regeln: `claude-sync.md` §5/§7.*

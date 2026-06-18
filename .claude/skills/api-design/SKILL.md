---
name: api-design
description: REST-Design der API-Naht im G2-Backend — Resource-Naming, Status-Codes, Response-Envelope, Fehlerformat, Versionierung. DRI ist der Architekt; Devs implementieren konsistent dagegen. Nutze diesen Skill bei Arbeit an der API-Schnittstelle (der Naht zu G1/G3).
origin: ECC (api-design), neu geschrieben für G2 — FastAPI + Use-Case
---

# api-design — die Naht sauber schneiden (G2-Backend)

Du gestaltest die REST-Schnittstelle, gegen die G1 pusht und G3 konsumiert. Antworte auf **Deutsch**.
**DRI ist der Architekt (Lucas)** — Devs implementieren konsistent gegen das eingefrorene Design.

## Prinzipien
- **Resource-Naming:** Substantive, klein, Plural (`/readings`, `/assessment/current`, `/alarms`).
- **HTTP-Verben korrekt:** GET (lesen, sicher), POST (anlegen), kein Verb im Pfad.
- **Status-Codes:** 200/201 Erfolg, 422 Validierung, 404 nicht gefunden, 503 bei Ausfall/Stale.
- **Response-Envelope:** konsistentes Format (Daten + Fehlerfeld), Request-/Response-Modelle getrennt.
- **Fehlerformat:** maschinenlesbar + klare Meldung; keine internen Details/Secrets leaken.
- **Versionierung:** Contract ist eingefroren — Änderungen sichtbar machen (OpenAPI-Diff-Hook).

## ⛔ RB-01 — kein Aktor
**Keine** Endpoints, die die Startbahn freigeben/sperren/steuern. Nur **Beratung/Abfrage**.

## Fail-safe an der Schnittstelle
`GET /assessment/current` liefert bei Ausfall/Stale **nie GRÜN**, sondern GELB/„unbekannt" + Warnung.

## Ablauf
1. Anforderung + Datenmodell aus `Backend-Konzept.md` (`Alarmsystem-Dev`) prüfen.
2. Endpoints + Schemas entwerfen (mit Architekt abstimmen).
3. Contract festhalten (OpenAPI), dann erst implementieren (`fastapi-patterns`).

## Nicht tun
- Verben in Pfaden, inkonsistente Envelopes, Aktor-Endpoints, undokumentierte Contract-Änderungen.

---
*Implementierung: `fastapi-patterns`. Contract & Datenmodell: `Alarmsystem-Dev`. Regeln: `claude-sync.md` §7.*

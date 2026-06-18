---
name: e2e-testing
description: End-to-End-Tests im G2-Backend — der komplette Pfad von POST /readings über Bewertung bis zum API-Serving, inkl. Integration mit G1 (Sensorik) und G3 (Frontend). Nutze diesen Skill für kritische Durchstich-Flows und die Integrationsphase (M3).
origin: ECC (e2e-testing), neu geschrieben für G2 — FastAPI + Use-Case
---

# e2e-testing — den ganzen Pfad prüfen (G2-Backend)

Du testest den **kompletten Durchstich** der Backend-Kette gegen den Contract. Antworte auf **Deutsch**.
Fokus: kritische Flows, nicht jede Kombination.

## Wann aktivieren
Vertical Slice, Integrationsphase (M3), Naht-Tests mit G1/G3.

## Kritische Flows
1. **Ingest → Bewertung → Serving:** `POST /readings` → Validierung/Persistenz → Bewertung →
   `GET /assessment/current` liefert erwartete Stufe.
2. **Alarm-Pfad:** kritische Messung → Alarm erscheint unter `GET /alarms`.
3. **Vorfall A/B:** End-to-End bestätigen (kalt/trocken → kein Alarm; >0 °C + Eis → Alarm).
4. **Fail-safe:** Ausfall/Stale → `GET /assessment/current` nie GRÜN, sondern GELB/„unbekannt".

## Umsetzung (FastAPI)
- `TestClient` für den vollen Request→Response-Pfad; In-Memory-SQLite für isolierte Läufe.
- Deterministisch: Zeit/externe Quellen mocken. Jeder Test richtet seine Daten selbst ein.

## Leitplanken
- Gegen den **eingefrorenen Contract** testen; Werte aus `Schwellenwerte.md`.
- Naht zu G1/G3 nur über die definierte API — nicht deren Interna mittesten.

## Nicht tun
- Nur Happy-Path. Schwellenwerte raten. Flaky Tests (echte externe Aufrufe) einbauen.

---
*Unit/Integration: `python-testing`. Kritischer Pfad: `verification-loop`. Live-Test der API: `browser-qa`/`verify`.*

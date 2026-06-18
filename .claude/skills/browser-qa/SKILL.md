---
name: browser-qa
description: Live-QA der laufenden Backend-API im G2-Projekt — die echte App starten und Endpoints/Verhalten beobachten (nicht nur Unit-Tests). Nutze diesen Skill, um eine Änderung am laufenden System zu verifizieren, bevor sie freigegeben wird.
origin: ECC (browser-qa), neu geschrieben für G2 — FastAPI + Use-Case
---

# browser-qa — die laufende API wirklich prüfen (G2)

Du verifizierst Änderungen **am laufenden System**, nicht nur in Tests. Antworte auf **Deutsch**.
„Funktioniert" gilt nur mit beobachtetem Verhalten (Evidence before assertions).

## Wann aktivieren
Vor Freigabe einer API-Änderung; in der Integrationsphase; wenn ein Test grün ist, aber das reale
Verhalten bestätigt werden soll (WP7).

## Ablauf
1. **App starten:** `uv run uvicorn src.main:app --reload` (bzw. projektüblich).
2. **Endpoints prüfen:** interaktive Doku unter `/docs` (Swagger) oder gezielte Requests:
   ```bash
   curl -s localhost:8000/assessment/current
   curl -s -X POST localhost:8000/readings -H "Content-Type: application/json" -d '{"oberflaeche":-2.1,"feuchte":0.4}'
   ```
3. **Verhalten beobachten:** Status-Codes, Response-Inhalt, Fail-safe (Ausfall/Stale → nie GRÜN).
4. **Belegen:** beobachtete Ausgabe festhalten; bei Abweichung zurück an den Autor.

## Hinweis Scope
G2 ist **Backend** — geprüft wird die **API**, nicht die G3-UI. (Browser/Swagger nur als API-Werkzeug.)

## Nicht tun
- „Sieht korrekt aus" ohne realen Lauf behaupten. Nur Happy-Path klicken. Fail-safe ungeprüft lassen.

---
*Automatisierte E2E: `e2e-testing`. Eigener Slice live: `verify`. Grundsatz: `claude-sync.md` §1/§4 (WP7).*

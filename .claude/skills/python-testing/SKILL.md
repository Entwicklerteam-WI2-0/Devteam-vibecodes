---
name: python-testing
description: pytest-Handwerk für das G2-Backend — Unit- und Integrationstests mit AAA-Struktur, sprechenden Namen, Fixtures und Mocking. Nutze diesen Skill, wenn du konkrete pytest-Tests schreibst (das WIE); für den TDD-Prozess (RED→GREEN) siehe tdd-workflow.
origin: ECC (python-testing), neu geschrieben für G2 — Python/pytest + Use-Case
---

# python-testing — pytest-Tests schreiben (G2-Backend)

Du schreibst konkrete Tests mit dem Entwickler. Antworte auf **Deutsch**. Dies ist das **Handwerk**
(wie ein guter pytest-Test aussieht); der **Prozess** (Tests zuerst) steht in `tdd-workflow`.

## Testarten
- **Unit** — Bewertungslogik, reine Funktionen, Helfer (schnell, isoliert).
- **Integration** — API-Endpoints (FastAPI `TestClient`), SQLite-Persistenz, Ingest.

## AAA-Struktur + sprechende Namen
```python
def test_stale_daten_nie_gruen():
    # Arrange
    messung = letzte_messung(alter_sekunden=900)  # veraltet
    # Act
    stufe = bewerte_vereisung(messung)
    # Assert
    assert stufe is not Stufe.GRUEN  # Fail-safe: bei Stale nie GRÜN
```
Ein Verhalten pro Test. Name beschreibt das Verhalten (`test_<situation>_<erwartung>`).

## Integrationstest (FastAPI)
```python
from fastapi.testclient import TestClient

def test_post_readings_speichert_messung(client: TestClient):
    resp = client.post("/readings", json={"oberflaeche": -2.1, "feuchte": 0.40})
    assert resp.status_code == 201
```

## Fixtures & Mocking
- Gemeinsame Vorbereitung als `@pytest.fixture` (z. B. `client`, In-Memory-SQLite).
- Externe/instabile Abhängigkeiten (Uhrzeit, externe Quellen) **mocken**, damit Tests deterministisch sind.
- Jeder Test richtet **seine eigenen Daten** ein — keine Abhängigkeit zwischen Tests.

## Use-Case-Pflichttests (Bewertungslogik)
Mindestens: **Vorfall A** (kalt/trocken → kein Alarm), **Vorfall B** (>0 °C aber Eis → Alarm),
**Fail-safe** (Ausfall/Stale → nie GRÜN). Werte nur aus `Schwellenwerte.md` (`Alarmsystem-Dev`) — nichts erfinden.

## Ausführen
```bash
uv run pytest -v
uv run pytest --cov=src --cov-report=term-missing   # Coverage (Ziel ≥ 80 % Bewertungslogik)
```

## Nicht tun
- Implementierungsdetails testen statt beobachtbares Verhalten.
- Tests voneinander abhängig machen oder echte externe Dienste aufrufen.
- Schwellenwerte erfinden.

---
*Prozess: `tdd-workflow`. Coverage-Lücken schließen: `test-coverage`. Use-Case-Fakten: `Alarmsystem-Dev`.*

---
name: verification-loop
description: Verifikation des kritischen Pfads im G2-Backend — Bewertungslogik gegen Schwellenwerte.md und die dokumentierten Vorfälle prüfen. Startet Tests, prüft Coverage, gleicht Schwellen ab und gibt eine Freigabe-Empfehlung.
origin: ECC (verification-loop), neu geschrieben für G2 — Use-Case
---

# verification-loop — kritischen Pfad absichern (G2-Backend)

Du verifizierst die sicherheitskritische Bewertungslogik **gründlich** — hier reicht „Tests grün" allein nicht. Antworte auf **Deutsch**. Belegbasiert: jede Aussage mit Test-/Command-Beweis.

## Wann aktivieren

Vor Freigabe sicherheitskritischer Teile:
- **Bewertungslogik** in `assessment/`
- Alarm-Auslösung
- Plausibilitäts-/Stale-Erkennung

## Voraussetzung

- Du befindest dich im Code-Repo `Alarmsystem-Dev`.
- `Schwellenwerte.md` ist lesbar.
- Die Bewertungslogik ist implementiert und es gibt mindestens einen Testlauf.

## Ablauf

### Schritt 1 — Source of Truth laden

1. Lies `Schwellenwerte.md` aus `Alarmsystem-Dev` vollständig.
2. Notiere dir:
   - Die konkreten Schwellenwerte (z. B. Temperaturen, Feuchtigkeiten).
   - Die definierten Vorfälle (Vorfall A: kalt & trocken; Vorfall B: >0 °C Luft aber Eis).
   - Fail-safe-Regel: Ausfall/Stale → nie GRÜN.

### Schritt 2 — Pflicht-Tests identifizieren und ausführen

Suche die drei Pflicht-Testfälle im Repo:

```bash
# Tests finden, die die Vorfälle oder Fail-safe erwähnen
grep -Rin "vorfall\|fail.safe\|stale\|fehlalarm\|eisbildung" tests/ src/
```

Führe sie gezielt aus:

```bash
uv run pytest -v -k "vorfall_a or vorfall_b or fail_safe or stale or fehlalarm"
```

**Erwartetes Ergebnis:** Alle drei Pflichtfälle existieren als benannte Tests und sind grün.

### Schritt 3 — Schwellenwerte exakt abgleichen

1. Öffne die Bewertungslogik (meist `src/assessment/`).
2. Vergleiche jede verwendete Schwelle mit `Schwellenwerte.md`.
3. Prüfe:
   - Keine hartcodierten Schwellen, die von der Source of Truth abweichen.
   - Schwellen sind zur Laufzeit parametrierbar (Konfiguration, nicht Magic Numbers).
   - Einheiten stimmen (°C, %, etc.).

### Schritt 4 — Grenzwerte und Randfälle prüfen

Stelle sicher, dass folgende Fälle abgedeckt sind:

| Fall | Erwartetes Verhalten | Test prüft? |
|---|---|---|
| Wert knapp über der Schwelle | Korrekte Bewertungsstufe | ✅/❌ |
| Wert knapp unter der Schwelle | Korrekte Bewertungsstufe | ✅/❌ |
| Fehlende Felder im Input | Kein Crash, sicherer Zustand (GELB/unbekannt) | ✅/❌ |
| Sensor-Defekt / unplausibler Wert | Sicherer Zustand (GELB/unbekannt) | ✅/❌ |
| Stale-Daten (veraltet) | Nie GRÜN | ✅/❌ |
| Ausfall (keine Daten) | Nie GRÜN | ✅/❌ |

### Schritt 5 — Coverage prüfen

```bash
uv run pytest --cov=src/assessment --cov-report=term-missing
```

**Erwartet:** ≥ 80 % Coverage auf `assessment/`, inklusive Fehlerpfaden.

### Schritt 6 — Live-Verifikation (optional, aber empfohlen)

Falls die API läuft:

```bash
# App starten
uv run uvicorn src.main:app --reload
```

Spiele die Vorfälle und Fail-safe-Fälle über die API ein und prüfe die Antworten:

```bash
curl -X POST http://localhost:8000/readings \
  -H "Content-Type: application/json" \
  -d '{"sensor_id": "t1", "temperature": -2.1, "humidity": 45, "timestamp": "2026-01-01T12:00:00Z"}'
```

> **Hinweis:** Ersetze das Beispiel durch die tatsächlichen Endpoints und Testdaten aus dem Projekt.

### Schritt 7 — Report erstellen

```markdown
## Verification-Loop Report: [Modul/PR]

### Schwellenwert-Abgleich
| Schwelle | Wert in Schwellenwerte.md | Wert im Code | Status |
|---|---|---|---|
| ... | ... | ... | ✅/❌ |

### Pflicht-Tests
| Test | Status | Bemerkung |
|---|---|---|
| Vorfall A (kalt & trocken) | ✅/❌ | ... |
| Vorfall B (>0 °C, Eis) | ✅/❌ | ... |
| Fail-safe (Stale/Ausfall) | ✅/❌ | ... |

### Coverage
- `assessment/`: **XX %** (Ziel: ≥ 80 %)

### Randfälle
- [Liste der geprüften Randfälle mit Status]

### Freigabe-Empfehlung
✅ Freigabereif / ❌ Nicht freigabereif

### Nächste Schritte
1. ...
2. ...
```

## Eskalation

Bei Unsicherheit oder wenn der kritische Pfad komplex ist → starte `santa-loop` (adversariales Dual-Review). Zwei unabhängige Prüfungen müssen bestehen, bevor freigegeben wird.

## Nicht tun

- „Grün = fertig" ohne die drei Pflichtfälle.
- Schwellenwerte raten oder aus dem Gedächtnis verwenden.
- Fehlerpfade ungeprüft lassen.
- Ohne Belege freigeben.

---
*Tests: `tdd-workflow`/`python-testing`. Coverage: `test-coverage`. Dual-Review: `santa-loop`. Regeln: `claude-sync.md` §7.*
*Toolkit-Version: v1.5.1 · Stand: 2026-06-21*

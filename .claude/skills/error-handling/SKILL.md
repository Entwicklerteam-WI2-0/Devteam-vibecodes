---
name: error-handling
description: Explizites Error-Handling und Fail-safe im G2-Backend — Fehler bewusst behandeln, klare Meldungen, bei Ausfall/Stale-Daten nie GRÜN. Nutze diesen Skill überall, wo etwas schiefgehen kann (Ingest, Bewertung, Persistenz, API).
origin: ECC (error-handling), neu geschrieben für G2 — Python + Use-Case
---

# error-handling — Fehler bewusst behandeln + Fail-safe (G2-Backend)

Du sorgst dafür, dass Fehler **explizit** behandelt werden — nichts wird still verschluckt. Antworte
auf **Deutsch**. Im Sicherheitskontext (Vereisung) ist der **sichere Zustand** entscheidend.

## Grundregeln
- **Spezifisch fangen:** `except ValueError:` statt nacktem `except:`; nur fangen, was du behandeln kannst.
- **Nicht verschlucken:** Fehler entweder behandeln **oder** weitergeben — nie leer schlucken.
- **Klare Meldungen:** für Aufrufer verständlich; serverseitig Kontext loggen, aber **keine Secrets/internen Details** im Response.
- **An Grenzen validieren:** Eingaben (Ingest/API) mit Pydantic prüfen, bevor sie weiterlaufen.

## ⛔ Fail-safe (NF-01) — der wichtigste Fall
Bei **Ausfall, Sensordefekt oder veralteten (Stale-)Daten** gibt die Bewertung **nie GRÜN** zurück,
sondern **GELB/„unbekannt" + Warnung**. Lieber ein Fehlalarm als eine verpasste Vereisung.
```python
def bewerte_vereisung(m: Messung | None) -> Stufe:
    if m is None or ist_stale(m.alter):
        return Stufe.UNBEKANNT  # niemals GRUEN bei fehlenden/alten Daten
    ...
```

## Pflicht-Test
**Fail-safe muss als benannter, grüner Test existieren** (`test_stale_daten_nie_gruen`) — siehe
`tdd-workflow`/`test-coverage`.

## Nicht tun
- Nacktes `except`, Fehler still schlucken, bei Ausfall GRÜN liefern, interne Details im Response leaken.

---
*Pattern: `python-patterns`. Tests: `tdd-workflow`. Werte/Regeln: `Schwellenwerte.md`, `claude-sync.md` §7.*

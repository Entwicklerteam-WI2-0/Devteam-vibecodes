---
name: error-handling
description: Explizites Error-Handling + Fail-safe für das G2-Backend. Nutze diesen Skill bei WP3, besonders bei der Bewertungslogik.
origin: ECC (error-handling), neu geschrieben für G2 — Python/FastAPI/SQLite + Use-Case
---

# error-handling — Fehler explizit behandeln (G2)

Du implementierst explizites Error-Handling mit Fail-safe-Verhalten. Antworte auf **Deutsch**.

## Regeln
1. **Spezifische Exceptions:** Niemals `except Exception: pass`.
2. **Klare HTTP-Codes:** 422 Validierung, 404 Not Found, 503 bei Ausfall.
3. **Fail-safe (NF-01):** Bei Ausfall oder veralteten (Stale-)Daten → **nie GRÜN**, sondern GELB/„unbekannt" + Warnung.
4. **Logging:** Fehler und Warnungen loggen, aber keine Secrets.
5. **Grenzen:** Validierung an der API-Grenze (Pydantic), Fehlerbehandlung in der Fachlogik.

## Beispiel
```python
try:
    messung = repo.latest()
except StorageError:
    logger.warning("Messung nicht lesbar — Fail-safe")
    return Assessment(stufe=Stufe.GELB, warnung="Daten unvollständig")
```

## Nicht tun
- Fehler verschlucken.
- Bei Ausfall GRÜN liefern.
- Secrets in Fehlermeldungen ausgeben.

---
*Tests: `tdd-workflow`. Regeln: `claude-sync.md` §5/§7.*

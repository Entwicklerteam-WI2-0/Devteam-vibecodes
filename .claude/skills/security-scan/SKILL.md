---
name: security-scan
description: Schneller, fokussierter Sicherheits-Quick-Scan im G2-Backend — der mechanische Gate-Check direkt vor Commit/Merge: Secrets, SQL-Injection, Eingabevalidierung, RB-01, Fehler-Leaks. Bewusst schlank; den vollständigen strukturierten Sicherheits-Review (Fail-safe-Tiefe, Audit/Datenintegrität, Schweregrad-Triage, menschliche Verantwortung) liefert `security-review`. Nutze diesen Skill als schnellen Scan an Ingest-/API-/DB-Code.
origin: ECC (security-scan), neu geschrieben für G2 — Use-Case
---

# security-scan — schneller Sicherheits-Quick-Scan (G2-Backend)

Du machst den **schnellen, mechanischen** Sicherheits-Durchlauf direkt am Gate (vor Commit/Merge) —
gezielt auf die Befunde mit dem höchsten Signal. Antworte auf **Deutsch**, mit konkreten Befunden
(Datei:Zeile) und Schweregrad. CRITICAL blockt den Merge.

> **Abgrenzung zu `security-review`:** Dieser Skill ist der **operative Quick-Scan** — schlank, schnell,
> als Gate. Den **strukturierten Rahmen** (Fail-safe als verifizierter Test, Audit-Trail/Datenintegrität,
> Schweregrad-Triage, Abhängigkeits-Bewertung, menschliche Verantwortung nach der 40 %-Regel) liefert
> `security-review`. Nicht doppeln: **hier** schnell scannen, **dort** strukturiert reviewen.

## Wann aktivieren
Schneller Check an **Ingest-/API-/DB-Code**, unmittelbar **vor Commit (WP4)** bzw. **vor PR/Merge** —
ergänzt `quality-gate` (Secret-Scan-Hook). Für einen vollständigen PR-Sicherheits-Review → `security-review`.

## Quick-Checks (High-Signal-Mechanik)
- **Keine Secrets:** keine API-Keys/Tokens/Passwörter im Code, in Logs oder Commits → Env/Secret-Manager.
- **SQL-Injection:** **parametrisierte** Queries, keine String-Konkatenation in SQL.
- **Eingabevalidierung:** alle externen Daten (POST /readings, Query-Params) über Pydantic (Typen, Bereiche).
- **⛔ RB-01:** keine Aktor-/Freigabe-Endpoints (Security- *und* Safety-relevant) → sofort blocken.
- **Fehler-Leaks:** Fehlermeldungen ohne interne Details/Stacktraces/Secrets nach außen.

## Befund-Schweregrade
**CRITICAL** (Secret/Injection/RB-01 → blockt) · **HIGH** · **MEDIUM** · **LOW**.

## Bei Fund
STOPP, Befund + Fix vorschlagen; exponierte Secrets als rotationsbedürftig markieren. Bei breiterem oder
sicherheitskritischem Verdacht (Fail-safe, Audit/Datenintegrität, Dependencies) → in den vollen `security-review`.

## Nicht tun
- Eingaben ungeprüft übernehmen. SQL zusammenstückeln. Secrets committen. Aktor-Endpoints zulassen.
- Den Quick-Scan als vollständigen Sicherheits-Review ausgeben (dafür `security-review`).

---
*Voller Rahmen: `security-review`. Reviews: `python-review`/`fastapi-review`. Vor Commit: `quality-gate`. Regeln: `claude-sync.md` §7.*

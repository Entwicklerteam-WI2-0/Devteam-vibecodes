---
name: security-scan
description: Sicherheits-Check im G2-Backend — Eingabevalidierung, keine Secrets, SQL-Injection-Schutz, RB-01, Fehler ohne Datenleck. Nutze diesen Skill bei Ingest-/API-/DB-Code und vor dem PR/Merge.
origin: ECC (security-scan), neu geschrieben für G2 — Use-Case
---

# security-scan — Sicherheit prüfen (G2-Backend)

Du prüfst Code auf Sicherheitsprobleme. Antworte auf **Deutsch**, mit konkreten Befunden (Datei:Zeile)
und Schweregrad. CRITICAL blockt den Merge.

## Checkliste
- **Eingabevalidierung:** alle externen Daten (POST /readings, Query-Params) über Pydantic geprüft
  (Typen, Bereiche). Nie ungeprüft weiterverarbeiten.
- **Keine Secrets:** keine API-Keys/Tokens/Passwörter im Code, in Logs oder Commits → Env/Secret-Manager.
- **SQL-Injection:** **parametrisierte** Queries, keine String-Konkatenation in SQL.
- **Fehler-Leaks:** Fehlermeldungen ohne interne Details/Stacktraces/Secrets nach außen.
- **⛔ RB-01:** keine Aktor-/Freigabe-Endpoints (Security- *und* Safety-relevant).
- **Datenintegrität:** Audit-Log append-only; keine unkontrollierten Schreibpfade.
- **Abhängigkeiten:** keine offensichtlich unsicheren/veralteten Pakete einführen.

## Befund-Schweregrade
**CRITICAL** (Secret/Injection/RB-01 → blockt) · **HIGH** · **MEDIUM** · **LOW**.

## Bei Fund
STOPP, Befund + Fix vorschlagen; exponierte Secrets als rotationsbedürftig markieren.

## Nicht tun
- Eingaben ungeprüft übernehmen. SQL zusammenstückeln. Secrets committen. Aktor-Endpoints zulassen.

---
*Reviews: `python-review`/`fastapi-review`. Regeln: `claude-sync.md` §7. Vor Commit: `quality-gate` (Secret-Scan-Hook).*

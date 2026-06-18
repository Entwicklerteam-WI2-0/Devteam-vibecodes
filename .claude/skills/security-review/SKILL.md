---
name: security-review
description: Sicherheits-Review als Dual-Use-Rahmen im G2-Backend — Eingabevalidierung, RB-01, Fail-safe, Secrets, Audit. Nutze diesen Skill als Selbst-Review (Dev) und als Reviewer-Werkzeug; fokussierte Scans laufen über `security-scan`.
origin: ECC (security-review), neu geschrieben für G2 — Use-Case
---

# security-review — Sicherheit bewusst prüfen (G2-Backend)

Du führst einen **strukturierten Sicherheits-Review** durch — als **Selbst-Review** vor dem PR (WP5)
oder als Reviewer-Check (WP6). Antworte auf **Deutsch**, mit konkreten Befunden (`Datei:Zeile`).

Dieser Skill ist der **Rahmen**; für den fokussierten operativen Scan nutzt du `security-scan`.

## Wann aktivieren
- Bei jedem PR, der Ingest, API, Persistenz, Bewertungslogik oder Alarme berührt.
- Vor Freigabe sicherheitskritischer Änderungen (RB-01, Fail-safe).

## Checkliste
- **⛔ RB-01 — kein Aktor:** Keine Freigabe-/Sperr-/Steuer-Endpoints. Falls vorhanden: **CRITICAL,
  sofort blocken**.
- **Eingabevalidierung:** Alle externen Daten (POST /readings, Query-Params) über Pydantic geprüft;
  Bereiche und Typen beschränkt.
- **Fail-safe (NF-01):** Bei Ausfall oder veralteten/Stale-Daten wird **nie GRÜN** ausgegeben.
- **Keine Secrets:** Keine API-Keys, Tokens oder Passwörter im Code, in Logs oder Commits.
- **SQL-Injection:** Parametrisierte Queries; keine String-Konkatenation in SQL.
- **Fehler-Leaks:** Fehlermeldungen geben keine internen Details, Stacktraces oder Secrets preis.
- **Datenintegrität & Audit:** Schreibpfade nachvollziehbar; Audit-Log append-only.
- **Abhängigkeiten:** Keine offensichtlich unsicheren oder veralteten Pakete eingeführt.

## Befund-Schweregrade
**CRITICAL** (RB-01/Secret/Injection → blockt) · **HIGH** · **MEDIUM** · **LOW**.

## Haltung
- Evidence-based: jeden Befund mit Code-Zeile belegen.
- Mensch versteht und verantwortet den Review (40 %-Regel) — nicht blind posten.
- Bei CRITICAL: STOPP, Fix vorschlagen, exponierte Secrets als rotationsbedürftig markieren.

## Nicht tun
- Aktor-Endpoints durchgehen lassen. Eingaben ungeprüft akzeptieren. Secrets übersehen.

---
*Operativer Scan: `security-scan`. Fach-Reviews: `python-review`, `fastapi-review`. Regeln: `claude-sync.md` §7.*

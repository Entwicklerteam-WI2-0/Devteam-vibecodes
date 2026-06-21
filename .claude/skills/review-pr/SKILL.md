---
name: review-pr
description: Vollständiges Pull-Request-Review der Reviewer/Test-Abteilung (G2) — der DoD-gegatete Orchestrator. Startet code-tour, code-review, python-review, fastapi-review, security-review und verification-loop, fasst Befunde zusammen und gibt eine Freigabe-Empfehlung. Für reine Diff-Prüfung → code-review.
origin: ECC (review-pr), neu geschrieben für G2 — Use-Case
---

# review-pr — Pull Request prüfen (G2)

Du führst das **vollständige** PR-Review der Reviewer/Test-Abteilung durch. Antworte auf **Deutsch**. Der **Mensch verantwortet die Freigabe** (40-%-Regel) — du lieferst fundierte Befunde, kein blindes Durchwinken.

> **Abgrenzung zu `code-review`:** Dieser Skill ist der **Orchestrator** — er bündelt die Bausteine zu einer DoD-gegateten Freigabe-Entscheidung. Die reine inhaltliche Diff-Bewertung: `code-review`.

## Wann aktivieren

Neuer PR der Backend-Abteilung ist offen (Workflow-Punkt WP6).

## Voraussetzung

- PR-URL, Branch-Name oder Commit-Range ist bekannt.
- Du befindest dich im Code-Repo `Alarmsystem-Dev` (nicht im Tooling-Repo).

## Ablauf

### Schritt 1 — Kontext laden

1. Führe `uni:start` aus (bzw. `/skill:start` in Kimi / `/prompts:start` in Codex).
2. Zeige den aktuellen Git-Status und den offenen PR an:
   ```bash
   git status --short
   git log --oneline -10
   ```
3. Falls `gh` verfügbar ist, zeige PR-Details:
   ```bash
   gh pr view [PR-NUMMER] --json title,body,author,headRefName,baseRefName
   ```

### Schritt 2 — Änderungen verstehen (`code-tour`)

1. Lies den Diff des PR:
   ```bash
   git diff origin/main...[BRANCH]
   ```
   oder lade den PR-Diff über `gh pr diff [PR-NUMMER]`.
2. Identifiziere:
   - Welche Anforderungs-ID(en) werden bearbeitet?
   - Welche Module wurden berührt (`ingest`, `model`, `assessment`, `storage`, `api`, `config`, `forecast`)?
   - Gibt es Änderungen am eingefrorenen Contract/API?

### Schritt 3 — DoD prüfen

1. **Tests ausführen:**
   ```bash
   uv run pytest -q
   ```
   oder das im Projekt übliche Test-Kommando.
2. **Coverage der Bewertungslogik prüfen:**
   ```bash
   uv run pytest --cov=src/assessment --cov-report=term-missing
   ```
   Ziel: ≥ 80 % auf `assessment/`.
3. **Kritischer Pfad:** Suche die benannten Tests für Vorfall A, Vorfall B und Fail-safe. Sind sie vorhanden und grün?
   ```bash
   uv run pytest -v -k "vorfall_a or vorfall_b or fail_safe or stale"
   ```
4. **Anforderungs-ID und Entscheidungslogbuch:**
   - Ist im PR-Body oder in Commit-Messages eine Anforderungs-ID referenziert (z. B. `FA-01`, `P2.4`)?
   - Gibt es einen Eintrag im Entscheidungslogbuch des Authors (`Entscheidungslog-[Name]/`)?

### Schritt 4 — Qualitätsprüfung

1. **Code-Review:** Wende `code-review` auf den Diff an.
2. **Python-spezifisch:** Wende `python-review` an (PEP 8, Typing, Idiome).
3. **FastAPI-spezifisch:** Wende `fastapi-review` an (Async, Dependency Injection, Pydantic-Schemas, OpenAPI).
4. Prüfe manuell:
   - Keine Magic Numbers, benannte Konstanten.
   - Kleine Dateien/Funktionen (< 800 Zeilen Datei, < 50 Zeilen Funktion).
   - Explizites Error-Handling.

### Schritt 5 — Sicherheitsprüfung

1. **Schneller Gate-Scan:** `security-scan` auf den geänderten Dateien.
2. **Strukturierter Sicherheits-Review:** `security-review` mit Fokus auf:
   - Eingabevalidierung.
   - Keine Secrets/Tokens im Diff.
   - **RB-01:** Keine Aktor-/Freigabe-/Sperr-Endpoints.
   - **Fail-safe:** Ausfall/Stale-Daten führen nie zu „GRÜN".

### Schritt 6 — Kritischer Pfad verifizieren (`verification-loop`)

1. Starte `verification-loop` für die Bewertungslogik.
2. Bei Unsicherheit oder hohem Risiko: Starte zusätzlich `santa-loop` (adversariales Dual-Review).

### Schritt 7 — Befunde zusammenfassen und Freigabe-Empfehlung

Erstelle einen strukturierten Report:

```markdown
## PR-Review: [Titel] ([PR-URL])

### DoD-Status
| Kriterium | Status | Bemerkung |
|---|---|---|
| Tests grün | ✅/❌ | ... |
| Coverage assessment ≥ 80 % | ✅/❌ | ... |
| Vorfall A/B + Fail-safe als grüne Tests | ✅/❌ | ... |
| Anforderungs-ID referenziert | ✅/❌ | ... |
| Entscheidungslogbuch | ✅/❌ | ... |

### Qualität
- [Befunde aus code-review / python-review / fastapi-review]

### Sicherheit
- [Befunde aus security-review / security-scan]

### Kritischer Pfad
- [Befunde aus verification-loop / santa-loop]

### Freigabe-Empfehlung
✅ Freigabereif / ❌ Nicht freigabereif — Rückgabe an Autor

### Nächste Schritte
1. ...
2. ...
```

## Freigabe-Kriterium

**Freigabe nur**, wenn:
- Keine offenen CRITICAL-Befunde.
- Keine offenen HIGH-Befunde, die den kritischen Pfad betreffen.
- DoD vollständig (Tests grün, Coverage ≥ 80 %, Vorfall A/B + Fail-safe geprüft, Anforderungs-ID, Logbuch).

Sonst: **zurück an den Autor**.
Merge selbst **erst nach Freigabe durch Lucas**.

## Nicht tun

- Durchwinken ohne Verständnis/erfüllte DoD.
- RB-01-/Fail-safe-Verstöße übersehen.
- Den Merge eigenmächtig durchführen.

---
*Verstehen: `code-tour`. Qualität: `python-review`/`fastapi-review`. Kritischer Pfad: `verification-loop`/`santa-loop`.*
*Toolkit-Version: v1.5.1 · Stand: 2026-06-21*

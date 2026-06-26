---
name: uni-review-orchestrator
description: Use when a holistic UNI code review, QA and convention check is needed in the G2 backend — PR review, pre-release check, or milestone gate.
---

# uni-review-orchestrator — Ganzheitlicher UNI-Review

## Overview
Dieser Skill fasst alle relevanten UNI-Review-Skills zu einer durchlaufenden Kette zusammen. Die einzelnen Skills bleiben weiterhin manuell aufrufbar; der Orchestrator garantiert Vollständigkeit und eine sinnvolle Reihenfolge.

## When to Use
- Vor der Freigabe eines PR (Workflow-Punkt WP6).
- Vor einem Release oder einer Abgabe.
- Vor einem Meilenstein oder Qualitäts-Gate.
- Wann immer sichergestellt werden soll, dass keine Review-Dimension vergessen wird.

## The Chain

Rufe die folgenden Skills in dieser Reihenfolge auf. Keinen Schritt überspringen, außer es liegt eine begründete Ausnahme vor.

1. **`code-tour`** — Änderungen verstehen, bevor geurteilt wird.
2. **`python-review`** — Python-Qualität, Typing, Idiome, Fehlerbehandlung.
3. **`fastapi-review`** — API-/Endpoint-Qualität, Contract, RB-01, Fail-safe (nur wenn Endpoints betroffen).
4. **`security-review`** — Eingabevalidierung, RB-01, Fail-safe, Secrets, SQL-Injection, Audit.
5. **`test-coverage`** — Coverage messen, Lücken schließen, ≥ 80 % auf `assessment/` sicherstellen.
6. **`verification-loop`** — Kritischen Pfad gegen `Schwellenwerte.md` und dokumentierte Vorfälle prüfen.
7. **`doku-qualitaets-review`** — Nicht-Code-Doku auf Vollständigkeit, Aktualität und Verständlichkeit prüfen.
8. **`quality-gate`** — Formatter, Linter, keine Secrets, Build grün vor dem Commit.
9. **`konventions-healthcheck`** — Team-OS-Conventions: WP-Gates, Naming, Branch-Schutz, No-Main-Push.

## Shortcut für PRs
Für einen reinen PR-Review darf mit **`review-pr`** statt der Schritte 1–6 begonnen werden. Danach müssen trotzdem noch ausgeführt werden:

- `test-coverage`
- `quality-gate`
- `doku-qualitaets-review`
- `konventions-healthcheck`

## Outputs
- Strukturierter Befundereport pro Skill.
- Aggregiertes Urteil: freigabereif / nicht freigabereif.
- Liste der nächsten Schritte.

## Red Flags — STOPP und neu starten
- `code-tour` überspringen, bevor Code bewertet wird.
- `fastapi-review` aufrufen, obwohl keine Endpoints geändert wurden, ohne darüber nachzudenken.
- Sicherheitskritische Änderungen ohne `verification-loop` freigeben.
- Vor dem Status „grün" `quality-gate` überspringen.
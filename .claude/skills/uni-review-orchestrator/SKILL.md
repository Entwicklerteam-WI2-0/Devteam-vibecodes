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
10. **`git-workflow` / Branch-Main-Abgleich** — Feature-Branch vor Review-Abschluss zwingend mit `origin/main` abgleichen, sodass nur die eigentlichen Feature-Änderungen reviewt/iteriert werden.

## Shortcut für PRs
Für einen reinen PR-Review darf mit **`review-pr`** statt der Schritte 1–6 begonnen werden. Danach müssen trotzdem noch ausgeführt werden:

- `test-coverage`
- `quality-gate`
- `doku-qualitaets-review`
- `konventions-healthcheck`
- **Branch-Main-Abgleich** (Schritt 10)

## 10. Branch-Main-Abgleich (mandatorisch vor Review-Abschluss)

Bevor der Review abgeschlossen wird, muss der Feature-Branch auf dem neuesten Stand von `origin/main` sein. Ziel: Der Review betrachtet ausschließlich die Feature-Änderungen gegenüber einem aktuellen Main — keine veralteten Baselines oder bereits gelösten Konflikte.

### Ablauf
1. **Fetch:**
   ```bash
   git fetch origin
   ```
2. **Prüfen, ob Main ahead ist:**
   ```bash
   git log --oneline HEAD..origin/main
   ```
3. **Falls Main ahead:** Merge von `origin/main` in den Feature-Branch (kein Rebase, um Force-Push zu vermeiden):
   ```bash
   git merge origin/main
   ```
4. **Konflikte lösen** falls nötig — User informieren und gemeinsam auflösen.
5. **Tests erneut laufen lassen:**
   ```bash
   uv run pytest -q
   ```
6. **Quality-Gate erneut prüfen:**
   ```bash
   uv run ruff check .
   uv run ruff format . --check
   ```
7. **Branch pushen** — nur nach expliziter Freigabe durch Lucas.

> **Warum Merge statt Rebase:** Rebase ändert Commit-Hashes und erfordert einen Force-Push, der die Review-Historie und eventuell laufende CI-Checks durcheinanderbringt. Ein Merge-Commit ist im Feature-Branch erlaubt und sicherer.

## Outputs
- Strukturierter Befundereport pro Skill.
- Aggregiertes Urteil: freigabereif / nicht freigabereif.
- Liste der nächsten Schritte.

## Red Flags — STOPP und neu starten
- `code-tour` überspringen, bevor Code bewertet wird.
- `fastapi-review` aufrufen, obwohl keine Endpoints geändert wurden, ohne darüber nachzudenken.
- Sicherheitskritische Änderungen ohne `verification-loop` freigeben.
- Vor dem Status „grün" `quality-gate` überspringen.
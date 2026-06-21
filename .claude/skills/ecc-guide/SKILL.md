---
name: ecc-guide
description: Navigationshilfe für den ECC-Skill-Stack im G2-Backend — „Welcher Skill wann?". Nutze diesen Skill, wenn du/der User unsicher ist, welchen Skill der nächste Schritt braucht.
origin: ECC (ecc-guide), neu geschrieben für G2 — Use-Case
---

# ecc-guide — Welcher Skill wann? (G2-Backend)

Du hilfst dem User, den richtigen Skill für die aktuelle Situation zu finden. Antworte auf **Deutsch**,
kurz und praxisnah.

## Pflicht-Minimalkanon pro Rolle

### Backend-Entwickler:in (Tag 1)
1. `uni:start` — Session-Start & Kontext.
2. `tdd-workflow` — Tests-first für Bewertungslogik/Feature.
3. `quality-gate` — Format/Lint vor dem Commit.
4. `code-review` (Selbst-Review) + `pr` — vor dem PR.
5. `save-session` — am Ende.

### Reviewerin/Testerin (Tag 1)
1. `uni:start` — Session-Start & Kontext.
2. `code-tour` — Change verstehen.
3. `code-review` — Review durchführen.
4. `test-coverage` — Tests prüfen.
5. `run` + `verify` — Live-Test.
6. `save-session` — am Ende.

## Nach Workflow-Punkt (WP)

| WP | Situation | Passende Skills |
|---|---|---|
| WP0 | Session starten | `uni:start` |
| WP1 | Task verstehen / Codebase kennenlernen | `feature-dev`, `codebase-onboarding`, `code-tour` |
| WP2 | Große/kritische Task planen / API-Design | `plan`, `api-design` |
| WP3 | Implementieren | `tdd-workflow`, `python-testing`, `fastapi-patterns`, `python-patterns`, `error-handling` |
| WP4 | Vor Commit / Build rot | `quality-gate`, `build-fix` |
| WP5 | Vor PR (Dev) | `code-review`, `python-review`, `fastapi-review`, `security-review`, `test-coverage`, `pr` |
| WP6 | PR-Review (Reviewer) | `code-tour`, `code-review`, `review-pr`, `python-review`, `fastapi-review`, `security-review` |
| WP7 | Live-Test / Integration | `run`, `verify`, `e2e-testing`, `browser-qa`, `verification-loop` |
| WP8 | Ende / Doku | `save-session`, `entscheidungslog` |

> **Hinweis (Einsteiger):** `uni:start` ist ein **Command**, `run`/`verify` sind **globale** ECC-Skills —
> sie gehören **nicht** zum Team-Skill-Set (den Skills hier), sind aber trotzdem verfügbar. Dort nicht danach suchen.

## Wichtige Spezialskills
- **Kritischer Pfad:** `verification-loop` + `santa-loop` (adversariales Dual-Review).
- **Sicherheit:** `security-review` (Rahmen) + `security-scan` (fokussierter Quick-Scan).
- **Review-Tiefe:** `code-review` (inhaltlicher Prüf-Baustein / Dev-Selbst-Review) vs. `review-pr` (vollständiges PR-Review mit DoD-Gate & Freigabe).
- **Navigation / Seitenfrage:** `ecc-guide`, `aside`.

## Nicht tun
- Den User mit der vollen Liste überfordern — immer den nächsten sinnvollen Skill vorschlagen.
- Use-Case-Fakten raten; bei fachlichen Fragen auf `Alarmsystem-Dev` verweisen.

---
*Quellen: `Skill-Plan.md`, `gemeinsam/Skills.md`, `abteilung-backend-entwickler/Skills.md`, `abteilung-reviewer-tester/Skills.md`.*

# Skills — Abteilung Backend-Entwickler:innen

> **Wer:** Hartling · Ganter · Moritz · Sarkhab · (Vöhringer) — bauen Ingest, Persistenz,
> **Vereisungs-Bewertungslogik**, API-Implementierung **strikt gegen den vom Architekten
> definierten Contract**. Übergeordneter Plan: `../Skill-Plan.md`. Geteiltes Fundament: `../gemeinsam/Skills.md`.
> Schwerpunkt-Codes: **OP** · **SR** · **CR** · **WG** · **VO** (Legende in `../Skill-Plan.md §1`).

## 1. Auftrag dieser Abteilung (Kontext für die Skill-Wahl)

Devs setzen die **Tasks P2–P4** um (Endpoints, Persistenz, Bewertungsmodul, Plausibilität, Alarme,
Quittierung, Audit). Achse: **Architekt → Spec → Dev → Implementierung**, gegengeprüft in der
**TDD-Schleife** mit der Test-Rolle. **DoD:** Code im PR → Review bestanden → Merge; Tests grün
(Bewertungslogik ≥ 80 % Coverage); Anforderungs-ID referenziert; Entscheidung im Logbuch.

## 2. Skill-Tabelle (zusätzlich zu `../gemeinsam/Skills.md`)

| Skill | Usecase (konkret im Projekt) | Schwerpunkt | WP / Auslöser |
|---|---|---|---|
| `ecc:feature-dev` | Geführter Einstieg in eine Task (z. B. `POST /readings`, `GET /assessment/current`) mit Codebase-Verständnis & Architektur-Fokus | **OP/VO** | WP1 Task-Start |
| `ecc:plan` | Vor **kritischen/großen** Tasks (P1 Contract, **P2.4 Bewertungslogik**): Anforderung → Schritte, Risiken, betroffene Module | **WG/OP** | WP2 Planung |
| `ecc:api-design` | REST-Design der **Naht**: Resource-Naming, Status-Codes, Response-Envelope, Fehlerformat, Versionierung — *DRI Architekt, Devs implementieren konsistent dagegen* | **OP** | WP2/WP3 |
| `ecc:fastapi-patterns` | Endpoints, **Dependency-Injection**, Pydantic-Request/Response-Schemas, saubere Router-Struktur | **OP** | WP3 |
| `ecc:python-patterns` | Idiomatischer, wartbarer Python-Code (Typing, Datenklassen, Immutability) | **OP** | WP3 |
| `ecc:error-handling` | Explizites Error-Handling + **Fail-safe**: bei Ausfall/Stale **nie GRÜN** → GELB/„unbekannt" + Warnung (NF-01) | **OP** | WP3 |
| `ecc:tdd-workflow` | **Tests zuerst** für die Bewertungslogik; Ziel ≥ 80 % Coverage inkl. **beider Vorfälle** (−2,1 °C / +1,2 °C) | **OP** | WP3 (TDD-Schleife) |
| `ecc:python-testing` | pytest-Unit-/Integrationstests schreiben (AAA-Struktur, sprechende Namen) | **OP** | WP3 |
| `ecc:build-fix` | Roten Build / Type-Fehler mit minimalem Diff schnell grün bekommen | **WG** | WP4 (getriggert bei Build-Fehler) |
| `ecc:quality-gate` | Formatter-/Lint-Quality-Gate pro Datei vor dem Commit | **CR/WG** | WP4 vor Commit |
| `ecc:test-coverage` | Coverage analysieren + Lücken vor dem PR schließen (DoD-Nachweis ≥ 80 %) | **SR/WG** | WP5 vor PR |
| `ecc:pr` | Feature-PR aus dem Branch erstellen (Beschreibung, Test-Plan) — **Push erst nach Genehmigung** | **WG** | WP5 PR-Erstellung |
| `ecc:checkpoint` | Zwischenstand nach erfolgreicher Verifikation sichern | **WG** | WP4/WP5 |

> **Einstiegs-Set (Pflicht, Tag 1) — bewusst klein, 4 Kern-Skills:**
> `uni:start` (Start) · `tdd-workflow` (Kern-Arbeit, Tests-first) · `quality-gate` (vor Commit) ·
> `pr` mit `code-review` als Selbst-Review (vor PR). Am Ende immer `save-session`.
> **Woche 1, sobald TDD sitzt:** `feature-dev`, `python-testing`, `fastapi-patterns`.
> Alles Weitere ist **situativ** — nicht alles auf einmal lernen.
>
> **SQLite-Schema:** Im T0 **keine** Migrations-Toolchain nötig — Init per `CREATE TABLE` /
> `Backend-Konzept §7`. `ecc:database-migrations` (zielt auf Postgres/MySQL + ORMs) erst bei
> begründetem **Stack-Wechsel** (T2+) — nicht im Standard-Set.

### 2.1 Geteilte Review-Skills — hier als **Selbst-Review (SR)** vor dem PR

Aus `../gemeinsam/Skills.md`, am Workflow-Punkt **WP5** als Eigen-Check **bevor** der PR an die
Reviewer-Abteilung geht (entlastet WP6, hebt die Merge-Qualität):

| Skill | Als SR genutzt für |
|---|---|
| `ecc:code-review` | Allgemeine Qualität/Bugs der eigenen Changes |
| `ecc:python-review` | Python-Idiome, Typing, Stil |
| `ecc:fastapi-review` | Async/DI/Pydantic/OpenAPI der eigenen Endpoints |
| `ecc:security-review` | Ingest-Validierung, **RB-01**, keine Secrets |
| `verify` | Eigenen Slice live gegen die API prüfen |

## 3. Standard-Ablauf einer Dev-Task (WP-gebunden)

1. **WP0** `uni:start` → Kontext. **WP1** `feature-dev` → Task verstehen, Modul finden.
2. **WP2** (nur kritische/große Tasks) `plan`; bei API-Arbeit `api-design` (mit Architekt).
3. **WP3** `tdd-workflow` (RED) → `fastapi-patterns`/`python-patterns`/`error-handling` (GREEN) →
   `python-testing`. Build rot? → `build-fix`.
4. **WP4** `quality-gate` → Commit. **WP5** Selbst-Review (§2.1) + `test-coverage` → `pr`.
5. **WP6** wartet auf die Reviewer-Abteilung; Feedback einarbeiten. **WP8** `save-session` + Logbuch.

## 4. Abteilungs-Regeln

- **Contract-first:** Niemals gegen ein noch nicht eingefrorenes API/Datenmodell breit implementieren —
  erst Naht (P1), dann parallel bauen.
- **Kein Aktor:** Keine Freigabe-/Sperr-/Steuer-Endpoints (RB-01) — auch nicht „temporär".
- **Bewertungslogik** nur aus `Schwellenwerte.md`; nichts dazuerfinden; Defaults parametrierbar.
- **PR-Pflicht:** Kein direkter `main`-Push; Push/PR nur nach Genehmigung durch Lucas.
- **DoD vollständig** (Review + Tests grün + Anf-ID + Logbuch), sonst gilt die Task nicht als fertig.
- **Kritischer Pfad (P2.4 Bewertungslogik):** DoD ist **nicht** nur „≥ 80 % Coverage", sondern **beide
  dokumentierten Vorfälle (−2,1 / +1,2 °C) als benannte, grüne Testfälle** + Fail-safe-Test
  (Stale/Ausfall → nie GRÜN). Verifikation gegen `Schwellenwerte.md` (vgl. `ecc:verification-loop` bei Test).

---
*Toolkit-Version: v1.3.0 · Pflege: Lucas (Systemarchitekt) · Übergeordnet: `../Skill-Plan.md`, `../gemeinsam/Skills.md`.*

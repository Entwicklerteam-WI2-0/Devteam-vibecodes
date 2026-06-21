# Skill-Plan — Werkzeugkästen für G2 (Backend & Entscheidungslogik)

> **Zweck:** Verbindlicher Plan, **welche Claude-Code-Skills** jede Abteilung des G2-Teams
> standardmäßig einsetzt — kuratiert aus dem ECC-Stack, geschnitten auf **unseren Stack**
> (Python · FastAPI · SQLite), **unseren Workflow** (contract-first, TDD-Schleife, PR→Review→Merge)
> und unsere **realen Nutzer** (Hochschulteam, heterogen, ~2. Semester, 3-Wochen-Projekt).
> Source-of-Truth zum Use-Case: `Alarmsystem-Dev` (siehe `../Devteam-vibecodes/CLAUDE.md` §2).
> Sprache: **Deutsch**. Pflegt: Lucas (Systemarchitekt).

## 0. Wie dieser Plan organisiert ist

| Datei / Ordner | Inhalt |
|---|---|
| **`Skill-Plan.md`** (diese Datei) | Übersicht, Taxonomie, Workflow-Punkte, konsolidierte Tabellen, **Auswahl-Begründung + Ausschlüsse**, Pflicht-**Review-Loop** |
| **`gemeinsam/Skills.md`** | **Geteilte Skills** — von **beiden** Abteilungen genutzt (Fundament) |
| **`abteilung-backend-entwickler/Skills.md`** | Skills der **Backend-Entwickler:innen** |
| **`abteilung-reviewer-tester/Skills.md`** | Skills der **Reviewerinnen/Testerinnen** |

Die drei `Skills.md` sind eigenständig lesbare Arbeitsdokumente der jeweiligen Gruppe. Diese Datei
fasst alles zu **einem Plan** zusammen und begründet die Auswahl.

## 1. Nutzen-Schwerpunkt — Taxonomie (Legende)

Jeder Skill ist genau einem **Schwerpunkt** zugeordnet (warum existiert er im Toolkit):

| Code | Schwerpunkt | Bedeutung |
|---|---|---|
| **OP** | Operativ | erzeugt das eigentliche Deliverable (Code, Tests, Reviews, Doku) |
| **SR** | Selbst-Review | prüft die **eigene** Arbeit, bevor sie übergeben/gepostet wird |
| **CR** | Conventions/Regeln | **setzt/erzwingt Standards** (Stil, Config, Hooks, Quality-Gate) — *nicht* die fachlichen Code-Reviewer-Skills |
| **WG** | Workflow-Gate (funktional) | wird **an festen Punkten getriggert** (Start, vor Commit, vor PR, Ende) |
| **VO** | Verständnis/Onboarding | Use-Case/Codebase **verstehen**, bevor gehandelt wird |

> **Wichtig (auf Wunsch explizit):** Die fachlichen Review-Skills (`code-review`, `python-review`,
> `fastapi-review`, `security-review`) sind **kein** „CR". Ihr Schwerpunkt ist **SR** (wenn ein Dev
> die eigene Arbeit vor dem PR prüft) bzw. **OP** (wenn die Reviewer-Abteilung sie als Hauptwerkzeug
> nutzt). Genau dieser **Dual-Use** ist der Grund, warum sie unter `gemeinsam/` stehen.

## 2. Workflow-Punkte (WP) — wann welcher Skill greift

Aus `Tasks+Projektplan.md` (P0–P6, DoD) und `Team-Organisation+Regeln.md` (Kopplungen) abgeleitet:

| WP | Punkt im Workflow | Standard-Skills (Auszug) |
|---|---|---|
| **WP0** | **Session-Start** | `uni:start` — Kontext laden (`erinnerung/stand.md` + Regeln + Git-Status) |
| **WP1** | Task-Start / Verständnis | `codebase-onboarding`, `feature-dev`, `code-tour` |
| **WP2** | Planung (kritische/große Tasks: P1 Contract, P2.4 Logik) | `plan`, `api-design` |
| **WP3** | Implementierung | `fastapi-patterns`, `python-patterns`, `tdd-workflow`, `error-handling` |
| **WP4** | **Vor Commit** | `quality-gate`, `build-fix` (bei rotem Build) |
| **WP5** | **Vor PR** (Dev: Selbst-Review) | `code-review`/`python-review`/`fastapi-review`/`security-review` (SR), `test-coverage`, `pr` |
| **WP6** | **PR-Review** (Reviewer-Abteilung) | `code-review`/`review-pr` (OP), `code-tour`, `santa-loop` |
| **WP7** | Integration / **Live-Test** (P3.6, P5) | `verify`, `run`, `e2e-testing`, `browser-qa` |
| **WP8** | **Session-Ende / Doku** | `save-session`, `checkpoint`, `entscheidungslog`, Entscheidungslogbuch |

> WP4–WP6 spiegeln die **DoD** (Code im PR → Review bestanden → Merge; Tests grün ≥ 80 % auf der
> Bewertungslogik). WP6 ist die **Heimat der Reviewer-Abteilung**; WP3/WP5 die der Backend-Devs.

## 3. Konsolidierte Skill-Liste (alle drei Gruppen)

> Vollständige Usecases/Ablauf je Gruppe in den jeweiligen `Skills.md`. Hier die Übersicht.
> Präfix `ecc:` = ECC-Plugin-Skill; ohne Präfix = Claude-Code-Built-in.

### 3.1 GEMEINSAM (beide Abteilungen) → `gemeinsam/Skills.md`

| Skill | Usecase (projektbezogen) | Schwerpunkt | WP / Auslöser |
|---|---|---|---|
| `uni:start` | Session-Start: `erinnerung/stand.md` (Stand & Entscheidungen) + Regeln (`claude-sync.md`) + Git-Status laden | WG | WP0 jeder Start |
| `save-session` | Stand/Entscheidungen am Ende sichern (`erinnerung/stand.md` + Logbuch) | WG | WP8 Session-Ende |
| `ecc:coding-standards` | Gemeinsamer Maßstab (Naming, KISS/DRY, kleine Dateien, Error-Handling): Devs schreiben, Reviewer prüfen danach | CR | WP3 / WP6 |
| `ecc:git-workflow` | Feature-Branch → Commit-Konvention → PR; **kein direkter `main`-Push** | CR/WG | WP4–WP6 |
| `ecc:codebase-onboarding` | Heterogenes Team versteht Repo-Struktur (Backend-Konzept §7) schnell | VO | WP1 |
| `ecc:documentation-lookup` | Aktuelle FastAPI-/Pydantic-/SQLite-Doku statt Halluzination | OP/VO | WP3 |
| `ecc:ecc-guide` | „Welcher Skill für welche Aufgabe?" — Navigation im Stack | VO | n. Bedarf |
| `ecc:aside` | Schnelle Seitenfrage ohne Verlust des Task-Kontexts | WG | n. Bedarf |
| `grill-me` | Klärendes Interview vor Arbeitsbeginn — Anforderungen/Entscheidungen/Randbedingungen abklopfen (bes. bei der lückenhaften Anforderungslage) | VO/WG | WP1/WP2 |
| `ecc:code-review` | **Dual-Use:** Dev = Selbst-Review vor PR / Reviewer = Hauptwerkzeug | SR/OP | WP5 / WP6 |
| `ecc:python-review` | dito, Python-spezifisch (PEP 8, Typing, Idiome) | SR/OP | WP5 / WP6 |
| `ecc:fastapi-review` | dito, FastAPI (Async, DI, Pydantic, OpenAPI) | SR/OP | WP5 / WP6 |
| `ecc:security-review` | Ingest-Validierung, Audit, **RB-01** (kein Aktor-Endpoint), keine Secrets | SR/OP | WP5 / WP6 |
| `verify` | Laufende App/API starten + Verhalten beobachten | OP | WP5 / WP7 |

**Team-Infrastruktur (zentral von Lucas/Architekt gepflegt — kein Alltags-Skill der Mitglieder):**
`ecc:configure-ecc` · `ecc:hookify` (+`hookify-list`/`hookify-configure`) · `update-config` · `init`
→ setzen Designprinzip 2 (gemeinsame `.claude/`-Config) und 3 (Standards als **Hooks**, nicht als Text) um.
Konkrete Pflicht-Hooks (Details `gemeinsam/Skills.md §3`): **RB-01-Guard** (blockt Aktor-/Freigabe-Routen),
**Secret-Scan** (PreCommit), **OpenAPI-Schema-Diff** (Contract-Schutz).

### 3.2 BACKEND-ENTWICKLER:INNEN → `abteilung-backend-entwickler/Skills.md`

| Skill | Usecase (projektbezogen) | Schwerpunkt | WP / Auslöser |
|---|---|---|---|
| `ecc:feature-dev` | Geführter Einstieg in eine Task (P2/P3-Endpoints) mit Codebase-Verständnis | OP/VO | WP1 |
| `ecc:plan` | Vor kritischen/großen Tasks (P1 Contract, P2.4 Logik): Anforderung → Schritte, Risiken | WG/OP | WP2 |
| `ecc:api-design` | REST-Naht (Resource-Naming, Status-Codes, Envelope, Versionierung) — G2-Kernverantwortung (P1) | OP | WP2/3 *(DRI: Architekt)* |
| `ecc:fastapi-patterns` | Endpoints, Dependency-Injection, Pydantic-Schemas korrekt bauen | OP | WP3 |
| `ecc:python-patterns` | Idiomatischer, wartbarer Python-Code | OP | WP3 |
| `ecc:error-handling` | Explizites Error-Handling + **Fail-safe** (Ausfall/Stale → nie GRÜN, NF-01) | OP | WP3 |
| `ecc:tdd-workflow` | Tests-first für Bewertungslogik (DoD ≥ 80 %, beide Vorfälle) | OP | WP3 |
| `ecc:python-testing` | pytest-Unit-/Integrationstests | OP | WP3 |
| `ecc:build-fix` | Roten Build/Type-Fehler schnell grün bekommen | WG | WP4 (getriggert) |
| `ecc:quality-gate` | Formatter-/Lint-Gate pro Datei | CR/WG | WP4 vor Commit |
| `ecc:test-coverage` | Coverage-Lücken vor PR schließen (DoD-Nachweis) | SR/WG | WP5 |
| `ecc:pr` | Feature-PR aus Branch erstellen (Push erst nach Genehmigung) | WG | WP5 |
| `ecc:checkpoint` | Zwischenstand nach Verifikation sichern | WG | WP4/5 |
| *(geteilt, hier als SR)* | `code-review`/`python-review`/`fastapi-review`/`security-review` als **Selbst-Review** vor PR | SR | WP5 |

### 3.3 REVIEWERINNEN/TESTERINNEN → `abteilung-reviewer-tester/Skills.md`

| Skill | Usecase (projektbezogen) | Schwerpunkt | WP / Auslöser |
|---|---|---|---|
| `ecc:code-review` *(geteilt, hier OP)* | Lokaler Diff oder GitHub-PR reviewen — **Hauptwerkzeug** | OP | WP6 bei jedem PR |
| `ecc:review-pr` | Umfassendes PR-Review mit spezialisierten Agents | OP | WP6 |
| `ecc:verification-loop` | **Pflicht-Gate kritischer Pfad:** Bewertungslogik gegen `Schwellenwerte.md` (beide Vorfälle + Fail-safe als benannte Tests) | OP/WG | WP6/7 (kritisch) |
| `ecc:python-review` / `ecc:fastapi-review` *(geteilt, OP)* | Fachliche Detail-Reviews | OP | WP6 |
| `ecc:security-review` / `ecc:security-scan` *(geteilt, OP)* | Ingest, Audit, **RB-01**, Secrets | OP | WP6 |
| `ecc:test-coverage` | Coverage prüfen + fehlende Tests generieren (Suite-Pflege) | OP | WP6/7 |
| `ecc:python-testing` | Unit-Tests schreiben/pflegen (Agent erstellt, Mensch versteht) | OP | WP6/7 |
| `ecc:e2e-testing` | **API-E2E** mit `TestClient`/httpx (Ingest → Bewertung → API, P3.6); Browser-E2E (Playwright) nur bei echter G3-UI-Integration | OP | WP7 (optional) |
| `verify` *(geteilt, OP)* | **Live-Test der laufenden App/API** + Verhalten beobachten | OP | WP7 |
| `run` | App/Server starten, um Change live zu sehen | WG | WP7 |
| `ecc:code-tour` | Geführte Tour durch den geänderten Code — **verstehen vor Freigabe** | VO | WP6 |
| `ecc:santa-loop` | Adversariales Dual-Review (2 unabhängige Reviewer müssen zustimmen) — sicherheitskritische Logik (P2.4, Fail-safe, RB-01) | OP | WP6 (kritische PRs) |
| `ecc:browser-qa` | Live-API-Verhalten prüfen (Backend liefert Daten; Browser/Playwright nur bei G3-UI-Integration) | OP | WP7 (optional) |
| `ecc:checkpoint` | Test-Durchlauf-Stand sichern | WG | WP7 |

**Verbindliche Regel (bewertungsrelevant, 40 % Einzelleistung) — `CR`:**
> **Agent erstellt Review-/Test-Entwurf → Reviewerin liest, versteht, hinterfragt, gibt frei → erst dann
> posten/mergen.** Nie automatisch posten. **Mensch bleibt im Loop.** Diese Regel steuert *alle* obigen
> operativen Reviewer-Skills.

> **Ausnahme — nur durch Lucas:** `code-review ultra` (tiefes, **kostenpflichtiges** Cloud-Review) ist
> dem kritischsten PR (P2.4/RB-01) vorbehalten — kein Standard-Skill. Im Alltag genügt `santa-loop`.

## 4. Auswahl-Begründung (warum diese Skills, passend zum Workflow)

1. **Contract-first (P1):** `api-design` + `plan` sitzen bewusst auf **WP2**, weil die API/Datenmodell-Naht
   zuerst eingefroren wird und alles andere blockiert. DRI = Architekt; Devs implementieren dagegen.
2. **TDD-Schleife (Team-Org §2.3):** `tdd-workflow` + `python-testing` (Dev) ⇄ `test-coverage` +
   `python-testing` (Reviewer/Test) bilden die Achse Backend-Dev ⇄ Test 1:1 ab.
3. **DoD = Review + Tests grün (≥ 80 %):** Deshalb `code-review`/`*-review` als **WP5-Selbst-Gate** (Dev)
   und **WP6-Operativwerkzeug** (Reviewer) — derselbe Skill, invertierter Schwerpunkt → daher `gemeinsam`.
4. **Sicherheitskritisch (RB-01, Fail-safe):** `security-review` + `santa-loop` (Dual-Review) gezielt für
   den kritischen Pfad (P2.4 Bewertungslogik, Nachweis „kein Aktor-Endpoint", „bei Ausfall nie GRÜN").
5. **Niveau ~2. Semester:** Bevorzugt **wenige, getriggerte** Skills + **Hooks** (Automatik) statt
   einer Skill-Flut. Operative Standardarbeit (Format, Lint, Tests, Repo-Hygiene) übernimmt der Agent.
6. **Standards als Hooks (Prinzip 3):** `hookify`/`configure-ecc` zentral bei Lucas — PostToolUse
   (format/lint), PreToolUse (blocks), Stop (test/build-gate) — erzwingen statt erhoffen.
7. **Kontinuität (3 Wochen, Ausfallrisiko):** `uni:start` + `save-session` sichern Kontext über
   Personen-/Tageswechsel — passt zu „Non-Performer entkoppeln, Naht schützen".

## 5. Bewusst NICHT gewählt (Ausschlüsse — für Nachvollziehbarkeit)

| Ausgeschlossen | Grund |
|---|---|
| `react-*`, `nextjs-*`, `vue`, `ui-to-vue`, `frontend-*`, `motion-*`, `accessibility` | **Frontend = G3**, nicht G2. Bei Integration nur lesend relevant. |
| `kotlin-*`, `swift-*`, `go-*`, `rust-*`, `java-*`, `csharp-*`, `php`, `dotnet`, `android-*` | **Nicht unser Stack** (Python/FastAPI). |
| `django-*`, `springboot-*`, `quarkus-*`, `laravel-*`, `nestjs-*` | Andere Backend-Frameworks — wir nutzen **schlankes FastAPI** (T0-Empfehlung). |
| `postgres-*`, `mysql-*`, `clickhouse`, `prisma`, `redis-*`, **`database-migrations`** | **SQLite** im T0 (Init per `CREATE TABLE`/Backend-Konzept §7); `database-migrations` zielt auf Postgres/MySQL+ORMs → erst bei begründetem Stack-Wechsel (T2+). |
| `marketing-*`, `seo`, `investor-*`, `logistics-*`, `healthcare-*`, `finance-*`, `*-trading`, `defi-*`, `blockchain/evm-*` | **Fachfremd** zum Use-Case. |
| `claude-devfleet`, `team-agent-orchestration`, `multi-*`, `orch-*`, `gan-*`, `autonomous-*`, `loop-*` | Mächtig, aber **Overhead/Risiko** für ~2.-Semester-Niveau. Optional **nur für Lucas** als Hebel auf dem kritischen Pfad. |
| `deep-research`, `market-research`, `exa-search` | Außerhalb des Kern-Backend-Flows; bei Bedarf ad hoc, nicht im Standard-Toolkit. |

## 6. Review-Loop (Pflicht) — Ergebnis

> Nach Erststellung wurde der Plan **vollständig erneut gelesen** und gegen **Anwendungsbereich,
> Projekthintergrund und reale Nutzer** geprüft (Selbst-Review + eine unabhängige Zweitmeinung).

**Durchgang 1 — Selbst-Review (Befund → Korrektur, umgesetzt):**

| # | Linse | Befund | Korrektur |
|---|---|---|---|
| 1 | Reale Nutzer (~2. Sem.) | ~14 Skills/Abteilung ohne Pflicht-Minimalkanon → Überforderung | **Einstiegs-Set (Pflicht, Tag 1)** in jede Abteilungs-`Skills.md` + `gemeinsam` ergänzt; Rest als „situativ" markiert |
| 2 | Projekthintergrund (Bewertung) | **Entscheidungslogbuch** ist Pflichtdokument + benotet, hatte keinen Skill | `ecc:architecture-decision-records` zu Backend-Devs ergänzt — *v1.3.0 (2026-06-21): Skill entfernt, Logbuch-Pflege jetzt über `entscheidungslog` + `save-session`* |
| 3 | Projekthintergrund (Bewertung) | **API-Doku** ist Pflichtdokument, nicht abgedeckt | `ecc:update-docs` zu Backend-Devs ergänzt — *v1.3.0 (2026-06-21): Skill entfernt (Redundanz), API-/Doku-Sync in `save-session` gefaltet* |
| 4 | Reale Nutzer / Erwartung | `code-review ultra` könnte als „Agent macht das" missverstanden werden | Als **user-getriggert & kostenpflichtig** gekennzeichnet (Agent startet es nicht) |
| 5 | Anwendungsbereich (sicherheitskritisch) | Fail-safe/RB-01 nur in Dev-Regeln | Als **Pflichtchecks** auch in Reviewer-`Skills.md §4` verankert (NF-01, P4.5) |

**Konsistenz-Checks (bestanden):** alle referenzierten Skills existieren im ECC-/Built-in-Stack ·
Stack-Filter (Python/FastAPI/SQLite) und Scope-Filter (Backend, nicht Frontend=G3) eingehalten ·
IDs (RB-01, NF-01, P-Phasen) deckungsgleich mit `Alarmsystem-Dev` · alles auf Deutsch ·
40-%-Human-in-the-loop-Regel prominent bei der Reviewer-Abteilung.

**Durchgang 2 — unabhängige Zweitmeinung** (frischer, kontextfreier Reviewer; Befund → Korrektur, umgesetzt):

| Prio | Befund | Korrektur |
|---|---|---|
| **P1** | `ecc:database-migrations` zielt auf Postgres/MySQL + ORMs → widerspricht SQLite-Ausschluss | Aus dem Set **entfernt**; SQLite-Init per `CREATE TABLE`/Backend-Konzept §7; Migrations-Skill erst T2+ |
| **P1** | Kein echtes **Verifikations-Gate** für die sicherheitskritische Bewertungslogik (nur Coverage) | `ecc:verification-loop` als Pflicht-Gate ergänzt; **DoD kritischer Pfad** = beide Vorfälle als benannte, grüne Tests + Fail-safe-Test |
| **P1** | **RB-01** nur als menschlicher Lese-Check (fragil bei ~2. Sem.) | Als **RB-01-Guard-Hook** verankert (Team-Infra), der Aktor-/Freigabe-Routen blockt |
| **P2** | `e2e-testing`/`browser-qa` sind Playwright/Browser (Frontend=G3) | `e2e-testing` auf **„nur G3-UI-Integration"** beschränkt; **API-E2E → `python-testing`** (pytest+httpx) |
| **P2** | `code-review ultra` (kostenpflichtig) im Standard-Set = Kostenfalle | Zur **Ausnahme „nur durch Lucas"** verschoben; Alltag = `santa-loop` |
| **P2** | `santa-loop` als **SR** klassifiziert widerspricht der Taxonomie (adversarial = nicht Selbst-Review) | Auf **OP** umklassifiziert |
| **P2** | Dev-Einstiegs-Set (8 Skills) zu voll, Doppelungen (`tdd-workflow`+`python-testing`) | Tag-1 auf **4 Kern-Skills** gekürzt; Rest gestaffelt („Woche 1, wenn TDD sitzt") |
| **P2** | ADR ≠ Format des benoteten **Entscheidungslogbuchs** | ADR als **Rohstoff** klargestellt — *v1.3.0 (2026-06-21): `architecture-decision-records`/`update-docs` entfernt; Logbuch über `entscheidungslog` + `save-session`* |
| **P3** | Contract-Drift nicht abgesichert | **OpenAPI-Schema-Diff-Hook** (Team-Infra) ergänzt |
| **P3** | `security-scan` greift erst im Review, „keine Secrets" ist Commit-Zeit | **Secret-Scan-PreCommit-Hook** (Team-Infra) ergänzt |

**Vom Zweit-Review bestätigt (unverändert):** Dual-Use-Logik (Review-Skills in `gemeinsam` mit invertiertem
SR/OP-Schwerpunkt) · 40-%-Human-in-the-loop-Regel · Frontend-/Fremdstack-Ausschlüsse · `error-handling`→Fail-safe
(NF-01) · alle referenzierten Skills existieren im Stack.

> **Fazit Review-Loop:** Beide Durchgänge abgeschlossen; alle P1/P2 und beide P3 eingearbeitet. Der Plan ist
> jetzt stringent auf Stack (Python/FastAPI/SQLite), Sicherheitskritik (RB-01/Fail-safe als **Hooks+Gates**,
> nicht nur Reviews) und reale Nutzer (~2. Sem.: schlanker Pflicht-Kanon, Rest situativ) ausgerichtet.

---
*Toolkit-Version: v1.3.0 · Stand: 2026-06-21 (urspr. 2026-06-17) · Pflege: Lucas (Systemarchitekt) · Use-Case-Fakten stets aus `Alarmsystem-Dev` lesen.*

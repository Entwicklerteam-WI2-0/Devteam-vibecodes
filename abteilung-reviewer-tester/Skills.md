# Skills — Abteilung Reviewerinnen/Testerinnen

> **Wer:** Mohammadi · Berger (Test/Review) — verantworten Testfälle, Definition-of-Done,
> Testprotokoll, **Live-Test der laufenden App/API** und **technische Reviews**. Übergeordneter Plan:
> `../Skill-Plan.md`. Geteiltes Fundament: `../gemeinsam/Skills.md`.
> Schwerpunkt-Codes: **OP** · **SR** · **CR** · **WG** · **VO** (Legende in `../Skill-Plan.md §1`).

## 1. Auftrag dieser Abteilung (Kontext für die Skill-Wahl)

Der **Agent** übernimmt die operative Schwerarbeit (technische Reviews, Unit-Tests, Testsuite-Pflege,
Coverage); die **Reviewerin** versteht, prüft und gibt frei. Diese Abteilung sitzt auf **WP6 (PR-Review)**
und **WP7 (Integration/Live-Test)**. Test-Tasks: P2.6, P3.6, P3.7 (Fail-safe), P4.5 (RB-01-Nachweis),
P5.3 (Testprotokoll).

> ### ⚠️ Verbindliche Grundregel (bewertungsrelevant — 40 % Einzelleistung) — `CR`
> **Agent erstellt Review-/Test-Entwurf → Reviewerin liest, versteht, hinterfragt, gibt frei →
> erst dann posten/mergen.** Nie automatisch posten. **Der Mensch bleibt im Loop.**
> Diese Regel steuert *alle* unten genannten operativen Skills.

## 2. Skill-Tabelle (zusätzlich zu `../gemeinsam/Skills.md`)

| Skill | Usecase (konkret im Projekt) | Schwerpunkt | WP / Auslöser |
|---|---|---|---|
| `uni:code-review` *(geteilt, hier **OP**)* | **Hauptwerkzeug:** lokalen Diff oder GitHub-PR strukturiert reviewen; Befunde nach Schweregrad | **OP** | WP6 bei jedem PR |
| `uni:review-pr` | Umfassendes PR-Review mit mehreren spezialisierten Agents (Mehr-Perspektiven) | **OP** | WP6 |
| `uni:python-review` / `uni:fastapi-review` *(geteilt, OP)* | Fachliche Detail-Reviews (Python-Idiome / Async-DI-Pydantic-OpenAPI) | **OP** | WP6 |
| `uni:security-review` / `uni:security-scan` *(geteilt, OP)* | Ingest-Validierung, Audit-Log, **RB-01** (kein Aktor-Endpoint), keine Secrets | **OP** | WP6 |
| `uni:test-coverage` | Coverage analysieren + **fehlende Tests generieren** (Testsuite-Pflege, DoD ≥ 80 %) | **OP** | WP6/WP7 |
| `uni:python-testing` | Unit-Tests schreiben/pflegen (Agent erstellt, Reviewerin versteht) | **OP** | WP6/WP7 |
| `uni:e2e-testing` | **API-E2E** mit pytest + httpx/`TestClient` (Ingest → Bewertung → API, P3.6); Browser-E2E (Playwright) nur bei echter G3-UI-Integration | **OP** | WP7 (optional) |
| `verify` *(geteilt, OP)* | **Live-Test der laufenden App/API** — starten, Endpunkte ansprechen, Verhalten beobachten | **OP** | WP7 |
| `run` *(Built-in)* | App/Server starten, um einen Change live zu sehen (Voraussetzung für den Live-Test) | **WG** | WP7 |
| `uni:code-tour` | Geführte Tour durch den **geänderten** Code — Reviewerin **versteht** den Change vor der Freigabe (stützt die 40-%-Regel) | **VO** | WP6 |
| `uni:verification-loop` | **Pflicht-Gate kritischer Pfad:** Bewertungslogik gegen `Schwellenwerte.md` verifizieren — beide Vorfälle (−2,1/+1,2 °C) + Fail-safe (Stale→nie GRÜN) als **benannte, grüne Testfälle** | **OP/WG** | WP6/WP7 (kritisch) |
| `uni:santa-loop` | **Adversariales Dual-Review** (zwei unabhängige Reviewer müssen zustimmen) für sicherheitskritische Logik: P2.4, **Fail-safe** (P3.7), **RB-01** (P4.5) | **OP** | WP6 (kritische PRs) |
| `uni:browser-qa` | Live-API-Verhalten prüfen (Backend liefert Daten; Browser/Playwright nur bei G3-UI-Integration) | **OP** | WP7 (optional) |
| `uni:checkpoint` | Stand nach einem Test-Durchlauf sichern | **WG** | WP7 |

> **Ausnahme — nur durch Lucas:** `code-review ultra` (tiefes, **kostenpflichtiges** Multi-Agent-Cloud-Review)
> bleibt dem **kritischsten** PR vorbehalten (P2.4/RB-01) und wird ausschließlich von Lucas ausgelöst —
> kein Standard-Skill der Abteilung. Für den Alltag genügt `santa-loop` als adversariales Dual-Review.

> **Einstiegs-Set (Pflicht, Tag 1) — der Minimalkanon, den jede Reviewerin kennen muss:**
> `uni:start` (Start) · `code-tour` (Change verstehen) · `code-review` (reviewen) · `test-coverage` (Tests prüfen) ·
> `run` + `verify` (Live-Test) · `save-session` (Ende). Plus die **40-%-Regel** aus §1.
> `santa-loop` + `verification-loop` (kritischer Pfad) und `browser-qa` (G3-Integration) sind **situativ**;
> `code-review ultra` ist eine **Ausnahme nur durch Lucas** (kostenpflichtig).

## 3. Standard-Ablauf eines Reviews (WP-gebunden)

1. **WP0** `uni:start` → Kontext. Neuer PR offen → **WP6**.
2. **WP6 Verstehen:** `code-tour` durch die Changes. **Reviewen:** `code-review` (+ `python-review`/
   `fastapi-review`/`security-review` nach Bedarf). Kritischer Pfad → `santa-loop` und/oder `code-review ultra`.
3. **Tests:** `test-coverage` prüfen, Lücken via `python-testing` schließen; **API-E2E** via `python-testing`
   (pytest+httpx); `e2e-testing` (Browser) nur bei G3-UI-Integration. Kritischer Pfad → `verification-loop`.
4. **WP7 Live-Test:** `run` → `verify` (API live), bei G3-Integration `browser-qa`.
5. **Freigabe (40-%-Regel):** Entwurf lesen, verstehen, **selbst verantworten**, dann erst Kommentare im
   PR posten / Merge freigeben. **WP8** `save-session`; Befunde ins Testprotokoll (P5.3).

## 4. Abteilungs-Regeln

- **Human-in-the-loop** ist nicht optional (siehe §1) — der eingereichte Review ist deine Einzelleistung.
- **Fail-safe-Pflichtcheck:** Bei jedem PR an der Bewertungslogik prüfen, dass Ausfall/Stale **nie GRÜN** ergibt (NF-01).
- **RB-01-Pflichtcheck:** Kein Freigabe-/Sperr-/Aktor-Endpoint existiert (P4.5).
- **Testmaßstab = `Schwellenwerte.md §3`** (Abnahme-Checkliste) + NFA; Werte logisch plausibilisieren (KI-generiert).
- **Review-Befunde** nach Schweregrad (CRITICAL/HIGH/MEDIUM/LOW); CRITICAL blockt den Merge.

---
*Toolkit-Version: v1.4.0 · Pflege: Lucas (Systemarchitekt) · Übergeordnet: `../Skill-Plan.md`, `../gemeinsam/Skills.md`.*

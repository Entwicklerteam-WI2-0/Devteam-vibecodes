# Skillanleitung — die Skills in Aktion (G2-Backend)

> **Zweck:** Diese Anleitung macht die Team-Skills **greifbar** — nicht als Katalog (das ist `Skill-Plan.md`
> bzw. `gemeinsam/Skills.md`), sondern als **realistischer Durchlauf an einem echten Ticket**. Du siehst,
> *wann* welcher Skill feuert und *warum*. Sprache: Deutsch.
> **Wichtig:** Use-Case-Werte (Schwellen, Bewertungsregeln) stehen ausschließlich in `Alarmsystem-Dev`
> (`Schwellenwerte.md` etc.) — hier wird nur darauf verwiesen, nichts davon erfunden.

## Wie Skills überhaupt funktionieren (30 Sekunden)
- Ein Skill ist ein benannter Arbeitsschritt, den du im Chat auslöst: einfach den **Namen tippen**
  (z. B. `tdd-workflow`) oder die Aufgabe beschreiben — der Agent zieht den passenden Skill von selbst.
- `/uni:start`, `/setup`, `/update` sind **Commands** (mit `/`). Skills ruft man **ohne** `/` auf.
- Du musst die Liste **nicht** auswendig können: im Zweifel `ecc-guide` fragen („welcher Skill jetzt?").
- Der Agent macht die Arbeit — **du verstehst, entscheidest und verantwortest** (40 %-Einzelleistung).

---

## Szenario A — Backend-Entwickler:in: Fail-safe in der Bewertungslogik

**Ticket (realistisch):** *„In `assessment/` soll bei veralteten/Stale-Daten **nie GRÜN** herauskommen
(NF-01, Fail-safe)."* Das ist **kritischer Pfad** — also sauber, mit Tests, nicht schnell hingehackt.

### 1. `uni:start` — bevor irgendetwas passiert  · WP0
Du tippst `uni:start`. Lädt Stand (`erinnerung/stand.md`), Regeln und Git-Status. **Kein Blind-Start** —
du weißt sofort, wo das Team steht und auf welchem Branch du bist.

### 2. `feature-dev` — Task verstehen & im Code verorten  · WP1
Verankert das Ticket an einer **Anforderungs-ID** und zeigt dir, **wo** in `assessment/` der Eingriff
gehört. Statt zu raten, wird die Stelle gelesen. (Neu im Code? `codebase-onboarding` davor.)

### 3. `plan` — weil es den kritischen Pfad berührt  · WP2
Bei kritischen/großen Tasks **erst planen**. `plan` zerlegt den Eingriff in Schritte und benennt Risiken
(z. B. Betriebspunkt K1: Fehlalarm ↔ Auslassung). Kleine Tasks überspringen das.

### 4. `tdd-workflow` — Tests zuerst  · WP3  ← Herzstück
Hier liegt der Kern. Die **DoD** der Bewertungslogik verlangt **benannte, grüne** Testfälle:
- die zwei dokumentierten Vorfälle — *Fehlalarm bei trockener Kälte* und *nicht erkannte Eisbildung trotz
  positiver Lufttemperatur*,
- **plus** ein **Fail-safe-Test**: Stale/Ausfall → **nie GRÜN**.

Ablauf: Test schreiben (**RED**) → minimal implementieren (**GREEN**) → aufräumen (**Refactor**).
Schwellenwerte holst du aus `Schwellenwerte.md` (KI-generiert → gegen die Quelle plausibilisieren),
**nicht** aus dem Kopf. Ziel: Bewertungslogik **≥ 80 %** Coverage.

### 5. `coding-standards` + `error-handling` — während du schreibst  · WP3
`coding-standards` hält Namen/Struktur/Modulgrenzen sauber (Bewertungslogik bleibt in `assessment/`).
`error-handling` sorgt dafür, dass Stale/Defekt **explizit** behandelt wird — kein stiller Fehler, der
heimlich GRÜN durchrutscht. Schwellen als **benannte Konstanten**, zur Laufzeit parametrierbar.

### 6. `quality-gate` — vor dem Commit  · WP4
Format/Lint + Secret-Check. Roter Build? Erst grün, dann weiter — nicht „committen und hoffen".

### 7. `security-scan` — schneller Gate-Scan  · WP4
Der **schlanke Quick-Scan** direkt vor Commit/Merge: Secrets? SQL-Injection? **RB-01** (kein
Aktor-/Freigabe-Endpoint)? Fehler-Leaks? Bewusst schnell — **nicht** der große Review (der kommt im PR).

### 8. `code-review` (Selbst-Review) + `pr` — vor dem PR  · WP5
`code-review` auf deinen **eigenen** Diff: Struktur, Korrektheit, Tests. Dann `pr` — erzeugt den
Pull Request gegen den eingefrorenen Contract. Kein direkter `main`-Push.

### 9. `entscheidungslog` — wenn DU etwas entschieden hast
Hast du z. B. den sicheren Ersatzzustand „GELB" statt „unbekannt" gewählt? Das ist **deine** Entscheidung →
`entscheidungslog`: Optionen, Begründung, **verworfene Alternativen**, in deinen eigenen Worten.
Das sichert die benotete 40 %-Einzelleistung — der Agent schreibt sie **nicht** für dich.

### 10. `save-session` — am Ende  · WP8
Sichert den Stand (append-only in `erinnerung/`), damit der/die Nächste nahtlos weiterkommt.

---

## Szenario B — Reviewerin/Testerin: den PR von oben prüfen

### 1. `uni:start` → 2. `code-tour`  · WP0/WP6
`code-tour` führt dich durch den Change, **bevor** du urteilst — verstehen vor freigeben.

### 3. `review-pr` — der Orchestrator mit DoD-Gate  · WP6
**Das** Reviewer-Werkzeug. Bündelt die Bausteine zu einer **Freigabe-Entscheidung**:
`code-review` (+ `python-review`/`fastapi-review`) → `security-review` → `test-coverage` →
bei kritischem Pfad `verification-loop`. **Freigabe nur bei erfüllter DoD.** Der Agent entwirft das Review,
**du liest, hinterfragst und verantwortest** es.

### 4. `run` + `verify` — wirklich starten  · WP7
App/API **echt** hochfahren und Verhalten beobachten — nicht „sieht korrekt aus" behaupten. Speziell:
Stale-Daten reinspielen und prüfen, dass **nie GRÜN** rauskommt.

### 5. `save-session`  · WP8

---

## Schärfungs-Spickzettel — die leicht verwechselbaren Paare

| Wenn du… | nimm | **nicht** |
|---|---|---|
| schnell vor Commit auf Secrets/SQL/RB-01/Leaks scannst | `security-scan` (Quick-Scan) | `security-review` |
| einen PR sicherheitstechnisch **vollständig** prüfst (Fail-safe, Audit, Triage) | `security-review` (Rahmen) | `security-scan` |
| einen **Diff inhaltlich** bewertest (auch als Dev-Selbst-Review) | `code-review` (Prüf-Baustein) | `review-pr` |
| einen **PR mit DoD-Gate & Freigabe** abschließt | `review-pr` (Orchestrator) | `code-review` |

Merksatz: **scan = schnell am Gate, review = strukturiert & verantwortet.**
**code-review prüft einen Diff, review-pr entscheidet über den PR.**

---

## Wenn du nicht weiterweißt
- **Welcher Skill jetzt?** → `ecc-guide` fragen.
- **Fachfrage zum Use-Case** (Schwelle, Regel, Anforderung) → Quelle in `Alarmsystem-Dev`, **nie raten**.
- **Skill fehlt / Command unbekannt?** → falscher Ordner oder `setup` nicht gelaufen; sonst Lucas fragen.

---
*Ergänzt: `Skill-Plan.md` (Übersicht & Begründung), `gemeinsam/Skills.md` (Fundament),
`abteilung-backend-entwickler/Skills.md`, `abteilung-reviewer-tester/Skills.md` (Rollen-Kanon).*

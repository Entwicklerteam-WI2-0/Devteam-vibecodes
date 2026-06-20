# Devteam-Vibecodes — Team-OS für G2 (Backend & Entscheidungslogik)

> Das **Werkzeug-Repo** des Backend-Teams (G2) im Projektkurs *„Vereisungserkennung am Flughafen ANR"*.
> Hier liegt **nicht der Produktcode**, sondern das **Team-Betriebssystem**: eine einheitliche,
> lokal laufende KI-Agenten-Umgebung — geteilte **Anweisung**, **Skills**, Hooks und Setup —, mit der
> das Team produktiv und regelkonform im **echten Code-Repo** arbeitet.
> Self-contained: **ein Klon + ein Setup-Befehl**, kein Plugin nötig. Sprache aller Artefakte: **Deutsch**.

---

## Was ist das hier — und was nicht?

| | **Devteam-Vibecodes** (dieses Repo) | **Alarmsystem-Dev** (Code-Repo) |
|---|---|---|
| **Zweck** | Werkzeugkasten: geteilte Agenten-Anweisung + Skills + Setup | Der eigentliche Use-Case: Backend-Code + RE-/Design-Doku |
| **Inhalt** | `claude-sync.md`, `.claude/skills/`, Setup-Skripte, Konventionen | Lauffähiger Prototyp + Pflichtdokumentation |
| **Wer arbeitet hier** | Lucas (Architekt/PM) pflegt das Toolkit | Das gesamte Team (Devs + Reviewer:innen) |

> **Merke:** Wird ein Agent hier gebeten, „das System" zu bauen → das geschieht im **Code-Repo**.
> Hier wird das *Werkzeug* gebaut, mit dem dort gebaut wird.

---

## Schnellstart

**1. KI-CLI installieren** (einmalig). Der Standard ist **Claude Code**; Alternativen für **Kimi Code** (3b) und **Codex CLI** (3c) sind unten beschrieben.

**2. Dieses Repo klonen**
```bash
git clone <REPO-URL-von-Lucas>
cd Devteam-vibecodes
```

**3a. Setup — Claude Code (Standard)**
```bash
bash setup.sh                                        # macOS / Linux
powershell -ExecutionPolicy Bypass -File .\setup.ps1 # Windows (als Datei starten!)
```
Legt `claude-sync.md` als eigene Datei `~/.claude/team-os-g2.md` ab und ergänzt die globale `~/.claude/CLAUDE.md`
**additiv** um einen `@import`-Block — eine vorhandene persönliche `CLAUDE.md` bleibt erhalten (Backup wird angelegt).
Installiert außerdem die **Skills als `uni`-Plugin** (`~/.claude/skills/uni/` → Aufruf **`uni:<skill>`**,
kollisionsfrei neben einem evtl. installierten **ECC**-Stack) plus die globalen Commands `/setup` + `/update`.
Sie greifen in **jedem** Repo (auch im Code-Repo `Alarmsystem-Dev`), nicht nur in diesem Tooling-Repo.
Danach: Ordner in **VS Code** öffnen → `claude` starten → „Projekt vertrauen" → **`/uni:start`** tippen.
**Beim allerersten Lauf** startet ein kurzes **Rollen-Bootstrap** (Abteilung? bei Backend: Dev oder
Database-Engineer?) — danach plant der Agent jede Session entlang deines Abteilungs-Workflows und signiert
deine Erinnerungs-Einträge mit deiner Rolle.

**3b. Setup — Kimi Code (Alternative)**
```bash
bash setup-kimi.sh                                        # macOS / Linux
powershell -ExecutionPolicy Bypass -File .\setup-kimi.ps1 # Windows
```
Installiert **Skills** nach `~/.kimi-code/skills/` (Aufruf `/skill:<name>`), die **globale Anweisung** nach
`~/.kimi-code/AGENTS.md` (additiv) und die **Commands als Skills** — Kimi hat kein Command-Verzeichnis, daher
wird `/start` zu **`/skill:start`** und `/setup` zu `/skill:setup`.

**3c. Setup — Codex CLI (OpenAI / ChatGPT)**
Erst die **Codex CLI installieren** (`codex --version` muss laufen), dann denselben Ein-Befehl-Flow:
```bash
bash setup-codex.sh                                        # macOS / Linux
powershell -ExecutionPolicy Bypass -File .\setup-codex.ps1 # Windows
```
Ein Lauf erledigt **alles automatisch**: `claude-sync.md` **additiv** als Team-Block in `~/.codex/AGENTS.md`
(globaler System-Prompt; vorhandene `AGENTS.md` bleibt), alle Skills → `~/.codex/skills/` (nativ),
je Skill ein Command → `~/.codex/prompts/` (Aufruf **`/prompts:<name>`**, z. B. `/prompts:tdd-workflow` — oder `/` tippen und auswählen) und aktiviert das
Skills-Feature (`codex --enable skills`). Danach: `codex` starten → „Projekt vertrauen".
*Ist `codex` beim Setup noch nicht installiert, legt das Skript alles korrekt ab und nennt den einen
Befehl (`codex --enable skills`), den du danach einmal ausführst.*

> Details & Troubleshooting: [`ONBOARDING.md`](ONBOARDING.md).

---

## Aktualisieren & Versionierung

Das Toolkit ist **versioniert** — `VERSION`-Datei + Git-Tags (SemVer), **seit v1.0.0**.
Aktueller Stand: siehe `VERSION` bzw. neuester Tag (`git tag`).

**Update auf den neuesten Stand — ein Befehl:**
```bash
bash update.sh                                         # macOS / Linux
powershell -ExecutionPolicy Bypass -File .\update.ps1  # Windows
```
Holt den neuesten Stand (`git pull`) und führt anschließend das Setup erneut aus — frischt `team-os-g2.md`,
alle Skills und Commands in `~/.claude/` auf und zeigt **Version alt → neu**. Danach **Claude Code neu
starten**, damit neue Skills/Commands geladen werden. (Kimi/Codex: zusätzlich das jeweilige `setup-…` erneut ausführen.)

> Nach dem ersten Setup geht das in Claude Code auch per Slash-Command **`/update`** (identischer Ablauf).
> Erstmalig — solange `/update` noch nicht installiert ist — einmal `git pull` + Setup; danach steht `/update` bereit.
> **Versionspflege (Lucas):** bei nennenswerten Änderungen `VERSION` hochzählen + Tag setzen
> (`git tag -a vX.Y.Z -m "…" && git push origin vX.Y.Z`).

---

## Repo-Struktur

```text
Devteam-vibecodes/
├── claude-sync.md                  # GLOBALE Agenten-Anweisung → ~/.claude/team-os-g2.md (via setup)
├── setup.ps1 / setup.sh            # Setup Claude Code: team-os-g2.md + @import-Block in ~/.claude/CLAUDE.md
├── setup-kimi.ps1 / setup-kimi.sh  # Setup Kimi Code: Skills + Anweisung → ~/.kimi-code/
├── setup-codex.ps1 / setup-codex.sh# Setup Codex CLI: AGENTS.md + Skills + Commands → ~/.codex/
├── update.ps1 / update.sh          # Update: git pull + Setup erneut (Version alt → neu); auch via /update
├── VERSION                         # Tooling-Version (SemVer) — plus Git-Tags vX.Y.Z
├── ONBOARDING.md                   # 3-Schritte-Startanleitung (alle CLIs)
├── .github/
│   └── workflows/                  # CI: claude.yml (Issue-Trigger), claude-code-review.yml (PR-Review)
├── .claude/
│   ├── settings.json               # Aktive Hooks (SessionStart-Hinweis)
│   ├── commands/                   # start -> uni:start (ins uni-Plugin); /setup + /update bleiben global
│   ├── hooks/                      # Hook-Blueprint (RB-01-Guard, Secret-Scan, Schema-Diff — geplant)
│   └── skills/                     # 36 SKILLS (je eine SKILL.md — via setup global installiert)
├── erinnerung/                     # Geteiltes Projektgedächtnis (von uni:start geladen)
│   ├── stand.md                    # Aktueller Stand (Session-Resumé)
│   └── journal/                    # Tageseinträge (append-only)
├── Skill-Plan.md                   # Master-Plan: Taxonomie, Workflow-Punkte, Begründung
├── Skillanleitung.md               # Skills in Aktion: realistischer Durchlauf an einem Ticket (Dev + Reviewer)
├── Entscheidungslog-Lucas/         # persönl. Entscheidungslogs (Architekt) — jede Datei beginnt mit Datum
│   ├── Entscheidungslog-Toolkit.md      # Tool-/Modell-/Lizenz-Entscheidungen
│   └── Lucas-Entscheidungslog.md        # Aufbau Team-OS, Organisationsstruktur, Workflows
├── Seam-Sync-Fragenkatalog.md       # Naht-Fragen (Contract G1↔G2↔G3)
├── gemeinsam/Skills.md             # Geteilte Skills (beide Abteilungen)
├── abteilung-backend-entwickler/Skills.md   # Toolkit Backend-Dev
├── abteilung-reviewer-tester/Skills.md      # Toolkit Reviewer/Test
└── README.md                       # diese Datei
```

**Skills im `.claude/skills/`** (36, aus dem ECC-Stack auf Python/FastAPI/pytest + Use-Case angepasst) — `setup` installiert sie als **`uni`-Plugin**, Aufruf **`uni:<name>`** (kollisionsfrei neben ECC):

> **Skills in Aktion** — wann welcher Skill feuert, an einem echten Ticket durchgespielt:
> [`Skillanleitung.md`](Skillanleitung.md). Übersicht & Begründung: [`Skill-Plan.md`](Skill-Plan.md).

*Geteilt — beide Rollen:*
`aside` · `code-review` · `coding-standards` · `codebase-onboarding` · `documentation-lookup` ·
`ecc-guide` · `erinnerung-update` · `fastapi-review` · `git-workflow` · `python-review` ·
`save-session` · `security-review`

*Backend-Entwickler:innen:*
`api-design` · `architecture-decision-records` · `build-fix` · `checkpoint` · `entscheidungslog` ·
`error-handling` · `fastapi-patterns` · `feature-dev` · `plan` · `pr` ·
`python-patterns` · `python-testing` · `quality-gate` · `test-coverage` · `tdd-workflow` · `update-docs`

*Reviewerinnen/Testerinnen:*
`browser-qa` · `code-tour` · `e2e-testing` · `review-pr` · `santa-loop` ·
`security-scan` · `verification-loop`

*Situativ (erst bei Stack-Wechsel T2+):*
`database-migrations`

> Die **geteilte Anweisung** ist die versionierte `claude-sync.md`; `setup` legt sie als
> `~/.claude/team-os-g2.md` ab und bindet sie via `@import`-Block in die globale `~/.claude/CLAUDE.md` ein.
> **Immer `claude-sync.md` ändern (per PR)** — nicht die lokalen Dateien, sonst driften die Stände auseinander.

---

## Wie es funktioniert (Architektur)

- **Global vs. Projekt:** `claude-sync.md` (global) trägt Operating Mode, Workflow-Gates, Conventions,
  Sicherheit — **projektneutral**. Use-Case-Fakten (Schwellenwerte, RB-01-Werte, Phasen) bleiben im
  Code-Repo `Alarmsystem-Dev` und werden von dort gelesen, nicht hier dupliziert.
- **Skills reisen mit dem Repo:** echte `SKILL.md` unter `.claude/skills/` — kein ECC-Plugin nötig.
  `setup` installiert sie **global** — Claude nach `~/.claude/skills/`, Kimi nach `~/.kimi-code/skills/`,
  Codex nach `~/.codex/skills/` — damit sie in **jedem** Repo greifen, nicht nur im Tooling-Repo.
- **Standards als Hooks:** wiederkehrende Qualitäts-/Sicherheitsregeln werden als Hooks erzwungen
  (RB-01-Guard, Secret-Scan, OpenAPI-Schema-Diff — geplant/in Einrichtung), nicht nur im Review erhofft.
- **CI-Workflows:** `.github/workflows/claude.yml` reagiert auf Issue-/PR-Kommentare mit `@claude`-Trigger;
  `claude-code-review.yml` löst automatische PR-Reviews aus.

---

## Die zwei Werkzeugkästen (Abteilungen)

Eingeteilt nach **Systemverständnis & Output**, nicht nach reinem Coding-Skill — operative
Standardarbeit (Format, Lint, Tests, Repo-Hygiene) übernimmt der Agent.

- **A) Backend-Entwickler:innen** — bauen gegen den eingefrorenen Contract: Ingest, Persistenz,
  **Vereisungs-Bewertungslogik**, API. Tests-first (TDD), Selbst-Review vor dem PR.
- **B) Reviewerinnen/Testerinnen** — der Agent erstellt Review-/Test-Entwürfe, der **Mensch prüft und
  gibt frei** (bewertungsrelevant: 40 % Einzelleistung). Live-Test der laufenden API, Testsuite-Pflege.

**Einstiegs-Set (Pflicht, Tag 1) — bewusst klein:**
- **Backend-Dev (4 Kern-Skills):** `uni:start` · `tdd-workflow` · `quality-gate` · `pr` + `code-review` (Selbst-Review) · `save-session`
  Woche 1, sobald TDD sitzt: `feature-dev` · `python-testing` · `fastapi-patterns`
- **Reviewer/Test:** `uni:start` · `code-tour` · `code-review` · `test-coverage` · `run`/`verify` · `save-session`
  Situativ: `santa-loop` + `verification-loop` (kritischer Pfad) · `browser-qa` (G3-Integration)

Alles Weitere ist **situativ** — bei Bedarf aus den Abteilungs-`Skills.md` dazunehmen.

---

## Konventionen & Spielregeln

- **Sprache:** Deutsch für alle Artefakte.
- **Git:** Feature-Branch → Pull Request → Review → `main`. `main` bleibt lauffähig, **kein direkter Push**.
- **Genehmigungspflicht:** Push, PR, Merge, force-push und destruktive Git-Aktionen **nur nach
  expliziter Freigabe durch Lucas**. Den Branch/PR-Flow nimmt der Agent dem Dev ab.
- **Keine Secrets** committen — weder hier noch im Code-Repo.
- **Use-Case-Fakten** nie aus dem Gedächtnis — immer aus `Alarmsystem-Dev` lesen.
- **Sicherheitskritisch:** Das Zielsystem darf die Startbahn **nie automatisch freigeben/sperren**
  (RB-01); bei Ausfall/veralteten Daten **nie GRÜN** (Fail-safe).

---

## Bezug zum Use-Case

Der eigentliche Prototyp (Erfassung & Bewertung von Vereisungsbedingungen am fiktiven Regionalflughafen
**ANR**) und die maßgebliche Dokumentation liegen im Code-Repo:

➡️ **[Entwicklerteam-WI2-0/Alarmsystem-Dev](https://github.com/Entwicklerteam-WI2-0/Alarmsystem-Dev)**

Dort stehen Lastenheft, Backend-Konzept, Schwellenwert-/Bewertungslogik, Projektplan und
Entscheidungslogbuch. Bei Use-Case-Fragen **immer zuerst dort** nachsehen.

---

*Gepflegt von Lucas Vöhringer (Systemarchitekt G2). Stand: Juni 2026.*

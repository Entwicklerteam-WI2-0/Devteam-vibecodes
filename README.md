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

**1. KI-CLI installieren** (einmalig). Die meisten nutzen **Claude Code**; Sonderwege für **Kimi Code** (3b) und **Codex CLI** (3c) sind unten beschrieben.

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
Rollt `claude-sync.md` als globale `~/.claude/CLAUDE.md` aus. Skills/Commands/Hooks kommen automatisch aus `.claude/`.
Danach: Ordner in **VS Code** öffnen → `claude` starten → „Projekt vertrauen" → **`/start`** tippen.

**3b. Setup — Kimi Code (Sonderfall)**
```bash
bash setup-kimi.sh                                        # macOS / Linux
powershell -ExecutionPolicy Bypass -File .\setup-kimi.ps1 # Windows
```
Kopiert die Skills nach `~/.kimi-code/skills/` (Kimi liest dasselbe `SKILL.md`-Format nativ). Aufruf im Chat via `/skill:<name>`.
*Globale Anweisung, Hooks und `/start`/`/setup` folgen für Kimi als spätere, spezialisierte Iteration.*

**3c. Setup — Codex CLI (OpenAI / ChatGPT)**
Erst die **Codex CLI installieren** (`codex --version` muss laufen), dann **denselben Ein-Befehl-Flow**:
```bash
bash setup-codex.sh                                        # macOS / Linux
powershell -ExecutionPolicy Bypass -File .\setup-codex.ps1 # Windows
```
Ein Lauf erledigt **alles automatisch**: `claude-sync.md` → `~/.codex/AGENTS.md` (globaler System-Prompt,
gleiche Rolle wie die `CLAUDE.md`), alle Skills → `~/.codex/skills/` (nativ, identisches `SKILL.md`-Format),
je Skill ein Command → `~/.codex/prompts/` (Aufruf `/<name>`, z. B. `/tdd-workflow`) und aktiviert das
Skills-Feature (`codex --enable skills`). Danach: `codex` starten → „Projekt vertrauen". Skills laufen
automatisch (Auto-Trigger) **oder** explizit per Command.
*Ist `codex` beim Setup noch nicht installiert, legt das Skript alles korrekt ab und nennt den einen
Befehl (`codex --enable skills`), den du danach einmal ausführst.*

> Details & Troubleshooting: [`ONBOARDING.md`](ONBOARDING.md).

---

## Repo-Struktur

```text
Devteam-vibecodes/
├── claude-sync.md                  # GLOBALE Agenten-Anweisung → ~/.claude/CLAUDE.md (via setup)
├── setup.ps1 / setup.sh            # Setup Claude Code: rollt claude-sync.md global aus
├── setup-kimi.ps1 / setup-kimi.sh  # Setup Kimi Code: kopiert Skills → ~/.kimi-code/skills/
├── setup-codex.ps1 / setup-codex.sh# Setup Codex CLI: AGENTS.md + Skills + Commands global → ~/.codex/
├── ONBOARDING.md                   # 3-Schritte-Startanleitung (alle CLIs)
├── .claude/
│   ├── settings.json               # Hooks (aktiv: SessionStart-Hinweis)
│   ├── commands/                   # Slash-Commands: /start, /setup
│   ├── hooks/                      # Hook-Blueprint (RB-01-Guard, Secret-Scan … — Phase 2)
│   └── skills/                     # DIE 9 PFLICHT-SKILLS (echte SKILL.md, Use-Case-angepasst)
├── erinnerung/                     # geteiltes Projektgedächtnis (von /start geladen)
├── Skill-Plan.md                   # Master-Plan: Taxonomie, Workflow-Punkte, Begründung
├── Entscheidungslog-Toolkit.md     # Tooling-Entscheidungen (Harness/Modell/Umgebung)
├── gemeinsam/Skills.md             # Plan: GETEILTE Skills (beide Abteilungen)
├── abteilung-backend-entwickler/Skills.md   # Plan: Toolkit Backend-Dev
├── abteilung-reviewer-tester/Skills.md      # Plan: Toolkit Reviewer/Test
└── README.md                       # diese Datei
```

**Skills im `.claude/skills/`** (geforkt aus ECC, neu geschrieben auf Python/FastAPI/pytest + Use-Case):
`tdd-workflow` · `python-testing` · `quality-gate` · `fastapi-patterns` · `feature-dev` · `pr` ·
`code-tour` · `test-coverage` · `save-session`.

> Die **geteilte** Anweisung ist die versionierte `claude-sync.md`; `setup` rollt sie als globale
> `~/.claude/CLAUDE.md` aus. **Immer `claude-sync.md` ändern (per PR)** — nicht die lokale `CLAUDE.md`,
> sonst driften die Stände auseinander.

---

## Wie es funktioniert (Architektur)

- **Global vs. Projekt:** `claude-sync.md` (global) trägt Operating Mode, Workflow-Gates, Conventions,
  Sicherheit — **projektneutral**. Use-Case-Fakten (Schwellenwerte, RB-01-Werte, Phasen) bleiben im
  Code-Repo `Alarmsystem-Dev` und werden von dort gelesen, nicht hier dupliziert.
- **Skills reisen mit dem Repo:** echte `SKILL.md` unter `.claude/skills/` — kein ECC-Plugin nötig.
  Claude Code lädt sie aus `.claude/skills/`, Kimi aus `~/.kimi-code/skills/` (via `setup-kimi`),
  Codex aus `~/.codex/skills/` (via `setup-codex`).
- **Standards als Hooks:** wiederkehrende Qualitäts-/Sicherheitsregeln werden (Phase 2) als Hooks
  erzwungen, nicht nur im Review erhofft.

---

## Die zwei Werkzeugkästen (Abteilungen)

Eingeteilt nach **Systemverständnis & Output**, nicht nach reinem Coding-Skill — operative
Standardarbeit (Format, Lint, Tests, Repo-Hygiene) übernimmt der Agent.

- **A) Backend-Entwickler:innen** — bauen gegen den eingefrorenen Contract: Ingest, Persistenz,
  **Vereisungs-Bewertungslogik**, API. Tests-first (TDD), Selbst-Review vor dem PR.
- **B) Reviewerinnen/Testerinnen** — der Agent erstellt Review-/Test-Entwürfe, der **Mensch prüft und
  gibt frei** (bewertungsrelevant: 40 % Einzelleistung). Live-Test der laufenden API, Testsuite-Pflege.

**Einstiegs-Set (Pflicht, Tag 1) — bewusst klein:**
- **Backend-Dev:** `/start` · `tdd-workflow` · `quality-gate` · `pr` + `code-review` (Selbst-Review) · `save-session`
- **Reviewer/Test:** `/start` · `code-tour` · `code-review` · `test-coverage` · `run`/`verify` · `save-session`

Alles Weitere ist **situativ** — bei Bedarf aus der Abteilungs-`Skills.md` dazunehmen.

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

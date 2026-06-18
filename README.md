# Devteam-Vibecodes — Team-OS für G2 (Backend & Entscheidungslogik)

> Das **Werkzeug-Repo** des Backend-Teams (G2) im Projektkurs *„Vereisungserkennung am Flughafen ANR"*.
> Hier liegt **nicht der Produktcode**, sondern das **Team-Betriebssystem**: ein einheitlicher,
> lokal laufender Claude-Code-Stack (rollenspezifische **Skills**, Hooks, gemeinsame Config),
> mit dem das Team produktiv und regelkonform ins **echte Code-Repo** arbeitet.
> Sprache aller Artefakte: **Deutsch**.

---

## Was ist das hier — und was nicht?

| | **Devteam-Vibecodes** (dieses Repo) | **Alarmsystem-Dev** (Code-Repo) |
|---|---|---|
| **Zweck** | Werkzeugkasten: *welche* KI-Skills nutzt *welche* Rolle, *wann* | Der eigentliche Use-Case: Backend-Code + RE-/Design-Doku |
| **Inhalt** | Skill-Plan, rollenbasierte Toolkits, Konventionen | Lauffähiger Prototyp + Pflichtdokumentation |
| **Wer arbeitet hier** | Lucas (Architekt/PM) konzipiert die Toolkits | Das gesamte Team (Devs + Reviewer:innen) |

> **Merke:** Wird ein Agent hier gebeten, „das System" zu bauen → das geschieht im **Code-Repo**.
> Hier wird das *Werkzeug* gebaut, mit dem dort gebaut wird.

---

## Repo-Struktur

```text
Devteam-vibecodes/
├── claude-sync.md                       # GLOBALE Agenten-Anweisung → ~/.claude/CLAUDE.md (via setup)
├── setup.ps1 / setup.sh                 # Einmal-Setup: rollt claude-sync.md global aus
├── ONBOARDING.md                        # 3-Schritte-Startanleitung
├── .claude/                             # settings.json · commands/ (/start, /setup) · hooks/
├── erinnerung/                          # geteiltes Gedächtnis (von /start geladen)
├── Skill-Plan.md                        # Master-Plan: Taxonomie, Workflow-Punkte,
│                                        #   Begründung, Ausschlüsse, Review-Loop
├── gemeinsam/
│   └── Skills.md                        # GETEILTE Skills (von beiden Abteilungen genutzt)
├── abteilung-backend-entwickler/
│   └── Skills.md                        # Toolkit der Backend-Entwickler:innen
├── abteilung-reviewer-tester/
│   └── Skills.md                        # Toolkit der Reviewerinnen/Testerinnen
└── README.md                            # diese Datei
```

| Dokument | Inhalt |
|---|---|
| [`claude-sync.md`](claude-sync.md) | **Globale Agenten-Anweisung** → `~/.claude/CLAUDE.md` (Operating Mode, Workflow, Conventions, Sicherheit) |
| [`ONBOARDING.md`](ONBOARDING.md) | 3-Schritte-Setup (klonen → `setup` → `/start`) |
| [`Skill-Plan.md`](Skill-Plan.md) | Übersicht + Begründung des gesamten Skill-Plans (**hier starten**) |
| [`gemeinsam/Skills.md`](gemeinsam/Skills.md) | Fundament-Skills für **alle** (Kontext, Konventionen, Review, Git) |
| [`abteilung-backend-entwickler/Skills.md`](abteilung-backend-entwickler/Skills.md) | Skills für Implementierung (Ingest, API, Bewertungslogik, Tests) |
| [`abteilung-reviewer-tester/Skills.md`](abteilung-reviewer-tester/Skills.md) | Skills für Reviews, Tests & Live-Test der laufenden App |

> Die **geteilte** Agenten-Anweisung ist die versionierte `claude-sync.md`; `setup` rollt sie als
> globale `~/.claude/CLAUDE.md` aus. Eine lokale, nicht versionierte `CLAUDE.md` (gitignored) kann ein
> Mitglied zusätzlich für persönliche Notizen halten.

---

## Die zwei Werkzeugkästen (Abteilungen)

Eingeteilt nach **Systemverständnis & Output**, nicht nach reinem Coding-Skill — operative
Standardarbeit (Format, Lint, Tests, Repo-Hygiene) übernimmt der Agent.

- **A) Backend-Entwickler:innen** — bauen gegen den vom Architekten eingefrorenen Contract:
  Ingest, Persistenz, **Vereisungs-Bewertungslogik**, API. Tests-first (TDD), Selbst-Review vor dem PR.
- **B) Reviewerinnen/Testerinnen** — der Agent erstellt Review-/Test-Entwürfe, der **Mensch prüft und
  gibt frei** (bewertungsrelevant: 40 % Einzelleistung). Live-Test der laufenden API, Testsuite-Pflege.

Jeder Skill ist nach **Nutzen-Schwerpunkt** klassifiziert: **OP** Operativ · **SR** Selbst-Review ·
**CR** Conventions/Regeln · **WG** Workflow-Gate (getriggert) · **VO** Verständnis/Onboarding.

---

## Schnellstart für Teammitglieder

1. **Claude Code installieren** — ein Tool für alle (Skills/Hooks sind Claude-Code-spezifisch).
2. **Dieses Repo klonen** und die Rolle wählen (Backend-Dev *oder* Reviewer/Test).
3. **Setup ausführen** — `bash setup.sh` (macOS) bzw. `powershell -ExecutionPolicy Bypass -File setup.ps1` (Windows);
   rollt `claude-sync.md` als globale `~/.claude/CLAUDE.md` aus. Danach `claude` starten und **`/start`** tippen. Details: [`ONBOARDING.md`](ONBOARDING.md).
4. **Dein „Einstiegs-Set" lesen** — der bewusst kleine Pflichtkanon in deiner Abteilungs-`Skills.md`:
   - **Backend-Dev (Tag 1):** `ck` · `tdd-workflow` · `quality-gate` · `pr` + `code-review` (Selbst-Review) · `save-session`
   - **Reviewer/Test (Tag 1):** `ck` · `code-tour` · `code-review` · `test-coverage` · `run` + `verify` · `save-session`
5. **Alles Weitere ist situativ** — bei Bedarf aus der Tabelle dazunehmen. Nicht alles auf einmal lernen.

---

## Konventionen & Spielregeln

- **Sprache:** Deutsch für alle Artefakte.
- **Git:** Feature-Branch → Pull Request → Review → `main`. `main` bleibt lauffähig, **kein direkter Push**.
- **Genehmigungspflicht:** Push, PR, Merge, force-push und destruktive Git-Aktionen **nur nach
  expliziter Freigabe durch Lucas**.
- **Keine Secrets** committen — weder hier noch im Code-Repo.
- **Use-Case-Fakten** nie aus dem Gedächtnis — immer aus dem Code-Repo lesen (siehe unten).
- **Sicherheitskritisch:** Das Zielsystem darf die Startbahn **nie automatisch freigeben/sperren**
  (RB-01); bei Ausfall/veralteten Daten **nie GRÜN** (Fail-safe). Diese Regeln werden im Toolkit
  als **Hooks + Verifikations-Gate** erzwungen, nicht nur im Review erhofft.

---

## Bezug zum Use-Case

Der eigentliche Prototyp (Erfassung & Bewertung von Vereisungsbedingungen am fiktiven Regionalflughafen
**ANR** ≈ Flugplatz Coburg) und die maßgebliche Dokumentation liegen im Code-Repo:

➡️ **[Entwicklerteam-WI2-0/Alarmsystem-Dev](https://github.com/Entwicklerteam-WI2-0/Alarmsystem-Dev)**

Dort stehen das Lastenheft, das Backend-Konzept, die Schwellenwert-/Bewertungslogik, der Projektplan
und das Entscheidungslogbuch. Bei Use-Case-Fragen **immer zuerst dort** nachsehen.

---

*Gepflegt von Lucas Vöhringer (Systemarchitekt G2). Stand: Juni 2026.*

# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

**Devteam-Vibecodes — Team-OS für G2 (Backend & Entscheidungslogik).**

> Diese Datei steuert Agenten, die **in diesem Repo** arbeiten (`Devteam-vibecodes` — egal, wohin geklont).
> Hier wird **nicht der Produktcode** gebaut, sondern das **Team-Betriebssystem**: der
> einheitliche, lokal laufende Agenten-Stack (gemeinsame Config, Hooks, **rollenspezifische Skills**),
> mit dem die Backend-Gruppe G2 produktiv und regelkonform ins **echte Repo** arbeiten kann.
> Sprache aller Artefakte: **Deutsch**.

## 0. Repo-Mechanik (zuerst lesen — wie man *in* diesem Repo arbeitet)

**Kein Code-Projekt.** Dies ist ein **Config-/Tooling-Repo** (Markdown + Setup-Skripte). Es gibt
**keinen Build, keine Testsuite, kein Lint/CI für Produktcode**. Die einzigen ausführbaren Artefakte
sind die Setup-Skripte; „Tests" = nach dem Lauf prüfen, ob die Zielpfade entstanden sind.

**Die „Befehle" = Setup-Skripte** (idempotent + additiv, gefahrlos erneut ausführbar):

| CLI | macOS / Linux | Windows | Deployt nach |
|---|---|---|---|
| Claude Code | `bash setup.sh` | `powershell -ExecutionPolicy Bypass -File .\setup.ps1` | `~/.claude/team-os-g2.md` + `@import`-Block in `~/.claude/CLAUDE.md`; Skills → `~/.claude/skills/`; Commands → `~/.claude/commands/`; Hooks → `~/.claude/hooks/` + `~/.claude/settings.json` |
| Kimi Code | `bash setup-kimi.sh` | `.\setup-kimi.ps1` | `~/.kimi-code/AGENTS.md` (additiv) + Skills → `~/.kimi-code/skills/` (Commands als Skills: `/start` → `/skill:start`) |
| Codex CLI | `bash setup-codex.sh` | `.\setup-codex.ps1` | `~/.codex/AGENTS.md` (inline Team-Block) + Skills → `~/.codex/skills/` + Prompt-Wrapper → `~/.codex/prompts/` (`/prompts:<name>`) |

**Verifikation statt Tests:** nach `setup.sh` prüfen, dass `~/.claude/team-os-g2.md` existiert und
`~/.claude/CLAUDE.md` den `@import`-Block (`<!-- TEAM-OS-G2 BEGIN ... -->`) enthält. Skripte sind
**idempotent** → erneuter Lauf aktualisiert nur, überschreibt nie.

**Update & Versionierung.** Das Toolkit ist versioniert (`VERSION` + Git-Tags, SemVer, **seit v1.0.0**;
aktueller Stand: siehe `VERSION`/Tag). Auf den neuesten Stand bringen — ein Befehl: `bash update.sh` bzw.
`powershell -ExecutionPolicy Bypass -File .\update.ps1` (= `git pull` + Setup erneut, zeigt Version alt → neu);
in Claude Code nach dem ersten Setup auch via **`/update`**. Bei Tooling-Änderungen `VERSION` hochzählen +
Tag setzen (`git tag -a vX.Y.Z … && git push origin vX.Y.Z`). Hinweis: **diese `CLAUDE.md` ist jetzt versioniert** (im Repo getrackt, reist mit)
— die menschenlesbare Gesamtübersicht für die Kollegen bleibt das `README.md`.

**Versionsstempel-Pflicht (verbindlich, seit v1.3.0).** Jedes Dokument mit einer Versionsangabe trägt
**immer die aktuelle `VERSION`**. Bei **jedem** Edit an einem solchen Dokument wird der Stempel auf den
Stand von `VERSION` gebracht (Footer `Toolkit-Version: vX.Y.Z`). **Kein Edit ohne Versions-Sync** — eine
veraltete Versionsangabe in einem Dokument gilt als Bug. Source of Truth ist die `VERSION`-Datei.

### Deployment-Architektur (Source of Truth)
- **`claude-sync.md` ist die EINZIGE Quelle der globalen Agenten-Anweisung.** Setup kopiert sie an die
  deployten Ziele oben. → **Immer `claude-sync.md` editieren (per PR), NIE die deployten Kopien**
  (`~/.claude/team-os-g2.md`, `~/.kimi-code/AGENTS.md`, `~/.codex/AGENTS.md`), sonst driften die Stände.
- **Skills** sind echte `SKILL.md` unter `.claude/skills/<name>/` — aus **ECC geforkt** und auf
  Python/FastAPI/pytest + Use-Case umgeschrieben. Eine Datei pro Skill; Setup installiert sie **global**,
  damit sie in **jedem** Repo greifen (auch im Code-Repo), nicht nur hier.
- **Commands** liegen in `.claude/commands/*.md` (`uni:start`, `/setup`, `/update`); bei Kimi/Codex als Skill/Prompt
  gespiegelt (kein eigenes Command-Verzeichnis dort).
- Beim Ändern eines Setup-Skripts **alle Varianten konsistent halten**: je `.sh` **und** `.ps1`, über
  alle drei CLIs (Claude/Kimi/Codex).

### Kopplungs-Karte (Drift-Hotspots)

> **Gegen das wiederkehrende „README/Doku ist falsch"-Problem.** Änderst du einen dieser Fakten, sind
> **alle Spiegel** mitzuziehen. Die vollständige Kopplungs-Karte lebt jetzt in **`Abhaengigkeiten.md`**
> (Fakt → Source of Truth → Spiegel → Auslöser). Dieser Skill bzw. das Tooling-Repo aktualisiert sie dort
> zentral; bei Bedarf kann der Skill `coupling-map` die Spiegel automatisch nachziehen.

### Nicht-offensichtliche Stolpersteine
- **`CLAUDE.md` ist jetzt versioniert** (im Repo getrackt): **diese Projekt-Guidance reist mit `git pull`.**
  Die Quelle der **globalen** Agenten-Anweisung bleibt dennoch `claude-sync.md`; diese Datei ist die
  **projekt-spezifische** Guidance fürs Arbeiten *in* diesem Repo (anderer Zweck, andere Datei).
- Setup ist **additiv & idempotent** — überschreibt **nie** eine vorhandene persönliche `CLAUDE.md`/
  `AGENTS.md`; legt bei Bedarf ein `.bak`-Backup an. **Die uni-Skills werden hingegen gespiegelt:** aus der
  Quelle gelöschte Skills verschwinden beim nächsten `setup`/`update` auch bei bereits Installierten
  (Claude: dedizierter `uni`-Ordner; Kimi/Codex: manifest-gestützt via `.team-os-installed`, damit eigene
  Skills des Users erhalten bleiben — greift dort ab dem übernächsten Update, da das Manifest erst angelegt wird).
- **Deutsch** für alle erzeugten Artefakte (Skills, Commands, Doku).

### Orientierung — wo liegt was
- `claude-sync.md` — globale Anweisung (Workflow-Gates, Conventions, Sicherheit). **Hier ändern.**
- `.claude/skills/` — die Use-Case-Skills · `.claude/commands/` — `uni:start`, `/setup`, `/update` ·
  `.claude/hooks/README.md` — aktive Hooks (`fact-forcing-gate`, Claude Code + Kimi Code) + geplante Phase-2-Hooks
  (verdrahtet in `.claude/settings.json`).
- `Skill-Plan.md` — Master-Taxonomie/Begründung · `gemeinsam/Skills.md` +
  `abteilung-architekten/Skills.md` + `abteilung-backend-entwickler/Skills.md` +
  `abteilung-reviewer-tester/Skills.md` — rollenbasierte Pläne.
- `Entscheidungslog-Toolkit.md` — Tooling-Entscheidungen · `Seam-Sync-Fragenkatalog.md` — Contract/Naht-Fragen.
- `erinnerung/` — geteiltes Projektgedächtnis (`stand.md` + `journal/`), von `uni:start` gelesen, **append-only**.
- `.github/workflows/` — `claude.yml` (@claude-PR-Assistent) + `claude-code-review.yml` (Auto-PR-Review);
  brauchen Secret `CLAUDE_CODE_OAUTH_TOKEN`.

## 1. Was dieses Verzeichnis ist (und was nicht)

| | Dieses Verzeichnis `Devteam-vibecodes` | Das Code-/Doku-Repo `Alarmsystem-Dev` |
|---|---|---|
| **Zweck** | Werkzeugkasten/Team-OS: Skills, Hooks, Config, Onboarding für das Dev-Team | Eigentlicher Use-Case: Backend-Code + RE-/Design-Doku |
| **Wer arbeitet hier** | Lucas (Architekt/PM) konzipiert die Toolkits | Das gesamte Team (Devs + Reviewerinnen) |
| **Output** | gemeinsame `.claude/`-Config, rollenbasierte Skills, Hook-Setup, Anleitungen | lauffähiger Prototyp + Pflichtdokumentation |

**Merke:** Wenn ein Agent hier gebeten wird, „das System" oder „den Use-Case" zu bauen → das geschieht
**im anderen Repo**. Hier wird das *Werkzeug* gebaut, mit dem dort gebaut wird.

## 2. Source of Truth — das Code-Repo `Alarmsystem-Dev`

Lokal: das **separat geklonte** Schwester-Repo `Alarmsystem-Dev` (üblicherweise neben diesem Repo).
Remote: **`Entwicklerteam-WI2-0/Alarmsystem-Dev`** (GitHub, Org), Branch `main`.

Damit Agenten den Use-Case **richtig verstehen und bauen** können, sind dies die maßgeblichen Quellen
(immer dort lesen, nichts dazuerfinden):

### Root — Agenten-Onboarding (zuerst lesen)
- `CLAUDE.md` — **primärer Agenten-Einstieg** im Code-Repo; hält aktuellen Stand/Ergebnisse/Entscheidungen.
- `AGENTS.md` — Onboarding für CLI-Agenten; beschreibt den Stand **anhand der real vorhandenen Dateien**.
- `Agents-gpt-gemini.md` — kompaktes, beleg-basiertes **Use-Case-Briefing** (Projektkontext, Scope, Datei-Liste §4,
  einfügbarer Startprompt §9). Schnellster Weg, den Use-Case korrekt zu erfassen.
- `README.md` — ausführlichster **Gesamtüberblick** (Struktur, Deliverables, Workflow).

### Briefing-Rohmaterial (read-only, `01-quellen/`)
- `01-quellen/Die Hintergrundgeschichte.txt` — **bewusst widersprüchliches** Rohmaterial; Primärquelle des RE.
- `01-quellen/Studierenden-Handreichung.txt` — Aufgabenstellung, Rollen, Meilensteine, Bewertung.
- `01-quellen/Zeitplan.txt` — 3-Wochen-Plan, Meilensteine M1–M3.
- `01-quellen/Prüfungsleistung Anforderungen.txt` — Bewertungskriterien (40 % individuell / 60 % Gruppe).

### Erarbeitete Artefakte (`02-Arbeitsdokumente/`, lebende Deliverables)
- `02-Arbeitsdokumente/Usecase-quick.md` — Anforderungen **FA-01–12**, **NF-01–11**, Randbedingung **RB-01**,
  offene Entscheidungen **AE-01/AE-02**, Konflikte **K1–K9**.
- `02-Arbeitsdokumente/Schwellenwerte.md` — **Vereisungslogik + Schwellenwerte** (4 Stufen 🟢🟡🟠🔴).
  ⚠️ Selbst KI-generiert → **bezogene Werte mindestens logisch gegenprüfen**, nicht blind übernehmen.
- `02-Arbeitsdokumente/Backend-Konzept.md` — **Architektur G2**: Module (§2), Datenfluss (§3), Datenmodell (§4),
  Tech-Stack-Optionen (§6), **Code-/Repo-Struktur (§7)**, Ausbaustufen T0–T3 (§8), FA/NF→Modul-Mapping (§10).
- `02-Arbeitsdokumente/Tasks+Projektplan.md` — Phasen P0–P6, Meilensteine, Kanban (Owner/DoD/Größe).
- `02-Arbeitsdokumente/Team-Organisation+Regeln.md` — Rollen/DRI, Teamregeln.
- `02-Arbeitsdokumente/Entscheidungslog-Lucas-Systemarchitektur.md` — **Entscheidungslogbuch** (bewertungsrelevant).
- `02-Arbeitsdokumente/assets/` — Architekturskizze (`WhatsApp Image 2026-06-15 at 11.24.52.jpeg`), `Bild (1).png`.

### Abgaben (`03-abgaben/`, eingefrorene Stände)
- `03-abgaben/Nutzer und Stakeholdermodel 1.md` / `2.md` — Stakeholder-/Nutzermodell.

> **Gemeinsame IDs (FA/NF/RB/AE, K1–K9) über alle Dokumente.** Bei Klassifikations-/ID-Änderung **alle**
> betroffenen Dokumente konsistent halten (Drift-Gefahr). Die `CLAUDE.md` im Code-Repo hält den aktuellen
> Stand/Entscheidungen — bei Use-Case-Fragen **immer zuerst dort** nachsehen.

## 3. Der Use-Case in Kürze (damit Agenten den Kontext haben)

Prototyp zur **Erfassung & Bewertung von Vereisungsbedingungen** am fiktiven Regionalflughafen **ANR**
(Arbeitsannahme: ≈ Flugplatz Coburg). Fünf Komponenten gesamt; **G2 = Backend & Entscheidungslogik**.

**G2 baut:** Daten-Ingest · Validierung/Plausibilität (Stale/Defekt) · Persistenz · **Vereisungsbewertung
(4-Stufen-Logik)** · Alarm-Generierung · 30-min-Prognose · API · Logging/Audit · Config.
**G2 baut NICHT:** Sensor-Hardware (G1) · Visualisierung/UI (G3).
**Die einzige früh einzufrierende Naht = API + Datenmodell — gehört G2** (`Backend-Konzept.md §4/§9`).

Empfohlener Start-Stack (T0, offen, gehört begründet ins Entscheidungslogbuch):
**FastAPI + SQLite + HTTP-POST**; Bewertung als isolierbares, hoch getestetes Modul (Coverage ≥ 80 %).
Code-Struktur s. `Backend-Konzept.md §7` (`src/ingest|model|assessment|storage|api|config|forecast`, `tests/`).

## 4. Harte Randbedingungen (gelten für ALLES, was Agenten erzeugen)

- **RB-01 — keine Automatik-Freigabe:** Das System darf die Startbahn **nie** automatisch freigeben/sperren.
  Reine **Entscheidungsunterstützung**, kein Aktor. Kein Freigabe-/Steuer-Endpoint.
- **Vereisungslogik nur aus `Schwellenwerte.md`** — aber da KI-generiert: **logisch plausibilisieren**.
  Defaults parametrierbar, Betriebspunkt sicherheitsbetont („lieber zehn Fehlalarme als ein vereistes Flugzeug").
- **Fail-safe:** Bei veralteten/defekten Daten oder Ausfall **nicht** auf GRÜN → mind. GELB/„unbekannt" + Warnung.
- **Keine Secrets** committen (Code-Repo und hier).
- **Git:** Feature-Branch → PR → Review → `main`. **Push/PR/Merge/Force-Push/destruktive Aktionen nur nach
  expliziter Genehmigung** durch Lucas.

## 5. Team & Rollen (G2)

| Rolle | Personen |
|---|---|
| Teilprojektleiter | Landmann, Lucas |
| Systemarchitekt | **Vöhringer, Lucas** (ArchiDox, DRI für API/Datenmodell-Naht) · Petzold, Johannes |
| Backend-Entwickler | Hartling, Leon · Ganter, Luca · Moritz, Andreas · Sarkhab, Arash · (Vöhringer, Lucas) |
| Test / Review | Mohammadi, Azezoo · Berger, Amelie |
| Orga-Management | **Landmann, Lucas** (Orga-Manager, führt auch die Doku-Gruppe) |
| Doku-Gruppe (unter Orga-Management) | Reisi, Maryam · Ilchyshyn, Vladyslav |

**Kontext für die Toolkit-Gestaltung:** Hochschulprojekt, echter Use-Case, Skill-Niveau ~2. Semester.
Ziel der Werkzeugkästen: Einteilung nach **Systemverständnis & Output** statt nach reinem Coding-Skill;
operative Standardarbeit (cleaner Code, Tests, Reviews, Repo-Hygiene) übernimmt der Agent.

## 6. Die zwei Werkzeugkästen (Design-Ziel dieses Verzeichnisses)

### A) Backend-Entwickler:innen
Skills/Hooks für Standardprozesse: Repo-/Branch-Arbeit, **Pull Requests**, Conventions-/Regel-Check,
**Testsuite pflegen (TDD)**, Pre-Commit/Pre-PR-Gate (Architektur-/Standard-Compliance), Build-Fix.

### B) Reviewerinnen / Testerinnen
**Live-UI-Test** der laufenden App, begleitet vom Agenten; Agent übernimmt **technische Reviews + Unit-Tests
+ Testsuite-Pflege**. Review-Ergebnisse/Code-Kommentare landen im PR. Leitlinie (bewertungsrelevant,
40 % Einzelleistung): **Agent erstellt Review-Entwurf → Reviewerin liest/versteht/gibt frei → posten.**
Mensch bleibt im Loop.

> **Designprinzipien des Team-OS (entschieden — Vollbeleg: `Entscheidungslog-Toolkit.md`):**
> 1. **Ein gemeinsamer Stack:** **Claude Code** als Standard (volle Skill-/Hook-Parität); **Kimi Code** &
>    **Codex CLI** als **sanktionierte Varianten** (dieselbe portierte Anweisung, Skills nativ).
> 2. **Gemeinsame Config ins Repo committen** (`.claude/` mit settings, skills, hooks, CLAUDE.md) statt globaler
>    Pro-Maschine-Config → `git pull` = alle identisch, zentral von Lucas gepflegt.
> 3. **Standards als Hooks erzwingen** (Ziel): Aktiv sind **SessionStart-Hinweis** und das **Fact-Forcing-Gate**
>    (**Claude Code** + **Kimi Code**, eigener `UNI_GATE_*`-Namespace; auf Kimi via `~/.kimi-code/config.toml`,
>    seit v1.6.0); die weiteren Enforcement-Hooks (format/lint, RB-01-Guard, Secret-Scan, test-gate) sind
>    **Phase 2, noch nicht verdrahtet**. Bis dahin trägt **Review + GitHub Branch Protection** die Durchsetzung
>    (PR-Pflicht, kein direkter `main`-Push).
> 4. **Aus ECC kuratieren statt neu bauen** (vorhandene Skills/Agents: `python-review`, `fastapi-review`,
>    `tdd-workflow`, `pr`, `code-review`, `security-review`, `update-codemaps` …).
> 5. **Eine Umgebung für alle Rollen** (z. B. VSC + integriertes Terminal + Claude Code).

## 7. Arbeitskonventionen für Agenten hier

- **Use-Case-Fakten** nie aus dem Gedächtnis — immer aus den Pfaden in §2 lesen; im Zweifel die Code-Repo-`CLAUDE.md`.
- **Schwellenwerte/Bewertungslogik** ausschließlich aus `Schwellenwerte.md`, danach logisch prüfen.
- **Toolkit-Artefakte** (Skills/Hooks/Doku) so gestalten, dass sie für ~2.-Semester-Niveau **bedienbar** sind:
  klare Anleitungen, sichere Defaults, möglichst automatisch (Hooks) statt manuell.
- **Code-Stil** (auch für generierte Beispiele): KISS/DRY/YAGNI, kleine Dateien (<800 Zeilen), Funktionen <50 Zeilen,
  explizites Error-Handling, Input-Validierung an Systemgrenzen, keine Magic Numbers.
- **Entscheidungsstand:** Harness (Claude Code + Kimi/Codex) und Lizenz sind **entschieden** (`Entscheidungslog-Toolkit.md`);
  offen ist nur die **formale Begründung des Backend-Stacks (T0)** — als Empfehlung behandeln, nicht als gesetzt.

## 8. Entscheidungsstand (Tooling entschieden, Stack empfohlen)

Belegt im `Entscheidungslog-Toolkit.md` (vgl. `claude-sync.md` §8):
1. **Harness — entschieden:** **Claude Code** als Standard; **Kimi Code** & **Codex CLI** als sanktionierte Varianten (gleiche portierte Anweisung).
2. **LLM-Lizenz — entschieden:** Claude-Abo (Pro = Standard, Max optional); kein API-/Token-Billing im Normalbetrieb.
3. **Backend-Stack — empfohlen, noch zu begründen:** Python/FastAPI/SQLite (T0); die formale Begründung gehört ins Entscheidungslogbuch des Code-Repos und bestimmt, welche Reviewer-/Test-Skills greifen.

---
*Diese Datei pflegt Lucas (Systemarchitekt) · Toolkit-Version: v1.6.0 · Stand: 2026-06-21. Stand/Ergebnisse/Entscheidungen zum Use-Case selbst stehen in
der `CLAUDE.md` des Code-Repos `Alarmsystem-Dev`.*

*Toolkit-Version: v1.6.0*

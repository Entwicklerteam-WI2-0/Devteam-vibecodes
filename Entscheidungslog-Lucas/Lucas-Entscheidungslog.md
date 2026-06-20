# Persönliches Entscheidungslog — Lucas Vöhringer (G2)
## Aufbau Team-OS · Organisationsstruktur · Workflows der Abteilungen

> **Zeitraum der Erstellung:** dokumentierter Aufbau **2026-06-17 bis 2026-06-20** · **Erstellt am:** 2026-06-20
> **Autor:** Vöhringer, Lucas (Systemarchitekt G2) · **Status:** laufend gepflegt
> Eigene technische/organisatorische Entscheidungen + Begründung. **Bewertungsrelevant** (Nachvollziehbarkeit, 40 % Einzelleistung).

**Abgrenzung (damit nichts doppelt geführt/verwechselt wird):**
- **Tool-/Modell-/Lizenz-Entscheidungen** → `Entscheidungslog-Toolkit.md` (Harness=Claude Code, Claude-Abo, Modellstrategie, Codex-/Kimi-Ausnahmen). Hier nur referenziert, **nicht** wiederholt.
- **Produktarchitektur** (Schwellenwerte, Datenmodell, FA/NF/RB) → `Alarmsystem-Dev/02-Arbeitsdokumente/Entscheidungslog-Lucas-Systemarchitektur.md`.
- **Tagesfortschritt** → `erinnerung/journal/<YYYY-MM-DD>.md` (append-only). Dieses Log ist ein **eigenständiges Dokument**, kein Journal-Block → die Append-only-Journalregeln gelten hier nicht.

**Aufbau dieses Logs:** drei Teile — **A) Bau**, **B) Organisationsstruktur**, **C) Workflows + Sicherheit** — plus offene Punkte. Einträge sind datiert; neue Entscheidungen kommen unter den passenden Teil (Datum im Format `YYYY-MM-DD`).

---

## Teil A — Bau des Team-OS (Architektur der Werkzeug-Heimat)

### 2026-06-17 — Eigenständiges Werkzeug-Repo, getrennt vom Code-Repo
- **Kontext/Task:** Team-OS für G2 (7 Pers., ~2. Sem.); Tooling lag zuvor im Code-Repo.
- **Entscheidung:** Team-OS in eigenem Repo `Devteam-vibecodes`; `Alarmsystem-Dev` bleibt reine Code-/Use-Case-Source. Kein Skill/Hook/Command wandert ins Code-Repo.
- **Begründung:** Trennung Werkzeug ↔ Produkt verhindert Vermischung und Drift; **eine** Tooling-Heimat (`claude-sync.md` §6.1, `CLAUDE.md` §1).
- **Alternativen:** Tooling direkt im Code-Repo (verworfen — Vermischung, Review-Last auf Nicht-Code, Drift).
- **Ergebnis/Status:** umgesetzt.

### 2026-06-17 — Source of Truth: projektneutrale `claude-sync.md`, Use-Case-Fakten ausgelagert
- **Kontext/Task:** globale Agenten-Anweisung nötig, die in jeder Session/jedem Repo gilt.
- **Entscheidung:** `claude-sync.md` trägt nur **Methodik** (Operating Mode, WP-Gates, Conventions, Sicherheit). Use-Case-Fakten (Schwellenwerte, RB-01-Werte, Phasen) bleiben in `Alarmsystem-Dev` und werden dort gelesen, **nie dupliziert**. Deployment additiv über `@import`-Block.
- **Begründung:** Anti-Drift — eine Quelle, eine Änderung wirkt überall.
- **Alternativen:** alles in eine CLAUDE.md kopieren (verworfen — Drift, doppelte Pflege).
- **Ergebnis/Status:** umgesetzt.

### 2026-06-17 — Skills aus ECC kuratieren/forken statt neu bauen
- **Entscheidung:** Pflicht-Skills aus dem ECC-Stack forken, auf **Python/FastAPI/pytest + Use-Case** umschreiben; echte `SKILL.md` im Repo (kein Plugin-Zwang). Self-contained: ein Klon + ein Setup.
- **Begründung:** battle-tested; Designprinzip „kuratieren statt neu bauen" (`CLAUDE.md` §6.4).
- **Alternativen:** ECC-Plugin als Laufzeit-Abhängigkeit (verworfen — nicht self-contained); alles selbst schreiben (verworfen — Aufwand/Risiko).
- **Ergebnis/Status:** umgesetzt.

### 2026-06-18 → 2026-06-19 — Multi-CLI: zunächst vertagt, dann doch umgesetzt (Kurskorrektur, ehrlich vermerkt)
- **Kontext/Task:** nicht alle Member nutzen Claude (ChatGPT-Plus/Kimi vorhanden); Tool-/Modell-Begründung in `Entscheidungslog-Toolkit.md`.
- **Entscheidung:** Stand **18.06.** bewusst **vertagt** („zunächst nur Claude", `stand.md`). Am **19.06. revidiert** → drei Setup-Varianten (Claude/Kimi/Codex), weil `claude-sync.md` + `SKILL.md` harness-neutral portierbar sind.
- **Begründung:** Member mit anderem Abo nicht ausschließen (Zahlungszwang ist abgelehnt, s. Toolkit-Log-Randbedingungen); Codex/Kimi lesen `AGENTS.md`/`SKILL.md` nativ; Eigenheiten abgefangen (Codex inline statt `@import`; Kimi/Codex Commands als Skill/Prompt).
- **Alternativen:** nur Claude erzwingen (verworfen). Multi-Harness dauerhaft vertagen (verworfen, sobald Portierungsaufwand als gering erkannt).
- **Ergebnis/Status:** umgesetzt; **Claude bleibt empfohlener Standard** (Hook-/Qualitätsparität). Die ursprüngliche Vertagung war eine konservative Überschätzung des Portierungsaufwands — Korrektur hier festgehalten.

### 2026-06-19 — Setup additiv & idempotent (persönliche Config nie überschreiben)
- **Entscheidung:** Setup legt `~/.claude/team-os-g2.md` an und hängt den `@import`-Block **additiv** an; vorhandene persönliche `CLAUDE.md`/`AGENTS.md` bleibt erhalten (Backup `.bak`); Re-Run aktualisiert nur.
- **Begründung:** heterogenes Team, vorhandene Configs schützen; gefahrlose Wiederholbarkeit.
- **Alternativen:** Überschreiben (verworfen — zerstört persönliche Configs).
- **Ergebnis/Status:** umgesetzt (inkl. Migration einer früheren Direktkopie → `@import`).

---

## Teil B — Resultierende Organisationsstruktur

### 2026-06-17 — Zwei Werkzeugkästen/Abteilungen, eingeteilt nach Systemverständnis & Output
- **Entscheidung:** Aufteilung in **(A) Backend-Entwickler:innen** und **(B) Reviewerinnen/Testerinnen**; Einteilung nach **Systemverständnis & Output**, nicht nach reinem Coding-Skill. Operative Standardarbeit (Format/Lint/Tests/Repo-Hygiene) übernimmt der Agent.
- **Begründung:** ~2.-Sem.-Niveau — Verständnis ist der knappe Faktor, nicht Tippgeschwindigkeit; passt zur 40-%-Einzelleistung.
- **Alternativen:** Einteilung nach Coding-Skill (verworfen — bildet die reale Wertschöpfung mit Agent nicht ab).
- **Ergebnis/Status:** umgesetzt (`gemeinsam/` + `abteilung-backend-entwickler/` + `abteilung-reviewer-tester/`).

### 2026-06-17 — Geteiltes Fundament via Dual-Use statt doppelter Pflege
- **Entscheidung:** fachliche Review-Skills (`code-`/`python-`/`fastapi-`/`security-review`) liegen in `gemeinsam/` mit **invertiertem Schwerpunkt**: Dev = Selbst-Review (**SR**, WP5), Reviewer = Hauptwerkzeug (**OP**, WP6).
- **Begründung:** derselbe Skill, zwei Rollen → **einmal** pflegen, kein Drift zwischen Abteilungen.
- **Alternativen:** je Abteilung eigene Review-Skills (verworfen — Doppelpflege/Drift).
- **Ergebnis/Status:** umgesetzt.

### 2026-06-17 — Human-in-the-loop als verbindliche Organisationsregel (40 %)
- **Entscheidung:** Agent erstellt Review-/Test-**Entwurf** → Mensch liest/versteht/gibt frei → **erst dann** posten/mergen. **Nie** automatisch posten/mergen.
- **Begründung:** bewertungsrelevant (40 % Einzelleistung, Nachvollziehbarkeit); Anfänger erkennen subtile Modellfehler nicht.
- **Alternativen:** Agent posted/merged automatisch (verworfen — untergräbt Einzelleistung + Sicherheit).
- **Ergebnis/Status:** umgesetzt (prominente Regel: `abteilung-reviewer-tester/Skills.md` §4, `claude-sync.md` §6.3).

### 2026-06-17 — Kontinuität über geteiltes Gedächtnis `erinnerung/` (append-only)
- **Entscheidung:** geteiltes Projektgedächtnis (`stand.md` + `journal/<YYYY-MM-DD>.md`); `/start` **liest**, `save-session`/`erinnerung-update` **schreibt**; **append-only**; von der inhaltlichen WP6-Code-Review-Pflicht **ausgenommen**, aber Branch→PR→Merge bleibt (GitHub Branch Protection ist nicht pfad-granular).
- **Begründung:** 3-Wochen-Projekt mit Personen-/Tageswechsel; append-only = konfliktarm ohne Review.
- **Alternativen:** kein gemeinsames Gedächtnis (verworfen — Kontextverlust); review-pflichtig (verworfen — unnötige Last auf Nicht-Code).
- **Ergebnis/Status:** umgesetzt.

---

## Teil C — Workflows der Abteilungen + Sicherheit

### 2026-06-17 — Workflow-Gates WP0–WP8 als gemeinsames Gerüst
- **Entscheidung:** Standardzyklus **WP0** (Start/`/start`) → **WP1** Verständnis → **WP2** Plan (contract-first) → **WP3** TDD-Impl → **WP4** Quality-Gate vor Commit → **WP5** Selbst-Review + Coverage vor PR → **WP6** PR-Review (Reviewer) → **WP7** Live-Test → **WP8** Session-Ende/Doku. Jeder Skill genau **einem** WP + **einem** Schwerpunkt (OP/SR/CR/WG/VO) zugeordnet.
- **Begründung:** wenige, **getriggerte** Schritte statt Skill-Flut; bildet die DoD ab (Review + Tests grün ≥ 80 %); passt zu ~2. Sem.
- **Alternativen:** freie Skill-Nutzung ohne Gates (verworfen — Anfänger überspringen Pflichtschritte).
- **Ergebnis/Status:** umgesetzt (`claude-sync.md` §4, `Skill-Plan.md` §2).

### 2026-06-17 — Contract-first als Workflow-Priorität (G2-Kernverantwortung)
- **Entscheidung:** API/Datenmodell-Naht **zuerst einfrieren** (`api-design` + `plan` auf WP2); Devs bauen strikt dagegen; **DRI = Architekt**.
- **Begründung:** die Naht zu G1/G3 blockiert alles andere; späte Drift ist teuer.
- **Alternativen:** breit gegen eine nicht-eingefrorene Naht bauen (verworfen — Rework-Risiko).
- **Ergebnis/Status:** umgesetzt; soll durch geplanten **OpenAPI-Schema-Diff-Hook** abgesichert werden.

### 2026-06-17 — Sicherheitskritik über Gates + Hooks erzwingen, nicht nur Review
- **Entscheidung:** kritischer Pfad (Bewertungslogik, **RB-01**, **Fail-safe/NF-01**) bekommt `verification-loop` + `santa-loop` (adversariales Dual-Review) als **Gates**; zusätzlich Enforcement-**Hooks** (RB-01-Guard, Secret-Scan, OpenAPI-Diff) geplant.
- **Begründung:** menschlicher Lese-Check allein ist bei ~2. Sem. fragil; „erzwingen statt erhoffen" (`claude-sync.md` §6.2).
- **Alternativen:** nur Review/Coverage (verworfen — Skill-Plan-Review P1: kein echtes Verifikations-Gate, RB-01 nur menschlich abgesichert).
- **Ergebnis/Status:** Gates/Skills umgesetzt; **Enforcement-Hooks offen (Phase 2)** — siehe Eintrag 2026-06-20 und „Offene Punkte".

### 2026-06-17 — Pflicht-Tag-1-Kanon schlank halten (Ergebnis des Zwei-Pass-Review-Loops)
- **Entscheidung:** pro Rolle nur **~4 Kern-Skills** am Tag 1, Rest situativ. Der `Skill-Plan.md` wurde nach Erststellung **zweimal** geprüft (Selbst-Review + unabhängige Zweitmeinung).
- **Begründung:** ~14 Skills/Abteilung überfordern Einsteiger; gestaffeltes Onboarding („Woche 1, wenn TDD sitzt").
- **Alternativen:** vollen Kanon ab Tag 1 (verworfen — Überforderung, Doppelungen).
- **Ergebnis/Status:** umgesetzt. Konkrete Loop-Korrekturen: Tag-1 8→4 Skills; `database-migrations` entfernt (SQLite-T0); `santa-loop` SR→OP umklassifiziert; `e2e-testing` auf G3-UI-Integration beschränkt (API-E2E via `python-testing`); `code-review ultra` als kostenpflichtige Ausnahme „nur Lucas".

### 2026-06-20 — Hook-Verteilung: lokaler Agent installiert aus dem Repo nach
- **Kontext/Task:** Enforcement-Hooks (Phase 2) sollen bei allen Membern wirken; Setup deployt aktuell keine Hooks.
- **Entscheidung:** Verteilung **nicht** über das Setup-Skript, sondern der **lokale Agent jedes Mitglieds installiert die Hooks aus dem Repo nach** — das Repo enthält alles Notwendige (standalone `.claude/hooks/`-Skripte + `settings.json`-Referenz). Deckt sich mit der Absicht in `.claude/hooks/README.md`.
- **Begründung:** kein Cross-Platform-Setup-Code nötig; der Agent merged intelligent in eine evtl. vorhandene `settings.json`.
- **Alternativen:** Setup-Skript installiert Hooks global/per-Repo (offen gehalten — für dieses Modell nicht nötig).
- **Ergebnis/Status:** Modell festgelegt. **Offen:** die **fertigen** Hook-Artefakte (Skripte + `settings.json`-Block + `/install-hooks`-Command) müssen noch ins Repo, damit der Agent nur **installiert** statt neu schreibt — sonst Uniformitäts-/Drift-Risiko gerade bei den Security-Hooks. **Empfohlene Reihenfolge:** zuerst stack-agnostisch (`secret-scan`, `rb01-guard`, `size-guard`), dann stack-abhängig (`format-lint`, `test-gate`), `openapi-diff` als CI-Job.

---

## Offene Punkte / Review-Trigger
- **Enforcement-Hooks noch nicht gebaut** (nur Blueprint in `.claude/hooks/README.md`) → Security-Garantien hängen derzeit an menschlichem Review + GitHub Branch Protection.
- **Fertige Hook-Artefakte + `/install-hooks`-Command** ins Repo (siehe Eintrag 2026-06-20).
- **Doku-Drift:** `README.md` nennt „die 9 Pflicht-Skills", real liegen ~36 `SKILL.md` in `.claude/skills/` → angleichen.
- **`.claude/`-Config-Sync** (Commands/Hooks) über Member: aktuell nur `claude-sync.md` global via Setup; Commands/Hooks liegen repo-lokal (`stand.md`-Blocker).
- **Stack-Lock** (Python/FastAPI final?) blockt die stack-abhängigen Hooks (`format-lint`/`test-gate`/`openapi-diff`).

---
*Pflege: Lucas (Systemarchitekt G2). Tool-/Modell-Entscheidungen: `Entscheidungslog-Toolkit.md`. Produktarchitektur: `Alarmsystem-Dev`. Session-Ende: `save-session`.*

# Gemeinsame Skills — von BEIDEN Abteilungen genutzt

> Das **Fundament**: Skills, die jede:r im G2-Team (Backend-Dev **und** Reviewerin/Testerin)
> standardmäßig einsetzt. Übergeordneter Plan + Taxonomie: `../Skill-Plan.md`.
> Schwerpunkt-Codes: **OP** Operativ · **SR** Selbst-Review · **CR** Conventions/Regeln ·
> **WG** Workflow-Gate (getriggert) · **VO** Verständnis/Onboarding.

## 1. Warum „gemeinsam"?

Ein Skill steht hier, wenn er **von beiden Rollen** in der täglichen Arbeit gebraucht wird — entweder
identisch (z. B. Kontext laden) **oder** als **Dual-Use** mit invertiertem Schwerpunkt: Die
fachlichen Review-Skills sind für Devs ein **Selbst-Review-Gate (SR)** vor dem PR und für die
Reviewer-Abteilung das **operative Hauptwerkzeug (OP)**. Genau deshalb sind sie geteilt — nicht
doppelt gepflegt.

## 2. Skill-Tabelle

| Skill | Usecase (konkret im Projekt) | Schwerpunkt | WP / Auslöser |
|---|---|---|---|
| `uni:start` | Session-Start (Resume): lädt `erinnerung/stand.md` (Stand & Entscheidungen) + Regeln (`claude-sync.md`) + Git-Status → jede:r startet mit demselben Kontext (3-Wochen-Kontinuität, Personenwechsel) | **WG** | WP0 jeder Session-Start |
| `save-session` | Stand/Entscheidungen am Ende sichern (`erinnerung/stand.md` + Logbuch) | **WG** | WP8 Session-Ende |
| `entscheidungslog` | **Persönliches** Entscheidungslog des Devs anlegen/pflegen (eigene Entscheidungen + Begründung + Alternativen) — bewertungsrelevant (Nachvollziehbarkeit, 40 % Einzelleistung) | **CR/WG** | bei jeder eigenen Entscheidung + WP8 |
| `uni:coding-standards` | Gemeinsamer Maßstab: Naming, KISS/DRY/YAGNI, kleine Dateien (<800), Funktionen <50, explizites Error-Handling, keine Magic Numbers — **Devs schreiben danach, Reviewer prüfen danach** | **CR** | WP3 (Dev) / WP6 (Reviewer) |
| `uni:git-workflow` | Feature-Branch → Commit-Konvention (`feat/fix/...`) → PR; **kein direkter `main`-Push**; main bleibt lauffähig | **CR/WG** | WP4–WP6 |
| `uni:codebase-onboarding` | Heterogenes Team versteht Repo-Struktur (`Backend-Konzept §7`: `src/ingest|model|assessment|storage|api|config|forecast`) schnell | **VO** | WP1 (v. a. Onboarding) |
| `uni:documentation-lookup` | Aktuelle FastAPI-/Pydantic-/SQLite-Doku nachschlagen statt aus dem Gedächtnis raten | **OP/VO** | WP3 nach Bedarf |
| `uni:ecc-guide` | „Welcher Skill/Agent für welche Aufgabe?" — Navigation im ECC-Stack | **VO** | nach Bedarf |
| `uni:aside` | Schnelle Seitenfrage beantworten, ohne den laufenden Task-Kontext zu verlieren | **WG** | nach Bedarf |
| `uni:code-review` | **Dual-Use:** Dev prüft eigene Changes vor PR (**SR**); Reviewerin nutzt es als Hauptwerkzeug (**OP**) — lokaler Diff oder PR | **SR/OP** | WP5 (Dev) / WP6 (Reviewer) |
| `uni:python-review` | dito, Python-spezifisch (PEP 8, Type-Hints, Idiome, Sicherheit) | **SR/OP** | WP5 / WP6 |
| `uni:fastapi-review` | dito, FastAPI (Async-Korrektheit, Dependency-Injection, Pydantic-Schemas, OpenAPI-Qualität) | **SR/OP** | WP5 / WP6 |
| `uni:security-review` | Sicherheitskritisch: Ingest-Validierung, Audit-Log, **RB-01** (kein Freigabe-/Aktor-Endpoint), keine Secrets | **SR/OP** | WP5 / WP6 |
| `verify` | Laufende App/API starten und **Verhalten beobachten** — Dev verifiziert den Slice, Reviewerin macht den Live-Test | **OP** | WP5 / WP7 |

> **Pflicht-bei-jedem-Start/Ende (standardmäßig, nicht optional):** `uni:start` zu
> **WP0** und `save-session` zu **WP8**. Diese drei sind das gemeinsame Minimum, das **immer** läuft —
> alle anderen Skills sind rollen-/situationsabhängig (siehe die jeweiligen Abteilungs-`Skills.md`).

## 3. Team-Infrastruktur (zentral, NICHT Alltags-Skill jedes Mitglieds)

Diese Skills pflegt **Lucas (Systemarchitekt)** einmalig/zentral; sie wirken für alle automatisch.
Sie setzen die Designprinzipien aus `CLAUDE.md §6` um (gemeinsame Config + Standards als Hooks):

| Skill | Usecase | Schwerpunkt |
|---|---|---|
| `ecc:configure-ecc` | Gemeinsame `.claude/`-Config (settings, skills, CLAUDE.md) installieren/pflegen → `git pull` = alle identisch | **CR** |
| `ecc:hookify` (+ `hookify-list`, `hookify-configure`) | Standards **als Hooks erzwingen**: PostToolUse (format/lint), PreToolUse (blocks, z. B. Dateigröße), Stop (test/build-gate) | **CR** |
| `update-config` | `settings.json`, Permissions, Hooks gezielt anpassen | **CR** |
| `init` | `CLAUDE.md` im Code-Repo initial/aktualisiert halten | **CR** |

**Konkrete Pflicht-Hooks (sicherheits-/qualitätskritisch — via `ecc:hookify`, von Lucas eingerichtet):**

| Hook | Zweck | Wann |
|---|---|---|
| **RB-01-Guard** (PreToolUse/CI) | Blockt das Anlegen von Routen mit Namen wie `release\|freigabe\|sperr\|clear\|aktor\|control` → erzwingt **„kein Aktor-Endpoint" automatisch**, nicht nur im Review (RB-01) | bei Code-Änderung / PR |
| **Secret-Scan** (PreCommit) | Verhindert Secrets **an der Quelle** (WP4 Commit-Zeit), nicht erst im PR-Review | vor Commit |
| **OpenAPI-Schema-Diff** (CI/PR) | Meldet ungewollte Änderungen am **eingefrorenen Contract** → schützt die Naht (contract-first) | bei PR |

> Ergänzend **serverseitig**: GitHub **Branch Protection** (PR-Pflicht, kein direkter `main`-Push) —
> der Standard, den kein lokaler Hook umgehen kann.

## 4. Standard-Ablauf (gilt für beide Abteilungen)

1. **WP0 Start:** `uni:start` lädt Kontext (Stand, Regeln, Git-Status).
2. **WP1 Verständnis:** Bei Unklarheit `codebase-onboarding` / `ecc-guide`; Doku via `documentation-lookup`.
3. **WP4/5/6 Qualität:** Review-Skills greifen — als **SR** (Dev) bzw. **OP** (Reviewer), Maßstab = `coding-standards`.
4. **WP8 Ende:** `save-session`; Entscheidungen ins **Entscheidungslogbuch** (Doku-Rolle), `git-workflow` für PR.

## 5. Grenzen / Hinweise

- **Use-Case-Fakten** nie aus dem Gedächtnis — immer aus `Alarmsystem-Dev` lesen (`CLAUDE.md §2`).
- **Schwellenwerte/Bewertungslogik** ausschließlich aus `Schwellenwerte.md`, danach **logisch plausibilisieren** (KI-generiert).
- **Push/PR/Merge/destruktive Git-Aktionen** nur nach **expliziter Genehmigung** durch Lucas.

---

*Toolkit-Version: v1.4.0*

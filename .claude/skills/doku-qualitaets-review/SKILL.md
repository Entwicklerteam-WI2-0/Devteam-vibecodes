---
name: doku-qualitaets-review
description: Use when reviewing repository documentation quality before release, milestone gates, or after structural changes — or on request via /uni:doku-review. Checks READMEs, configs, YAMLs, prerequisites, and project scopes for correctness, completeness, and consistency with the actual codebase.
origin: G2-eigen (Orga-Management / Doku-Gruppe)
---

# doku-qualitaets-review — Repo-Doku-Qualität prüfen (G2)

Du führst ein **Qualitäts-Review der Repository-Dokumentation** durch. Ziel ist, dass READMEs, Konfigurationsdateien, YAML-Workflows, Voraussetzungen und Projekt-Scopes vollständig, korrekt und konsistent zum tatsächlichen Code sind. Du liest, vergleichst und dokumentierst Befunde — der Mensch (Doku-Gruppe / Orga-Manager) priorisiert und bearbeitet sie. Antworte auf **Deutsch**.

## Wann aktivieren

- Vor einem Release / einer Abgabe.
- Vor Meilenstein-Gates (M1–M3).
- Nach größeren strukturellen Änderungen (neue Module, neuer Stack, neue Workflows).
- Wenn vermutet wird, dass Doku und Code auseinanderdriften.
- Auf Anfrage „/uni:doku-review".

## Voraussetzung

- `uni:start` ausgeführt.
- Zugriff auf Repo-Root und `04-Source-code/` (falls vorhanden).

## Ablauf

### 1. Scope festlegen

Prüfe diese Dateien (mindestens):
- `README.md` (Projekt-Root)
- `04-Source-code/README.md` (falls vorhanden)
- `04-Source-code/.env.example`
- `04-Source-code/pyproject.toml` / `requirements.txt` / `requirements-dev.txt`
- `.github/workflows/*.yml` / `.github/workflows/*.yaml`
- `CLAUDE.md` / `AGENTS.md`
- `02-Arbeitsdokumente/Backend-Konzept.md`
- `02-Arbeitsdokumente/Usecase-quick.md`
- `02-Arbeitsdokumente/Schwellenwerte.md`
- Weitere READMEs, Configs oder YAMLs je nach Projektscope.

### 2. Kriterien prüfen

Für jede Datei:
1. **Existenz:** Gibt es die erwartete Datei? Fehlt ein README oder eine Config?
2. **Korrektheit:** Stimmen beschriebene Befehle, Pfade, Versionen und Abhängigkeiten mit der Realität überein?
3. **Vollständigkeit:** Werden alle aktuellen Module, Endpoints, Umgebungsvariablen, Rollen und Projekt-Scopes abgedeckt?
4. **Konsistenz:** Widersprechen sich README, `.env.example`, `pyproject.toml`, GitHub-Workflows und Konzeptdokumente?
5. **Projektscope:** Passen Configs und YAMLs zum definierten Scope (z. B. G2 = Backend, keine Sensorik, kein Frontend)?
6. **Voraussetzungen:** Sind Python-Version, DB, Tools und Installationsbefehle korrekt und ausführbar dokumentiert?

### 3. Befunde dokumentieren

Datei: `erinnerung/journal/<YYYY-MM-DD>.md` (append-only) oder separates `doku-review-<YYYY-MM-DD>.md` in `erinnerung/`.

```markdown
## Doku-Qualitäts-Review — YYYY-MM-DD
| Datei | Kriterium | Schweregrad | Befund | Empfohlene Aktion |
|---|---|---|---|---|
| <Datei> | Existenz / Korrektheit / Vollständigkeit / Konsistenz / Projektscope / Voraussetzungen | CRITICAL / HIGH / MEDIUM / LOW | <kurz> | <konkret> |
```

### 4. Kopplung prüfen

Wenn Befunde Änderungen an zentralen Fakten erfordern → `uni:coupling-map` vorschlagen.

## Checkliste / Outputs

- [ ] Alle relevanten READMEs geprüft.
- [ ] Alle relevanten Configs geprüft.
- [ ] Alle relevanten YAML-Workflows geprüft.
- [ ] Voraussetzungen und Installationsanleitung gegen Code geprüft.
- [ ] Projektscope in Doku und Code abgeglichen.
- [ ] Befunde mit Schweregrad dokumentiert.
- [ ] Empfohlene Aktionen benannt.
- [ ] `uni:coupling-map` vorgeschlagen, falls nötig.
- [ ] Doku-Gruppe / Orga-Manager informiert.

## Befund-Schweregrade

- **CRITICAL:** Doku lässt das Team gegen falsche Regeln arbeiten oder ein Setup/Befehl ist objektiv falsch.
- **HIGH:** Wichtige Information fehlt oder ist veraltet (z. B. fehlende Umgebungsvariable, falscher Python-Version).
- **MEDIUM:** Verständlichkeit oder Vollständigkeit könnten verbessert werden.
- **LOW:** Kosmetik / Tippfehler.

## Leitplanken

- Fokus liegt auf **Repo-Doku**, nicht auf reinen Team-/Orgadokumenten.
- Kein Code-Review — dafür gibt es `code-review`/`python-review`/`fastapi-review`.
- Keine automatischen Änderungen an Doku ohne Freigabe der Doku-Gruppe.
- Keine Änderungen an historischen Dateien (`erinnerung/journal/*`, `Entscheidungslog-*/`).

## Nicht tun

- Befunde ohne Belege dokumentieren („fühlt sich veraltet an").
- Nur Team-Doku prüfen und Repo-Doku auslassen.
- Automatisch Doku ändern, ohne dass die Doku-Gruppe freigegeben hat.
- Versionsstempel in historischen Dateien aktualisieren.

---
*Gegenstück: `uni:coupling-map`, `uni:konventions-healthcheck`. Ablauf: `claude-sync.md` §4 (WP8).*

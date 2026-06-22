---
name: doku-qualitaets-review
description: Nicht-Code-Doku auf Vollständigkeit, Aktualität und Verständlichkeit prüfen (Doku-Gruppe). Nutze diesen Skill vor Release, viertelwöchentlich oder auf Anfrage „/uni:doku-review".
origin: G2-eigen (Orga-Management / Doku-Gruppe)
---

# doku-qualitaets-review — Doku-Qualität prüfen (G2)

Du führst ein **Qualitäts-Review der Nicht-Code-Doku** durch. Ziel ist, dass README, Manual, Onboarding,
Skill-Plan und Abhängigkeiten konsistent, vollständig und für Einsteiger:innen verständlich bleiben. Du
liest, vergleichst und dokumentierst Befunde — der Mensch (Doku-Gruppe / Orga-Manager) priorisiert und
bearbeitet sie. Antworte auf **Deutsch**.

## Wann aktivieren

- Vor einem Release / einer Abgabe.
- Viertelwöchentlich (einmal pro Woche reicht in der Regel).
- Nach größeren Doku-Änderungen.
- Auf Anfrage „/uni:doku-review".

## Voraussetzung

- `uni:start` ausgeführt.
- Zugriff auf alle zentralen `.md`-Dateien.

## Ablauf

### 1. Scope festlegen

Prüfe diese Dateien (mindestens):
- `README.md`
- `ONBOARDING.md`
- `USERMANUAL.md`
- `CLAUDE.md`
- `claude-sync.md`
- `Skill-Plan.md`
- `gemeinsam/Skills.md`
- `abteilung-*/Skills.md`
- `Abhaengigkeiten.md`

### 2. Kriterien prüfen

Für jede Datei:
1. **Vollständigkeit:** Werden alle aktuellen Skills, Abteilungen, Rollen genannt?
2. **Aktualität:** Stimmen Versionsstempel, Skill-Anzahl, Personen, WP-Bezüge?
3. **Verständlichkeit:** Ist die Sprache für ~2.-Semester-Niveau geeignet? Fachbegriffe erklärt?
4. **Konsistenz:** Widersprechen sich `README.md`, `Skill-Plan.md` und Abteilungs-`Skills.md`?
5. **Coupling:** Gibt es Änderungen, die `uni:coupling-map` erfordern?

### 3. Befunde dokumentieren

Datei: `erinnerung/journal/<YYYY-MM-DD>.md` (append-only) oder separates `doku-review-<YYYY-MM-DD>.md`
in `erinnerung/`.

```markdown
## Doku-Qualitäts-Review — YYYY-MM-DD
| Datei | Kriterium | Schweregrad | Befund | Empfohlene Aktion |
|---|---|---|---|---|
| <Datei> | Vollständigkeit / Aktualität / Verständlichkeit / Konsistenz | CRITICAL / HIGH / MEDIUM / LOW | <kurz> | <konkret> |
```

### 4. Kopplung prüfen

Wenn Befunde Änderungen an zentralen Fakten erfordern → `uni:coupling-map` vorschlagen.

## Checkliste / Outputs

- [ ] Alle zentralen Doku-Dateien geprüft.
- [ ] Befunde mit Schweregrad dokumentiert.
- [ ] Empfohlene Aktionen benannt.
- [ ] `uni:coupling-map` vorgeschlagen, falls nötig.
- [ ] Doku-Gruppe / Orga-Manager informiert.

## Befund-Schweregrade

- **CRITICAL:** Widerspruch, der das Team gegen falsche Regeln arbeiten lässt.
- **HIGH:** Wichtige Information fehlt oder ist veraltet (z. B. Skill nicht erwähnt).
- **MEDIUM:** Verständlichkeit könnte verbessert werden.
- **LOW:** Kosmetik / Tippfehler.

## Leitplanken

- Doku-Gruppe nutzt diesen Skill als Hauptwerkzeug.
- Nicht Code reviewen — dafür gibt es `code-review`/`python-review`/`fastapi-review`.
- Keine Änderungen an historischen Dateien (`erinnerung/journal/*`, `Entscheidungslog-Lucas/*`).

## Nicht tun

- Befunde ohne Belege dokumentieren („fühlt sich veraltet an").
- Automatisch Doku ändern, ohne dass die Doku-Gruppe freigegeben hat.
- Versionsstempel in historischen Dateien aktualisieren.

---
*Gegenstück: `uni:coupling-map`, `uni:konventions-healthcheck`. Ablauf: `claude-sync.md` §4 (WP8).*
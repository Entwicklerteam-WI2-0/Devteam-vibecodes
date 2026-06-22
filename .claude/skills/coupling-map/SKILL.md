---
name: coupling-map
description: Bei Änderung eines Fakts alle abhängigen Spiegel in Abhaengigkeiten.md identifizieren und aktualisieren.
metadata:
  scope: team-os-maintenance
  author: Lucas (Systemarchitekt)
  version: v1.6.0
---

# coupling-map

> **Verwendung:** Direkt nach einer Änderung an einem zentralen Fakt des Team-OS (z. B. neuer Skill,
> neuer WP-Punkt, neuer Hook-Status). Der Skill liest `Abhaengigkeiten.md`, ermittelt alle betroffenen
> Spiegel und aktualisiert sie. So verhindert er das wiederkehrende „README/Doku ist falsch"-Problem.
>
> Sprache: **Deutsch**.

---

## Workflow

**1. Fakt vom User erfragen**
- User nennt den geänderten Fakt (z. B. „Skill `database-migrations` entfernt", „WP8 umbenannt",
  „Hook `fact-forcing-gate` deaktiviert", „VERSION auf v1.6.0").
- Falls unklar: kurz nachfragen, welche Source-of-Truth-Datei sich geändert hat.

**2. `Abhaengigkeiten.md` lesen**
- Lies die Kopplungs-Karte in `Abhaengigkeiten.md` im Repo-Root.
- Finde die Zeile, in der der Fakt in der Spalte **Fakt** steht.
- Extrahiere die Spalte **Spiegel (mit-aktualisieren)**.

**3. Betroffene Spiegel auflisten**
- Wandle die kompakte Spiegel-Liste in konkrete Dateipfade um.
- Unterscheide:
  - **Dokumente** (`README.md`, `ONBOARDING.md`, `CLAUDE.md`, `claude-sync.md`, `Skill-Plan.md`, `Skillanleitung.md`, `Seam-Sync-Fragenkatalog.md`, `erinnerung/README.md`)
  - **Abteilungs-Listen** (`gemeinsam/Skills.md`, `abteilung-architekten/Skills.md`, `abteilung-backend-entwickler/Skills.md`, `abteilung-reviewer-tester/Skills.md`)
  - **Einzelne Skills** (`.claude/skills/<name>/SKILL.md`)
  - **Setup/Config** (`.claude/settings.json`, `.claude/commands/setup.md`, `.claude/commands/start.md`, die 6 `setup*`-Skripte)

**4. Jeden Spiegel prüfen und aktualisieren**
- Lies den Spiegel.
- Suche nach dem alten Fakt-Wert (Name, Zahl, Pfad, §-Nummer, WP-Bezeichnung, Versionsstempel).
- Aktualisiere ihn auf den neuen Wert.
- **Versionsstempel-Pflicht (seit v1.3.0):** Bei jedem Edit an einem versionierten Dokument den Footer
  `Toolkit-Version: vX.Y.Z` auf die aktuelle `VERSION`-Datei setzen.
- **Keine historischen Dateien ändern:** `erinnerung/stand.md`, `erinnerung/journal/*` und
  `Entscheidungslog-Lucas/*` bleiben append-only.

**5. Zusammenfassung ausgeben**
- Welcher Fakt wurde geändert?
- Welche Spiegel wurden aktualisiert?
- Welche Spiegel waren bereits korrekt?
- Welche offenen Punkte bleiben (z. B. Review durch Lucas nötig, VERSION hochzählen + Tag)?

---

## Konkrete Beispiele

### Beispiel A: Skill-Set geändert

> „Wir haben den Skill `database-migrations` entfernt; das Skill-Set hat jetzt 40 Skills."

**Source of Truth:** `.claude/skills/` (echte Ordner).

**Spiegel aktualisieren:**

| Spiegel | Was ändern |
|---|---|
| `README.md` | Zahl „42 SKILLS" → aktuelle Anzahl; Skill-Listen (situativ/Standard) anpassen |
| `Skill-Plan.md` | Konsolidierte Tabellen in §3; ggf. Ausschluss-Liste in §5 ergänzen |
| `gemeinsam/Skills.md` | Falls Skill dort gelistet, entfernen |
| `abteilung-architekten/Skills.md` | Falls Skill dort gelistet, entfernen |
| `abteilung-backend-entwickler/Skills.md` | Falls Skill dort gelistet, entfernen |
| `abteilung-reviewer-tester/Skills.md` | Falls Skill dort gelistet, entfernen |
| `.claude/skills/ecc-guide/SKILL.md` | WP-Tabelle + Kanon-Liste korrigieren |

### Beispiel B: Start-Command `uni:start` geändert

> „Der Command heißt jetzt `uni:resume` statt `uni:start`."

**Source of Truth:** `.claude/commands/start.md` + `setup*`-Skripte.

**Spiegel aktualisieren:**

| Spiegel | Was ändern |
|---|---|
| `README.md` | Alle Vorkommen von `uni:start` / `/uni:start` |
| `ONBOARDING.md` | Alle Vorkommen |
| `claude-sync.md` | §0, §4, §9, §10 |
| `Skill-Plan.md` | WP0-Tabelle, Textreferenzen |
| `gemeinsam/Skills.md` | `uni:start` → `uni:resume` |
| `abteilung-architekten/Skills.md` | ggf. erwähnt |
| `abteilung-backend-entwickler/Skills.md` | Einstiegs-Set |
| `abteilung-reviewer-tester/Skills.md` | Einstiegs-Set |
| `Skillanleitung.md` | Szenario-Durchlauf |
| `.claude/skills/ecc-guide/SKILL.md` | Kanon-Eintrag |
| `.claude/skills/feature-dev/SKILL.md` | Falls dort erwähnt |
| `.claude/skills/save-session/SKILL.md` | Falls dort erwähnt |
| `erinnerung/README.md` | Aufruf-Beispiel |
| `.claude/settings.json` | SessionStart-Hinweis |
| `.claude/commands/setup.md` | Beschreibung des Setup-Ergebnisses |

### Beispiel C: VERSION / Tag geändert

> „VERSION ist jetzt v1.6.0; Git-Tag folgt."

**Source of Truth:** `VERSION`-Datei + Git-Tag.

**Spiegel aktualisieren:**

| Spiegel | Was ändern |
|---|---|
| `README.md` | Footer `Toolkit-Version: v1.5.0` → `v1.6.0` |
| `ONBOARDING.md` | Footer / Versionshinweis |
| `CLAUDE.md` | Footer / Versionshinweis |
| `claude-sync.md` | Footer / Versionshinweis |
| `Skill-Plan.md` | Footer |
| `Skillanleitung.md` | Footer |
| `gemeinsam/Skills.md` | Footer |
| `abteilung-architekten/Skills.md` | Footer |
| `abteilung-backend-entwickler/Skills.md` | Footer |
| `abteilung-reviewer-tester/Skills.md` | Footer |
| `erinnerung/README.md` | Footer |
| `Seam-Sync-Fragenkatalog.md` | Footer |
| `Abhaengigkeiten.md` | Eigener Footer aktualisieren |
| `.claude/skills/coupling-map/SKILL.md` | Eigene Frontmatter-Version aktualisieren |

---

## Hinweise

- **Use-Case-Fakten** (Schwellenwerte, FA/NF/RB, Vorfälle −2,1/+1,2 °C) werden **nicht** in diesem
  Repo geändert — sie gehören nach `Alarmsystem-Dev`. Hier werden nur Verweise auf den externen
  Source of Truth gepflegt.
- **Konsistenz vor Schnelligkeit:** Lieber alle Spiegel gründlich prüfen, als einen zu vergessen.
- **Git:** Änderungen am Tooling-Repo laufen wie immer über Feature-Branch → PR → Review → `main`.
  Push/PR/Merge nur nach Freigabe durch Lucas.

---

*Gepflegt im Repo `Devteam-vibecodes` · Toolkit-Version: v1.6.0 · Stand: 2026-06-21*

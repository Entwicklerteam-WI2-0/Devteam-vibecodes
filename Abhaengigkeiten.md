# Abhängigkeiten — Kopplungs-Karte des Team-OS

> **Zweck:** Dieses Blatt zeigt, welche Dokumente/Dateien vom selben Fakt abhängen. Änderst du eine
> **Source of Truth**, müssen alle darunter gelisteten **Spiegel** mitgezogen werden — sonst driftet das
> Toolkit auseinander und Teammitglieder arbeiten gegen veraltete Regeln.
>
> **Prinzip:** Fakt → Source of Truth (hier ändern) → Spiegel (nachziehen).
> Sprache: **Deutsch** · Pflege: Lucas (Systemarchitekt).

---

## Kopplungs-Karte

| Fakt | Source of Truth (hier ändern) | Spiegel (mit-aktualisieren) | Auslöser |
|---|---|---|---|
| **Start-Command** `uni:start` | `.claude/commands/start.md` (+ `setup*` baut ihn) | `README.md` · `ONBOARDING.md` · `claude-sync.md` §0/§4/§9/§10 · `Skill-Plan.md` · `gemeinsam/Skills.md` · `abteilung-architekten/Skills.md` · `abteilung-backend-entwickler/Skills.md` · `abteilung-reviewer-tester/Skills.md` · `Skillanleitung.md` · Skills `ecc-guide` / `feature-dev` / `save-session` · `erinnerung/README.md` · `.claude/settings.json` · `.claude/commands/setup.md` | Command umbenennen |
| **Skill-Set** (Anzahl **42**, Namen, Rollen-Zuordnung) | die echten Ordner `.claude/skills/<name>/` | `README.md` (Zahl ×2 + Liste) · `Skill-Plan.md` · `gemeinsam/Skills.md` · `abteilung-architekten/Skills.md` · `abteilung-backend-entwickler/Skills.md` · `abteilung-reviewer-tester/Skills.md` · `ecc-guide` (WP-Tabelle + Kanon) | Skill add/remove/rename |
| **uni-Namespace / Plugin** | `setup.sh` + `setup.ps1` (bauen `plugin.json`) | `README.md` · `ONBOARDING.md` · `claude-sync.md` §10 · `CLAUDE.md` | Namespace/Plugin-Mechanik ändern |
| **§-Nummern (§0–§10) + WP-Punkte (WP0–WP8)** | `claude-sync.md` | viele Skills (Verweise „§X"/„WPX") · `Skill-Plan.md` · `abteilung-architekten/Skills.md` · `abteilung-backend-entwickler/Skills.md` · `abteilung-reviewer-tester/Skills.md` | Sektion/WP umnummerieren |
| **Deploy-Dateiname** `team-os-g2.md` | `setup*`-Skripte (Variable) | `README.md` · `ONBOARDING.md` · `CLAUDE.md` · `claude-sync.md`-Intro | Zieldatei umbenennen |
| **Install-Pfade & Setup-Flow** | die **6** `setup*`-Skripte | `README.md` · `ONBOARDING.md` · `CLAUDE.md` §0-Tabelle | Pfad/Flow → **immer .sh + .ps1 × 3 CLIs** |
| **VERSION / Tags** | `VERSION` + Git-Tags | `README.md` („seit v1.0.0") · `ONBOARDING.md` | Release → `VERSION` hoch + Tag |
| **Hook-Status (aktiv vs. geplant)** | `.claude/settings.json` (real aktiv) + `.claude/hooks/README.md` | `README.md` (Architektur) · `claude-sync.md` §6.2 · `CLAUDE.md` | Hook scharfschalten; aktuell aktiv: `fact-forcing-gate` (Claude Code only) |
| **Repo-/Org-Namen + URLs** | GitHub | `README.md` · `claude-sync.md` §2 · `CLAUDE.md` · Setup-Fehlermeldungen | Umbenennung |
| **Team-Roster / Rollen** | `CLAUDE.md` §5 + Köpfe der `abteilung-*/Skills.md` | `claude-sync.md` §3 | Personalwechsel |
| **Use-Case-Fakten** (Schwellen, FA/NF/RB, Vorfälle −2,1/+1,2 °C) | **extern: `Alarmsystem-Dev`** | hier nur als **Verweis** (`claude-sync.md` §7 · `abteilung-*/Skills.md` · `Skillanleitung.md`) | **nie hier** ändern — nur dort |
| **Toolkit-Version-Stempel** | `VERSION` | **alle versionierten Docs** (`README.md` · `CLAUDE.md` · `claude-sync.md` · `Skill-Plan.md` · `Skillanleitung.md` · `gemeinsam/Skills.md` · `abteilung-architekten/Skills.md` · `abteilung-backend-entwickler/Skills.md` · `abteilung-reviewer-tester/Skills.md` · `ONBOARDING.md` · `erinnerung/README.md` · `Seam-Sync-Fragenkatalog.md` · `USERMANUAL.md`) | **jeder** Doc-Edit (Versionsstempel-Pflicht) |

> **Historie nicht anfassen:** `erinnerung/stand.md`, `erinnerung/journal/`, `Entscheidungslog-Lucas/` sind
> append-only — sie dokumentieren den Stand von **damals** und werden bei solchen Sweeps **nicht**
> rückwirkend korrigiert.

---

## Wo dieses Blatt referenziert wird

Diese Kopplungs-Karte wird in den folgenden zentralen Dokumenten erwähnt bzw. sollte dort gelesen werden:

- `CLAUDE.md` §0 — Repo-Mechanik & Kopplungs-Karte (Originaleintrag)
- `AGENTS.md` — Agenten-Onboarding im Tooling-Repo
- `.claude/skills/coupling-map/SKILL.md` — Skill, der bei Änderungen die Spiegel aktualisiert
- Setup-/Update-Workflows, wenn Docs synchron gehalten werden müssen

---

*Gepflegt im Repo `Devteam-vibecodes` · Toolkit-Version: v1.5.1 · Stand: 2026-06-21*

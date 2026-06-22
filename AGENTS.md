# AGENTS.md — Projektbasierte Agenten-Anweisung (Devteam-vibecodes)

> Diese Datei ergänzt die globale Anweisung `claude-sync.md` für Arbeiten **im Tooling-Repo selbst**
> (`Devteam-vibecodes`). Sie gilt für alle KI-CLIs, die hier arbeiten.
> Sprache: **Deutsch**.

---

## 1. Tooling-Repo vs. Code-Repo

Dieses Repo enthält das **Team-Betriebssystem** (Skills, Commands, Hooks, globale Anweisung) für das
G2-Backend-Team. Es enthält **keinen** Produktcode und **keine** Use-Case-Fakten (Schwellenwerte,
Bewertungslogik, Anforderungen) — die liegen ausschließlich in `Alarmsystem-Dev`.

---

## 2. Kopplungs-Karte beachten — Spiegel nicht vergessen

Bei jeder Änderung am Repo-Tooling (neuer/entfernter Skill, neuer WP-Punkt, geänderter Command,
neuer Hook-Status, Versionsstempel etc.) **müssen alle abhängigen Spiegel mitgezogen werden**.

- **Source of Truth:** `Abhaengigkeiten.md` im Repo-Root — zeigt pro Fakt, welche Dateien synchron
  gehalten werden müssen.
- **Durchführung:** Skill `uni:coupling-map` — liest `Abhaengigkeiten.md`, listet die betroffenen
  Spiegel auf und aktualisiert sie.

> **Regel:** Bevor ein Commit/PR zu Tooling-Änderungen abgeschickt wird, `uni:coupling-map` aufrufen
> und prüfen, ob alle Spiegel konsistent sind.

Historische Dateien (`erinnerung/stand.md`, `erinnerung/journal/*`, `Entscheidungslog-Lucas/*`) sind
davon **ausgenommen** — sie bleiben append-only.

---

## 3. Grundlegende Conventions

- **Sprache:** Deutsch für alle Artefakte.
- **Git:** Feature-Branch → PR → Review → `main`; `main` bleibt lauffähig.
- **Genehmigungspflicht:** Push, PR, Merge, force-push und destruktive Git-Aktionen **nur nach
  expliziter Freigabe durch Lucas**.
- **Keine Secrets** committen.
- **Use-Case-Fakten** nie hier erfinden — immer aus `Alarmsystem-Dev` lesen.

---

*Gepflegt im Repo `Devteam-vibecodes` · Toolkit-Version: v1.6.0 · Stand: 2026-06-21.*

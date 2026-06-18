---
name: quality-gate
description: Qualitäts-Gate vor jedem Commit im G2-Backend — Formatter + Linter (ruff) sauber, keine Secrets, Conventions eingehalten. Nutze diesen Skill unmittelbar vor jedem Commit.
origin: ECC (quality-gate), neu geschrieben für G2 — Python/ruff + Use-Case
---

# Quality-Gate — sauber vor jedem Commit (G2-Backend)

Du prüfst die Änderungen **bevor** committet wird. Antworte auf **Deutsch**. Die Devs sind
Einsteiger:innen — **du führst die Checks aus** und erklärst Befunde kurz, statt sie zu überfordern.

## Wann aktivieren
Unmittelbar **vor jedem Commit** (Workflow-Punkt WP4 in `claude-sync.md`).

## Checks (in dieser Reihenfolge)
1. **Formatter:**
   ```bash
   uv run ruff format .
   ```
2. **Linter (mit Auto-Fix):**
   ```bash
   uv run ruff check --fix .
   ```
   Verbleibende Warnungen **erklären und beheben**, nicht ignorieren.
3. **Keine Secrets im Diff:** prüfe den Diff auf API-Keys/Tokens/Passwörter. Im Zweifel: Platzhalter +
   Umgebungsvariable. (Wird zusätzlich per Secret-Scan-Hook abgesichert.)
4. **Conventions (aus `claude-sync.md` §5):** Datei < 800 Zeilen, Funktion < 50 Zeilen, keine tiefe
   Verschachtelung (> 4), keine Magic Numbers (benannte Konstanten), explizites Error-Handling.
5. **Build/Import sauber:**
   ```bash
   uv run python -c "import src"   # bzw. das betroffene Modul
   ```

## Erst wenn alles grün ist
→ committen (Commit-Konvention `feat:`/`fix:`/`docs:` …). **Push/PR erst nach Freigabe durch Lucas.**
Roter Build oder offene Lint-Fehler? → erst beheben (siehe `build-fix`), dann committen.

## Nicht tun
- Mit roten Lints oder Format-Diffs committen.
- Lint-Warnungen blind per `# noqa` unterdrücken, ohne den Grund zu verstehen.
- Secrets committen. Direkt auf `main` pushen.

---
*Reihenfolge im Ablauf & Genehmigungspflichten: `claude-sync.md` §4/§7.*

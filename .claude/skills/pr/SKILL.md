---
name: pr
description: Feature-Pull-Request im G2-Backend erstellen — Feature-Branch sicherstellen, DoD prüfen, Beschreibung + Test-Plan erzeugen. Push/PR erst nach Freigabe durch Lucas. Nutze diesen Skill am Ende einer Task, vor der Reviewer-Abteilung.
origin: ECC (pr), neu geschrieben für G2 — GitHub-Flow + Use-Case
---

# pr — Pull Request erstellen (G2-Backend)

Du nimmst dem Entwickler die **komplette Git-/PR-Mechanik ab**. Antworte auf **Deutsch**. Der Dev muss
**keine** Git-Befehle kennen — du führst Branch, Commit, PR.

## Wann aktivieren
Workflow-Punkt WP5: Task fertig, Selbst-Review gemacht, vor Übergabe an die Reviewer-Abteilung.

## Ablauf
1. **Feature-Branch sicherstellen.** Bist du auf `main`? → **niemals** dort committen; vorher
   `git checkout -b feat/<task>`. Branch-Naming: `feat/…`, `fix/…`.
2. **DoD prüfen** (sonst ist die Task **nicht** fertig):
   - Tests grün; Bewertungslogik **≥ 80 % Coverage** (`test-coverage`).
   - **Anforderungs-ID** referenziert.
   - Kritischer Pfad: beide Vorfälle (A/B) + Fail-safe als benannte grüne Tests.
   - Entscheidung im **Entscheidungslogbuch** (benotet).
3. **Selbst-Review** der eigenen Changes (`code-review`) — Befunde einarbeiten.
4. **PR vorbereiten:** Branch pushen + PR mit **Beschreibung + Test-Plan** (Anf-ID, was getestet wurde):
   ```bash
   git push -u origin feat/<task>
   gh pr create --fill --base main
   ```
5. **⛔ Freigabe-Gate:** `git push`, `gh pr create` und Merge **erst nach expliziter Freigabe durch
   Lucas**. Kein direkter `main`-Push, kein force-push.

## Nicht tun
- Auf `main` committen/pushen. Pushen/PR/Merge ohne Freigabe.
- PR ohne erfüllte DoD oder ohne Selbst-Review erstellen.

---
*Vorher: `code-review`, `test-coverage`. Regeln & Genehmigungspflichten: `claude-sync.md` §4/§7.*

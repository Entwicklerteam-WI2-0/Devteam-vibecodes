---
name: build-fix
description: Roten Build / Import- / Type- / Lint-Fehler im G2-Backend mit minimalem Diff schnell grün bekommen — ohne Architekturänderung. Nutze diesen Skill, wenn der Build oder die Tests aus technischen (nicht fachlichen) Gründen rot sind.
origin: ECC (build-fix), neu geschrieben für G2 — Python/uv + Use-Case
---

# build-fix — schnell wieder grün (G2-Backend)

Du bringst einen roten Build/Testlauf mit **minimalem, sicherem Diff** zurück auf grün. Antworte auf
**Deutsch**. Keine Architektur-Umbauten — nur die Blockade beheben.

## Wann aktivieren
Build/Imports/Typen/Lint rot (technisch), z. B. nach Refactoring oder neuem Code (WP4).

## Ablauf
1. **Fehler lesen:** die **erste** Fehlermeldung zuerst (Folgefehler verschwinden oft mit).
   ```bash
   uv run python -c "import src"      # Import-/Syntaxfehler
   uv run ruff check .               # Lint
   uv run pytest -x -q               # erster fehlschlagender Test
   ```
2. **Ursache eingrenzen:** Import, fehlende Abhängigkeit (`uv add ...`), Typ, Syntax, Pfad.
3. **Minimal fixen:** kleinste Änderung, die grün macht. Kein Umbau der Logik/Architektur.
4. **Verifizieren:** denselben Befehl erneut → grün. Dann erst weiter.

## Leitplanken
- **Fachlogik nicht ändern**, um einen Test grün zu „tricksen" — ein fachlich roter Test gehört in den
  TDD-Zyklus (`tdd-workflow`), nicht hierher.
- Tests **nicht** löschen/skippen, um grün zu werden.

## Nicht tun
- Große Refactorings im Build-Fix. Tests anpassen statt Code, wenn der Code falsch ist. Fehler verschlucken.

---
*Fachliche Fehler: `tdd-workflow`. Lint/Format: `quality-gate`. Regeln: `claude-sync.md` §4 (WP4).*

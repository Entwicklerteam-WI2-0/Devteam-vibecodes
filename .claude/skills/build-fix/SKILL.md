---
name: build-fix
description: Roten Build / Type-Fehler mit minimalem Diff schnell grün bekommen. Nutze diesen Skill bei WP4, wenn Format, Lint oder Tests rot sind.
origin: ECC (build-fix), neu geschrieben für G2 — Python/ruff/pytest + Use-Case
---

# build-fix — roten Build grün bekommen (G2)

Du behebt Build-/Lint-/Test-Fehler mit dem kleinstmöglichen Diff. Antworte auf **Deutsch**.

## Ablauf
1. **Fehler lesen:** Welcher Befehl ist rot? `ruff`, `pytest`, Import?
2. **Ursache verstehen:** Syntax, Import, Typing, Format, Test-Logik?
3. **Minimaler Fix:** Nur das ändern, was nötig ist — keine Refactorings mitschleifen.
4. **Verifizieren:** Befehl erneut ausführen, bis grün.

## Typische Befehle
```bash
uv run ruff format .
uv run ruff check --fix .
uv run pytest -v
uv run python -c "import src"
```

## Nicht tun
- Lint-Warnungen blind mit `# noqa` unterdrücken.
- Großflächig refactoren, während der Build rot ist.
- Schwellenwerte/Anforderungen ändern, um Tests grün zu bekommen.

---
*Vorher: `quality-gate`. Regeln: `claude-sync.md` §4.*

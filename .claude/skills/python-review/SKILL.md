---
name: python-review
description: Python-spezifischer Review — PEP 8, Typing, Idiome, Sicherheit. Nutze diesen Skill als Selbst-Review vor dem PR oder als Reviewer-Werkzeug.
origin: ECC (python-review), neu geschrieben für G2 — Python + Use-Case
---

# python-review — Python-Idiome prüfen (G2)

Du reviewst Python-Code auf Idiome, Typing, Stil und Sicherheit. Antworte auf **Deutsch**.

## Checkliste
1. **PEP 8 / ruff:** Formatierung und Lint sauber?
2. **Typing:** Type-Hints vorhanden, korrekt, keine `Any`-Fluchten ohne Grund?
3. **Idiome:** List-Comprehensions, `dataclasses`, `pathlib`, `isinstance` statt `type()`?
4. **Fehlerbehandlung:** Spezifische Exceptions, kein `except Exception` als Allheilmittel.
5. **Sicherheit:** Kein `eval`, kein SQL-String-Concat, keine Secrets.
6. **Tests:** Testbarkeit gegeben, Fixtures sinnvoll?

## Nicht tun
- Stil ohne fachlichen Mehrwert blockieren.
- Blind `# noqa` akzeptieren.

---
*Allgemeiner Review: `code-review`. FastAPI-Review: `fastapi-review`. Regeln: `claude-sync.md` §5.*

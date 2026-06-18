---
name: python-patterns
description: Idiomatischer, wartbarer Python-Code im G2-Backend — Typing, Datenklassen, Immutability, klare Fehlerbehandlung, kleine Funktionen. Nutze diesen Skill beim Schreiben/Refactoring von Python-Code.
origin: ECC (python-patterns), neu geschrieben für G2 — Python + Use-Case
---

# python-patterns — sauberer Python-Code (G2-Backend)

Du schreibst idiomatischen, lesbaren Python-Code mit dem Entwickler. Antworte auf **Deutsch**.
Für Einsteiger:innen: Klarheit vor Cleverness.

## Kern
- **Type Hints** überall (Signaturen, Rückgaben). `float | None` statt unklarer Typen.
- **Datenklassen/Pydantic** für strukturierte Daten (z. B. `Messung`, `Bewertung`); unveränderlich
  wo möglich (`frozen=True` / neue Objekte statt Mutation).
- **Kleine Funktionen** (< 50 Zeilen), eine Aufgabe; sprechende Namen (`bewerte_vereisung`).
- **Keine Magic Numbers** — benannte Konstanten; Schwellenwerte aus `config`/`Schwellenwerte.md`.
- **Explizites Error-Handling** (siehe `error-handling`); keine nackten `except:`.
- **Früh zurückkehren** statt tiefer Verschachtelung (> 4 Ebenen vermeiden).

## Beispiel
```python
from dataclasses import dataclass

@dataclass(frozen=True)
class Messung:
    oberflaeche: float
    taupunkt: float | None
    feuchte: float
    niederschlag: bool

def ist_stale(alter_sekunden: int, *, max_alter: int = MAX_ALTER_S) -> bool:
    return alter_sekunden > max_alter
```

## Leitplanken
- **KISS/DRY/YAGNI** — einfachste Lösung, die wirklich funktioniert; keine spekulative Generik.
- Bewertungslogik **nur** aus `Schwellenwerte.md` — nichts dazuerfinden.

## Nicht tun
- Typen weglassen, Objekte mutieren, Magic Numbers, tiefe Verschachtelung, Fehler verschlucken.

---
*Tests: `tdd-workflow`/`python-testing`. Fehler/Fail-safe: `error-handling`. Conventions: `coding-standards`, `claude-sync.md` §5.*

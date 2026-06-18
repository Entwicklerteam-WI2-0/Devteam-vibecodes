---
name: coding-standards
description: Baseline-Coding-Conventions im G2-Backend — Naming, kleine Dateien/Funktionen, Immutability, explizites Error-Handling, keine Magic Numbers. Nutze diesen Skill als Maßstab beim Schreiben und Reviewen von Code.
origin: ECC (coding-standards), neu geschrieben für G2 — Use-Case
---

# coding-standards — der gemeinsame Qualitäts-Maßstab (G2)

Du wendest die Team-Conventions an und benennst Verstöße. Antworte auf **Deutsch**. Diese Regeln
spiegeln `claude-sync.md` §5 — hier kompakt als Nachschlagewerk.

## Conventions
- **Naming:** Python `snake_case` (Funktionen/Variablen), `PascalCase` (Klassen/Typen),
  `UPPER_SNAKE_CASE` (Konstanten); sprechende Namen (`bewerte_vereisung`, nicht `calc`).
- **Größe:** Dateien < 800 Zeilen, Funktionen < 50 Zeilen; viele kleine Module > wenige große.
- **Verschachtelung:** max ~4 Ebenen; früh zurückkehren statt tief verschachteln.
- **Magic Numbers:** keine — benannte Konstanten; Schwellenwerte aus `config`/`Schwellenwerte.md`.
- **Immutability:** neue Objekte statt Mutation, wo sinnvoll (`frozen` Datenklassen).
- **Error-Handling:** explizit, nichts verschlucken (`error-handling`).
- **KISS/DRY/YAGNI:** einfachste Lösung, die funktioniert; Abstraktion erst bei echter Wiederholung.

## Anwendung
- Beim **Schreiben**: direkt einhalten.
- Beim **Review**: Verstöße mit Schweregrad benennen (CRITICAL/HIGH/MEDIUM/LOW).

## Nicht tun
- Conventions „später" verschieben. Große Funktionen/Dateien wachsen lassen. Magic Numbers streuen.

---
*Sprach-spezifisch: `python-patterns`. Review: `python-review`. Quelle: `claude-sync.md` §5.*

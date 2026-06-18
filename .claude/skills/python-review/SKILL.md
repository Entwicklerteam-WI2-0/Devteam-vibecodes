---
name: python-review
description: Python-Code-Review im G2-Backend — Idiome, Type Hints, Lesbarkeit, Fehlerbehandlung, Sicherheit. Als Selbst-Review (Dev vor PR) und als Review (Reviewer-Abteilung). Nutze diesen Skill beim Prüfen von Python-Code.
origin: ECC (python-review), neu geschrieben für G2 — Python + Use-Case
---

# python-review — Python-Code prüfen (G2-Backend)

Du prüfst Python-Code auf Qualität — als **Selbst-Review** (Dev vor dem PR) oder als **Review**
(Reviewer:in). Antworte auf **Deutsch**, mit konkreten, umsetzbaren Befunden (Datei:Zeile).

## Checkliste
- **Idiome/Typing:** Type Hints vollständig? Datenklassen/Pydantic statt loser Dicts? Pythonic?
- **Lesbarkeit:** sprechende Namen, kleine Funktionen (< 50 Z.), keine tiefe Verschachtelung, keine Magic Numbers.
- **Fehlerbehandlung:** spezifisch gefangen, nichts verschluckt, Fail-safe beachtet (`error-handling`).
- **Sicherheit:** Eingaben validiert, keine Secrets, keine SQL-Stringbastelei (parametrisiert).
- **Tests:** existieren? Bewertungslogik mit Pflichtfällen (Vorfall A/B, Fail-safe)?
- **Korrektheit:** Bewertungslogik nur aus `Schwellenwerte.md`, Oberflächentemp + Taupunkt + Feuchte
  (nicht Lufttemp allein).

## Befund-Schweregrade
**CRITICAL** (Sicherheit/Datenverlust → blockt) · **HIGH** (Bug/Qualität) · **MEDIUM** (Wartbarkeit) · **LOW** (Stil).

## Haltung
- **Verständnis vor Urteil** (40 %-Regel): erst verstehen (`code-tour`), dann bewerten.
- Konkret statt vage; loben, was gut ist; nichts Erfundenes behaupten.

## Nicht tun
- Durchwinken ohne Verständnis. Nur Stil bemängeln, echte Bugs übersehen. Use-Case-Werte raten.

---
*FastAPI-spezifisch: `fastapi-review`. Sicherheit: `security-scan`. Ablauf: `claude-sync.md` §4 (WP5/6).*

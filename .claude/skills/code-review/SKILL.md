---
name: code-review
description: Inhaltliches Code-Review für das G2-Backend — Struktur, Lesbarkeit, Korrektheit, Sicherheit, Tests. Der wiederverwendbare Prüf-Baustein: als Selbst-Review (Dev vor PR) und als Kern-Check im PR-Review. Für das vollständige PR-Review mit DoD-Gate und Freigabe → `review-pr`. Nutze diesen Skill beim Prüfen eines Diffs/Changes.
origin: ECC (code-review), neu geschrieben für G2 — Python/FastAPI/SQLite + Use-Case
---

# code-review — Changes reviewen (G2-Backend)

Du reviewst Code-Changes — als **Selbst-Review** (Dev vor dem PR, WP5) oder als **inhaltlicher Kern-Check**
innerhalb des Reviewer-PR-Reviews (WP6). Antworte auf **Deutsch**, mit konkreten Befunden (`Datei:Zeile`).

> **Abgrenzung zu `review-pr`:** Dieser Skill ist der **inhaltliche Prüf-Baustein** (einen Diff bewerten).
> Das **vollständige PR-Review** mit DoD-Gate, Coverage-Nachweis und Freigabe-Kriterium orchestriert
> `review-pr` — es *nutzt* `code-review` als einen seiner Bausteine.

## Wann aktivieren
- Vor dem PR: eigener Diff noch einmal strukturiert prüfen.
- Beim PR-Review: fremde Changes verstehen (nach `code-tour`) und bewerten.

## Checkliste
- **Struktur & Lesbarkeit:** sprechende Namen, kleine Funktionen (< 50 Z.), klare Module; keine
  überflüssige Komplexität (KISS/DRY/YAGNI).
- **Korrektheit:** Logik passt zur Anforderung/Anforderungs-ID; keine offensichtlichen Bugs;
  Use-Case-Werte nur aus `Schwellenwerte.md` / `Alarmsystem-Dev`, nicht erfunden.
- **Contract-Treue:** API-/Datenmodell-Änderungen passen zur eingefrorenen Naht.
- **Sicherheit:** Eingaben validiert, keine Secrets, keine SQL-String-Bastelei; Aktor-/Freigabe-Endpoints
  sofort flaggen (**RB-01**).
- **Fail-safe:** bei Ausfall/Stale-Daten **nie GRÜN**; Fehler explizit behandelt.
- **Tests:** existieren, sind verständlich und decken den Change ab; Bewertungslogik inkl. Fail-safe.
- **Conventions:** `coding-standards` eingehalten (Naming, Größe, Magic Numbers).

## Befund-Schweregrade
**CRITICAL** (Sicherheit/RB-01/Fail-safe/Datenverlust → blockt) · **HIGH** (Bug/Qualität) ·
**MEDIUM** (Wartbarkeit) · **LOW** (Stil/Kosmetik).

## Haltung
- **Verständnis vor Urteil** (40 %-Regel): Code-Tour gemacht oder Change selbst nachvollzogen, bevor
  bewertet wird.
- Konkret statt vage; loben, was gut ist; nichts behaupten, das nicht im Diff belegt ist.
- Der Mensch liest, hinterfragt und verantwortet den Review — nicht blind posten.

## Nicht tun
- Durchwinken ohne Verständnis. Nur Stil bemängeln und echte Bugs übersehen. Use-Case-Werte raten.
- Automatisch GitHub-Kommentare posten oder mergen.

---
*Vollständiges PR-Review (Orchestrator): `review-pr`. Fachlich vertiefen: `python-review`, `fastapi-review`, `security-review`. Vorbereiten: `code-tour`. Regeln: `claude-sync.md` §4 (WP5/6) / §7.*

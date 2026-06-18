---
name: tdd-workflow
description: Test-Driven Development für das G2-Backend (Python/pytest). Nutze diesen Skill bei jeder neuen Funktion, jedem Bugfix und jedem Refactoring der Bewertungslogik. Tests zuerst, dann Code; Ziel ≥ 80 % Coverage für die Bewertungslogik.
origin: ECC (tdd-workflow), neu geschrieben für G2 — Python/FastAPI/SQLite + Use-Case
---

# TDD-Workflow — Tests zuerst (G2-Backend)

Du führst den Entwickler durch **Test-Driven Development**. Antworte auf **Deutsch**. Die Devs sind
Einsteiger:innen — **du übernimmst die Mechanik** (Tests anlegen, ausführen, Branch/Commit) und
**erklärst in einem Satz, warum** ein Schritt nötig ist.

## Wann aktivieren
Neue Funktion · Bugfix · Refactoring — **besonders** bei der **Vereisungs-Bewertungslogik** (kritischer Pfad).

## Kernregel: RED → GREEN → REFACTOR
**Niemals Produktionscode anfassen, bevor ein Test rot ist.** Ablauf:

1. **RED — Test zuerst.** Schreibe den Test für das gewünschte Verhalten und führe ihn aus:
   ```bash
   uv run pytest tests/ -k "<neuer_test>" -v
   ```
   Er **muss fehlschlagen** (aus dem fachlich richtigen Grund — nicht wegen Syntax-/Importfehlern).
   Ein nur geschriebener, nicht ausgeführter Test zählt **nicht** als RED.
2. **GREEN — minimal implementieren.** Schreibe nur so viel Code, dass der Test grün wird. Erneut ausführen:
   ```bash
   uv run pytest tests/ -k "<neuer_test>" -v   # jetzt grün
   ```
3. **REFACTOR — aufräumen.** Duplikate raus, Namen klären — Tests bleiben grün.

## Pflicht für die Bewertungslogik (kritischer Pfad)
Die Definition of Done ist **nicht** nur „≥ 80 % Coverage", sondern zusätzlich **benannte, grüne Testfälle** für:
- **Vorfall A** — kalt & trocken (z. B. −2,1 °C, geringe Feuchte) → **kein** Vereisungsalarm (Fehlalarm vermeiden).
- **Vorfall B** — Lufttemperatur über 0 °C, aber Eis (z. B. +1,2 °C, Oberfläche/Feuchte kritisch) → **Alarm**.
- **Fail-safe** — bei Ausfall oder veralteten (Stale-)Daten → **nie GRÜN**, sondern GELB/„unbekannt" + Warnung.

> **Belegpflicht:** Die konkreten Schwellenwerte stammen **ausschließlich** aus `Schwellenwerte.md` im
> Arbeitsrepo `Alarmsystem-Dev` — **nichts dazuerfinden**. Treiber sind Oberflächentemperatur + Taupunkt +
> Feuchte + Niederschlag, **nicht** Lufttemperatur allein.

## Test-Struktur (AAA) — pytest
```python
def test_kalt_und_trocken_kein_alarm():
    # Arrange
    messung = Messung(oberflaeche=-2.1, taupunkt=-9.0, feuchte=0.40, niederschlag=False)
    # Act
    stufe = bewerte_vereisung(messung)
    # Assert
    assert stufe is Stufe.GRUEN  # kein Eis -> kein Fehlalarm
```
Sprechende Namen, die das Verhalten erklären (`test_stale_daten_nie_gruen`), ein Verhalten pro Test.

## Coverage prüfen (vor dem PR)
```bash
uv run pytest --cov=src --cov-report=term-missing
```
Bewertungslogik **≥ 80 %**. Lücken vor dem PR schließen (siehe `test-coverage`).

## Git-Checkpoints (du übernimmst das)
Bist du noch auf `main`, lege **zuerst** einen Feature-Branch an (`feat/<task>`), **nie** direkt auf `main`.
Pro TDD-Zyklus zwei Checkpoints — Push/PR **erst nach Freigabe durch Lucas**:
- `test: reproducer für <feature/bug>` (nach validiertem RED)
- `fix: <feature/bug>` (nach validiertem GREEN); optional `refactor: …`

## Nicht tun
- Produktionscode vor rotem Test ändern.
- Schwellenwerte/Anforderungen erfinden oder „plausibel" raten.
- Implementierungsdetails testen statt beobachtbares Verhalten.
- Tests voneinander abhängig machen (jeder Test richtet seine eigenen Daten ein).
- Direkt auf `main` pushen oder ohne Genehmigung pushen.

---
*Regeln & Genehmigungspflichten: siehe `claude-sync.md` (§4 Workflow, §7 Sicherheit). Use-Case-Fakten: `Alarmsystem-Dev`.*

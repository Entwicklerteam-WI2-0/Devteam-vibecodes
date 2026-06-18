---
name: test-coverage
description: Test-Coverage im G2-Backend messen und Lücken vor dem PR schließen — Ziel ≥ 80 % für die Bewertungslogik, inkl. der dokumentierten Vorfälle und Fail-safe. Nutze diesen Skill vor dem PR und im Review.
origin: ECC (test-coverage), neu geschrieben für G2 — Python/pytest + Use-Case
---

# test-coverage — Lücken finden und schließen (G2)

Du misst die Abdeckung und schließt **gezielt** die wichtigen Lücken. Antworte auf **Deutsch**.
Coverage ist **Mittel**, nicht Selbstzweck — die richtigen Fälle zählen mehr als die Prozentzahl.

## Wann aktivieren
Vor dem PR (Workflow-Punkt WP5, DoD-Nachweis) und im Review (WP6).

## Ablauf
1. **Messen:**
   ```bash
   uv run pytest --cov=src --cov-report=term-missing
   ```
2. **Lücken lesen:** `term-missing` zeigt ungetestete Zeilen. Priorisiere **Bewertungslogik**
   (`assessment`) und Eingabe-Validierung (`ingest`) — nicht triviale Getter.
3. **Gezielt Tests ergänzen** (`python-testing`) für die echten Lücken, besonders Verzweigungen
   (Branches), Fehlerpfade und Grenzwerte.
4. **DoD prüfen:** Bewertungslogik **≥ 80 %**; **Pflichtfälle vorhanden und grün** — Vorfall A
   (kalt/trocken → kein Alarm), Vorfall B (>0 °C aber Eis → Alarm), Fail-safe (Stale/Ausfall → nie GRÜN).

## Qualität vor Quote
- Ein hoher Prozentwert ohne die drei Pflichtfälle ist **nicht** DoD-konform.
- Branch- statt nur Line-Coverage im Blick behalten (Fehlerpfade!).

## Nicht tun
- Coverage mit Trivial-Tests „aufblähen". Den kritischen Pfad als nur „% erreicht" abhaken.
- Schwellenwerte erfinden — Werte aus `Schwellenwerte.md` (`Alarmsystem-Dev`).

---
*Tests schreiben: `python-testing`. Prozess: `tdd-workflow`. DoD & Regeln: `claude-sync.md` §7.*

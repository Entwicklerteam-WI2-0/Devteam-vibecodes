---
name: santa-loop
description: Adversariale Doppel-Prüfung für sicherheitskritische Teile im G2-Backend — zwei unabhängige Prüfungen müssen beide bestehen, bevor freigegeben wird. Nutze diesen Skill für den kritischen Pfad (Bewertungslogik, Alarme) vor der Freigabe.
origin: ECC (santa-loop / santa-method), neu geschrieben für G2 — Use-Case
---

# santa-loop — zwei müssen zustimmen (G2-Backend)

Du sicherst sicherheitskritische Teile durch **adversariales Dual-Review**: zwei **unabhängige**
Prüfungen, die jeweils versuchen, das Ergebnis zu **widerlegen**. Erst wenn **beide** bestehen, gilt es
als freigabereif. Antworte auf **Deutsch**.

## Wann aktivieren
Kritischer Pfad: **Vereisungs-Bewertungslogik**, Alarm-Auslösung, Fail-safe/Stale-Erkennung —
besonders vor Merge/Abgabe.

## Ablauf
1. **Prüfung A (Korrektheit):** Stimmt die Logik exakt mit `Schwellenwerte.md`? Vorfall A/B + Fail-safe
   grün? Grenzwerte/Branches abgedeckt?
2. **Prüfung B (Adversarial):** Versuche aktiv, einen Fehler zu finden — fehlende Felder, Sensor-Defekt,
   Grenzwert knapp daneben, Stale-Daten, Lufttemp-Falle (>0 °C aber Eis).
3. **Konvergenz:** Nur wenn **beide** ohne offene CRITICAL/HIGH durchlaufen → freigabereif. Sonst zurück
   in die TDD-Schleife.

## Haltung
- Default skeptisch: im Zweifel **nicht** freigeben (Safety-Bias: lieber Fehlalarm als verpasste Vereisung).
- Belegbasiert: jede „okay"-Aussage mit grünem Test.

## Nicht tun
- Mit nur einer Prüfung freigeben. Adversariale Prüfung als Formalie abhaken. Sicherheits-Zweifel ignorieren.

---
*Verifikation: `verification-loop`. Tests: `tdd-workflow`/`test-coverage`. Regeln: `claude-sync.md` §7.*

---
name: verification-loop
description: Verifikation des kritischen Pfads im G2-Backend — Bewertungslogik gegen die dokumentierten Vorfälle und Fail-safe prüfen, gegen Schwellenwerte.md abgleichen. Nutze diesen Skill für sicherheitskritische Teile (Bewertung, Alarm) vor Freigabe.
origin: ECC (verification-loop), neu geschrieben für G2 — Use-Case
---

# verification-loop — kritischen Pfad absichern (G2-Backend)

Du verifizierst die sicherheitskritische Bewertungslogik **gründlich** — hier reicht „Tests grün" allein
nicht. Antworte auf **Deutsch**. Belegbasiert: jede Aussage mit Test-/Command-Beweis.

## Wann aktivieren
Vor Freigabe sicherheitskritischer Teile: **Bewertungslogik**, Alarme, Plausibilität/Stale-Erkennung.

## Pflicht-Verifikation
1. **Vorfall A** (kalt & trocken, z. B. −2,1 °C) → **kein** Alarm (Fehlalarm vermeiden) — als grüner Test.
2. **Vorfall B** (>0 °C Luft, aber Eis, z. B. +1,2 °C) → **Alarm** — als grüner Test.
3. **Fail-safe** (Ausfall/Stale) → **nie GRÜN** — als grüner Test.
4. **Werte-Abgleich:** Schwellen exakt gegen `Schwellenwerte.md` (`Alarmsystem-Dev`) — keine Abweichung.
5. **Grenzwerte/Branches:** knapp über/unter Schwelle, fehlende Felder, Sensor-Defekt.
6. **Coverage** der Bewertungslogik ≥ 80 % (`test-coverage`), inkl. Fehlerpfade.

## Eskalation
Kritischer Pfad bei Unsicherheit → **adversariales Dual-Review** (`santa-loop`): zwei unabhängige
Prüfungen müssen bestehen, bevor freigegeben wird.

## Nicht tun
- „Grün = fertig" ohne die drei Pflichtfälle. Schwellenwerte raten. Fehlerpfade ungeprüft lassen.

---
*Tests: `tdd-workflow`/`python-testing`. Coverage: `test-coverage`. Dual-Review: `santa-loop`. Regeln: `claude-sync.md` §7.*

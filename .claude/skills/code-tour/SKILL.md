---
name: code-tour
description: Geführter Code-Walkthrough für die Reviewer/Test-Abteilung im G2-Backend — Änderungen Schritt für Schritt nachvollziehen, bevor reviewt oder getestet wird. Nutze diesen Skill vor einem PR-Review.
origin: ECC (code-tour), neu geschrieben für G2 — Use-Case
---

# code-tour — Änderungen verstehen vor dem Review (G2)

Du führst die Reviewerin/Testerin durch fremde Änderungen, **bevor** sie urteilt. Antworte auf
**Deutsch**. Ziel: **Verständnis vor Bewertung** — niemand winkt Code durch, den er nicht versteht (40 %-Regel).

## Wann aktivieren
Vor einem PR-Review oder Test (Workflow-Punkt WP6/WP7), zum Einarbeiten in einen fremden Slice.

## Ablauf
1. **Überblick:** Welche **Anforderungs-ID/Phase** adressiert der PR? Welche Module sind berührt
   (`ingest · model · assessment · storage · api …`)?
2. **Pfad nachvollziehen:** Folge dem Datenfluss durch die Änderung Schritt für Schritt (Eingang →
   Validierung → Bewertung → Persistenz/Response). Erkläre jeden Schritt in 1–2 Sätzen.
3. **Kritische Stellen markieren:** Bewertungslogik, **RB-01** (kein Aktor), **Fail-safe**,
   Eingabe-Validierung — hier genau hinschauen.
4. **Verständnis-Check:** Offene Fragen sammeln, die der Autor klären muss, bevor das Review startet.

## Übergabe
Danach ins eigentliche Review (`code-review`) bzw. den Live-Test (`verify`/`run`) — jetzt fundiert,
nicht blind.

## Nicht tun
- Reviewen/abnicken ohne den Code verstanden zu haben.
- Use-Case-Konformität raten — gegen `Schwellenwerte.md` / Anforderungen in `Alarmsystem-Dev` prüfen.

---
*Danach: `code-review`, `test-coverage`, `verify`. Regeln: `claude-sync.md` §4 (WP6/7).*

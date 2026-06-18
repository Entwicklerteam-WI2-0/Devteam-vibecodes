---
name: review-pr
description: Vollständiges Pull-Request-Review in der Reviewer/Test-Abteilung (G2) — Änderungen verstehen, DoD prüfen, Befunde mit Schweregrad melden, Freigabe nur bei erfüllter DoD. Nutze diesen Skill, wenn ein PR der Backend-Abteilung zu prüfen ist.
origin: ECC (review-pr), neu geschrieben für G2 — Use-Case
---

# review-pr — Pull Request prüfen (G2)

Du führst das PR-Review der Reviewer/Test-Abteilung. Antworte auf **Deutsch**. Der **Mensch
verantwortet die Freigabe** (40 %-Regel) — du lieferst fundierte Befunde, kein blindes Durchwinken.

## Wann aktivieren
Neuer PR der Backend-Abteilung offen (Workflow-Punkt WP6).

## Ablauf
1. **Verstehen:** Änderungen durchgehen (`code-tour`) — welche Anforderungs-ID/Module?
2. **DoD prüfen:**
   - Tests grün; Bewertungslogik **≥ 80 % Coverage**.
   - Kritischer Pfad: Vorfall A/B + Fail-safe als benannte grüne Tests (`verification-loop`).
   - Anforderungs-ID referenziert; Entscheidung im Logbuch.
3. **Qualität prüfen:** `python-review` + `fastapi-review` (Idiome, DI, Schemas, RB-01, Fail-safe).
4. **Sicherheit:** Eingabevalidierung, keine Secrets (`security-scan`).
5. **Befunde melden:** mit Schweregrad (CRITICAL blockt; HIGH/MEDIUM/LOW), konkret + umsetzbar.

## Freigabe-Kriterium
**Freigabe nur**, wenn keine CRITICAL/offenen HIGH und die DoD vollständig ist. Sonst: zurück an den Autor.
Merge selbst **erst nach Freigabe durch Lucas**.

## Nicht tun
- Durchwinken ohne Verständnis/erfüllte DoD. RB-01-/Fail-safe-Verstöße übersehen.

---
*Verstehen: `code-tour`. Qualität: `python-review`/`fastapi-review`. Kritischer Pfad: `verification-loop`/`santa-loop`.*

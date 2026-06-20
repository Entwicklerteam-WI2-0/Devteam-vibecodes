---
description: Session-Start — Stand, Regeln und Git-Status laden (Resume)
---
Du beginnst eine Arbeitssitzung im **Vibecoding-Stack** (Team-OS-Werkzeugrepo). Antworte auf **Deutsch**.

> **`uni:start` liest nur — es fetcht/pullt nicht.** Die Devs `git pull`en als ersten Workflow-Schritt selbst; `uni:start` liest den **lokal bereits aktualisierten** Stand.

Gehe so vor:
1. **Erinnerung lesen (vollständig):**
   - `erinnerung/stand.md` — der konsolidierte Gesamtüberblick des Team-OS-Aufbaus.
   - das **heutige** `erinnerung/journal/<YYYY-MM-DD>.md` (Detail-Tagebuch des geteilten Repo-Fortschritts) und, falls heute noch leer, zusätzlich das **letzte vorhandene** Journal-Dokument. Nicht das ganze Journal-Archiv laden — nur heute + ggf. den letzten Tag.
2. **Regeln laden:** `claude-sync.md` (die geteilte, höchste Agenten-Anweisung). Verinnerliche besonders deinen **Operating Mode als beaufsichtigender Coach** (§1), die **Workflow-/Supervisions-Gates** (§4), die **Conventions** (§5) und die **Genehmigungspflichten** (§7).
3. **Git-Stand anzeigen (nicht ändern):** aktuellen Branch nennen. **Kein** `git fetch`/`pull`, kein Merge — die Devs haben vor der Session selbst gepullt. Wirkt der Stand auffällig veraltet, weise nur darauf hin („ggf. vorher pullen"), führe aber nichts aus.
4. **Zusammenfassen (5–8 Zeilen):** Wo stehen wir? Was ist als Nächstes dran? Welche Regeln gelten für die anstehende Aufgabe?

Erfinde **keine** Fakten — alles aus den Dateien. Use-Case-Fakten (Schwellenwerte, Anforderungen) stehen **nicht hier**, sondern im Arbeitsrepo `Alarmsystem-Dev` (siehe `claude-sync.md` §2).

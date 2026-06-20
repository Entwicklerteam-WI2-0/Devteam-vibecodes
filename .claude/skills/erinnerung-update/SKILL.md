---
name: erinnerung-update
description: Geteilten Repo-Fortschritt am Session-Ende ins Tages-Journal schreiben (G2) — hängt einen append-only-Block an erinnerung/journal/<YYYY-MM-DD>.md an. Nutze diesen Skill am Session-Ende (WP8), zusammen mit oder als Schreibteil von save-session.
origin: neu für G2 — Team-OS-Erinnerungssystem (geteilter Repo-Fortschritt)
---

# erinnerung-update — Tages-Journal fortschreiben (G2)

Du schreibst den **geteilten Repo-Fortschritt** fort: einen kurzen Block ins **heutige Tages-Dokument**,
damit die nächste Person (oder du morgen) den Verlauf des Teams nachvollziehen kann. Antworte auf
**Deutsch**. Kurz, faktisch.

## Wann aktivieren
Am **Session-Ende** (Workflow-Punkt WP8 in `claude-sync.md`). Schreibt das, was `save-session` an
geteiltem Fortschritt festhält, ins Journal. `uni:start` **liest** dieses Journal beim nächsten Start.

## Goldene Regel: append-only
**Niemals** bestehende Blöcke oder Zeilen anderer ändern, umschreiben oder löschen — nur **unten anhängen**.
Das hält Merges konfliktfrei (zwei Leute hängen an verschiedenen Stellen an → Git merged automatisch).

## Ablauf
1. **Daten ziehen — nicht erfinden:**
   - **Datum** (Dateiname `YYYY-MM-DD`) und **Uhrzeit** `HH:MM` aus dem System bzw. dem letzten Commit:
     `git log -1 --format='%cd' --date=format:'%Y-%m-%d %H:%M'`.
   - **Commit/Push:** Kurz-Hash + Message aus `git log -1 --format='%h \"%s\"'`. Nichts raten.
   - **Branch:** `git rev-parse --abbrev-ref HEAD`.
2. **Rolle bestimmen** — eine von `tester` · `architekt` · `backend-db` · `backend-dev`. Kennst du die
   Rolle des Devs aus dem Kontext (`claude-sync.md` §3, Session-Kontext)? Dann setze sie. **Im Zweifel
   kurz nachfragen** statt raten.
3. **Datei wählen:** `erinnerung/journal/<heute>.md`.
   - **Existiert nicht** → neu anlegen, beginnend mit der Kopfzeile `# Journal <YYYY-MM-DD>`.
   - **Existiert** → die Datei lesen und den neuen Block **unten anhängen** (bestehende Zeilen unberührt).
4. **Block anhängen** nach diesem Schema:
   ```markdown
   ## [HH:MM] <Rolle> · <Name oder Branch>
   - Was/Wo: <kurz: welches Modul/Feature, was passiert ist>
   - Commit/Push: <hash> "<message>"
   - Nächster Schritt: <kurz>
   ```
5. **Konsolidierung getrennt halten:** Das Journal ist das **Detail-Tagebuch**. Den verdichteten
   Gesamtüberblick pflegt der Architekt in `erinnerung/stand.md` (separat, nicht hier automatisch).

## Beispiel-Block
```markdown
## [16:40] backend-dev · feat/ingest-validation
- Was/Wo: Eingabe-Validierung für POST /readings (Pydantic-Schema + Grenzwert-Checks)
- Commit/Push: a1b2c3d "feat: validate reading payload"
- Nächster Schritt: Fail-safe-Test für Stale-Daten ergänzen
```

## Inhalt-Regeln
- Deutsch, faktisch. **Keine Secrets/Tokens.** **Keine personenbezogenen Bewertungen** über Teammitglieder.
- Use-Case-/Produktstand (Schwellenwerte, Anforderungs-IDs) gehört **nicht** ins Journal, sondern ins
  Arbeitsrepo `Alarmsystem-Dev`. Hier nur der **Arbeits-/Repo-Fortschritt**.

## Nicht tun
- Bestehende Journal-Zeilen ändern/löschen (bricht append-only & Konfliktfreiheit).
- Datum, Uhrzeit oder Commit-Hash erfinden — immer aus `git`/System ziehen.
- Das ganze Journal umschreiben oder „aufräumen".

---
*Gegenstück beim Start: `uni:start` (liest stand.md + heutiges Journal). Verwandt: `save-session`. Ablauf: `claude-sync.md` §4 (WP8). Git-Ausnahme für `erinnerung/`: §7.*

---
name: entscheidungslog2-architekt
description: Use at session end or after significant architecture work to create a personal, locally stored decision and session log that combines decision records, implementation summary, and overall progress — without the 40% grade focus.
origin: G2-eigen (Use-Case-Skill, kein ECC-Fork)
---

# entscheidungslog2-architekt — Persönliches Architekten-Session-Log (G2)

Du erstellst ein **persönliches, lokal gespeichertes Architekten-Session-Log**. Es vereint drei Dinge in einem
Dokument:
1. **Entscheidungen** im bekannten Muster aus `entscheidungslog` (Kontext, Begründung, Alternativen, Status),
2. eine **ausführliche Zusammenfassung** dessen, was in der Session gemacht und implementiert wurde,
3. einen **Stand bezogen auf den gesamten Fortschritt**.

Antworte auf **Deutsch**. Kurz, faktisch. **Kein Bewertungsfokus** — das Log dient der persönlichen
Kontinuität und Nachvollziehbarkeit, nicht der 40 %-Einzelleistung.

## Wann aktivieren
- Am **Session-Ende** oder nach **nennenswerten Architektur-/Planungsarbeiten**.
- Wenn mehrere Entscheidungen, Implementierungen und ein Gesamtstand zusammengefasst werden sollen.
- Wenn das geteilte `erinnerung/`-Journal nicht gewünscht ist oder bereits durch `save-session` gepflegt wird.

## Schritt 0 — Letzte PRs auf ungelöste Änderungen, Stände und Entscheidungen prüfen
Bevor der Log-Eintrag geschrieben wird, die letzten PRs des aktuellen Repos durchsehen und
relevante Befunde für den Architekten-Log extrahieren:

1. **PRs auflisten:** z. B. via GitHub CLI
   `gh pr list --state all --limit 10 --json number,title,state,mergedAt,updatedAt,body,reviewDecision`
   oder über die GitHub-Weboberfläche. Alternativ: `git log --oneline --grep="Merge pull request" -n 10`.
2. **Relevante PRs auswählen:** PRs der letzten Tage/Woche, die den eigenen Architektur-/Tooling-Bereich
   betreffen oder in die aktuelle Session hineinspielen.
3. **Auf ungelöste Punkte prüfen:**
   - Offene/unbeantwortete Review-Kommentare
   - Nicht umgesetzte Änderungswünsche
   - Noch offene Entscheidungen oder Abstimmungsbedarf
   - Stände, die noch nicht ins Team-OS / die Doku zurückgeflossen sind
4. **Befunde zusammenfassen:** Kurz notieren, was noch offen ist und was in die Session/Planung
   einfließen muss.

Die Befunde fließen in den Eintrag unter **Abschnitt 4. PR-Stand / ungelöste Punkte** ein.

## Speicherort (lokal, nicht geteilt)
1. **Vorhandenen persönlichen Log-Ordner nutzen:** `<Name>-Entscheidungslog/` im Wurzelverzeichnis des
   aktuellen Repos. Existiert bereits ein Ordner wie `Entscheidungslog-Lucas/`, nutze diesen.
2. **Falls kein Ordner vorhanden:** einmalig nach Name/Kürzel fragen (z. B. Nachname) und
   `<Name>-Entscheidungslog/` anlegen.
3. **Datei:** `<Name>-Entscheidungslog/<Name>-Entscheidungslog2-Architekt.md`

> Beispiel: Lucas → `Entscheidungslog-Lucas/Entscheidungslog2-Architekt.md`.

## Datei-Kopf (verbindlich)
Jede Log-Datei beginnt mit einem Datums-Header. Bei jeder Bearbeitung das „Letzte Bearbeitung"-Datum
aktualisieren.

```markdown
# Persönliches Architekten-Session-Log — <Vorname Nachname> (G2)
> **Erstellt am:** YYYY-MM-DD · **Letzte Bearbeitung:** YYYY-MM-DD
> **Autor:** <Name> · **Rolle:** Architekt / Systemarchitekt
> Zweck: Entscheidungen + Session-Zusammenfassung + Gesamtfortschritt. Lokal gespeichert, nicht bewertungsrelevant.
```

## Eintrag pro Session

```markdown
## YYYY-MM-DD — <Kurztitel der Session>

### 1. Entscheidungen (bekanntes Muster, ohne 40%-Fokus)
- **Entscheidung:** <was wurde gewählt?>
  - **Kontext/Task:** <P#.# · Anf-ID (FA-/NF-/RB-/K-) oder allgemeiner Kontext>
  - **Begründung:** <warum? belegbasiert>
  - **Alternativen:** <was wurde erwogen und verworfen?>
  - **Ergebnis/Status:** <umgesetzt / offen / später korrigiert>

### 2. Session-Verlauf (was wurde gemacht / implementiert)
- <ausführlicher, aber strukturierter Verlauf>
- <Module, Dateien, Endpoints, Konzepte, die angefasst wurden>
- <Technische Details, die für die Wiederaufnahme wichtig sind>

### 3. Gesamtfortschritt / Stand
- <Stand des Projekts / der Architektur aus heutiger Sicht>
- <Was ist fertig, was fehlt noch, was ist der nächste kritische Pfad?>
- <Offene Punkte oder Risiken>

### 4. PR-Stand / ungelöste Punkte
- <PR #X — Titel>: <offener Punkt, Stand, Entscheidung oder Änderung>
- <PR #Y — Titel>: <...>
```

## Leitplanken
- **Deutsch, faktisch, keine Secrets.**
- **Lokal speichern:** Keine git-Operationen, kein Push, kein PR, keine Änderung an `erinnerung/`.
- **Ausführlich, aber nicht romanhaft:** Der Verlauf soll die Session rekonstruierbar machen.
- **Gesamtstand:** Nicht nur das Heute beschreiben, sondern einordnen, wo das Projekt insgesamt steht.
- **Kein 40%-Fokus:** Der Mensch muss die Begründungen nicht für die Bewertung aufpolieren, sondern für
  sich selbst nachvollziehbar halten.

## Nicht tun
- In geteilte Dateien (`erinnerung/`, `*-Entscheidungslog.md` anderer Personen) schreiben.
- Entscheidungen erfinden oder Begründungen raten.
- Bestehende Log-Einträge anderer überschreiben oder löschen.
- Git-Operationen durchführen.

---
*Persönliches Log: `entscheidungslog`. Geteiltes Session-Ende: `save-session`.*

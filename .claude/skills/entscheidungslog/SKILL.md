---
name: entscheidungslog
description: Persönliches Entscheidungslog des Entwicklers anlegen und pflegen (G2) — beim Auslösen automatisch den eigenen Ordner `<Name>-Entscheidungslog/` anlegen (falls nicht vorhanden) und eigene technische Entscheidungen mit Begründung und verworfenen Alternativen dokumentieren. Bewertungsrelevant (Nachvollziehbarkeit, 40 % Einzelleistung). Nutze diesen Skill bei jeder eigenen nennenswerten Entscheidung und am Session-Ende.
origin: G2-eigen (Use-Case-Skill, kein ECC-Fork)
---

# entscheidungslog — persönliches Entscheidungslog (G2)

Du hilfst der Person, ihr **persönliches** Entscheidungslog anzulegen und laufend zu pflegen. Antworte auf
**Deutsch**. Das Log weist die **eigene Einzelleistung** nach und zahlt direkt auf das benotete Kriterium
**„Nachvollziehbarkeit"** ein (40 % Einzelleistung). **Die Reflexion gehört der Person** — du lieferst
**Struktur + Belege + verworfene Alternativen**; die **Begründung formuliert und verantwortet der Mensch**.

## Wann aktivieren
- Bei jeder **eigenen** nennenswerten technischen Entscheidung (Ansatz, Datenmodell, Bibliothek,
  Bewertungs-Parametrisierung, verworfene Alternative).
- Spätestens **am Session-Ende** (zusammen mit `save-session`) — Tageseinträge nachtragen.

## Schritt 1 — Eigenen Log-Ordner sicherstellen (automatisch, idempotent)
1. **Vorhandenen Log finden / Namen bestimmen:** Gibt es im aktuellen Repo schon einen persönlichen
   Log-Ordner dieser Person — `<Name>-Entscheidungslog/` **oder** das bestehende `Entscheidungslog-Lucas/`
   (Architekt) — dann **diesen nutzen**. Sonst **einmal** kurz nach Name/Kürzel fragen (z. B. Nachname).
2. **Ordner anlegen, falls nicht vorhanden:** `<Name>-Entscheidungslog/` im **Wurzelverzeichnis des
   aktuellen Repos** (idempotent — nur erzeugen, wenn er fehlt).
   - **Tooling-/Team-OS-Entscheidungen** (Aufbau Werkzeugkasten, Stack-/Modellwahl, Workflows) → in
     **diesem** Repo (`Devteam-vibecodes`).
   - **Produktcode-Entscheidungen** (Backend-Devs) → im Code-Repo `Alarmsystem-Dev` (Team-Konvention;
     im Zweifel mit dem Team abstimmen, **nicht** raten).
3. **Log-Datei anlegen, falls nicht vorhanden:** `<Name>-Entscheidungslog/<Name>-Entscheidungslog.md`
   mit dem Datums-Kopf aus Schritt 2.

> Beispiel: Person „Hartling" → `Hartling-Entscheidungslog/Hartling-Entscheidungslog.md`.
> Lucas' bestehendes `Entscheidungslog-Lucas/` ist der **Architekten-/Tooling-Log** und bleibt unter
> seinem Namen — neue Personen bekommen das Muster `<Name>-Entscheidungslog/`.

## Schritt 2 — Datei-Kopf (verbindliche Datums-Konvention)
Jede Log-Datei **beginnt mit einem Datum** — Erstellungs- und letztes-Bearbeitungs-Datum (`YYYY-MM-DD`).
Sammelt sie Entscheidungen über mehrere Tage, zusätzlich einen **Zeitraum** (von–bis). **Bei jeder
Bearbeitung** das „Letzte Bearbeitung"-Datum (und ggf. den Zeitraum) aktualisieren.

```markdown
# Persönliches Entscheidungslog — <Vorname Nachname> (G2)
> **Erstellt am:** YYYY-MM-DD · **Letzte Bearbeitung:** YYYY-MM-DD  ·  *(bei Sammel-Logs:)* **Zeitraum:** YYYY-MM-DD bis YYYY-MM-DD
> **Autor:** <Name> · **Status:** laufend gepflegt
> Eigene technische Entscheidungen + Begründung. **Bewertungsrelevant** (Nachvollziehbarkeit, 40 % Einzelleistung).
```

## Schritt 3 — Ein Eintrag pro Entscheidung
```markdown
## YYYY-MM-DD — <Kurztitel der Entscheidung>
- **Kontext/Task:** P#.# · Anf-ID (FA-/NF-/RB-/K-)
- **Entscheidung:** was wurde gewählt?
- **Begründung:** warum? (belegbasiert — Fakten aus `Alarmsystem-Dev`, nicht raten)
- **Alternativen:** was wurde erwogen und warum verworfen?
- **Ergebnis/Status:** umgesetzt / offen / später korrigiert (auch Fehlentscheidungen ehrlich festhalten)
```
Datum im Format `YYYY-MM-DD`. Reihenfolge (neueste oben **oder** unten) **konsistent** halten. Wächst das
Log, optional in **Teile** gliedern (z. B. Bau / Organisation / Workflows) — wie im Architekten-Log.

## Abgrenzung
- **Persönliches** Log (deine Beiträge) ≠ **zentrales** Entscheidungslogbuch des Teams.
- Diese Datei ist **kein** append-only-Journal (≠ `erinnerung/journal/`) — frühere Einträge darfst du
  präzisieren/korrigieren.
- `architecture-decision-records` liefert die ADR-Struktur als Rohstoff; **dieser** Skill ist das laufende
  persönliche Log. Konsolidierung/Doku-Sync über `update-docs`.

## Leitplanken
- **Die Person entscheidet & formuliert die Begründung selbst** — du strukturierst und lieferst Belege,
  drängst **keine** fertige Entscheidung auf (40 %-Regel, `claude-sync.md` §1).
- **Ehrlich:** auch verworfene Ansätze und Korrekturen festhalten (das zeigt Verständnis).
- **Belegbasiert:** Bezug zu Anf-IDs/Tasks; keine erfundenen Begründungen.
- Deutsch; **keine Secrets**, keine personenbezogenen Bewertungen anderer.

## Nicht tun
- Entscheidungen erst kurz vor Abgabe „rekonstruieren". Alternativen weglassen. Log mit dem zentralen
  Team-Logbuch verwechseln. Ordnernamen/Ablageort **raten**, statt den Namen zu erfragen bzw. einen
  vorhandenen `*-Entscheidungslog/`-Ordner zu nutzen.

---
*ADR-Struktur: `architecture-decision-records`. Doku-Sync: `update-docs`. Session-Ende: `save-session`. Fakten: `Alarmsystem-Dev`.*

---
name: save-session
description: Arbeitsstand am Session-Ende sichern (G2) — geteilten Repo-Fortschritt ins Journal schreiben (append-only), Stand aktualisieren, Entscheidungen ins Logbuch, offene Punkte festhalten. Das EINZIGE Skill, das die geteilte Team-Erinnerung (erinnerung/) updatet. Nutze diesen Skill am Ende jeder Arbeitssitzung.
origin: ECC (save-session), neu geschrieben für G2 — Use-Case
---

# save-session — Stand sichern (G2)

Du sicherst den Arbeitsstand, damit die nächste Sitzung (auch durch eine andere Person) nahtlos
weiterläuft. Du bist das **einzige** Skill, das die geteilte Team-Erinnerung (`erinnerung/`) updatet —
es gibt **keinen separaten Schreib-Skill** mehr. Antworte auf **Deutsch**. Kurz, faktisch.

## Wann aktivieren
Am **Session-Ende** (Workflow-Punkt WP8 in `claude-sync.md`). Gegenstück beim Start: `uni:start` liest, was du hier schreibst.

## Ablauf

### 1. Journal fortschreiben — `erinnerung/journal/<heute>.md` (append-only)
Der geteilte Repo-Fortschritt, den `uni:start` beim nächsten Mal liest. **Goldene Regel: append-only** —
niemals bestehende Blöcke/Zeilen anderer ändern oder löschen, nur **unten anhängen** (hält Merges konfliktfrei).

1. **Daten ziehen, nicht erfinden:**
   - **Datum/Uhrzeit** aus System bzw. letztem Commit: `git log -1 --format='%cd' --date=format:'%Y-%m-%d %H:%M'`.
   - **Commit/Push:** Kurz-Hash + Message aus `git log -1 --format='%h \"%s\"'`.
   - **Branch:** `git rev-parse --abbrev-ref HEAD`.
2. **Rolle bestimmen** — `tester` · `architekt` · `backend-db` · `backend-dev` (aus Session-Kontext /
   `claude-sync.md` §3; im Zweifel kurz nachfragen statt raten).
3. **Datei `erinnerung/journal/<heute>.md`:** existiert nicht → neu anlegen mit Kopfzeile
   `# Journal <YYYY-MM-DD>`; existiert → lesen und den Block **unten anhängen** (bestehende Zeilen unberührt).
4. **Block anhängen:**
   ```markdown
   ## [HH:MM] <Rolle> · <Name oder Branch>
   - Was/Wo: <kurz: welches Modul/Feature, was passiert ist>
   - Commit/Push: <hash> "<message>"
   - Nächster Schritt: <kurz>
   ```

### 2. Stand aktualisieren — `erinnerung/stand.md`
Den konsolidierten Gesamtüberblick bei nennenswertem Fortschritt nachziehen. Knapp halten; veraltete
Notizen ersetzen, nicht anhäufen. (Detail lebt im Journal, `stand.md` ist die Verdichtung.)

### 3. Entscheidungen festhalten
Getroffene Entscheidungen ins **Entscheidungslogbuch** (benotetes Pflichtdokument, Kriterium
„Nachvollziehbarkeit"): Was, warum, welche Alternativen. **Persönliche** Entscheidungen → Skill `entscheidungslog`.

### 4. Offene Punkte / Fragen
Notieren, was jemand noch klären muss.

## Inhalt-Regeln
- Deutsch, faktisch. **Keine Secrets/Tokens.** **Keine personenbezogenen Bewertungen** über Teammitglieder.
- Daten (Datum/Uhrzeit/Commit-Hash) aus `git`/System ziehen — nichts raten.
- Use-Case-/Produktstand → Arbeitsrepo `Alarmsystem-Dev`; Team-OS-Stand → hierher (`erinnerung/`).

## Nicht tun
- Bestehende Journal-Zeilen ändern/löschen (bricht append-only & Konfliktfreiheit). Lange, veraltete
  Protokolle anhäufen. Entscheidungen undokumentiert lassen (kostet Punkte).

---
*Gegenstück beim Start: `uni:start`. Persönliches Log: `entscheidungslog`. Ablauf: `claude-sync.md` §4 (WP8). Git-Ausnahme für `erinnerung/`: §7.*

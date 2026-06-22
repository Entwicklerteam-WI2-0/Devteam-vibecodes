---
name: standup-moderator
description: Tägliches Standup strukturiert führen und als Protokoll in erinnerung/journal/<datum>.md schreiben. Nutze diesen Skill zu Beginn jedes Arbeitstags oder auf Anfrage „/uni:standup".
origin: G2-eigen (Orga-Management)
---

# standup-moderator — Tägliches Standup moderieren (G2)

Du führst das tägliche Standup **strukturiert** und schreibst ein kurzes Protokoll ins Journal. Du
übernimmst die Mechanik, der Mensch (Orga-Manager) liefert die Inhalte. Antworte auf **Deutsch**.

## Wann aktivieren

- Zu Beginn jedes Arbeitstags.
- Auf Anfrage „/uni:standup".
- Wenn `erinnerung/stand.md` eine Blocker-Liste hat, die täglich aktualisiert werden soll.

## Voraussetzung

- `uni:start` wurde ausgeführt (`erinnerung/stand.md` + Regeln geladen).
- Aktuelles Datum und Uhrzeit bekannt (System).

## Ablauf

### 1. Kontext sammeln (nicht erfinden)

1. Lies `erinnerung/stand.md` und das aktuelle Journal (`erinnerung/journal/<heute>.md` bzw. letzter Eintrag).
2. Ziehe Git-Status: offene Branches, uncommitted Changes, offene PRs (lokal oder via GitHub-API).
3. Identifiziere die letzte bekannte Blocker-Liste.

### 2. Standup-Runde führen

Frage der Reihe nach für jede Abteilung / jedes aktive Mitglied:

1. **Was wurde seit dem letzten Standup erreicht?** (faktisch, anhand Journal/Commits/PRs)
2. **Was kommt heute?** (1–3 konkrete Ziele)
3. **Wo blockiert es?** (Hilfe, Rückfragen, Abhängigkeiten)

> Für Einsteiger:innen kurz halten; bei Unklarheit nicht raten, sondern „offen" notieren.

### 3. Protokoll ins Journal schreiben

Datei: `erinnerung/journal/<YYYY-MM-DD>.md` — append-only (bestehende Zeilen nicht ändern).

```markdown
## [HH:MM] Standup
- Teilnehmer: <Namen oder Abteilungen>
- Erreicht seit letztem Standup:
  - <Abteilung/Person>: <kurz>
- Heute geplant:
  - <Abteilung/Person>: <1–3 Punkte>
- Blocker / Hilfe nötig:
  - <Wer>: <Was> → <Nächster Schritt / Verantwortlicher>
```

### 4. Blocker aktualisieren

Wenn ein Blocker neu, gelöst oder eskaliert ist: in `erinnerung/stand.md` unter „Offene Punkte / Blocker"
aktualisieren. Bei Blockern > 24h oder kritischer Pfad → `uni:blocker-escalation` vorschlagen.

## Checkliste / Outputs

- [ ] Standup-Runde durchgeführt.
- [ ] Protokoll append-only in `erinnerung/journal/<heute>.md` geschrieben.
- [ ] Blocker-Liste in `erinnerung/stand.md` aktualisiert.
- [ ] Bei Eskalationsbedarf `uni:blocker-escalation` angestoßen.

## Leitplanken

- Append-only im Journal — niemals fremde Zeilen ändern (`claude-sync.md` §7).
- Keine persönlichen Bewertungen, keine Secrets.
- Fakten aus Journal/Git/Stand ziehen; nichts erfinden.

## Nicht tun

- Standup-Protokoll für andere Tage rückwirkend verändern.
- Blocker „unterschlagen" oder als „nicht wichtig" abtun, wenn sie den kritischen Pfad berühren.
- Automatisch in GitHub/Issues posten — der Mensch kommuniziert.

---
*Gegenstück: `uni:fortschritts-board`, `uni:blocker-escalation`. Ablauf: `claude-sync.md` §4 (WP0).*
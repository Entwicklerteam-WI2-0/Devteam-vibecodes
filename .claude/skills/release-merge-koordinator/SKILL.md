---
name: release-merge-koordinator
description: Koordiniertes Mergen auf main planen: Was, wann, von wem, Abhängigkeiten, Rollback. Nutze diesen Skill, wenn mehrere PRs bereit sind oder ein Release ansteht.
origin: G2-eigen (Orga-Management)
---

# release-merge-koordinator — Merge & Release koordinieren (G2)

Du planst ein **koordiniertes Mergen auf `main`**: Welche PRs gehen wann rein, in welcher Reihenfolge,
mit welchen Risiken und mit welchem Rollback-Plan. Du schreibst einen Merge-Plan, den der Orga-Manager
und Lucas prüfen. Antworte auf **Deutsch**.

## Wann aktivieren

- Mehrere PRs sind bereit für `main`.
- Ein Release / eine Abgabe steht an.
- Vor der Merge-Freigabe durch Lucas.
- Auf Anfrage „/uni:merge-plan".

## Voraussetzung

- `uni:start` ausgeführt.
- Liste der bereiten PRs (approved, grüne CI, keine offenen Change-Requests).
- Kenntnis der Abhängigkeiten zwischen PRs (aus `Abhaengigkeiten.md`, PR-Beschreibungen, Architekt).

## Ablauf

### 1. Kandidaten sammeln

1. Offene PRs prüfen: `gh pr list --json number,title,author,state,reviewDecision,mergeStateStatus`.
2. Nur PRs berücksichtigen, die:
   - mindestens ein Approval haben (bzw. bei kritischem Pfad `uni:santa-loop` / Dual-Review),
   - grüne CI haben,
   - keine offenen Change-Requests mehr haben.

### 2. Abhängigkeiten ermitteln

Für jeden Kandidaten:
- Baut er auf einem anderen PR auf?
- Muss er vor oder nach einem bestimmten PR gemergt werden?
- Berührt er den eingefrorenen Contract (API-Naht)?
- Berührt er den kritischen Pfad (Bewertungslogik, RB-01, Fail-safe)?

### 3. Merge-Reihenfolge planen

```markdown
## Merge-Plan — YYYY-MM-DD
> **Ziel:** main auf Stand bringen für <Release/Abgabe>

| Reihenfolge | PR | Titel | Autor | Kritischer Pfad? | Abhängigkeiten |
|---|---|---|---|---|---|
| 1 | #<n> | <Titel> | <Autor> | ja / nein | <von/nach welchem PR> |

### Risiken
- <Risiko 1 + Gegenmaßnahme>

### Rollback
- Letzter bekannter guter Stand: <Commit-Hash>
- Rollback-Befehl: `git revert <hash>` bzw. Branch `<backup-branch>`

### Checkliste vor Merge
- [ ] Alle CI-Checks grün
- [ ] Review bestanden (bzw. Dual-Review für kritischen Pfad)
- [ ] `uni:coupling-map` geprüft, falls Tooling-Änderungen betroffen
- [ ] Lucas-Freigabe vorhanden
```

### 4. Risiken & Rollback

- Für jeden kritischen PR: Was kann schiefgehen?
- Backup-Branch oder letzter bekannter guter Stand notieren.
- Rollback-Befehl vorbereiten.

### 5. Freigabe einholen

Merge-Plan dem Orga-Manager / Lucas vorlegen. **Kein automatisches Mergen.**
Nach Freigabe: `git-workflow` ausführen lassen (durch den Menschen).

### 6. Protokoll

Merge-Plan in `erinnerung/journal/<heute>.md` (append-only) und ggf. `erinnerung/board.md` eintragen.

## Checkliste / Outputs

- [ ] Bereite PRs erfasst.
- [ ] Abhängigkeiten ermittelt.
- [ ] Merge-Reihenfolge definiert.
- [ ] Risiken und Rollback dokumentiert.
- [ ] Freigabe durch Lucas eingeholt (Mensch).
- [ ] Protokoll in Journal/Board geschrieben.

## Leitplanken

- Kein Merge ohne Freigabe durch Lucas.
- Kritischer Pfad → Dual-Review / `uni:santa-loop` als erledigt prüfen.
- Tooling-Änderungen → `uni:coupling-map` vor Merge.

## Nicht tun

- Automatisch mergen, rebasen oder force-pushen.
- PRs mergen, die noch Change-Requests haben.
- Den Rollback-Plan vergessen.

---
*Gegenstück: `uni:git-workflow`, `uni:blocker-escalation`, `uni:santa-loop`. Ablauf: `claude-sync.md` §4 (WP5–WP6).*
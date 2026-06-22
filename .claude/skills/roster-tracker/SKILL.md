---
name: roster-tracker
description: Team-Roster pflegen: Wer ist in welcher Abteilung, Verfügbarkeit, Buddy, Kontakt. Nutze diesen Skill bei Personalwechsel, Krankheit, Urlaub oder wöchentlich.
origin: G2-eigen (Orga-Management)
---

# roster-tracker — Team-Roster pflegen (G2)

Du pflegst das zentrale **Team-Roster**: Wer gehört zu welcher Abteilung, wer ist verfügbar, wer ist
Buddy für wen. Du aktualisierst `erinnerung/stand.md` und prüfst, ob `CLAUDE.md` §5 noch konsistent ist.
Antworte auf **Deutsch**.

## Wann aktivieren

- Neues Mitglied onboardet (`uni:onboarding-orchestrator`).
- Jemand wechselt die Abteilung oder Rolle.
- Abwesenheit (Krankheit, Urlaub, Ausfall).
- Wöchentlich als Pflege-Routine.
- Auf Anfrage „/uni:roster".

## Voraussetzung

- Aktuelle Roster-Informationen vorliegen (entweder aus `erinnerung/stand.md`, `CLAUDE.md` §5 oder Rückmeldung des Orga-Managers).
- Keine Annahmen über Verfügbarkeit raten.

## Ablauf

### 1. Bestehende Quellen lesen

1. `CLAUDE.md` §5 (Organigramm / Rollen ↔ Personen).
2. `erinnerung/stand.md` (Roster-Sektion, falls vorhanden).
3. Abteilungs-`Skills.md` (Köpfe pro Abteilung).

### 2. Roster aktualisieren

In `erinnerung/stand.md` eine Sektion „Team-Roster" pflegen (überschreibbar, da aktueller Stand):

```markdown
## Team-Roster
| Name | Abteilung | Rolle | Status | Buddy | Notizen |
|---|---|---|---|---|---|
| <Name> | Backend-Dev / Reviewer-Test / Architekt / Orga-Mgmt / Doku | <Rolle> | aktiv / abwesend bis YYYY-MM-DD | <Buddy> | <z. B. „nur vormittags"> |
```

### 3. Konsistenz prüfen

Vergleiche das Roster mit:
- `CLAUDE.md` §5 — bei Abweichung `CLAUDE.md` aktualisieren.
- Abteilungs-`Skills.md` Köpfe — bei Abweichung anpassen.

### 4. Auswirkungen kommunizieren

Wenn Abwesenheiten Reviews/Tasks blockieren könnten:
- `uni:dev-reviewer-koordinator` informieren (Reviewer-Kapazität).
- `uni:fortschritts-board` aktualisieren.
- Bei kritischer Pfad-Gefährdung `uni:blocker-escalation` prüfen.

## Checkliste / Outputs

- [ ] `erinnerung/stand.md` Team-Roster aktualisiert.
- [ ] `CLAUDE.md` §5 bei Abweichung angepasst.
- [ ] Abteilungs-`Skills.md` Köpfe konsistent.
- [ ] Betroffene Skills (`dev-reviewer-koordinator`, `fortschritts-board`) informiert.

## Leitplanken

- Nur bestätigte Informationen eintragen; bei Unklarheit offen lassen / nachfragen.
- Keine persönlichen Bewertungen oder Krankheitsdetails über das Nötige hinaus.
- Buddy-System für neue/abwesende Mitglieder pflegen.

## Nicht tun

- Roster aus dem Gedächtnis aktualisieren.
- Abwesenheiten ignorieren, die den kritischen Pfad gefährden.
- `CLAUDE.md` §5 vergessen — das ist die öffentliche Organigramm-Quelle.

---
*Gegenstück: `uni:onboarding-orchestrator`, `uni:dev-reviewer-koordinator`. Ablauf: `claude-sync.md` §4 (kontinuierlich).*
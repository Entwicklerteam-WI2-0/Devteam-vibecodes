---
name: onboarding-orchestrator
description: Neues Teammitglied Schritt für Schritt in Stack, Rollen und ersten Task einführen. Nutze diesen Skill bei Neuzugang: „/uni:onboarding <Name> <Rolle>".
origin: G2-eigen (Orga-Management)
---

# onboarding-orchestrator — Neues Mitglied onboarden (G2)

Du führst ein neues Teammitglied **Schritt für Schritt** in das Team-OS, die Rollen und den ersten Task
ein. Du übernimmst die Struktur, der Mensch (Orga-Manager oder Buddy) begleitet die Person. Antworte
auf **Deutsch**.

## Wann aktivieren

- Ein neues Mitglied tritt dem Team bei.
- Auf Anfrage „/uni:onboarding <Name> <Rolle>".
- Wenn ein bestehendes Mitglied in eine andere Abteilung wechselt.

## Voraussetzung

- Name und geplante Rolle/Abteilung des neuen Mitglieds bekannt.
- `ONBOARDING.md`, `CLAUDE.md`, `claude-sync.md` und die Abteilungs-`Skills.md` lesbar.

## Ablauf

### 1. Persönlichen Onboarding-Ordner anlegen

Ordner: `onboarding/<Name>/` (neu anlegen, falls nicht vorhanden).
Datei: `onboarding/<Name>/Onboarding-Checkliste.md`.

### 2. Checkliste zusammenstellen

```markdown
# Onboarding-Checkliste — <Name>
> **Rolle:** <Backend-Dev / Reviewer-Test / Architekt / Orga-Management / Doku-Gruppe>
> **Buddy:** <Name> · **Startdatum:** YYYY-MM-DD

## Tag 1 — Team-OS verstehen
- [ ] `ONBOARDING.md` gelesen
- [ ] `CLAUDE.md` §0–§5 gelesen
- [ ] `claude-sync.md` §1–§7 gelesen
- [ ] Setup-Skript für die eigene CLI ausgeführt (`setup-kimi.sh` / `setup-claude.sh` / `setup-codex.sh`)
- [ ] `uni:start` getestet

## Tag 1–2 — Rollen-Skills kennenlernen
- [ ] Abteilungs-`Skills.md` gelesen: `<abteilung-.../Skills.md>`
- [ ] Einstiegs-Set (Tag 1) der Abteilung durchgesprochen
- [ ] `gemeinsam/Skills.md` gelesen

## Tag 2–3 — Erster Task
- [ ] Erster Task ausgewählt (mit Buddy/Orga-Manager)
- [ ] Task mit `uni:feature-dev` / passendem Skill begonnen
- [ ] Erster Commit/PR nach Workflow (Feature-Branch → Quality-Gate → PR)
- [ ] `save-session` am Ende ausgeführt

## Offene Fragen / Notizen
- <Platz für Notizen>
```

### 3. Rollen-Bootstrap

- Für Backend-Dev: Verweis auf `abteilung-backend-entwickler/Skills.md` + Einstiegs-Set.
- Für Reviewer/Test: Verweis auf `abteilung-reviewer-tester/Skills.md` + 40-%-Regel.
- Für Architekt: Verweis auf `abteilung-architekten/Skills.md`.
- Für Orga-Management/Doku: Verweis auf `abteilung-orga-management/Skills.md`.

### 4. Roster aktualisieren

Neues Mitglied in `erinnerung/stand.md` Team-Roster eintragen (oder `uni:roster-tracker` vorschlagen).

### 5. Buddy zuweisen

Buddy aus der gleichen Abteilung vorschlagen; in der Checkliste festhalten.

## Checkliste / Outputs

- [ ] `onboarding/<Name>/Onboarding-Checkliste.md` angelegt.
- [ ] Persönliche Setup- und Rollen-Checkliste erstellt.
- [ ] Buddy vorgeschlagen.
- [ ] Roster in `erinnerung/stand.md` aktualisiert (oder `uni:roster-tracker` angestoßen).
- [ ] Erster Task mit Buddy besprochen.

## Leitplanken

- Nicht überfordern — Einstiegs-Set zuerst, Rest nach Bedarf.
- Use-Case-Fakten nicht im Onboarding erfinden; Verweise auf `Alarmsystem-Dev` setzen.
- Setup wirklich ausführen lassen (nicht nur „gelesen" abhaken).

## Nicht tun

- Dem Neuen sofort einen kritischen Pfad-Task geben.
- Setup-Schritte überspringen.
- Passwörte/Secrets im Onboarding-Ordner hinterlegen.

---
*Gegenstück: `uni:roster-tracker`, `uni:start`. Ablauf: `claude-sync.md` §4 (WP1).*
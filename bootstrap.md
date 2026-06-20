# Rollen-Bootstrap — was beim allerersten Start passiert

> Einmaliger Ablauf beim **ersten `uni:start`** auf einer frisch eingerichteten Maschine. **Maßgeblich ist
> §0 in `claude-sync.md`** (vom Setup als `~/.claude/team-os-g2.md` ausgerollt) — dieses Dokument erklärt es
> nur menschenlesbar. Bei Widerspruch gilt §0. Beschrieben für **Claude Code**; bei **Kimi/Codex** analog in
> der `AGENTS.md`.

## Wozu der Bootstrap?
Damit der Agent weiß, **wer du bist** (Abteilung + Rolle), dir nur **deine** Skills/Workflows anbietet und
deine Erinnerungs-Einträge **signiert**. Ab dann startet jede Session mit einem geplanten Workflow-Vorschlag.

## Auslöser — einmalig, selbst-erkennend
Steht **ganz oben in `~/.claude/CLAUDE.md`** noch **kein** Rollen-Header `<!-- TEAM-OS-ROLLE: … -->`, läuft
der Bootstrap. Sobald der Header existiert, wird §0 **übersprungen** — also genau **einmal**.

## Das kurze Interview
1. **Abteilung?** Backend-Entwicklung **oder** Reviewer/Test.
2. **Nur bei Backend:** Funktion? **Dev** **oder** **Database-Engineer**.

## Was der Agent danach dauerhaft einträgt
…in deine **persönliche** `~/.claude/CLAUDE.md` (nicht in `team-os-g2.md` — die wird bei `/update` überschrieben):

1. **Rollen-Header ganz oben** — `<!-- TEAM-OS-ROLLE: Abteilung=…; Rolle=…; Signatur=… -->` plus eine
   lesbare Zeile. Überlebt jedes `/update`.
2. **Save-Signatur** — jeder Eintrag von `save-session` / `erinnerung-update` wird mit deiner Rolle signiert
   (z. B. `—backenddev`, `—database-engineer`, `—reviewer`). So ist nachvollziehbar, **wer** gesichert hat.
3. **Fremd-Abteilung ausblenden — rollenbasiert, KEINE Datei-Löschung.** Du siehst nur Workflow + Skills
   deiner Abteilung (§10); die andere wird ignoriert, ihre exklusiven Skills werden dir nicht vorgeschlagen.
   **Geteilte** Skills bleiben für alle. Es wird **nichts** gelöscht → der Filter ist update-fest.
4. **Standing-Instruktion** — jeder Session-Start: deinen Workflow (§10) lesen, **Erinnerungen + `stand.md`**
   heranziehen, **nach der nächsten Task fragen** und **Schritt für Schritt** planen, mit Vorschlag der
   passenden **`uni:`-Skills**.

## Sonderfall Architekt / Admin / PM
Wer **quer** zu beiden Abteilungen arbeitet (z. B. Lucas), setzt den Header **manuell** mit `Ausblenden=nein`.
Dann läuft **kein** Interview, und **beide** Abteilungen bleiben sichtbar — sinnvoll für die Person, die das
Toolkit pflegt.

## Wann greift das überhaupt?
Nur solange `team-os-g2.md` aktiv ist (Claude Code: global eingebunden; bzw. gemäß dem Vermerk in deiner
`CLAUDE.md`, wenn in den Projekt-Repos gearbeitet wird). Verändert wird die team-weite `team-os-g2.md`
**nicht** — sie bleibt voll (beide Abteilungen), gefiltert wird **zur Laufzeit per Rolle**.

---
*Maßgeblicher Wortlaut: **§0 Bootstrap** und **§10 Abteilungskonzept** in [`claude-sync.md`](claude-sync.md).
Praxis-Durchlauf der Skills: [`Skillanleitung.md`](Skillanleitung.md).*

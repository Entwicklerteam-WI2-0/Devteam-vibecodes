---
name: pmai-shaping
description: Interaktives Shaping einer Lösung mit dem User — iterativ Requirements (R) und Lösungsoptionen (Shapes S) erarbeiten, Fit-Check durchführen, Shape auswählen und in vertikale Slices überführen.
origin: community (pmai-shaping), gekürzt und ausführbar gemacht für G2
---

# pmai-shaping — Lösung interaktiv shapeen

Du führst den User Schritt für Schritt durch ein **Shaping**: gemeinsam Problem und Lösungsoptionen erarbeiten, bis eine ausgewählte Lösung in konkrete, baubare Slices zerlegt ist. Antworte auf **Deutsch**.

> **Wichtig:** Shaping ist **kollaborative Verhandlung** — du füllst nichts allein aus, sondern stellst Fragen, machst Vorschläge und lässt den User entscheiden.

## Wann aktivieren

- Eine neue Anforderung ist unklar oder widersprüchlich.
- Es gibt mehrere mögliche Lösungswege.
- Die Lösung muss vor der Implementierung strukturiert werden (WP1/WP2).

## Dokument-Hierarchie

Shaping erzeugt Dokumente auf drei Ebenen:

1. **Frame** — das „Warum": Source, Problem, Outcome.
2. **Shaping-Doc** — das „Was": Requirements (R), Shapes (S), Fit Check, Breadboard.
3. **Slices-Doc / Slice-Plans** — das „Wie": vertikale, baubare Inkremente.

> **Regel:** Änderungen auf einer Ebene müssen in die betroffenen Ebenen oben und unten nachziehen.

## Ablauf

### Phase 1 — Frame erstellen

**Ziel:** Problem und gewünschtes Outcome verstehen.

1. Frage den User:
   - „Was ist der Auslöser?" (Source: Original-Anforderung, Mail, Chat — wörtlich zitieren)
   - „Was ist das eigentliche Problem?"
   - „Wie sieht Erfolg aus?" (Outcome, lösungsneutral)
2. Erstelle oder aktualisiere `docs/shaping/[feature]-frame.md`:
   ```markdown
   ---
   shaping: true
   ---
   # Frame: [Feature-Name]

   ## Source
   > Wörtliches Zitat der Anforderung

   ## Problem
   [Kurze Beschreibung]

   ## Outcome
   [Was muss erreicht sein?]
   ```

### Phase 2 — Requirements sammeln (R)

**Ziel:** 5–9 top-level Requirements ermitteln.

1. Stelle klärende Fragen:
   - Was ist das **Core goal**?
   - Was ist Must-have, was Nice-to-have?
   - Was ist explizit out of scope?
   - Gibt es technische oder organisatorische Constraints?
2. Schreibe sie in das Shaping-Doc:
   ```markdown
   ## Requirements (R)

   | ID | Requirement | Status |
   |---|---|---|
   | R0 | [Core goal] | Core goal |
   | R1 | [Must-have] | Must-have |
   | R2 | [Undecided] | Undecided |
   ```
3. Maximal 9 Top-Level-Rs. Bei mehr: gruppieren (R3.1, R3.2...).

### Phase 3 — Shapes skizzieren (S)

**Ziel:** 2–4 sich gegenseitig ausschließende Lösungsansätze entwerfen.

1. Mache Vorschläge für Shapes A, B, C...
2. Für jeden Shape notiere:
   - Titel (kurz, prägnant).
   - Mechanismen ( konkrete Teile, z. B. „B1: API-Endpoint mit Pydantic-Schema").
   - Was wird gebaut/geändert?
3. Markiere unklare Mechanismen mit ⚠️ (Flagged Unknown).

```markdown
## Shapes

### A: [Titel]

| Part | Mechanism | Flag |
|---|---|---|
| A1 | ... | |
| A2 | ... | ⚠️ |

### B: [Titel]
...
```

### Phase 4 — Fit Check durchführen

**Ziel:** Shapes gegen Requirements prüfen.

1. Baue eine binäre Matrix:
   ```markdown
   ## Fit Check

   | Req | Requirement | Status | A | B | C |
   |---|---|---|---|---|---|
   | R0 | ... | Core goal | ✅ | ✅ | ✅ |
   | R1 | ... | Must-have | ✅ | ❌ | ✅ |
   ```
2. Trage nur ✅ oder ❌ ein.
3. Erkläre Fehler kurz in einem **Notes**-Block.
4. Wenn ein Shape alle Checks besteht, aber „komisch" wirkt → es fehlt eine Requirement. Füge sie hinzu und wiederhole.

### Phase 5 — Shape auswählen und detaillieren

**Ziel:** Einen Shape auswählen und in konkrete UI-/Non-UI-Affordances und Wiring zerlegen.

1. Lasse den User einen Shape wählen.
2. Prüfe: Hat der ausgewählte Shape noch ⚠️-Flags?
   - Ja → Starte einen **Spike** (`spike-[thema].md`), um die Unklarheit zu klären.
   - Nein → Weiter mit Detailing.
3. Nutze `/breadboarding` oder erstelle manuell:
   - **UI Affordances:** Was sieht der User?
   - **Non-UI Affordances:** Handler, Services, Datenmodelle.
   - **Wiring:** Wie sind sie verbunden?

### Phase 6 — Slicing

**Ziel:** Den Shape in vertikale, demo-fähige Inkremente zerlegen.

1. Identifiziere 2–5 vertikale Slices.
2. Jeder Slice muss ein **sichtbares Ergebnis** liefern (keine reine Datenbank- oder Infrastruktur-Schicht).
3. Erstelle `docs/shaping/[feature]-slices.md`:
   ```markdown
   ---
   shaping: true
   ---
   # Slices: [Feature-Name]

   | Slice | Ziel | Demo | Abhängigkeiten |
   |---|---|---|---|
   | V1 | ... | ... | ... |
   | V2 | ... | ... | ... |
   ```
4. Erstelle für jeden Slice einen Plan: `docs/shaping/V1-plan.md`, `V2-plan.md`, ...

## Wichtige Regeln

- **R sagt WAS nötig ist, S sagt WIE es gebaut wird.** Keine Tautologien.
- **Fit Check ist binär:** nur ✅ oder ❌.
- **⚠️ = Unklarheit:** ein Shape mit Flags darf noch nicht ausgewählt werden.
- **Änderungen kaskadieren:** Frame → Shaping → Slices immer synchron halten.
- **Spikes in eigene Dateien:** `spike-[thema].md` — sie untersuchen, sie entscheiden nicht.
- **Mensch entscheidet:** Der User wählt Shape, Slice-Reihenfolge und Out-of-Scope.

## Nicht tun

- Requirements oder Shapes allein ausfüllen.
- Fit Checks mit ⚠️ oder anderen Symbolen als ✅/❌ versehen.
- Horizontale Schichten als Slices verkaufen.
- Aus einem Shape mit offenen Unklarheiten direkt implementieren.

---
*Begleit-Skills: `blueprint-spec`, `citypaul-planning`, `mp-codebase-design`, `breadboarding`.*
*Toolkit-Version: v1.5.1 · Stand: 2026-06-21*

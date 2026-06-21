# Skills — Abteilung Architekten

> **Wer:** Lucas · Johannes — verantworten API-/Datenmodell-Naht, Architekturentscheidungen,
> technische Unterstützung der aktiven Entwickler. Übergeordneter Plan: `../Skill-Plan.md`.
> Geteiltes Fundament: `../gemeinsam/Skills.md`.
> Schwerpunkt-Codes: **OP** · **SR** · **CR** · **WG** · **VO** (Legende in `../Skill-Plan.md §1`).

## 1. Auftrag dieser Abteilung (Kontext für die Skill-Wahl)

Architekten definieren den **Contract** (API + Datenmodell), halten die Naht zu G1/G3 frei
und treffen begründete Technologie-/Strukturentscheidungen. Ihre Arbeit liegt **vor und neben**
der reinen Implementierung: Anforderungen schärfen, Spezifikation aufschreiben, Slices planen,
Module designen — damit die Backend-Devs gegen einen eingefrorenen Vertrag bauen können.
**DoD:** Entscheidung dokumentiert (Entscheidungslogbuch), Contract abgestimmt, Reviewerin
versteht die Naht.

## 2. Skill-Tabelle (zusätzlich zu `../gemeinsam/Skills.md`)

| Skill | Usecase (konkret im Projekt) | Schwerpunkt | WP / Auslöser |
|---|---|---|---|
| `uni:spec-driven-dev` | Feature-Anfrage in strukturierte Doku vor dem Codieren verwandeln (`requirements.md` → `design.md` → `tasks.md`) | **OP/WG** | WP1/WP2 |
| `uni:pmai-shaping` | Gemeinsam mit dem User Problemdefinition (R) und Lösungsoptionen (S) iterieren | **VO/WG** | WP1/WP2 |
| `uni:blueprint-spec` | `SPEC.md` anlegen/ändern — alleiniger Mutator der Projektspezifikation; erwartet `FORMAT.md` | **OP** | WP2 |
| `uni:citypaul-planning` | Arbeit in vertikale Slices planen (PR-große, beobachtbare Einheiten) | **OP/WG** | WP2 |
| `uni:mp-codebase-design` | Deep modules designen — kleine Interfaces, versteckte Komplexheit, saubere Seams | **VO/OP** | WP2/WP3 |
| `uni:blueprint-build` | Gegen `SPEC.md` implementieren (plan → execute); bei Fail automatisch `blueprint-backprop` | **OP** | WP3 |
| `uni:blueprint-backprop` | Bug/Test-Fail → `SPEC.md` protokollieren (`§B` + ggf. neue `§V`-Invariante) | **SR/WG** | bei Bug / Test-Fail |

> **Einstiegs-Set (Pflicht, Tag 1) — bewusst schlank:**
> `uni:start` (Start) · `uni:spec-driven-dev` / `uni:blueprint-spec` (Spezifikation) ·
> `uni:citypaul-planning` (Slices) · `uni:mp-codebase-design` (Module). Am Ende immer `save-session`.

## 3. Standard-Ablauf

1. **WP0 Start:** `uni:start` lädt Kontext (`erinnerung/stand.md`, Regeln, Git-Status).
2. **WP1 Verständnis / Shaping:** Mit dem Team Anforderungen klären — `pmai-shaping`, `grill-me`.
3. **WP2 Spezifikation & Planung:** `spec-driven-dev` / `blueprint-spec` für die Spec,
   `citypaul-planning` für vertikale Slices, `mp-codebase-design` für Module/Seams.
4. **WP3 Begleitung:** Architekt unterstützt Dev bei Schnittstellen-Fragen; `blueprint-build`
   kann für kleine Proof-of-Slices genutzt werden.
5. **WP5/WP6 Review:** Architekt steht für Naht-/Contract-Fragen bereit; `blueprint-backprop`
   wenn ein Bug eine Invariante in der Spec offenbart.
6. **WP8 Ende:** `save-session`; Entscheidungen ins **Entscheidungslogbuch**.

## 4. Grenzen / Hinweise

- **Use-Case-Fakten** nie aus dem Gedächtnis — immer aus `Alarmsystem-Dev` lesen (`CLAUDE.md §2`).
- **Schwellenwerte/Bewertungslogik** ausschließlich aus `Schwellenwerte.md` — Architekt definiert
  die Naht, nicht die Fachlogik selbst.
- **Push/PR/Merge/destruktive Git-Aktionen** nur nach **expliziter Genehmigung** durch Lucas.

---
*Toolkit-Version: v1.5.1 · Pflege: Lucas (Systemarchitekt) · Übergeordnet: `../Skill-Plan.md`.*

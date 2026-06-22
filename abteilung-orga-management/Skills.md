# Skills — Abteilung Orga-Management

> **Wer:** LucasL (Orga-Manager) — führt Team-Organisation, Koordination zwischen den Abteilungen und
> die **Doku-Gruppe** (Reisi · Ilchyshyn). Verantwortet Sichtbarkeit, Continuity, Onboarding und
> Eskalationsmanagement. Übergeordneter Plan: `../Skill-Plan.md`. Geteiltes Fundament: `../gemeinsam/Skills.md`.
> Schwerpunkt-Codes: **OP** · **SR** · **CR** · **WG** · **VO** (Legende in `../Skill-Plan.md §1`).

## 1. Auftrag dieser Abteilung (Kontext für die Skill-Wahl)

Orga-Management schließt die Lücke zwischen den **technischen WP-Skills** und der **menschlichen
Koordination**. Diese Abteilung sorgt dafür, dass das Team trotz Heterogenität, Personenwechseln und
3-Wochen-Zeitdruck zusammenbleibt. Sie arbeitet **quer zu allen Abteilungen**, greift selten in Code ein,
sondern hält den **Überblick, die Prozesse und die Dokumentation**.

**DoD:** Teamstatus ist sichtbar, Blocker sind eskaliert, neue Mitglieder sind eingebunden, Doku ist
vollständig und konsistent, Merge- und Release-Aktionen sind koordiniert.

## 2. Skill-Tabelle (zusätzlich zu `../gemeinsam/Skills.md`)

| Skill | Usecase (konkret im Projekt) | Schwerpunkt | WP / Auslöser |
|---|---|---|---|
| `uni:standup-moderator` | Tägliches Standup strukturiert führen und als Protokoll ins Journal schreiben | **OP/WG** | Täglich / WP0 |
| `uni:fortschritts-board` | Projektstatus sichtbar machen: offene Tasks, laufende PRs, Review-Backlog, Blocker | **OP/WG** | Täglich / vor Standup |
| `uni:dev-reviewer-koordinator` | Übergabe Backend-Dev → Reviewer/Test steuern: PR-Zuweisung, Review-Backlog, Rückfragen | **OP/WG** | PR erstellt / Review hängt |
| `uni:onboarding-orchestrator` | Neues Teammitglied Schritt für Schritt in Stack, Rollen und ersten Task einführen | **VO/OP** | Neuzugang |
| `uni:roster-tracker` | Team-Roster pflegen: Wer ist in welcher Abteilung, Verfügbarkeit, Buddy, Kontakt | **CR/WG** | Personalwechsel / wöchentlich |
| `uni:doku-qualitaets-review` | Nicht-Code-Doku auf Vollständigkeit, Aktualität und Verständlichkeit prüfen (Doku-Gruppe) | **SR/OP** | Vor Release / viertelwöchentlich |
| `uni:konventions-healthcheck` | Team-OS-Conventions lebendig prüfen (WP-Gates, Naming, Branch-Schutz, No-Main-Push) | **CR/SR** | Wöchentlich / vor Meilenstein |
| `uni:blocker-escalation` | Blocker und Risiken erfassen, priorisieren und Eskalationspfad auslösen | **WG/OP** | Blocker > 24h / kritischer Pfad |
| `uni:meilenstein-tracker` | 3-Wochen-Plan und Meilensteine tracken (Ampel + nächste Aktionen) | **OP/WG** | Wochenstart / nach Standup |
| `uni:release-merge-koordinator` | Koordiniertes Mergen auf `main` planen (Reihenfolge, Risiken, Tests vor/nach Merge) | **OP/WG** | Mehrere PRs bereit / Release |

> **Einstiegs-Set (Pflicht, Tag 1) — bewusst schlank:**
> `uni:start` (Start) · `uni:standup-moderator` (Tagesrhythmus) · `uni:fortschritts-board` (Sichtbarkeit) ·
> `uni:dev-reviewer-koordinator` (Abteilungsübergabe) · `save-session` (Ende).
> Alles Weitere ist **situativ** — je nach Projektphase und Teamgröße.

## 3. Standard-Ablauf einer Orga-Woche

1. **WP0 Start:** `uni:start` lädt Kontext (`erinnerung/stand.md`, Regeln, Git-Status).
2. **Täglich:** `uni:standup-moderator` führt das Standup und schreibt ein Protokoll ins Journal.
3. **Täglich / vor Standup:** `uni:fortschritts-board` aktualisiert den Projektstatus.
4. **Bei PR-Übergabe:** `uni:dev-reviewer-koordinator` steuert Dev → Reviewer.
5. **Bei Blockern > 24h:** `uni:blocker-escalation` erfasst und eskaliert.
6. **Wochenstart:** `uni:meilenstein-tracker` prüft Meilensteine.
7. **Wöchentlich:** `uni:konventions-healthcheck` prüft Lebendigkeit der Conventions.
8. **Bei Neuzugang:** `uni:onboarding-orchestrator` führt das neue Mitglied ein.
9. **Bei Personalwechsel:** `uni:roster-tracker` aktualisiert das Roster.
10. **Vor Release / viertelwöchentlich:** `uni:doku-qualitaets-review` prüft die Doku-Qualität.
11. **Vor koordiniertem Merge:** `uni:release-merge-koordinator` plant Reihenfolge und Risiken.
12. **WP8 Ende:** `save-session`; wichtige Orga-Entscheidungen ins **Entscheidungslogbuch**.

## 4. Grenzen / Hinweise

- **Kein Code-Review, kein Architektur-Decision:** Orga-Management **koordiniert** technische Arbeit,
  ersetzt aber nicht `code-review`, `plan`, `api-design` oder `spec-driven-dev`.
- **Use-Case-Fakten** nie aus dem Gedächtnis — immer aus `Alarmsystem-Dev` lesen (`CLAUDE.md §2`).
- **Push/PR/Merge/destruktive Git-Aktionen** nur nach **expliziter Genehmigung** durch Lucas.
- **Human-in-the-loop:** Der Orga-Manager verantwortet die Protokolle, Zuweisungen und Eskalationen —
  der Agent liefert Entwurf und Struktur, der Mensch prüft und kommuniziert.
- **Doku-Gruppe:** Die Doku-Gruppe nutzt `uni:doku-qualitaets-review` und `uni:coupling-map` als
  Hauptwerkzeuge; sie arbeitet eng mit dem Orga-Manager zusammen.

---
*Toolkit-Version: v1.6.0 · Pflege: Lucas (Systemarchitekt) · Übergeordnet: `../Skill-Plan.md`, `../gemeinsam/Skills.md`.*

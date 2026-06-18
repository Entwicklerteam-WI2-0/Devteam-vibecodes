---
name: checkpoint
description: Zwischenstand nach erfolgreicher Verifikation als Git-Checkpoint sichern (G2) — kleiner, beschriebener Commit auf dem Feature-Branch nach grünem Test/Build. Nutze diesen Skill nach jedem verifizierten Fortschritt.
origin: ECC (checkpoint), neu geschrieben für G2 — Git + Use-Case
---

# checkpoint — verifizierten Stand sichern (G2)

Du sicherst einen **grünen** Zwischenstand als Checkpoint-Commit, damit Fortschritt nicht verloren geht
und der Verlauf nachvollziehbar bleibt. Antworte auf **Deutsch**. Du übernimmst die Git-Mechanik.

## Wann aktivieren
Nach einem **verifizierten** Schritt (Test grün, Build grün) — typisch in der TDD-Schleife (WP4/WP5).

## Ablauf
1. **Feature-Branch sicher:** nicht auf `main`. Falls nötig vorher `git checkout -b feat/<task>`.
2. **Nur grün committen:** Checkpoint nur, wenn der relevante Test-/Build-Stand wirklich grün ist
   (Beleg: Command-Output).
3. **Sprechende Message:** beschreibt Stage + Beleg, konventionell:
   - `test: reproducer für <…>` (RED validiert)
   - `fix: <…>` (GREEN validiert) · optional `refactor: <…>`
4. **Verlauf erhalten:** Checkpoints nicht squashen/umschreiben, solange die Task läuft.

## ⛔ Genehmigungspflicht
**Lokale** Checkpoint-Commits sind ok. **Push/PR erst nach Freigabe durch Lucas**, kein direkter `main`-Push.

## Nicht tun
- Roten Stand committen. Auf `main` committen. Ohne Beleg „funktioniert" behaupten.

---
*TDD-Zyklus: `tdd-workflow`. PR: `pr`. Regeln/Genehmigung: `claude-sync.md` §4/§7.*

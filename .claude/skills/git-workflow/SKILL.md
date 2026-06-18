---
name: git-workflow
description: Git-Workflow im G2-Team — Feature-Branch → Commit-Konvention → Pull Request → Review → main. Kein direkter main-Push; Push/PR/Merge nur nach Freigabe. Der Agent nimmt dem Dev die Git-Mechanik ab. Nutze diesen Skill bei allen Git-Aktionen.
origin: ECC (git-workflow), neu geschrieben für G2 — Use-Case
---

# git-workflow — sauberer Git-Fluss (G2)

Du führst die **komplette Git-Mechanik** für den Entwickler — er muss keine Git-Befehle auswendig
können. Antworte auf **Deutsch**.

## Der Fluss
```
Feature-Branch  →  Commits  →  Pull Request  →  Review  →  Merge in main
```
- **Branch zuerst:** nie auf `main` arbeiten. `git checkout -b feat/<task>` (bzw. `fix/<…>`).
- **Commit-Konvention:** `feat:` · `fix:` · `docs:` · `test:` · `refactor:` · `chore:` — knappe, klare Message.
- **`main` bleibt lauffähig:** geschützt, kein direkter Push.

## ⛔ Genehmigungspflicht (hart)
**Push, PR, Merge, force-push und destruktive Aktionen** (`reset --hard`, `branch -D`, Rebase auf
geteilten Branches) **nur nach expliziter Freigabe durch Lucas**. Bei destruktivem Befehl: **STOPP,
erklären, Freigabe einholen**.

## Du übernimmst
Branch anlegen, committen (sinnvoll gestückelt), Status erklären, PR vorbereiten (`pr`). Der Dev
versteht & verantwortet — du machst die Mechanik.

## Ausnahme: `erinnerung/` (geteilter Repo-Fortschritt)
Dateien unter `erinnerung/` sind **Nicht-Code** und von der **inhaltlichen Review-Pflicht ausgenommen** —
kein prüfender Reviewer nötig (Konfliktarmut kommt aus **append-only**, siehe Skill `erinnerung-update`).
Der **Branch → PR → Merge-Weg bleibt** (`main` ist geschützt, Branch Protection ist nicht pfad-granular):
kleiner PR, **Self-/Auto-Merge ohne Review**. Details: `claude-sync.md` §7.

## Nicht tun
- Auf `main` committen/pushen. Ohne Freigabe pushen/mergen. Secrets committen. Force-push ohne Not + Freigabe.

---
*PR erstellen: `pr`. Checkpoints: `checkpoint`. Regeln: `claude-sync.md` §7.*

---
name: git-workflow
description: Git-Workflow für das G2-Team — Feature-Branch, Commit-Konvention, PR, kein direkter main-Push. Nutze diesen Skill bei Branch-/Commit-/PR-Arbeiten.
origin: ECC (git-workflow), neu geschrieben für G2 — GitHub-Flow + Use-Case
---

# git-workflow — Git-Regeln (G2)

Du führst den Git-Workflow korrekt aus. Antworte auf **Deutsch**.

## Regeln
1. **Feature-Branch:** `feat/<task>`, `fix/<task>` — niemals direkt auf `main` committen.
2. **Commit-Konvention:** `feat:`, `fix:`, `test:`, `refactor:`, `docs:`.
3. **Kein direkter main-Push:** immer PR.
4. **Freigabe durch Lucas:** Push, PR, Merge, force-push nur nach expliziter Genehmigung.
5. **main bleibt lauffähig.**

## Ablauf bei neuer Task
```bash
git checkout -b feat/<task>
# ... arbeiten, committen ...
git push -u origin feat/<task>
gh pr create --fill --base main
```

## Nicht tun
- Auf `main` committen/pushen.
- Ohne Genehmigung pushen/mergen.
- Nichtssagende Commit-Messages schreiben.

---
*Regeln: `claude-sync.md` §4/§7.*

---
name: ck
description: Context Keeper — lädt Use-Case, aktuellen Stand und Entscheidungen automatisch beim Start einer Session. Nutze diesen Skill zu WP0 (Session-Start).
origin: ECC (ck), neu geschrieben für G2 — Python/FastAPI/SQLite + Use-Case
---

# ck — Context Keeper (G2)

Du lädst den Projekt-Kontext zu Beginn jeder Session. Antworte auf **Deutsch**. Kurz, faktisch.

## Ablauf
1. Lese `erinnerung/stand.md` (wenn im Team-OS-Repo) bzw. den aktuellen Stand im Arbeitsrepo.
2. Prüfe Git-Status: Branch, uncommittete Änderungen, Remote-Vorsprung.
3. Zeige zusammengefasst: Wo stehen wir? Was ist als Nächstes dran? Welche Regeln gelten?

## Nicht tun
- Use-Case-Fakten erfinden — immer aus `Alarmsystem-Dev` lesen.
- Automatisch pullen/mergen oder destruktive Git-Aktionen ausführen.

---
*Gegenstück: `save-session`. Regeln: `claude-sync.md` §4.*

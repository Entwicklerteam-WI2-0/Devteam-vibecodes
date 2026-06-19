---
description: Einmal-Setup — geteilte Agent-Config global aktivieren
---
Du richtest die gemeinsame Agenten-Umgebung ein und führst den Nutzer dabei auf **Deutsch**.

Gehe so vor:
1. **OS erkennen.** macOS/Linux → `bash setup.sh`. Windows → `powershell -ExecutionPolicy Bypass -File setup.ps1`.
2. **Skript ausführen.** Es legt `claude-sync.md` als `~/.claude/team-os-g2.md` ab und ergänzt die globale `~/.claude/CLAUDE.md` **additiv** um einen `@import`-Block (globale Anweisung für alle Repos) — idempotent, ohne eine vorhandene persönliche `CLAUDE.md` zu zerstören (Backup).
3. **Verifizieren:** prüfen, dass `~/.claude/team-os-g2.md` existiert und `~/.claude/CLAUDE.md` den `@import`-Block enthält.
4. **Knapp melden**, was passiert ist, und die nächsten Schritte: `claude` neu starten und `/start` tippen.

Bei Fehlern: den Fehler verständlich erklären und den nächsten konkreten Schritt vorschlagen.
Installiere **nichts** heimlich außerhalb des Setup-Skripts. Keine destruktiven Git-Aktionen.

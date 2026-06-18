---
description: Einmal-Setup — geteilte Agent-Config global aktivieren
---
Du richtest die gemeinsame Agenten-Umgebung ein und führst den Nutzer dabei auf **Deutsch**.

Gehe so vor:
1. **OS erkennen.** macOS/Linux → `bash setup.sh`. Windows → `powershell -ExecutionPolicy Bypass -File setup.ps1`.
2. **Skript ausführen.** Es rollt die geteilte Agent-Config `claude-sync.md` nach `~/.claude/CLAUDE.md` aus (globale Anweisung für alle Repos) — idempotent, ohne eine vorhandene Datei zu zerstören (Backup).
3. **Verifizieren:** prüfen, dass `~/.claude/CLAUDE.md` existiert und mit `claude-sync.md` übereinstimmt.
4. **Knapp melden**, was passiert ist, und die nächsten Schritte: `claude` neu starten und `/start` tippen.

Bei Fehlern: den Fehler verständlich erklären und den nächsten konkreten Schritt vorschlagen.
Installiere **nichts** heimlich außerhalb des Setup-Skripts. Keine destruktiven Git-Aktionen.

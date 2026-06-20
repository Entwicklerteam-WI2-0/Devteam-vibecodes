---
description: Einmal-Setup — geteilte Agent-Config global aktivieren
---
Du richtest die gemeinsame Agenten-Umgebung ein und führst den Nutzer dabei auf **Deutsch**.

Gehe so vor:
1. **OS erkennen.** macOS/Linux → `bash setup.sh`. Windows → `powershell -ExecutionPolicy Bypass -File setup.ps1`.
2. **Skript ausführen.** Verhalten je nach Lage (idempotent, immer mit `.bak`-Backup):
   - **Keine** globale `~/.claude/CLAUDE.md` vorhanden → `claude-sync.md` **wird** die globale `CLAUDE.md` (voll, inline). Kein `team-os-g2.md`, kein Import.
   - **Persönliche** `CLAUDE.md` vorhanden → bleibt erhalten; es wird `~/.claude/team-os-g2.md` angelegt und ein **additiver** `@import`-Block angehängt.
   - Re-Runs aktualisieren nur (Vollkopie in-place, sonst `team-os-g2.md`) — nie doppelt.
3. **Verifizieren:** prüfen, dass `~/.claude/CLAUDE.md` die Team-Anweisung enthält — **entweder direkt** (inline) **oder via** `@import` auf `~/.claude/team-os-g2.md`.
4. **Knapp melden**, was passiert ist, und die nächsten Schritte: `claude` neu starten und `uni:start` tippen.

Bei Fehlern: den Fehler verständlich erklären und den nächsten konkreten Schritt vorschlagen.
Installiere **nichts** heimlich außerhalb des Setup-Skripts. Keine destruktiven Git-Aktionen.

---
description: Team-OS aktualisieren — neuesten Stand holen (git pull) + Setup erneut ausführen
---
Du bringst die gemeinsame Agenten-Umgebung auf den neuesten Stand und führst den Nutzer dabei auf **Deutsch**.

Voraussetzung: im geklonten Ordner `Devteam-vibecodes` sein (sonst zuerst dorthin wechseln).

Gehe so vor:
1. **OS erkennen.** macOS/Linux → `bash update.sh`. Windows → `powershell -ExecutionPolicy Bypass -File update.ps1`.
2. **Skript ausführen.** Es holt den neuesten Stand (`git pull --autostash`) und führt anschließend das Setup erneut aus — frischt `team-os-g2.md`, die 36 Skills und die Commands in `~/.claude/` auf. Das Skript zeigt **Version alt → neu**.
3. **Verifizieren:** prüfen, dass die ausgegebene **neue Version** der erwarteten entspricht und Skills/Commands installiert wurden.
4. **Knapp melden**, von welcher auf welche Version aktualisiert wurde, und darauf hinweisen: **Claude Code neu starten**, damit neue Skills/Commands geladen werden.

Bei lokalen Änderungen/Konflikten beim Pull: den Konflikt verständlich erklären und den nächsten konkreten Schritt vorschlagen — **nichts erzwingen, keine destruktiven Git-Aktionen** ohne Rückfrage.

#!/usr/bin/env bash
# -------------------------------------------------------------
# setup.sh - Einmal-Setup Team-OS (macOS / Linux)
# Aufruf:  bash setup.sh    (oder ./setup.sh nach chmod +x)
# Macht:   geteilte Agent-Config claude-sync.md -> globale ~/.claude/CLAUDE.md
# -------------------------------------------------------------
set -euo pipefail

# Skript-Verzeichnis robust ermitteln; claude-sync.md daneben suchen,
# sonst im aktuellen Verzeichnis.
SCRIPT_DIR="$(cd "$(dirname "$0")" 2>/dev/null && pwd || pwd)"
SOURCE="$SCRIPT_DIR/claude-sync.md"
if [ ! -f "$SOURCE" ] && [ -f "./claude-sync.md" ]; then
  SCRIPT_DIR="$(pwd)"
  SOURCE="$SCRIPT_DIR/claude-sync.md"
fi

if [ ! -f "$SOURCE" ]; then
  echo "FEHLER: claude-sync.md nicht gefunden (gesucht in: $SCRIPT_DIR)." >&2
  echo "Bitte pruefen:" >&2
  echo "  1) Du bist im geklonten Ordner 'Devteam-vibecodes'." >&2
  echo "  2) 'git pull' ausgefuehrt (Datei muss im Repo liegen)." >&2
  echo "  3) Start:  bash setup.sh" >&2
  exit 1
fi

cd "$SCRIPT_DIR"
echo "Team-OS-Setup startet in: $SCRIPT_DIR"

CLAUDE_DIR="$HOME/.claude"
TARGET="$CLAUDE_DIR/CLAUDE.md"

# 1) ~/.claude sicherstellen
mkdir -p "$CLAUDE_DIR"

# 2) Geteilte Agent-Config global aktivieren (claude-sync.md -> ~/.claude/CLAUDE.md)
if [ ! -f "$TARGET" ]; then
  cp "$SOURCE" "$TARGET"
  echo "Globale CLAUDE.md aus claude-sync.md erstellt: $TARGET"
else
  cp "$TARGET" "$TARGET.bak"
  echo "HINWEIS: ~/.claude/CLAUDE.md existiert bereits - wird NICHT ueberschrieben."
  echo "  Backup angelegt: $TARGET.bak"
  echo "  Team-Config uebernehmen/aktualisieren? -> cp \"$SOURCE\" \"$TARGET\""
fi

echo ""
echo "Fertig. Naechste Schritte:"
echo "  1) Ordner in VS Code oeffnen"
echo "  2) 'claude' im integrierten Terminal starten"
echo "  3) Projekt einmal 'vertrauen', dann '/start' tippen"
echo "  4) Fuer die Produktcode-Arbeit zusaetzlich das Arbeitsrepo 'Alarmsystem-Dev' klonen + dessen Setup ausfuehren."

#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────
# setup.sh — Einmal-Setup Team-OS (macOS / Linux)
# Aufruf:  bash setup.sh    (oder ./setup.sh nach chmod +x)
# Macht:   geteilte Agent-Config claude-sync.md -> globale ~/.claude/CLAUDE.md
# ──────────────────────────────────────────────────────────────
set -euo pipefail

cd "$(dirname "$0")"
echo "▶ Team-OS-Setup startet in: $(pwd)"

SOURCE="claude-sync.md"
CLAUDE_DIR="$HOME/.claude"
TARGET="$CLAUDE_DIR/CLAUDE.md"

if [ ! -f "$SOURCE" ]; then
  echo "✗ claude-sync.md nicht gefunden in $(pwd) — falscher Ordner?" >&2
  exit 1
fi

# 1) ~/.claude sicherstellen
mkdir -p "$CLAUDE_DIR"

# 2) Geteilte Agent-Config global aktivieren (claude-sync.md -> ~/.claude/CLAUDE.md)
if [ ! -f "$TARGET" ]; then
  cp "$SOURCE" "$TARGET"
  echo "✓ Globale CLAUDE.md aus claude-sync.md erstellt: $TARGET"
else
  cp "$TARGET" "$TARGET.bak"
  echo "ℹ ~/.claude/CLAUDE.md existiert bereits — wird NICHT überschrieben."
  echo "  Backup angelegt: $TARGET.bak"
  echo "  Team-Config übernehmen/aktualisieren? -> cp \"$SOURCE\" \"$TARGET\""
fi

echo ""
echo "✅ Fertig. Nächste Schritte:"
echo "   1) Ordner in VS Code öffnen"
echo "   2) 'claude' im integrierten Terminal starten"
echo "   3) Projekt einmal 'vertrauen', dann '/start' tippen"
echo "   4) Für die Produktcode-Arbeit zusätzlich das Arbeitsrepo 'Alarmsystem-Dev' klonen + dessen Setup ausführen."

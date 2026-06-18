#!/usr/bin/env bash
# -------------------------------------------------------------
# setup-kimi.sh - Team-Skills fuer Kimi Code CLI installieren
# Aufruf:  bash setup-kimi.sh    (im geklonten 'Devteam-vibecodes'-Ordner)
# Macht:   kopiert .claude/skills/*/SKILL.md -> ~/.kimi/skills/
#          Kimi Code liest diesen Pfad nativ (gleiches SKILL.md-Format).
# -------------------------------------------------------------
set -euo pipefail

# Skript-/Repo-Verzeichnis robust ermitteln
SCRIPT_DIR="$(cd "$(dirname "$0")" 2>/dev/null && pwd || pwd)"
SRC="$SCRIPT_DIR/.claude/skills"
if [ ! -d "$SRC" ] && [ -d "./.claude/skills" ]; then
  SCRIPT_DIR="$(pwd)"; SRC="$SCRIPT_DIR/.claude/skills"
fi

if [ ! -d "$SRC" ]; then
  echo "FEHLER: .claude/skills/ nicht gefunden (gesucht in: $SCRIPT_DIR)." >&2
  echo "Bitte im geklonten Ordner 'Devteam-vibecodes' ausfuehren (ggf. vorher 'git pull')." >&2
  exit 1
fi

DEST="$HOME/.kimi-code/skills"
mkdir -p "$DEST"
echo "Installiere Team-Skills fuer Kimi Code -> $DEST"

count=0
for d in "$SRC"/*/; do
  [ -d "$d" ] || continue
  [ -f "${d}SKILL.md" ] || continue
  name="$(basename "$d")"
  mkdir -p "$DEST/$name"
  cp "${d}SKILL.md" "$DEST/$name/SKILL.md"
  echo "  + $name"
  count=$((count + 1))
done

echo ""
echo "Fertig: $count Skills installiert in $DEST"
echo "Kimi Code findet sie automatisch (Brand-Pfad ~/.kimi-code/skills/)."
echo "Aufruf im Chat z.B.:  /skill:tdd-workflow"
echo ""
echo "Hinweis: Globale Anweisung (claude-sync.md), Hooks und die Slash-Commands"
echo "         /start und /setup nutzen in Kimi ein anderes Format und folgen"
echo "         als spezialisierte Iteration (siehe erinnerung/stand.md)."

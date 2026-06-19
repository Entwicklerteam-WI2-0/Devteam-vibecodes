#!/usr/bin/env bash
# -------------------------------------------------------------
# setup.sh - Einmal-Setup Team-OS (macOS / Linux)
# Aufruf:  bash setup.sh    (oder ./setup.sh nach chmod +x)
# Macht:   - claude-sync.md  -> eigene Datei ~/.claude/team-os-g2.md
#          - ADDITIVER @import-Block in ~/.claude/CLAUDE.md (nie ueberschreiben)
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
TEAM_FILE="$CLAUDE_DIR/team-os-g2.md"
IMPORT="@~/.claude/team-os-g2.md"
BEGIN="<!-- TEAM-OS-G2 BEGIN - verwaltet von setup, nicht editieren -->"
END="<!-- TEAM-OS-G2 END -->"

# 1) ~/.claude sicherstellen
mkdir -p "$CLAUDE_DIR"

# 2) Team-Anweisung als EIGENE Datei (eine Quelle; bei jedem Lauf aktualisiert)
cp "$SOURCE" "$TEAM_FILE"
echo "Team-Anweisung aktualisiert: $TEAM_FILE"

# 3) Import in die globale CLAUDE.md - ADDITIV, nie ueberschreiben (idempotent)
if [ ! -f "$TARGET" ]; then
  { printf '%s\n' "$BEGIN"; printf '%s\n' "$IMPORT"; printf '%s\n' "$END"; } > "$TARGET"
  echo "Globale CLAUDE.md angelegt mit Team-Import: $TARGET"
elif grep -qF "$IMPORT" "$TARGET"; then
  echo "Team-Import bereits vorhanden in CLAUDE.md - nichts zu tun."
elif grep -q "Globale Agenten-Anweisung (Team-OS G2)" "$TARGET"; then
  # Frueherer Stand: claude-sync.md wurde direkt hineinkopiert -> auf Import umstellen.
  cp "$TARGET" "$TARGET.bak"
  { printf '%s\n' "$BEGIN"; printf '%s\n' "$IMPORT"; printf '%s\n' "$END"; } > "$TARGET"
  echo "Alte Direktkopie erkannt -> auf Import umgestellt (Backup: $TARGET.bak)."
else
  # Persoenliche CLAUDE.md vorhanden -> nur den Block anhaengen, Inhalt bleibt.
  cp "$TARGET" "$TARGET.bak"
  { printf '\n'; printf '%s\n' "$BEGIN"; printf '%s\n' "$IMPORT"; printf '%s\n' "$END"; } >> "$TARGET"
  echo "Persoenliche CLAUDE.md beibehalten; Team-Import angehaengt (Backup: $TARGET.bak)."
fi

# 4) Skills GLOBAL installieren -> in JEDEM Repo verfuegbar (auch Alarmsystem-Dev),
#    nicht nur wenn man in diesem Tooling-Repo sitzt.
SKILLS_SRC="$SCRIPT_DIR/.claude/skills"
SKILLS_DST="$CLAUDE_DIR/skills"
if [ -d "$SKILLS_SRC" ]; then
  scount=0
  for d in "$SKILLS_SRC"/*/; do
    [ -d "$d" ] || continue
    [ -f "${d}SKILL.md" ] || continue
    name="$(basename "$d")"
    mkdir -p "$SKILLS_DST/$name"
    cp "${d}SKILL.md" "$SKILLS_DST/$name/SKILL.md"
    scount=$((scount + 1))
  done
  echo "Skills global installiert: $scount -> $SKILLS_DST"
fi

# 5) Commands GLOBAL installieren (/start, /setup ueberall verfuegbar)
CMD_SRC="$SCRIPT_DIR/.claude/commands"
CMD_DST="$CLAUDE_DIR/commands"
if [ -d "$CMD_SRC" ]; then
  mkdir -p "$CMD_DST"
  ccount=0
  for f in "$CMD_SRC"/*.md; do
    [ -f "$f" ] || continue
    cp "$f" "$CMD_DST/$(basename "$f")"
    ccount=$((ccount + 1))
  done
  echo "Commands global installiert: $ccount -> $CMD_DST"
fi

echo ""
echo "Fertig. Naechste Schritte:"
echo "  1) Ordner in VS Code oeffnen"
echo "  2) 'claude' im integrierten Terminal starten"
echo "  3) Projekt einmal 'vertrauen', dann '/start' tippen"
echo "  4) Fuer die Produktcode-Arbeit zusaetzlich das Arbeitsrepo 'Alarmsystem-Dev' klonen + dessen Setup ausfuehren."

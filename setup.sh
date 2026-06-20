#!/usr/bin/env bash
# -------------------------------------------------------------
# setup.sh - Einmal-Setup Team-OS (macOS / Linux)
# Aufruf:  bash setup.sh    (oder ./setup.sh nach chmod +x)
# Macht (globale ~/.claude/CLAUDE.md, 4 Faelle):
#   - fehlt          -> claude-sync.md WIRD die globale CLAUDE.md (voll, inline)
#   - hat Import     -> nur ~/.claude/team-os-g2.md auffrischen
#   - Team-Vollkopie -> CLAUDE.md in-place aktualisieren (Backup)
#   - persoenlich    -> team-os-g2.md anlegen + additiver @import-Block (Backup)
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

# 2) Globale CLAUDE.md gemaess 4 Faellen behandeln (idempotent):
#    Fall 1  fehlt         -> claude-sync.md WIRD die CLAUDE.md (voll, inline)
#    Fall 2  hat Import     -> nur team-os-g2.md auffrischen (bereits erweitert)
#    Fall 3  Team-Vollkopie -> CLAUDE.md in-place aktualisieren (inline-Mitglied, Re-Run)
#    Fall 4  persoenlich    -> team-os-g2.md anlegen + Import-Block anhaengen
HEADING="Globale Agenten-Anweisung (Team-OS G2)"

if [ ! -f "$TARGET" ]; then
  # Fall 1: keine globale CLAUDE.md -> claude-sync.md wird sie (voll, inline)
  cp "$SOURCE" "$TARGET"
  echo "Keine globale CLAUDE.md gefunden -> claude-sync.md als globale CLAUDE.md gesetzt: $TARGET"
elif grep -qF "$IMPORT" "$TARGET"; then
  # Fall 2: bereits erweitertes Mitglied -> nur Team-Anweisung auffrischen
  cp "$SOURCE" "$TEAM_FILE"
  echo "Import bereits vorhanden -> team-os-g2.md aufgefrischt (CLAUDE.md unangetastet): $TEAM_FILE"
elif grep -qF "$HEADING" "$TARGET"; then
  # Fall 3: CLAUDE.md IST eine Team-OS-Vollkopie -> in-place aktualisieren
  cp "$TARGET" "$TARGET.bak"
  cp "$SOURCE" "$TARGET"
  echo "Team-OS-Vollkopie erkannt -> CLAUDE.md in-place aktualisiert (Backup: $TARGET.bak)."
else
  # Fall 4: persoenliche CLAUDE.md -> behalten; team-os-g2.md + Import anhaengen
  cp "$SOURCE" "$TEAM_FILE"
  cp "$TARGET" "$TARGET.bak"
  { printf '\n'; printf '%s\n' "$BEGIN"; printf '%s\n' "$IMPORT"; printf '%s\n' "$END"; } >> "$TARGET"
  echo "Persoenliche CLAUDE.md beibehalten; team-os-g2.md angelegt + Import angehaengt (Backup: $TARGET.bak)."
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

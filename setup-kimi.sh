#!/usr/bin/env bash
# -------------------------------------------------------------
# setup-kimi.sh - Team-OS fuer Kimi Code CLI einrichten (macOS / Linux)
# Aufruf:  bash setup-kimi.sh    (im geklonten 'Devteam-vibecodes'-Ordner)
# Macht:
#   1) .claude/skills/*/SKILL.md -> $KIMI_CODE_HOME/skills/<name>/SKILL.md   (nativ, /skill:<name>)
#   2) .claude/commands/*.md     -> $KIMI_CODE_HOME/skills/<name>/SKILL.md   (Kimi hat KEIN
#                                   Command-Verzeichnis -> Commands werden Skills: /skill:start)
#   3) claude-sync.md            -> $KIMI_CODE_HOME/AGENTS.md  (fehlt -> WIRD AGENTS.md; sonst additiv)
#   Kimi liest ~/.kimi-code/ nativ (gleiches SKILL.md-Format; KIMI_CODE_HOME wird respektiert).
# -------------------------------------------------------------
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" 2>/dev/null && pwd || pwd)"
SRC="$SCRIPT_DIR/.claude/skills"
CMD_SRC="$SCRIPT_DIR/.claude/commands"
SYNC="$SCRIPT_DIR/claude-sync.md"
if [ ! -d "$SRC" ] && [ -d "./.claude/skills" ]; then
  SCRIPT_DIR="$(pwd)"; SRC="$SCRIPT_DIR/.claude/skills"; CMD_SRC="$SCRIPT_DIR/.claude/commands"; SYNC="$SCRIPT_DIR/claude-sync.md"
fi

if [ ! -d "$SRC" ] || [ ! -f "$SYNC" ]; then
  echo "FEHLER: .claude/skills/ oder claude-sync.md nicht gefunden (gesucht in: $SCRIPT_DIR)." >&2
  echo "Bitte im geklonten Ordner 'Devteam-vibecodes' ausfuehren (ggf. vorher 'git pull')." >&2
  exit 1
fi

KIMI_HOME="${KIMI_CODE_HOME:-$HOME/.kimi-code}"
KSKILLS="$KIMI_HOME/skills"
KAGENTS="$KIMI_HOME/AGENTS.md"
mkdir -p "$KSKILLS"
echo "Team-OS-Setup fuer Kimi Code -> $KIMI_HOME"

# Mirror statt additiv: zuvor vom Team installierte Skills entfernen, die es in der Quelle NICHT MEHR gibt.
# Manifest-gestuetzt -> persoenliche Kimi-Skills des Users bleiben unangetastet.
KMANIFEST="$KSKILLS/.team-os-installed"
TEAM_SET="$( { for d in "$SRC"/*/; do [ -f "${d}SKILL.md" ] && basename "$d"; done; for f in "$CMD_SRC"/*.md; do [ -f "$f" ] && basename "$f" .md; done; } | sort -u )"
if [ -f "$KMANIFEST" ]; then
  while IFS= read -r old; do
    [ -n "$old" ] || continue
    printf '%s\n' "$TEAM_SET" | grep -qxF "$old" || { rm -rf "$KSKILLS/$old"; echo "  entfernt (nicht mehr in der Quelle): $old"; }
  done < "$KMANIFEST"
fi

# 1) Skills nativ
count=0
for d in "$SRC"/*/; do
  [ -d "$d" ] || continue
  [ -f "${d}SKILL.md" ] || continue
  name="$(basename "$d")"
  mkdir -p "$KSKILLS/$name"
  cp "${d}SKILL.md" "$KSKILLS/$name/SKILL.md"
  count=$((count + 1))
done
echo "[1/3] $count Skills installiert -> $KSKILLS  (Aufruf: /skill:<name>)"

# 2) Commands als Skills (Kimi hat kein Command-Verzeichnis)
get_desc() { awk '/^description:/{sub(/^description:[[:space:]]*/,""); gsub(/"/,"'"'"'"); print; exit}' "$1"; }
strip_fm() { awk 'NR==1 && $0=="---"{f=1;next} f==1 && $0=="---"{f=2;next} f!=1{print}' "$1"; }
ccount=0
if [ -d "$CMD_SRC" ]; then
  for f in "$CMD_SRC"/*.md; do
    [ -f "$f" ] || continue
    base="$(basename "$f" .md)"
    desc="$(get_desc "$f")"; [ -n "$desc" ] || desc="Team-Command $base"
    mkdir -p "$KSKILLS/$base"
    { printf '%s\n' '---'; printf 'name: %s\n' "$base"; printf 'description: "%s"\n' "$desc"; printf '%s\n' '---'; printf '%s\n' ''; strip_fm "$f"; } > "$KSKILLS/$base/SKILL.md"
    ccount=$((ccount + 1))
  done
fi
printf '%s\n' "$TEAM_SET" > "$KMANIFEST"
echo "[2/3] $ccount Commands als Skills installiert  (Aufruf: /skill:start, /skill:setup)"

# 3) Globale Anweisung -> AGENTS.md, 4 Faelle (idempotent, Kimi inline; kein @import):
#    Fall 1  fehlt         -> claude-sync.md WIRD die AGENTS.md (voll, inline)
#    Fall 2  hat Team-Block -> Block auffrischen (bereits erweitert)
#    Fall 3  Team-Vollkopie -> AGENTS.md in-place aktualisieren (Backup)
#    Fall 4  persoenlich    -> Team-Block anhaengen (Backup)
KB="<!-- TEAM-OS-G2 BEGIN - verwaltet von setup-kimi, nicht editieren -->"
KE="<!-- TEAM-OS-G2 END -->"
HEADING="Globale Agenten-Anweisung (Team-OS G2)"
if [ ! -f "$KAGENTS" ]; then
  # Fall 1: keine AGENTS.md -> claude-sync.md wird sie (voll, inline)
  cp "$SYNC" "$KAGENTS"
  echo "[3/3] Keine AGENTS.md gefunden -> claude-sync.md als AGENTS.md gesetzt: $KAGENTS"
elif grep -qF "$KB" "$KAGENTS"; then
  # Fall 2: bereits erweitert -> Team-Block auffrischen
  awk -v b="$KB" -v e="$KE" '$0==b{i=1;next} $0==e{i=0;next} !i{print}' "$KAGENTS" > "$KAGENTS.tmp"
  { cat "$KAGENTS.tmp"; printf '%s\n' "$KB"; cat "$SYNC"; printf '\n%s\n' "$KE"; } > "$KAGENTS"
  rm -f "$KAGENTS.tmp"
  echo "[3/3] Team-Block in AGENTS.md aufgefrischt: $KAGENTS"
elif grep -qF "$HEADING" "$KAGENTS"; then
  # Fall 3: AGENTS.md IST eine Team-OS-Vollkopie -> in-place aktualisieren
  cp "$KAGENTS" "$KAGENTS.bak"
  cp "$SYNC" "$KAGENTS"
  echo "[3/3] Team-OS-Vollkopie erkannt -> AGENTS.md in-place aktualisiert (Backup: $KAGENTS.bak)."
else
  # Fall 4: persoenliche AGENTS.md -> behalten, Team-Block anhaengen
  cp "$KAGENTS" "$KAGENTS.bak"
  { cat "$KAGENTS"; printf '\n'; printf '%s\n' "$KB"; cat "$SYNC"; printf '\n%s\n' "$KE"; } > "$KAGENTS.tmp"
  mv "$KAGENTS.tmp" "$KAGENTS"
  echo "[3/3] Persoenliche AGENTS.md beibehalten; Team-Block angehaengt (Backup: $KAGENTS.bak)."
fi

echo ""
echo "Fertig. Kimi findet Skills + Anweisung automatisch (KIMI_CODE_HOME)."
echo "Aufruf z.B.:  /skill:tdd-workflow   -   Session-Start:  /skill:start"

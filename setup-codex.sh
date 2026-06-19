#!/usr/bin/env bash
# -------------------------------------------------------------
# setup-codex.sh - Team-OS fuer OpenAI Codex CLI einrichten (macOS / Linux)
# Aufruf:  bash setup-codex.sh    (im geklonten 'Devteam-vibecodes'-Ordner)
# Macht:
#   1) claude-sync.md            -> $CODEX_HOME/AGENTS.md   (globaler System-Prompt)
#   2) .claude/skills/*/SKILL.md -> $CODEX_HOME/skills/<name>/SKILL.md  (nativ, Auto-Trigger)
#   3) je Skill ein Command      -> $CODEX_HOME/prompts/<name>.md       (explizit per /<name>)
#   4) Skills-Feature aktivieren -> codex --enable skills (falls codex installiert)
#
# Codex liest AGENTS.md und SKILL.md nativ (gleiches Format wie Claude Code/Kimi).
# CODEX_HOME respektiert eine eigene Codex-Home (Default: ~/.codex).
# -------------------------------------------------------------
set -euo pipefail

# --- Repo-/Skript-Verzeichnis robust ermitteln -------------------------------
SCRIPT_DIR="$(cd "$(dirname "$0")" 2>/dev/null && pwd || pwd)"
SYNC="$SCRIPT_DIR/claude-sync.md"
SRC="$SCRIPT_DIR/.claude/skills"
if [ ! -f "$SYNC" ] && [ -f "./claude-sync.md" ]; then
  SCRIPT_DIR="$(pwd)"; SYNC="$SCRIPT_DIR/claude-sync.md"; SRC="$SCRIPT_DIR/.claude/skills"
fi

if [ ! -f "$SYNC" ] || [ ! -d "$SRC" ]; then
  echo "FEHLER: claude-sync.md oder .claude/skills/ nicht gefunden (gesucht in: $SCRIPT_DIR)." >&2
  echo "Bitte im geklonten Ordner 'Devteam-vibecodes' ausfuehren (ggf. vorher 'git pull')." >&2
  exit 1
fi

# --- Codex-Home bestimmen -----------------------------------------------------
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
SKILLS_DIR="$CODEX_HOME/skills"
PROMPTS_DIR="$CODEX_HOME/prompts"
AGENTS="$CODEX_HOME/AGENTS.md"
mkdir -p "$SKILLS_DIR" "$PROMPTS_DIR"

echo "Team-OS-Setup fuer Codex startet."
echo "  Repo:       $SCRIPT_DIR"
echo "  Codex-Home: $CODEX_HOME"
echo ""

# --- 1) Globaler System-Prompt: claude-sync.md -> AGENTS.md -------------------
if [ -f "$AGENTS" ]; then
  cp "$AGENTS" "$AGENTS.bak"
  echo "HINWEIS: vorhandene AGENTS.md gesichert -> $AGENTS.bak"
fi
cp "$SYNC" "$AGENTS"
echo "[1/3] Globaler System-Prompt gesetzt: $AGENTS"

# --- Hilfsfunktion: Command-Wrapper schreiben (sichere Quoting-Variante) ------
write_prompt() {
  local name="$1" desc="$2" out="$3"
  {
    printf '%s\n' '---'
    printf 'description: "%s"\n' "$desc"
    printf '%s\n' '---'
    printf '%s\n' ''
    printf 'Aktiviere den Team-Skill **%s** und befolge ihn vollstaendig fuer die aktuelle Aufgabe.\n' "$name"
    printf '%s\n' ''
    printf 'Die Skill-Definition liegt in `~/.codex/skills/%s/SKILL.md`. Ist der Skill nicht bereits automatisch geladen, lies diese Datei zuerst und arbeite dann strikt nach ihren Anweisungen. Antworte auf Deutsch.\n' "$name"
    printf '%s\n' ''
    printf '%s\n' 'Zusaetzlicher Kontext/Argumente: $ARGUMENTS'
  } > "$out"
}

# --- 2) + 3) Skills nativ kopieren + Command-Wrapper erzeugen -----------------
count=0
for d in "$SRC"/*/; do
  [ -d "$d" ] || continue
  [ -f "${d}SKILL.md" ] || continue
  name="$(basename "$d")"

  # 2) nativer Skill (byte-genaue Kopie -> kein Encoding-Risiko)
  mkdir -p "$SKILLS_DIR/$name"
  cp "${d}SKILL.md" "$SKILLS_DIR/$name/SKILL.md"

  # 3) Command-Wrapper mit description aus dem Frontmatter
  desc="$(awk '/^description:/{sub(/^description:[[:space:]]*/,""); gsub(/"/,"'"'"'"); print; exit}' "${d}SKILL.md")"
  [ -n "$desc" ] || desc="Team-Skill $name"
  write_prompt "$name" "$desc" "$PROMPTS_DIR/$name.md"

  echo "  + $name"
  count=$((count + 1))
done
echo "[2/3] $count Skills nativ installiert -> $SKILLS_DIR"
echo "[3/3] $count Commands erzeugt        -> $PROMPTS_DIR  (Aufruf: /<name>)"
echo ""

# --- 4) Skills-Feature aktivieren --------------------------------------------
if command -v codex >/dev/null 2>&1; then
  if codex --enable skills >/dev/null 2>&1; then
    echo "Skills-Feature aktiviert (codex --enable skills)."
  else
    echo "HINWEIS: 'codex --enable skills' fehlgeschlagen - bitte einmal manuell ausfuehren."
  fi
else
  echo "HINWEIS: 'codex' nicht im PATH. Nach der Codex-Installation einmal ausfuehren:"
  echo "         codex --enable skills"
fi

echo ""
echo "Fertig. Naechste Schritte:"
echo "  1) Ordner in VS Code oeffnen, 'codex' im Terminal starten, Projekt 'vertrauen'."
echo "  2) Skills laufen automatisch (Auto-Trigger) ODER explizit per Command, z.B.:  /tdd-workflow"
echo "  3) Der globale System-Prompt (claude-sync.md) gilt jetzt in jeder Codex-Session."
echo "  4) Fuer die Produktcode-Arbeit zusaetzlich 'Alarmsystem-Dev' klonen (hat eigene AGENTS.md)."

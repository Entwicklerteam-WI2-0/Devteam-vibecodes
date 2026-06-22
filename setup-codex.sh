#!/usr/bin/env bash
# -------------------------------------------------------------
# setup-codex.sh - Team-OS fuer OpenAI Codex CLI einrichten (macOS / Linux)
# Aufruf:  bash setup-codex.sh    (im geklonten 'Devteam-vibecodes'-Ordner)
# Macht:
#   1) claude-sync.md            -> $CODEX_HOME/AGENTS.md   (globaler System-Prompt)
#   2) .claude/skills/*/SKILL.md -> $CODEX_HOME/skills/<name>/SKILL.md  (nativ, Auto-Trigger)
#   3) je Skill ein Command      -> $CODEX_HOME/prompts/<name>.md       (explizit per /prompts:<name>)
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

# --- 1) Globaler System-Prompt: Team-Block in AGENTS.md (ADDITIV) ------------
# Codex garantiert keinen @import-Include in AGENTS.md -> Team-Inhalt wird als
# markierter Block inline gefuehrt; vorhandene AGENTS.md bleibt erhalten.
CODEX_BEGIN="<!-- TEAM-OS-G2 BEGIN - verwaltet von setup-codex, nicht editieren -->"
CODEX_END="<!-- TEAM-OS-G2 END -->"

if [ ! -f "$AGENTS" ]; then
  { printf '%s\n' "$CODEX_BEGIN"; cat "$SYNC"; printf '\n%s\n' "$CODEX_END"; } > "$AGENTS"
  echo "[1/3] Globaler System-Prompt angelegt: $AGENTS"
elif grep -qF "$CODEX_BEGIN" "$AGENTS"; then
  # Alten Team-Block entfernen, frischen anhaengen (Re-Run aktualisiert den Inhalt).
  awk -v b="$CODEX_BEGIN" -v e="$CODEX_END" '$0==b{inb=1;next} $0==e{inb=0;next} !inb{print}' "$AGENTS" > "$AGENTS.tmp"
  { cat "$AGENTS.tmp"; printf '%s\n' "$CODEX_BEGIN"; cat "$SYNC"; printf '\n%s\n' "$CODEX_END"; } > "$AGENTS"
  rm -f "$AGENTS.tmp"
  echo "[1/3] Team-Block in AGENTS.md aktualisiert: $AGENTS"
else
  # Persoenliche AGENTS.md vorhanden -> Block anhaengen, Inhalt bleibt.
  cp "$AGENTS" "$AGENTS.bak"
  { cat "$AGENTS"; printf '\n'; printf '%s\n' "$CODEX_BEGIN"; cat "$SYNC"; printf '\n%s\n' "$CODEX_END"; } > "$AGENTS.tmp"
  mv "$AGENTS.tmp" "$AGENTS"
  echo "[1/3] Persoenliche AGENTS.md beibehalten; Team-Block angehaengt (Backup: $AGENTS.bak)."
fi

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

# Mirror statt additiv: zuvor vom Team installierte Skills/Prompts entfernen, die es in der Quelle NICHT MEHR gibt.
# Manifest-gestuetzt -> persoenliche Codex-Skills/Prompts des Users bleiben unangetastet.
CMANIFEST="$SKILLS_DIR/.team-os-installed"
TEAM_SET="$( for d in "$SRC"/*/; do [ -f "${d}SKILL.md" ] && basename "$d"; done | sort -u )"
if [ -f "$CMANIFEST" ]; then
  while IFS= read -r old; do
    [ -n "$old" ] || continue
    if ! printf '%s\n' "$TEAM_SET" | grep -qxF "$old"; then
      rm -rf "$SKILLS_DIR/$old"; rm -f "$PROMPTS_DIR/$old.md"
      echo "  entfernt (nicht mehr in der Quelle): $old"
    fi
  done < "$CMANIFEST"
fi

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
printf '%s\n' "$TEAM_SET" > "$CMANIFEST"
echo "[3/3] $count Commands erzeugt        -> $PROMPTS_DIR  (Aufruf: /prompts:<name>  oder / tippen und auswaehlen)"
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
echo "  2) Skills triggern primaer AUTOMATISCH (Aufgabe beschreiben). Explizit optional: /prompts:tdd-workflow"
echo "  3) Der globale System-Prompt (claude-sync.md) gilt jetzt in jeder Codex-Session."
echo "  4) Fuer die Produktcode-Arbeit zusaetzlich 'Alarmsystem-Dev' klonen (hat eigene AGENTS.md)."
echo "  5) HINWEIS: Das Fact-Forcing-Gate (Tool-Block) laeuft auf Claude Code und Kimi Code. Auf Codex gilt nur die Text-Guidance aus AGENTS.md (kein blockierender Hook)."

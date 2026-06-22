#!/usr/bin/env bash
# -------------------------------------------------------------
# setup-kimi.sh - Team-OS fuer Kimi Code CLI einrichten (macOS / Linux)
# Aufruf:  bash setup-kimi.sh    (im geklonten 'Devteam-vibecodes'-Ordner)
# Macht:
#   1) .claude/skills/*/SKILL.md -> $KIMI_CODE_HOME/skills/<name>/SKILL.md   (nativ, /skill:<name>)
#   2) .claude/commands/*.md     -> $KIMI_CODE_HOME/skills/<name>/SKILL.md   (Kimi hat KEIN
#                                   Command-Verzeichnis -> Commands werden Skills: /skill:start)
#   3) claude-sync.md            -> $KIMI_CODE_HOME/AGENTS.md  (fehlt -> WIRD AGENTS.md; sonst additiv)
#   4) .claude/hooks/fact-forcing-gate.js -> $KIMI_CODE_HOME/hooks/ + config.toml verdrahten
#                                   (Kimi-Hooks sind Claude-kompatibel: PreToolUse blockable,
#                                    deny via stdout-JSON; das Gate-Skript ist harness-agnostisch.)
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
echo "[1/4] $count Skills installiert -> $KSKILLS  (Aufruf: /skill:<name>)"

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
echo "[2/4] $ccount Commands als Skills installiert  (Aufruf: /skill:start, /skill:setup)"

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
  echo "[3/4] Keine AGENTS.md gefunden -> claude-sync.md als AGENTS.md gesetzt: $KAGENTS"
elif grep -qF "$KB" "$KAGENTS"; then
  # Fall 2: bereits erweitert -> Team-Block auffrischen
  awk -v b="$KB" -v e="$KE" '$0==b{i=1;next} $0==e{i=0;next} !i{print}' "$KAGENTS" > "$KAGENTS.tmp"
  { cat "$KAGENTS.tmp"; printf '%s\n' "$KB"; cat "$SYNC"; printf '\n%s\n' "$KE"; } > "$KAGENTS"
  rm -f "$KAGENTS.tmp"
  echo "[3/4] Team-Block in AGENTS.md aufgefrischt: $KAGENTS"
elif grep -qF "$HEADING" "$KAGENTS"; then
  # Fall 3: AGENTS.md IST eine Team-OS-Vollkopie -> in-place aktualisieren
  cp "$KAGENTS" "$KAGENTS.bak"
  cp "$SYNC" "$KAGENTS"
  echo "[3/4] Team-OS-Vollkopie erkannt -> AGENTS.md in-place aktualisiert (Backup: $KAGENTS.bak)."
else
  # Fall 4: persoenliche AGENTS.md -> behalten, Team-Block anhaengen
  cp "$KAGENTS" "$KAGENTS.bak"
  { cat "$KAGENTS"; printf '\n'; printf '%s\n' "$KB"; cat "$SYNC"; printf '\n%s\n' "$KE"; } > "$KAGENTS.tmp"
  mv "$KAGENTS.tmp" "$KAGENTS"
  echo "[3/4] Persoenliche AGENTS.md beibehalten; Team-Block angehaengt (Backup: $KAGENTS.bak)."
fi

# 4) Fact-Forcing-Gate deployen (Kimi config.toml verdrahten, idempotent).
#    Kimis Hook-System ist Claude-kompatibel (PreToolUse blockbar, deny via stdout-JSON);
#    das bestehende, harness-agnostische Gate-Skript wird unverändert weitergenutzt.
#    Quelle der Hook-Semantik: offizielle Kimi-Code-Doku (customization/hooks).
GATE_SRC="$SCRIPT_DIR/.claude/hooks/fact-forcing-gate.js"
if [ -f "$GATE_SRC" ]; then
  KHOOKS="$KIMI_HOME/hooks"
  KCONFIG="$KIMI_HOME/config.toml"
  mkdir -p "$KHOOKS"
  cp "$GATE_SRC" "$KHOOKS/fact-forcing-gate.js"
  # Forward-Slashes (Node akzeptiert sie plattformuebergreifend; TOML-basic-strings escapen Backslashes).
  KIMI_HOME_FW="${KIMI_HOME//\\//}"
  GATE_CMD="node \"$KIMI_HOME_FW/hooks/fact-forcing-gate.js\""
  HB="# TEAM-OS-G2 HOOKS BEGIN - verwaltet von setup-kimi, nicht editieren"
  HE="# TEAM-OS-G2 HOOKS END"
  HOOK_BLOCK="$(cat <<EOF
$HB
[[hooks]]
event = "PreToolUse"
matcher = "Bash"
command = '$GATE_CMD'
timeout = 5

[[hooks]]
event = "PreToolUse"
matcher = "Edit|Write|MultiEdit"
command = '$GATE_CMD'
timeout = 5
$HE
EOF
)"
  if [ ! -f "$KCONFIG" ]; then
    printf '%s\n' "$HOOK_BLOCK" > "$KCONFIG"
    echo "[4/4] config.toml angelegt + Fact-Forcing-Gate verdrahtet: $KCONFIG"
  elif grep -qF "$HB" "$KCONFIG"; then
    # Block bereits vorhanden -> zwischen Markern ersetzen (idempotent)
    awk -v b="$HB" -v e="$HE" '$0==b{i=1;next} $0==e{i=0;next} !i{print}' "$KCONFIG" > "$KCONFIG.tmp"
    { cat "$KCONFIG.tmp"; printf '\n%s\n' "$HOOK_BLOCK"; } > "$KCONFIG"
    rm -f "$KCONFIG.tmp"
    echo "[4/4] Fact-Forcing-Gate in bestehender config.toml aufgefrischt: $KCONFIG"
  else
    # Persoenliche config.toml -> behalten, Block anhaengen (Backup)
    cp "$KCONFIG" "$KCONFIG.bak"
    { cat "$KCONFIG"; printf '\n\n%s\n' "$HOOK_BLOCK"; } > "$KCONFIG.tmp"
    mv "$KCONFIG.tmp" "$KCONFIG"
    echo "[4/4] Persoenliche config.toml beibehalten; Fact-Forcing-Gate angehaengt (Backup: $KCONFIG.bak)."
  fi
else
  echo "[4/4] WARNUNG: .claude/hooks/fact-forcing-gate.js nicht gefunden - kein Kimi-Gate deployt."
fi

echo ""
echo "Fertig. Kimi findet Skills + Anweisung automatisch (KIMI_CODE_HOME)."
echo "Aufruf z.B.:  /skill:tdd-workflow   -   Session-Start:  /skill:start"
echo "Fact-Forcing-Gate: als PreToolUse-Hook in config.toml verdrahtet (Bash + Edit/Write/MultiEdit)."
echo "Verifikation: in Kimi '/hooks' zeigt die geladenen Hooks. Steuerung via User-Env"
echo "  UNI_GATE_OFF=off oder UNI_DISABLED_HOOKS=uni:pre:bash:fact-force,uni:pre:edit-write:fact-force."
echo "Hinweis: Kimi fuehrt Hooks fail-open aus (Doku) - das Gate ist Coaching, keine alleinige Safety-Barriere."

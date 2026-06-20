#!/usr/bin/env bash
# -------------------------------------------------------------
# update.sh - Team-OS auf den neuesten Stand bringen (macOS / Linux)
# Aufruf:  bash update.sh
# Macht:   git pull (neuester Stand) + setup.sh erneut ausfuehren
#          (Anweisung/Skills/Commands global in ~/.claude auffrischen).
#          Zeigt Version  alt -> neu.
# -------------------------------------------------------------
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" 2>/dev/null && pwd || pwd)"
cd "$SCRIPT_DIR"

if [ ! -d "$SCRIPT_DIR/.git" ]; then
  echo "FEHLER: Das ist kein Git-Repo ($SCRIPT_DIR)." >&2
  echo "Bitte aus dem geklonten Ordner 'Devteam-vibecodes' starten:  bash update.sh" >&2
  exit 1
fi

old_ver="$(cat "$SCRIPT_DIR/VERSION" 2>/dev/null || echo 'unbekannt')"
echo "Team-OS Update startet in: $SCRIPT_DIR"
echo "Aktuelle Version: $old_ver"

echo "Hole neuesten Stand (git pull) ..."
git -c pull.rebase=false pull --autostash origin master

new_ver="$(cat "$SCRIPT_DIR/VERSION" 2>/dev/null || echo 'unbekannt')"
echo "Neue Version: $new_ver"

echo "Frische Anweisung/Skills/Commands auf (setup.sh) ..."
bash "$SCRIPT_DIR/setup.sh"

echo ""
echo "Update fertig:  $old_ver -> $new_ver"
echo "Hinweis: Claude Code neu starten, damit neue Skills/Commands geladen werden."
echo "Kimi/Codex-Nutzer: zusaetzlich das jeweilige Setup erneut ausfuehren (setup-kimi.sh / setup-codex.sh)."

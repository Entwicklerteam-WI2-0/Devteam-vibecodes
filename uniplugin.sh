#!/usr/bin/env bash
# -------------------------------------------------------------
# uniplugin.sh - Team-OS CLI (macOS / Linux). Dispatcher fuer den globalen Befehl 'uniplugin'.
# Wird ueber den Symlink ~/.local/bin/uniplugin aufgerufen (siehe install-cli.sh).
# Aufruf:  uniplugin <update|setup|version|help>
# 'update' = git pull + Redeploy (Skills/Commands auffrischen, geloeschte entfernen).
# -------------------------------------------------------------
set -euo pipefail

# Repo = Verzeichnis dieser Datei (Symlinks aufloesen, damit es vom PATH-Shim aus stimmt).
SRC="${BASH_SOURCE[0]}"
while [ -h "$SRC" ]; do
  DIR="$(cd -P "$(dirname "$SRC")" && pwd)"
  SRC="$(readlink "$SRC")"
  [[ "$SRC" != /* ]] && SRC="$DIR/$SRC"
done
REPO="$(cd -P "$(dirname "$SRC")" && pwd)"

cmd="${1:-help}"
case "$cmd" in
  update)  bash "$REPO/update.sh" ;;
  setup)   bash "$REPO/setup.sh" ;;
  version|-v|--version)
    echo "uniplugin (Team-OS G2) v$(tr -d '\r\n' < "$REPO/VERSION")"
    echo "Repo: $REPO" ;;
  *)
    echo "uniplugin - Team-OS G2 CLI"
    echo "  uniplugin update    neuesten Stand holen + Skills/Commands auffrischen (geloeschte entfernen)"
    echo "  uniplugin setup     Einmal-Setup erneut ausfuehren"
    echo "  uniplugin version   installierte Version + Repo-Pfad zeigen" ;;
esac

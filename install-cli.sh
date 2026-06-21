#!/usr/bin/env bash
# -------------------------------------------------------------
# install-cli.sh - Registriert den globalen Terminal-Befehl 'uniplugin' (macOS / Linux).
# Aufruf (einmalig, im geklonten Devteam-vibecodes):
#   bash install-cli.sh
# Danach:  uniplugin update
# -------------------------------------------------------------
set -euo pipefail

REPO="$(cd "$(dirname "$0")" 2>/dev/null && pwd || pwd)"

if [ ! -f "$REPO/uniplugin.sh" ]; then
  echo "FEHLER: uniplugin.sh nicht gefunden in $REPO." >&2
  echo "Bitte im geklonten Ordner 'Devteam-vibecodes' ausfuehren." >&2
  exit 1
fi

chmod +x "$REPO/uniplugin.sh"

BIN="$HOME/.local/bin"
mkdir -p "$BIN"
ln -sf "$REPO/uniplugin.sh" "$BIN/uniplugin"
echo "Befehl angelegt: $BIN/uniplugin  ->  $REPO/uniplugin.sh"

case ":$PATH:" in
  *":$BIN:"*)
    echo "PATH enthaelt $BIN bereits." ;;
  *)
    echo "HINWEIS: $BIN ist nicht im PATH. Einmalig in ~/.bashrc bzw. ~/.zshrc ergaenzen:"
    echo '  export PATH="$HOME/.local/bin:$PATH"'
    echo "Dann neues Terminal oeffnen (oder die Datei sourcen)." ;;
esac

echo ""
echo "Fertig. Testen:"
echo "  uniplugin version"
echo "  uniplugin update"

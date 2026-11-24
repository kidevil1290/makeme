#!/bin/bash
# Starts a small local web server for the prebuilt MakeMe app and opens it
# in the default browser. Needs no Flutter SDK and no emulator.
# Usage: bash run.sh      (stop it with Ctrl+C)

# Always work from the folder this script is in, wherever it is run from
cd "$(dirname "$0")/release/web" || { echo "release/web not found"; exit 1; }

PORT=57100
URL="http://localhost:$PORT"

# On a Mac without the Command Line Tools, /usr/bin/python3 is only a shim,
# so "command -v python3" would wrongly say it exists. Running it for real is
# the reliable check. If the tools are missing, macOS also opens its own
# install dialog at this point.
if python3 --version >/dev/null 2>&1; then
  echo "MakeMe is running at $URL (press Ctrl+C to stop)"
  # Opens the browser one second later, after the server has started.
  # 'open' is the macOS command for opening a URL.
  (sleep 1 && open "$URL") &
  python3 -m http.server "$PORT"
else
  echo ""
  echo "Python 3 is needed to serve the app and was not found."
  echo "If macOS opened a window offering to install the Command Line Tools,"
  echo "click Install, wait for it to finish, then run this script again:"
  echo "    bash run.sh"
  echo "Otherwise run:  xcode-select --install"
  # Asks macOS to open the install window (harmless if already installed)
  xcode-select --install 2>/dev/null
  exit 1
fi
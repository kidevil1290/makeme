#!/bin/bash
# Builds the web version of MakeMe and copies it into release/web, which is
# the folder that run.sh serves.
# Usage (from anywhere):  bash build_release.sh

# Stop at the first error, so a failed build never touches release/
set -e

# Work from the folder this script is in
cd "$(dirname "$0")"

if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter was not found. Install it first (see the README)."
  exit 1
fi

echo "Building the web version..."
flutter build web --release

# The build must have produced an index.html, or something went wrong
if [ ! -f build/web/index.html ]; then
  echo "build/web/index.html is missing. release/ was not changed."
  exit 1
fi

# Replace the old copy only now that the new build is known to be good
rm -rf release
mkdir release
cp -R build/web release/web

echo ""
echo "Done. release/web is up to date."
echo "Test it with: bash run.sh, then clear site data for localhost:8080."
#!/usr/bin/env bash
#
# Render the quote mockup through the SAME wkhtmltopdf build and fonts as
# production, so local pagination matches the server.
#
#   ./docker/render.sh                  # renders quote.html -> quote-linux.pdf
#   ./docker/render.sh foo.html out.pdf
#
# The macOS wkhtmltopdf the gem ships is an x86_64 Cocoa build whose font
# database does not work under Rosetta — it resolves every family, even
# Georgia and Courier New, to Helvetica. Helvetica is narrower than Archivo,
# so rendering locally on macOS silently under-estimates how much vertical
# space the content needs and hides page breaks that appear in production.
# This image exists to remove that difference.

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(dirname "$HERE")"

INPUT="${1:-quote.html}"
OUTPUT="${2:-quote-linux.pdf}"

# Which Ubuntu the gem targets on the server. Check with `lsb_release -rs`
# there and change this if it is not 22.04.
UBUNTU_BUILD="${UBUNTU_BUILD:-wkhtmltopdf_ubuntu_22.04_amd64}"

# Pull the production binary straight out of the installed gem.
if [ ! -f "$HERE/wkhtmltopdf" ]; then
  echo "==> extracting $UBUNTU_BUILD from the wkhtmltopdf-binary gem"
  GEM_BIN="$(gem contents wkhtmltopdf-binary 2>/dev/null \
             | grep -m1 "${UBUNTU_BUILD}\.gz" || true)"
  if [ -z "$GEM_BIN" ]; then
    echo "Could not find ${UBUNTU_BUILD}.gz in the installed gem." >&2
    echo "Available builds:" >&2
    gem contents wkhtmltopdf-binary 2>/dev/null | grep -o 'wkhtmltopdf_[a-z0-9._]*' | sort -u >&2
    exit 1
  fi
  gunzip -c "$GEM_BIN" > "$HERE/wkhtmltopdf"
fi

# Fonts are copied in rather than mounted, so the image carries them.
rm -rf "$HERE/fonts"
cp -R "$ROOT/fonts" "$HERE/fonts"

echo "==> building image (first run is slow under emulation)"
docker build --platform linux/amd64 -t bigtrees-pdf "$HERE"

echo "==> rendering $INPUT"
docker run --rm --platform linux/amd64 \
  -v "$ROOT":/work \
  bigtrees-pdf \
  --page-size Letter \
  --margin-top 0 --margin-bottom 0 --margin-left 0 --margin-right 0 \
  --enable-local-file-access \
  "/work/$INPUT" "/work/$OUTPUT"

echo "==> fonts actually embedded:"
strings "$ROOT/$OUTPUT" | grep BaseFont | sort -u

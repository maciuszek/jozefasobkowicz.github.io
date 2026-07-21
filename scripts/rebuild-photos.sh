#!/usr/bin/env bash
# Rebuild served photo derivatives from originals/.
#
# For every originals/<name>.jpg, (re)writes:
#   assets/img/photos/full/<name>.jpg           2560px max, q88 — served in the lightbox
#   assets/img/photos/thumbs/thumbs_<name>.jpg  600² center-crop, q80 — served in the grid
#
# Safe to re-run; existing derivatives are overwritten in place.
# Originals in originals/ are never modified.
#
# Requires ImageMagick. If `magick` isn't on PATH, this script pulls it in
# via `nix shell nixpkgs#imagemagick` (works out of the box on NixOS).

set -euo pipefail
cd "$(dirname "$0")/.."

if ! command -v magick >/dev/null 2>&1; then
  exec nix shell nixpkgs#imagemagick -c "$0" "$@"
fi

ORIG=originals
FULL=assets/img/photos/full
THUMB=assets/img/photos/thumbs
mkdir -p "$FULL" "$THUMB"

shopt -s nullglob
srcs=("$ORIG"/*.jpg)
if (( ${#srcs[@]} == 0 )); then
  echo "no .jpg files found in $ORIG/" >&2
  exit 1
fi

i=0
for src in "${srcs[@]}"; do
  name=$(basename "$src" .jpg)
  magick "$src" -auto-orient -resize '2560x2560>' -quality 88 "$FULL/${name}.jpg"
  magick "$src" -auto-orient -resize '600x600^' -gravity center -extent 600x600 -quality 80 "$THUMB/thumbs_${name}.jpg"
  i=$((i+1))
  (( i % 50 == 0 )) && echo "  processed $i…"
done
echo "done: $i image(s) → $FULL, $THUMB"

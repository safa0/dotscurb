#!/bin/sh
# dotscurb installer: fetches dotscurb to ~/.local/share/dotscurb, then runs `dotscurb init`, which wires it into
# YOUR OWN chezmoi dotfiles repo (or starts one). Run:
#   curl -fsSL https://raw.githubusercontent.com/safa0/dotscurb/main/install.sh | sh
set -eu
REPO=${DOTSCURB_REPO:-https://github.com/safa0/dotscurb.git}
D="$HOME/.local/share/dotscurb"
command -v git >/dev/null 2>&1 || { echo "dotscurb: git is required" >&2; exit 1; }
if [ -d "$D/.git" ]; then git -C "$D" pull --ff-only --quiet || echo "dotscurb: could not update $D, using it as is" >&2
else mkdir -p "$(dirname "$D")" && git clone --quiet "$REPO" "$D"; fi
exec sh "$D/bin/dotscurb" init "$@"

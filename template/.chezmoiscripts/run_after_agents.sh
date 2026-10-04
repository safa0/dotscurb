#!/bin/sh
# After files are placed: tools (mise), skills/MCP/plugins (dotagents), then the glue (dotscurb). Idempotent.
set -u
export PATH="$HOME/.local/bin:$HOME/.local/share/mise/shims:$PATH"
command -v mise >/dev/null 2>&1 || { if command -v brew >/dev/null 2>&1; then brew install mise; else curl -fsSL https://mise.run | sh; fi; }
mise install --yes >/dev/null 2>&1 || echo "dotscurb: mise install failed" >&2
if command -v dotagents >/dev/null 2>&1; then
  (cd "$HOME" && { dotagents --global doctor >/dev/null 2>&1 || dotagents --global install >/dev/null 2>&1; dotagents --global sync >/dev/null 2>&1; }) || echo "dotscurb: dotagents failed" >&2
else echo "dotscurb: dotagents not available (needs Node 20+)" >&2; fi
dotscurb apply --quiet

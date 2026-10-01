#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."
export PATH="${ROKIT_ROOT:-$HOME/.rokit}/bin:$PATH"
if ! command -v rokit >/dev/null; then
  echo 'Rokit is required: https://github.com/rojo-rbx/rokit#installation' >&2
  exit 1
fi
if ! command -v python3 >/dev/null; then
  echo 'Python 3 is required for credential-safe bootstrap.' >&2
  exit 1
fi

python3 scripts/rokit-auth.py
# Trust only the repositories explicitly selected in the canonical manifest.
rokit trust rojo-rbx/rojo JohnnyMorganz/luau-lsp lune-org/lune Kampfkarren/selene JohnnyMorganz/StyLua
rokit install

for tool in rojo luau-lsp lune selene stylua; do
  "$tool" --version
done

python3 scripts/roblox-types.py

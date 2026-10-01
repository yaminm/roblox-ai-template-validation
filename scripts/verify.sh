#!/usr/bin/env bash
set -euo pipefail
for tool in lune stylua selene rojo; do
  command -v "$tool" >/dev/null || { echo "$tool missing; run ./scripts/bootstrap.sh" >&2; exit 1; }
done
lune run scripts/verify.luau

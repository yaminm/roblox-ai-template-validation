#!/usr/bin/env bash
set -euo pipefail
if ! command -v aftman >/dev/null; then
  echo 'aftman is required: https://github.com/LPGhatguy/aftman' >&2
  exit 1
fi
aftman install

#!/usr/bin/env bash
# Encrypt using the real agenix CLI (run in iTerm — needs a TTY or working EDITOR).
# Usage: ./agenix-edit.sh ssh/authorized_keys/boog.age ssh/authorized_keys/boog.plain
set -euo pipefail

age_file="${1:?age file path under secrets/}"
plain="${2:?plaintext file}"

cd "$(dirname "$0")/.."
export RULES="$PWD/secrets.nix"

if [[ ! -f "$plain" ]]; then
  echo "Missing $plain" >&2
  exit 1
fi

plain_abs="$(cd "$(dirname "$plain")" && pwd)/$(basename "$plain")"
editor="$(mktemp)"
chmod +x "$editor"
printf '#!/bin/sh\ncp "%s" "$1"\n' "$plain_abs" >"$editor"
export EDITOR="$editor"

rm -f "$age_file"
echo "Running agenix -e $age_file (must be listed in secrets.nix)..."
nix run --accept-flake-config github:ryantm/agenix#agenix -- -e "$age_file"
rm -f "$editor"

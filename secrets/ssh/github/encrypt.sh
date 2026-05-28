#!/usr/bin/env bash
# Encrypt GitHub deploy key the same way as `agenix -e` (age -r <ssh-pubkey>).
# Usage: ./encrypt.sh sheol|abaddon
set -euo pipefail

host="${1:-}"
if [[ "$host" != "sheol" && "$host" != "abaddon" ]]; then
  echo "Usage: $0 sheol|abaddon" >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=../_tools.sh
source "$SCRIPT_DIR/../_tools.sh"
cd "$SCRIPT_DIR/../.."

PLAIN="ssh/github/${host}.plain"
OUT="ssh/github/${host}.age"

if [[ ! -f "$PLAIN" ]]; then
  echo "Missing $PLAIN." >&2
  exit 1
fi

recipients="$(mktemp)"
filtered="$(mktemp)"
trap 'rm -f "$recipients" "$filtered"' EXIT

nix eval --raw --impure --expr "
  let
    secrets = import ./secrets.nix;
    entry = secrets.\"ssh/github/${host}.age\";
    keys = if builtins.isList entry then entry else entry.publicKeys;
  in builtins.concatStringsSep \"\n\" keys
" >"$recipients"

grep -v '^[[:space:]]*#' "$PLAIN" | grep -v '^[[:space:]]*$' >"$filtered"
if [[ ! -s "$filtered" ]]; then
  echo "No key material in $PLAIN." >&2
  exit 1
fi

age_encrypt_ssh_recipients "$recipients" "$filtered" "$OUT"

echo "Wrote $OUT"

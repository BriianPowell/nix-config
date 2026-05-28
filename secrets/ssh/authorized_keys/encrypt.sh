#!/usr/bin/env bash
# Encrypt boog authorized_keys the same way as `agenix -e` (age -r <ssh-pubkey>).
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=../_tools.sh
source "$SCRIPT_DIR/../_tools.sh"
cd "$SCRIPT_DIR/../.."

PLAIN_FILE="ssh/authorized_keys/boog.plain"
OUT_FILE="ssh/authorized_keys/boog.age"

if [[ ! -f "$PLAIN_FILE" ]]; then
  echo "Missing $PLAIN_FILE — add one OpenSSH public key per line." >&2
  exit 1
fi

recipients_file="$(mktemp)"
filtered="$(mktemp)"
trap 'rm -f "$recipients_file" "$filtered"' EXIT

nix eval --raw --impure --file ./ssh/authorized_keys/recipients.nix >"$recipients_file"
grep -v '^[[:space:]]*#' "$PLAIN_FILE" | grep -v '^[[:space:]]*$' >"$filtered"
if [[ ! -s "$filtered" ]]; then
  echo "No keys in $PLAIN_FILE." >&2
  exit 1
fi

age_encrypt_ssh_recipients "$recipients_file" "$filtered" "$OUT_FILE"

echo "Wrote $OUT_FILE"
echo "If login keys changed, update secrets/keys.nix (nixosAdmin) to match."

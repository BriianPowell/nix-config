#!/usr/bin/env bash
# Encrypt boog authorized_keys for agenix (public recipients only; no local SSH private key).
set -euo pipefail
cd "$(dirname "$0")/../.."

PLAIN_FILE="ssh/authorized_keys/boog.plain"
OUT_FILE="ssh/authorized_keys/boog.age"

if [[ ! -f "$PLAIN_FILE" ]]; then
  echo "Missing $PLAIN_FILE — add one OpenSSH public key per line." >&2
  exit 1
fi

recipients_file="$(mktemp)"
trap 'rm -f "$recipients_file"' EXIT

nix eval --raw --impure --file ./ssh/authorized_keys/recipients.nix >"$recipients_file"

: >"${recipients_file}.age"
while IFS= read -r ssh_key; do
  [[ -z "$ssh_key" ]] && continue
  nix run --accept-flake-config nixpkgs#ssh-to-age -- "$ssh_key" >>"${recipients_file}.age"
done <"$recipients_file"

filtered="$(mktemp)"
trap 'rm -f "$recipients_file" "$filtered"' EXIT
grep -v '^[[:space:]]*#' "$PLAIN_FILE" | grep -v '^[[:space:]]*$' >"$filtered"
if [[ ! -s "$filtered" ]]; then
  echo "No keys in $PLAIN_FILE — paste your 1Password NixOS Admin public key (see README.md)." >&2
  exit 1
fi

nix run --accept-flake-config nixpkgs#age -- \
  -e -R "${recipients_file}.age" \
  -o "$OUT_FILE" \
  <"$filtered"

rm -f "${recipients_file}.age"
echo "Wrote $OUT_FILE"

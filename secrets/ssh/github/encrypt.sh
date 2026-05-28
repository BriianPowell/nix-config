#!/usr/bin/env bash
# Encrypt a host GitHub deploy private key (public recipients only).
# Usage: ./encrypt.sh sheol|abaddon
set -euo pipefail

host="${1:-}"
if [[ "$host" != "sheol" && "$host" != "abaddon" ]]; then
  echo "Usage: $0 sheol|abaddon" >&2
  exit 1
fi

cd "$(dirname "$0")/../.."
PLAIN="ssh/github/${host}.plain"
OUT="ssh/github/${host}.age"

if [[ ! -f "$PLAIN" ]]; then
  echo "Missing $PLAIN — generate a deploy key and paste the private key (see README.md)." >&2
  exit 1
fi

recipients="$(mktemp)"
trap 'rm -f "$recipients" "${recipients}.age"' EXIT

nix eval --raw --impure --expr "
  let
    secrets = import ./secrets.nix;
    entry = secrets.\"ssh/github/${host}.age\";
    keys = if builtins.isList entry then entry else entry.publicKeys;
  in builtins.concatStringsSep \"\n\" keys
" >"$recipients"

: >"${recipients}.age"
while IFS= read -r ssh_key; do
  [[ -z "$ssh_key" ]] && continue
  nix run --accept-flake-config nixpkgs#ssh-to-age -- "$ssh_key" >>"${recipients}.age"
done <"$recipients"

filtered="$(mktemp)"
trap 'rm -f "$recipients" "${recipients}.age" "$filtered"' EXIT
grep -v '^[[:space:]]*#' "$PLAIN" | grep -v '^[[:space:]]*$' >"$filtered"
if [[ ! -s "$filtered" ]]; then
  echo "No key material in $PLAIN." >&2
  exit 1
fi

nix run --accept-flake-config nixpkgs#age -- \
  -e -R "${recipients}.age" \
  -o "$OUT" \
  <"$filtered"

echo "Wrote $OUT"

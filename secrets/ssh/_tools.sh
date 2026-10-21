#!/usr/bin/env bash
# Encrypt the same way agenix 0.15 does: age -r <ssh-public-key> (not ssh-to-age).
set -euo pipefail

_age_bin() {
  # Any age build produces files agenix can decrypt; resolve one from nixpkgs
  # instead of pinning a store path that garbage collection can remove.
  local out
  out="$(nix build --no-link --print-out-paths nixpkgs#age)"
  echo "$out/bin/age"
}

age_encrypt_ssh_recipients() {
  local recipients_file="$1"
  local plaintext_file="$2"
  local output_file="$3"
  local age_bin args=()
  age_bin="$(_age_bin)"
  while IFS= read -r ssh_key; do
    [[ -z "$ssh_key" ]] && continue
    args+=(-r "$ssh_key")
  done <"$recipients_file"
  if [[ ${#args[@]} -eq 0 ]]; then
    echo "No recipients" >&2
    return 1
  fi
  "$age_bin" "${args[@]}" -o "$output_file" <"$plaintext_file"
}

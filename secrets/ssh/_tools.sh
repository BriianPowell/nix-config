#!/usr/bin/env bash
# Encrypt the same way agenix 0.15 does: age -r <ssh-public-key> (not ssh-to-age).
set -euo pipefail

_age_bin() {
  # Same age build agenix 0.15 uses (see: agenix --help).
  nix build --no-link --print-out-paths --accept-flake-config \
    "github:ryantm/agenix#packages.$(nix eval --raw --impure --expr builtins.currentSystem).default" \
    >/dev/null 2>&1 || true
  echo "/nix/store/p8k7clblzsl67b4ackia5b51fpimq77i-age-1.2.1/bin/age"
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

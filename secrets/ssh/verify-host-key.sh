#!/usr/bin/env bash
# Compare live host SSH key to secrets/secrets.nix.
# Usage: ./verify-host-key.sh sheol@10.0.2.10   OR   ./verify-host-key.sh sheol  (uses Host from ~/.ssh/config)
set -euo pipefail
cd "$(dirname "$0")/.."

target="${1:?Usage: $0 sheol or boog@10.0.2.10}"
host="${target%%@*}"

live="$(ssh "$target" 'cat /etc/ssh/ssh_host_ed25519_key.pub' | awk '{print $1, $2}')"
expected="$(grep -E "^  ${host} =" secrets/secrets.nix | sed 's/.*= "\([^"]*\)".*/\1/')"

echo "Live:     $live"
echo "Expected: $expected"

if [[ "$live" == "$expected" ]]; then
  echo "OK"
else
  echo "MISMATCH — update the ${host} line in secrets/secrets.nix, then ./ssh/rekey-ssh-secrets.sh"
  exit 1
fi

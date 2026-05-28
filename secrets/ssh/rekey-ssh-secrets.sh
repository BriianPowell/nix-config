  #!/usr/bin/env bash
# Re-encrypt SSH agenix secrets so sheol/abaddon host keys can decrypt them.
set -euo pipefail
cd "$(dirname "$0")/.."

echo "Recipients for encryption:"
nix eval --raw --impure --file ./ssh/authorized_keys/recipients.nix | while read -r k; do
  echo "  $k"
done

echo ""
echo "Re-encrypting authorized_keys..."
./ssh/authorized_keys/encrypt.sh

for host in sheol abaddon; do
  if [[ -f "ssh/github/${host}.plain" ]]; then
    echo "Re-encrypting github/${host}..."
    ./ssh/github/encrypt.sh "$host"
  else
    echo "Skip github/${host} (no ${host}.plain)"
  fi
done

echo ""
echo "Done. Commit *.age, pull on sheol, and nixos-rebuild switch again."

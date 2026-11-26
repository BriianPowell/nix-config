# Overrides tide's item: show the dev shell name (direnv/nix develop set $name),
# not $IN_NIX_SHELL, which is just "impure" for flake shells. No icon.
function _tide_item_nix_shell
    set -q IN_NIX_SHELL || return
    set -l label $name
    test -n "$label" || set label nix
    _tide_print_item nix_shell $label
end

function nixos_remote -d 'Check or switch the sheol/abaddon NixOS servers from this machine'
    # Reference: https://wiki.nixos.org/wiki/Nixos-rebuild#Deploying_on_other_machines
    argparse h/help 'f/flake=' y/yes -- $argv; or return 1

    set -l hosts abaddon sheol # abaddon first: it is the node with less running on it

    if set -q _flag_help; or test (count $argv) -lt 1
        echo "Usage: nixos_remote [-f flake] [-y] <action> [host...|all]"
        echo
        echo "Actions:"
        echo "  check   dry-activate: build on the server, show what would change, activate nothing"
        echo "  build   build on the server only"
        echo "  test    activate now, without touching the bootloader (undone by a reboot)"
        echo "  switch  activate now and make it the boot default"
        echo "  boot    make it the boot default, activate on next reboot"
        echo
        echo "Hosts: $hosts, or 'all' (default: all, in that order, stopping at the first failure)"
        echo
        echo "  -f, --flake  flake to deploy (default: ~/Code/Self/nix-config)"
        echo "  -y, --yes    skip the confirmation for test/switch/boot"
        echo
        echo "Hosts are reached through the ssh aliases of the same name (user boog); sudo asks"
        echo "for your password on each. Builds run on the server, since this machine cannot"
        echo "build x86_64-linux."
        test (count $argv) -lt 1; and not set -q _flag_help; and return 1
        return 0
    end

    set -l action $argv[1]
    set -l verb
    switch $action
        case check
            set verb dry-activate
        case build test switch boot
            set verb $action
        case '*'
            echo "nixos_remote: unknown action '$action' (use check, build, test, switch or boot)" >&2
            return 1
    end

    set -l targets $argv[2..-1]
    if test (count $targets) -eq 0; or contains -- all $targets
        set targets $hosts
    end
    for h in $targets
        if not contains -- $h $hosts
            echo "nixos_remote: unknown host '$h' (use $hosts, or all)" >&2
            return 1
        end
    end

    set -q _flag_flake; or set _flag_flake ~/Code/Self/nix-config
    if not test -f $_flag_flake/flake.nix
        echo "nixos_remote: no flake.nix in $_flag_flake" >&2
        return 1
    end

    # A flake build uses the working tree, so uncommitted tracked changes (or another
    # branch) would be deployed too. Say so before anything activates.
    if contains -- $verb test switch boot
        set -l branch (command git -C $_flag_flake branch --show-current 2>/dev/null)
        set -l dirty (command git -C $_flag_flake status --porcelain --untracked-files=no 2>/dev/null)
        test "$branch" != main; and echo "Warning: $_flag_flake is on branch '$branch', not main"
        if test (count $dirty) -gt 0
            echo "Warning: uncommitted changes in $_flag_flake will be deployed:"
            printf '  %s\n' $dirty
        end

        if not set -q _flag_yes
            read -l -P "$action $targets? [y/N] " answer
            string match -qri '^y(es)?$' -- $answer; or return 1
        end
    end

    for h in $targets
        echo "==> nixos-rebuild $verb $h"
        # Build on the target (--build-host) because this machine is aarch64. The
        # nixos-rebuild comes from the flake, so it matches the flake's nixpkgs.
        command nix shell "$_flag_flake#nixos-rebuild" -c nixos-rebuild $verb \
            --flake "$_flag_flake#$h" \
            --build-host $h --target-host $h \
            --elevate sudo --ask-elevate-password
        or begin
            echo "nixos_remote: $verb failed on $h; stopping" >&2
            return 1
        end
    end
end

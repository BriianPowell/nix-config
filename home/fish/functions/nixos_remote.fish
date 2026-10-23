function nixos_remote -d 'Check or switch the sheol/abaddon NixOS servers from this machine'
    # Reference: https://wiki.nixos.org/wiki/Nixos-rebuild#Deploying_on_other_machines
    argparse h/help 'f/flake=' y/yes 't/timeout=' no-revert -- $argv; or return 1

    set -l hosts abaddon sheol # abaddon first: it is the node with less running on it

    if set -q _flag_help; or test (count $argv) -lt 1
        echo "Usage: nixos_remote [-f flake] [-y] <action> [host...|all]"
        echo
        echo "Actions:"
        echo "  status  show each host's installed, running, booted and boot-default generation"
        echo "  check   dry-activate: build on the server, show what would change, activate nothing"
        echo "  build   build on the server only"
        echo "  test    activate now, without touching the bootloader (undone by a reboot);"
        echo "          reverts by itself unless you confirm in time (see --timeout)"
        echo "  switch  activate now and make it the boot default"
        echo "  boot    make it the boot default, activate on next reboot"
        echo "  rollback  go back one generation (or undo a 'test'), activate now and make it the boot default"
        echo
        echo "Hosts: $hosts, or 'all' (default: all, in that order, stopping at the first failure)"
        echo
        echo "  -f, --flake  flake to deploy (default: ~/Code/Self/nix-config)"
        echo "  -y, --yes    skip the confirmation for test/switch/boot/rollback"
        echo "  -t, --timeout SECONDS  how long 'test' waits for you before reverting (default 300)"
        echo "  --no-revert  'test' without the automatic revert"
        echo
        echo "Hosts are reached through the ssh aliases of the same name (user boog); sudo asks"
        echo "for your password on each. Builds run on the server, since this machine cannot"
        echo "build x86_64-linux."
        test (count $argv) -lt 1; and not set -q _flag_help; and return 1
        return 0
    end

    set -l action $argv[1]
    if test "$action" = status
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
        __nixos_remote_status $targets
        return
    end
    set -l verb
    switch $action
        case rollback
            set verb rollback
        case check
            set verb dry-activate
        case build test switch boot
            set verb $action
        case '*'
            echo "nixos_remote: unknown action '$action' (use status, check, build, test, switch, boot or rollback)" >&2
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

    if test $verb = rollback
        if not set -q _flag_yes
            read -l -P "rollback $targets? [y/N] " answer
            string match -qri '^y(es)?$' -- $answer; or return 1
        end
        for h in $targets
            echo "==> rollback $h"
            __nixos_remote_rollback $h
            or begin
                echo "nixos_remote: rollback failed on $h; stopping" >&2
                return 1
            end
        end
        return
    end

    set -q _flag_timeout; or set _flag_timeout 300
    string match -qr '^[0-9]+$' -- $_flag_timeout; or begin
        echo "nixos_remote: --timeout needs a number of seconds" >&2
        return 1
    end

    set -q _flag_flake; or set _flag_flake ~/Code/Self/nix-config
    if not test -f $_flag_flake/flake.nix
        echo "nixos_remote: no flake.nix in $_flag_flake" >&2
        return 1
    end
    # This file is installed from the nix store, so it cannot find its own repository;
    # say which checkout is being deployed instead, so a wrong one is obvious.
    set -l flake_rev (command git -C $_flag_flake rev-parse --short HEAD 2>/dev/null)
    echo "flake: "(path resolve $_flag_flake)" @ $flake_rev"

    # A flake build uses the working tree, so uncommitted tracked changes (or another
    # branch) would be deployed too. Say so before anything activates.
    if contains -- $verb test switch boot rollback
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
        if test $verb = test; and not set -q _flag_no_revert
            # Build first, so the revert timer is not counting down during the build.
            __nixos_remote_rebuild build $h $_flag_flake; or return 1
            set -l unit nixos-remote-revert-(date +%s)
            echo "==> arming an automatic revert on $h in $_flag_timeout seconds"
            # The installed generation is untouched by `test`, so re-activating it is the undo.
            command ssh -t $h sudo systemd-run --unit=$unit --on-active=$_flag_timeout \
                --description=nixos-remote-test-revert \
                /nix/var/nix/profiles/system/bin/switch-to-configuration test
            or begin
                echo "nixos_remote: could not arm the revert on $h; not activating" >&2
                return 1
            end
            __nixos_remote_rebuild test $h $_flag_flake
            or begin
                echo "nixos_remote: test failed on $h; the revert still runs in $_flag_timeout seconds" >&2
                return 1
            end
            __nixos_remote_confirm $h $unit $_flag_timeout; or return 1
            continue
        end
        __nixos_remote_rebuild $verb $h $_flag_flake; or return 1
        contains -- $verb switch boot; and __nixos_remote_verify $h $verb
    end
end

function __nixos_remote_rebuild -a verb host flake
    echo "==> nixos-rebuild $verb $host"
    # Build on the target (--build-host) because this machine is aarch64. The
    # nixos-rebuild comes from the flake, so it matches the flake's nixpkgs. That
    # 26.05 build still takes --sudo/--ask-sudo-password; the --elevate spelling is
    # newer (nixpkgs unstable) and is rejected here.
    command nix shell "$flake#nixos-rebuild" -c nixos-rebuild $verb \
        --flake "$flake#$host" \
        --build-host $host --target-host $host \
        --sudo --ask-sudo-password
    or begin
        echo "nixos_remote: $verb failed on $host; stopping" >&2
        return 1
    end
end

# After `test`: ask whether to keep the new configuration. If the host cannot be reached
# (a bad change can cut ssh), or the answer is no, the armed timer reverts it.
function __nixos_remote_confirm -a host unit secs
    if not __nixos_remote_probe $host >/dev/null 2>&1
        echo "Warning: $host is not answering over ssh. It reverts by itself within $secs seconds." >&2
        return 1
    end
    read -l -P "$host still reachable. Keep the new configuration until reboot? [y/N] " answer
    if string match -qri '^y(es)?$' -- $answer
        command ssh -t $host sudo systemctl stop $unit.timer
        or begin
            echo "Warning: could not cancel the revert on $host; it may still run" >&2
            return 1
        end
        echo "$host: kept (a reboot undoes it; run 'nixos_remote switch $host' to make it permanent)"
    else
        echo "==> reverting $host now"
        command ssh -t $host "sudo sh -c 'systemctl stop $unit.timer; systemctl start $unit.service'"
        or begin
            echo "Warning: could not revert $host over ssh; the timer still reverts it" >&2
            return 1
        end
        echo "$host: reverted to the installed generation"
    end
end

# `nixos_remote rollback`: a `test` deploy is undone by re-activating the installed
# generation; otherwise go back one generation and make that the boot default.
function __nixos_remote_rollback -a host
    set -l out (__nixos_remote_probe $host 2>/dev/null)
    if test $status -ne 0; or test (count $out) -eq 0
        echo "nixos_remote: could not read $host's state over ssh" >&2
        return 1
    end
    for line in $out
        set -l kv (string split -m1 = -- $line)
        set -f "p_$kv[1]" $kv[2]
    end
    if test "$p_current" != "$p_installed"
        echo "$host runs generation $p_current, installed is $p_installed: re-activating $p_installed"
        command ssh -t $host sudo /nix/var/nix/profiles/system/bin/switch-to-configuration test
        or return 1
        echo "$host: back on installed generation $p_installed"
    else
        echo "$host: generation $p_installed -> previous generation"
        command ssh -t $host sudo nixos-rebuild switch --rollback
        or return 1
        __nixos_remote_verify $host switch
    end
end

# After a switch or boot, check that the machine will actually come up on what was just
# installed: a default pinned with `bootctl set-default` overrides the new generation.
function __nixos_remote_verify -a host verb
    set -l out (__nixos_remote_probe $host 2>/dev/null)
    if test $status -ne 0; or test (count $out) -eq 0
        echo "Note: could not read $host's boot state over ssh; run: nixos_remote status $host" >&2
        return 0
    end
    for line in $out
        set -l kv (string split -m1 = -- $line)
        set -f "p_$kv[1]" $kv[2]
    end
    if test -n "$p_pinned"; and test "$p_pinned" != "$p_installed"
        echo "Warning: $host will boot generation $p_pinned, not the new $p_installed:" \
            "its boot default is pinned. Clear it with: sudo bootctl set-default ''" >&2
    end
    if test "$verb" = switch; and test "$p_reboot" = yes
        echo "Note: $host's kernel or initrd changed; reboot to run it." >&2
    end
    echo "$host: installed generation $p_installed, booted $p_booted"
end

# `nixos_remote status [host...]`: installed, running, booted and boot-default
# generation per host, without changing anything.
function __nixos_remote_status
    set -l targets $argv
    printf '%-10s %-10s %-9s %-8s %-10s %s\n' Host Installed Running Booted Default Reboot
    set -l warnings
    for h in $targets
        set -l out (__nixos_remote_probe $h 2>/dev/null)
        if test $status -ne 0; or test (count $out) -eq 0
            printf '%-10s %s\n' $h unreachable
            set -a warnings "$h: could not read its state over ssh"
            continue
        end
        for line in $out
            set -l kv (string split -m1 = -- $line)
            set -f "p_$kv[1]" $kv[2]
        end
        set -l default installed
        test -n "$p_pinned"; and set default "pin $p_pinned"
        printf '%-10s %-10s %-9s %-8s %-10s %s\n' $h $p_installed $p_current "$p_booted" $default $p_reboot
        test -n "$p_pinned"; and test "$p_pinned" != "$p_installed"
        and set -a warnings "$h: boot default is pinned to generation $p_pinned, not $p_installed (clear with: sudo bootctl set-default '')"
        test "$p_current" != "$p_installed"
        and set -a warnings "$h: running generation $p_current is not the installed $p_installed (a 'test' deploy, or a rollback)"
        set -e p_installed p_current p_booted p_pinned p_reboot
    end

    if test (count $warnings) -gt 0
        echo
        printf 'Warning: %s\n' $warnings
    end
end

function __nixos_remote_probe -a host -d 'Print key=value boot state for a NixOS server'
    # The servers' login shell is fish, so the POSIX script goes in on stdin to `sh -s`
    # instead of being passed as a command line.
    #
    # Output keys: installed (profile generation), current (generation of the running
    # system, or ? when it is not a profile, e.g. after `test`), booted (generation the
    # machine booted), pinned (generation set with `bootctl set-default`, empty when
    # none), reboot (yes when the kernel or initrd differ from the booted ones).
    # No sudo is needed: the EFI variables are world readable.
    set -l script '
guid=4a67b082-0a4c-41cf-b6c7-440b29bb8c4f
gen() { basename "$1" | sed "s/^system-\([0-9]*\)-link$/\1/"; }
entry() {
  f=/sys/firmware/efi/efivars/$1-$guid
  [ -r "$f" ] && tail -c +5 "$f" | tr -d "\000" | sed "s/^nixos-generation-\([0-9]*\)\.conf$/\1/"
  return 0
}
installed=$(gen "$(readlink /nix/var/nix/profiles/system)")
cur=$(readlink /run/current-system)
current=
for l in /nix/var/nix/profiles/system-*-link; do
  [ "$(readlink "$l")" = "$cur" ] && current=$(gen "$l")
done
reboot=no
for f in kernel initrd kernel-modules; do
  [ "$(readlink /run/booted-system/$f)" = "$(readlink /run/current-system/$f)" ] || reboot=yes
done
echo installed=$installed
echo current=${current:-?}
echo booted=$(entry LoaderEntrySelected)
echo pinned=$(entry LoaderEntryDefault)
echo reboot=$reboot
'
    printf '%s\n' $script | command ssh -o BatchMode=yes -o ConnectTimeout=10 $host sh -s
end

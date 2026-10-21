# Everything a NixOS-WSL distro needs. WSL manages its own networking, firewall and
# init, so we only pull in the locale/docs/ssh/security modules that make sense
# inside it, plus the WSL settings below. A host sets `networking.hostName` and
# `wsl.defaultUser`.
{ config, lib, ... }:
{
  imports = [
    ../i18n.nix
    ../minimal-docs.nix
    ../openssh.nix
    ../security.nix
  ];

  wsl = {
    enable = true;

    # Expose the wsl.exe-aware launchers in the Windows Start Menu.
    startMenuLaunchers = true;

    # Integrate with Docker Desktop for Windows (sockets, CLI plugin).
    docker-desktop.enable = true;

    # Use the Windows-side GPU/OpenGL driver when available (CUDA, /dev/dxg).
    useWindowsDriver = true;

    # /etc/wsl.conf
    wslConf = {
      automount = {
        enabled = true;
        root = "/mnt";
        options = "metadata,uid=1000,gid=100,umask=022,fmask=011";
      };
      network = {
        generateHosts = true;
        generateResolvConf = true;
      };
      interop = {
        enabled = true;
        # Keep $PATH clean; opt-in to Windows binaries explicitly when needed.
        appendWindowsPath = false;
      };
    };
  };

  # WSL never presents a console login prompt for the default user, so we don't
  # need (and can't easily provision on first boot) the agenix-managed passwords the
  # user modules set. Those use mkDefault, so a plain null here wins.
  users.users.${config.wsl.defaultUser}.hashedPasswordFile = null;
  users.users.root.hashedPasswordFile = null;
  # With no password or key on any account, NixOS asserts that you would be locked out.
  # In WSL you enter through wsl.exe, not a login prompt, so that does not apply.
  users.allowNoPasswordLogin = true;

  # Convenience: passwordless sudo from the WSL shell.
  security.sudo.wheelNeedsPassword = false;

  # WSL handles DNS / interfaces via /etc/wsl.conf and the Windows host; we only
  # need the firewall disabled so the Windows-side networking can reach in.
  networking.firewall.enable = lib.mkDefault false;

  # WSL disks live on a sparse VHDX that doesn't reclaim on its own; keep the
  # store from ballooning by garbage-collecting older generations weekly.
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  nix.optimise = {
    automatic = true;
    dates = [ "weekly" ];
  };
}

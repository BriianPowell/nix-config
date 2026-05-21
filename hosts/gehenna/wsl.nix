{ lib, ... }: {
  wsl = {
    enable = true;
    defaultUser = "boog";

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
  # need (and can't easily provision on first boot) the agenix-managed password
  # that users/boog and users/root configure. Override them to an unset value.
  users.mutableUsers = lib.mkForce false;
  users.users.boog.hashedPasswordFile = lib.mkForce null;
  users.users.root.hashedPasswordFile = lib.mkForce null;

  # Convenience: passwordless sudo from the WSL shell.
  security.sudo.wheelNeedsPassword = lib.mkForce false;
}

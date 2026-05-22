{
  config,
  pkgs,
  lib,
  ...
}:
let
  toolkit = pkgs.nvidia-container-toolkit;
  tools = toolkit.tools;

  # nvidia-container-runtime looks for runc in PATH; k3s bundles its own under /var/lib/rancher/k3s/data.
  runcWrapper = pkgs.writeShellScriptBin "runc" ''
    #!${pkgs.bash}/bin/bash
    set -euo pipefail
    for candidate in /var/lib/rancher/k3s/data/*/bin/runc; do
      if [ -x "''${candidate}" ]; then
        exec "''${candidate}" "$@"
      fi
    done
    exec ${lib.getExe pkgs.runc} "$@"
  '';
in
{
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.nvidia = {
    # Modesetting is needed most of the time
    modesetting.enable = true;

    # Enable power management (do not disable this unless you have a reason to).
    # Likely to cause problems on laptops and with screen tearing if disabled.
    powerManagement.enable = true;

    # Use the open source version of the kernel module ("nouveau")
    # Note that this offers much lower performance and does not
    # support all the latest Nvidia GPU features.
    # You most likely don't want this.
    # Only available on driver 515.43.04+
    open = false;

    # Enable the Nvidia settings menu,
    # accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  hardware.nvidia-container-toolkit = {
    enable = true;
    mount-nvidia-executables = true;
  };

  # OCI hooks and nvidia-container-runtime expect FHS paths and a discoverable runc.
  system.activationScripts.nvidiaContainerFhsCompat = lib.stringAfter [ "usr" ] ''
    mkdir -p /usr/bin
    ln -sfn ${toolkit}/bin/nvidia-ctk /usr/bin/nvidia-ctk
    ln -sfn ${tools}/bin/nvidia-container-runtime-hook /usr/bin/nvidia-container-runtime-hook
    ln -sfn ${pkgs.libnvidia-container}/bin/nvidia-container-cli /usr/bin/nvidia-container-cli

    ln -sfn ${runcWrapper}/bin/runc /usr/bin/runc
  '';

  systemd.services.k3s.serviceConfig.path = lib.mkAfter [
    "/usr/bin"
    "${pkgs.runc}/bin"
    "${toolkit}/bin"
    "${tools}/bin"
    "${pkgs.libnvidia-container}/bin"
  ];
}

# GPU driver + container toolkit.
# https://github.com/NixOS/nixpkgs/issues/519565 — user/module mounts need rprivate
# on shared filesystems to avoid mount propagation leaks (esp. with Bidirectional hostPath).
{
  config,
  pkgs,
  lib,
  ...
}:
let
  nvidiaDriver = config.hardware.nvidia.package;
  toolkit = pkgs.nvidia-container-toolkit;
  tools = lib.getOutput "tools" toolkit;

  # Per nixpkgs#519565; upstream default omits rprivate until fixed.
  mountOptions = [
    "ro"
    "nosuid"
    "nodev"
    "bind"
    "rprivate"
  ];

  mount = hostPath: containerPath: {
    inherit hostPath containerPath mountOptions;
  };

  # Mirrors nixpkgs module defaults; rprivate per https://github.com/NixOS/nixpkgs/issues/519565
  toolkitMounts = [
    (mount pkgs.addDriverRunpath.driverLink pkgs.addDriverRunpath.driverLink)
    (mount "${lib.getLib nvidiaDriver}" "${lib.getLib nvidiaDriver}")
    (mount "${lib.getLib pkgs.glibc}/lib" "${lib.getLib pkgs.glibc}/lib")
    (mount "${lib.getLib pkgs.glibc}/lib64" "${lib.getLib pkgs.glibc}/lib64")
    (mount (lib.getExe' nvidiaDriver "nvidia-cuda-mps-control") "/usr/bin/nvidia-cuda-mps-control")
    (mount (lib.getExe' nvidiaDriver "nvidia-cuda-mps-server") "/usr/bin/nvidia-cuda-mps-server")
    (mount (lib.getExe' nvidiaDriver "nvidia-debugdump") "/usr/bin/nvidia-debugdump")
    (mount (lib.getExe' nvidiaDriver "nvidia-powerd") "/usr/bin/nvidia-powerd")
    (mount (lib.getExe' nvidiaDriver "nvidia-smi") "/usr/bin/nvidia-smi")
    (mount "${lib.getLib nvidiaDriver}/lib" "/usr/local/nvidia/lib")
    (mount "${lib.getLib nvidiaDriver}/lib" "/usr/local/nvidia/lib64")
  ];

  # k3s invokes nvidia-container-runtime with a minimal env; wrapper finds k3s-bundled runc.
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
    mount-nvidia-docker-1-directories = true;
    mounts = lib.mkForce toolkitMounts;
  };

  # k3s containerd uses nvidia-container-runtime.legacy (kubernetes.nix). That binary requires
  # mode=legacy here; mode=cdi makes the prestart hook reject direct invocation and breaks all
  # runtimeClassName: nvidia pods (device-plugin, Plex). Docker CDI is separate (daemon cdi feature).
  environment.etc."nvidia-container-runtime/config.toml".text = ''
    disable-require = true
    supported-driver-capabilities = "compat32,compute,display,graphics,ngx,utility,video"

    [nvidia-container-cli]
    environment = []
    ldconfig = "@${lib.getExe' pkgs.glibc "ldconfig"}"
    load-kmods = true
    no-cgroups = false
    path = "${lib.getExe' pkgs.libnvidia-container "nvidia-container-cli"}"

    [nvidia-container-runtime]
    mode = "legacy"
    runtimes = [ "runc", "crun" ]

    [nvidia-container-runtime-hook]
    path = "${tools}/bin/nvidia-container-runtime-hook"

    [nvidia-ctk]
    path = "${lib.getExe' toolkit "nvidia-ctk"}"
  '';

  system.activationScripts.nvidiaK3sRuncCompat = lib.stringAfter [ "var" ] ''
    mkdir -p /usr/bin
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

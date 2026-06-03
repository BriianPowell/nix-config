{
  pkgs,
  lib,
  config,
  ...
}:
{
  programs.fish.enable = true;

  environment.shells = [
    "/opt/homebrew/bin/fish"
    "/Users/${config.system.primaryUser}/.local/bin/fish"
  ];

  nix.enable = false;

  networking = {
    computerName = "boog-MBP";
    hostName = "boog-MBP";
    wakeOnLan.enable = true;
  };

  power = {
    restartAfterFreeze = true;
    # restartAfterPowerFailure = true;
    sleep = {
      allowSleepByPowerButton = false;
      computer = 60;
      display = 15;
      harddisk = 120;
    };
  };

  environment.systemPackages = with pkgs; [
    # OS
    darwin.lsusb

    # Utils
    awscli2
    coreutils-full
    eternal-terminal # et client — servers: services.eternal-terminal on sheol/abaddon
    eza # https://github.com/ogham/exa
    git-secrets
    gh # https://cli.github.com/
    pre-commit
    trivy

    # DevOps
    ansible
    fluxcd
    # packer
    # terraform - use tfenv instead
    terraform-docs
    tflint

    # Build
    dotnet-sdk
    # go - use goenv instead
    jdk
    google-cloud-sdk
    platformio
    podman
  ];

  system = {
    primaryUser = config.machine.username;
    stateVersion = lib.mkDefault 4;
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = true;
    };

    activationScripts.postActivation.text = ''
      user="${config.system.primaryUser}"
      home="/Users/$user"

      # Nix fish is SIGKILL'd on Apple Silicon (invalid code signature). Prefer Homebrew fish.
      if [ -x /opt/homebrew/bin/fish ]; then
        fishShell="/opt/homebrew/bin/fish"
      else
        fishShell="$home/.local/bin/fish"
        mkdir -p "$(dirname "$fishShell")"
        cp /run/current-system/sw/bin/fish "$fishShell"
        chown "$user" "$fishShell"
        chmod u+w "$fishShell"
        sudo -u "$user" codesign -s - -f "$fishShell"
      fi

      dscl . -create /Users/"$user" UserShell "$fishShell"
    '';
  };
}

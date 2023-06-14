{ pkgs, ... }: {
  networking.hostName = "boog-MBP";

  services = {
    nix-daemon.enable = true;
  };

  environment.systemPackages = with pkgs; [
    # CLI
    coreutils-full
    awscli2
    # semgrep
    trivy

    # DevOps
    act
    ansible
    terraform

    # Build
    jdk
    python3Full
  ];

  system = {
    stateVersion = 4;
    defaults = {
      NSGlobalDomain = {
        InitialKeyRepeat = 15;
        KeyRepeat = 2;

        AppleInterfaceStyleSwitchesAutomatically = true;
        ApplePressAndHoldEnabled = false;
        AppleShowAllExtensions = true;
        AppleShowScrollBars = "WhenScrolling";

        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;

        NSDocumentSaveNewDocumentsToCloud = false;
      };
      dock = {
        autohide = true;
        orientation = "left";
        showhidden = true;
        tilesize = 40;
        minimize-to-application = true;
        mru-spaces = false;

        wvous-bl-corner = 5;
        wvous-br-corner = 14;
      };
      finder = {
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;
      };
      trackpad = {
        Clicking = true;
        TrackpadRightClick = true;
      };
    };
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = true;
    };
  };
}

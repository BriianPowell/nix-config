{ pkgs, lib, ... }:
{
  programs.fish.enable = true;

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
    eza # https://github.com/ogham/exa
    git-secrets
    gh # https://cli.github.com/
    trivy

    # DevOps
    ansible
    packer
    # terraform - use tfenv instead
    terraform-docs
    tflint

    # Build
    dotnet-sdk
    jdk
    google-cloud-sdk
    podman
  ];

  system = {
    primaryUser = "boog";
    stateVersion = lib.mkDefault 4;
    defaults = {
      NSGlobalDomain = {
        AppleEnableMouseSwipeNavigateWithScrolls = true;
        AppleEnableSwipeNavigateWithScrolls = true;
        AppleICUForce24HourTime = true;
        AppleInterfaceStyleSwitchesAutomatically = true;
        AppleKeyboardUIMode = 3;
        AppleMeasurementUnits = "Inches";
        AppleMetricUnits = 0;
        AppleTemperatureUnit = "Fahrenheit";
        ApplePressAndHoldEnabled = false;
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;
        AppleShowScrollBars = "WhenScrolling";

        InitialKeyRepeat = 15;
        KeyRepeat = 2;

        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
        NSDocumentSaveNewDocumentsToCloud = false;
        NSNavPanelExpandedStateForSaveMode = true;
        NSNavPanelExpandedStateForSaveMode2 = true;
        NSUseAnimatedFocusRing = false;
        NSWindowResizeTime = 0.001;

        PMPrintingExpandedStateForPrint = true;
        PMPrintingExpandedStateForPrint2 = true;

        "com.apple.trackpad.scaling" = -1.0;
        "com.apple.sound.beep.volume" = 0.472367;
        "com.apple.springing.delay" = 0.5;
        "com.apple.springing.enabled" = true;
      };
      controlcenter = {
        AirDrop = false;
        BatteryShowPercentage = false;
        Bluetooth = false;
        Display = false;
        FocusModes = false;
        NowPlaying = false;
        Sound = true;
      };
      dock = {
        autohide = true;
        autohide-delay = 0.0;
        autohide-time-modifier = 0.25;

        mineffect = "genie";
        minimize-to-application = true;
        mru-spaces = false;
        orientation = "left";

        showhidden = true;
        show-recents = false;
        static-only = false;

        tilesize = 35;

        wvous-bl-corner = 5;
        wvous-br-corner = 14;
      };
      finder = {
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;
        FXEnableExtensionChangeWarning = false;
        FXPreferredViewStyle = "Nlsv"; # "icnv" = Icon view, "Nlsv" = List view, "clmv" = Column View, "Flwv" = Gallery View - The default is icnv.
        FXRemoveOldTrashItems = true;
        FXDefaultSearchScope = "SCev"; # "SCcf" = Search the current folder, "SCsp" = Search the entire Mac, "SCev" = Use the previous search scope

        ShowPathbar = true;
        ShowStatusBar = true;

        QuitMenuItem = true;
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

    activationScripts.postActivation.text = ''
      sudo chsh -s ${pkgs.fish}/bin/fish
    '';
  };
}

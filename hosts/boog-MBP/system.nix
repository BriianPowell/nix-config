{ pkgs, lib, ... }:
{
  networking.hostName = "boog-MBP";

  environment.systemPackages = with pkgs; [
    # OS
    darwin.lsusb

    # Utils
    awscli2
    coreutils-full
    eza # https://github.com/ogham/exa
    git-secrets
    trivy

    # DevOps
    ansible
    packer
    # terraform - use tfenv instead
    terraform-docs
    tflint

    # Build
    # dotnet-sdk
    jdk
    google-cloud-sdk
    podman
  ];

  system = {
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

        "com.apple.sound.beep.volume" = 0.472367;
        "com.apple.springing.delay" = 0.5;
        "com.apple.springing.enabled" = true;
      };
      dock = {
        autohide = true;
        mineffect = "genie";
        minimize-to-application = true;
        mru-spaces = false;
        orientation = "left";
        showhidden = true;
        tilesize = 35;

        wvous-bl-corner = 5;
        wvous-br-corner = 14;
      };
      finder = {
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;
        FXEnableExtensionChangeWarning = false;
        FXPreferredViewStyle = "Nlsv"; # "icnv" = Icon view, "Nlsv" = List view, "clmv" = Column View, "Flwv" = Gallery View - The default is icnv.
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
      ${pkgs.vim}/bin/vim +PluginInstall +qall
      sudo chsh -s ${pkgs.fish}/bin/fish
    '';
  };
}

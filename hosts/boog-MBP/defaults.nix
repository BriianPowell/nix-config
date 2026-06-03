# macOS user defaults for nix-darwin (boog-MBP).
# Synced from live system defaults; re-export with: scripts/darwin-export-defaults
#
# See: https://nix-darwin.github.io/nix-darwin/manual/index.html#system.defaults
# Dock app layout is intentionally not managed (use persistent-apps only if you want declarative dock tiles).

{ ... }:
{
  system.defaults = {
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

      "com.apple.trackpad.scaling" = 1.0;
      "com.apple.trackpad.forceClick" = true;
      "com.apple.sound.beep.volume" = 0.472367;
      "com.apple.springing.delay" = 0.5;
      "com.apple.springing.enabled" = true;
    };

    # true = show control in menu bar; false = hide (nix-darwin maps to ByHost plist values).
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
      magnification = true;
      largesize = 72;
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
      FXPreferredViewStyle = "Nlsv";
      FXRemoveOldTrashItems = true;
      FXDefaultSearchScope = "SCev";
      ShowPathbar = true;
      ShowStatusBar = true;
      QuitMenuItem = true;
    };

    trackpad = {
      ActuateDetents = true;
      Clicking = true;
      DragLock = false;
      Dragging = false;
      FirstClickThreshold = 1;
      ForceSuppressed = false;
      SecondClickThreshold = 1;
      TrackpadCornerSecondaryClick = 0;
      TrackpadFourFingerHorizSwipeGesture = 2;
      TrackpadFourFingerPinchGesture = 2;
      TrackpadFourFingerVertSwipeGesture = 2;
      TrackpadMomentumScroll = true;
      TrackpadPinch = true;
      TrackpadRightClick = true;
      TrackpadRotate = true;
      TrackpadThreeFingerDrag = false;
      TrackpadThreeFingerHorizSwipeGesture = 2;
      TrackpadThreeFingerTapGesture = 0;
      TrackpadThreeFingerVertSwipeGesture = 2;
      TrackpadTwoFingerDoubleTapGesture = true;
      TrackpadTwoFingerFromRightEdgeSwipeGesture = 3;
    };

    WindowManager = {
      AppWindowGroupingBehavior = true;
      AutoHide = false;
      EnableTiledWindowMargins = false;
      EnableTilingByEdgeDrag = false;
      EnableTilingOptionAccelerator = false;
      EnableTopTilingByEdgeDrag = false;
      HideDesktop = true;
      StageManagerHideWidgets = false;
      StandardHideWidgets = false;
    };
  };
}

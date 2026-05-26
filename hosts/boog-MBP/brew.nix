# Quick Look plugins need quarantine cleared; Homebrew no longer supports --no-quarantine.
# See system.activationScripts.quickLookQuarantine below.

{ config, lib, ... }:
{
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = false;
      upgrade = false;
      cleanup = "zap";
    };
    taps = [
      "qmk/qmk"
      "osx-cross/arm"
    ];
    brews = [
      "displayplacer"
      "fish" # nixpkgs fish 4.2.1 has a broken Mach-O signature on aarch64-darwin (Killed: 9)
      # "qmk"
      "tfenv"
    ];
    casks = [
        "1password-cli"
        "1password"
        # "amazon-chime"
        "bettertouchtool"
        "cursor"
        "dash"
        # "docker"
        "finicky"
        "firefox"
        "google-chrome"
        "hex-fiend"
        "iina"
        "insomnia"
        "iterm2"
        "jordanbaird-ice"
        "keka"
        # "logi-options+" # Not good software
        # "microsoft-teams"
        "nextcloud"
        "parsec"
        "pgadmin4"
        "podman-desktop" # Using Docker Desktop for the time being
        # "postico" # Using pgAdmin4 instead
        # "postman" # Using Insomnia instead
        "provisionql"
        "qlcolorcode"
        "qlmarkdown"
        "qlstephen"
        "quicklook-video"
        "rectangle"
        # "signal" # Blocked on Firm laptop
        "slack"
        "spotify"
        "stay"
        # "steam" # Blocked on Firm laptop
        "sublime-text"
        "typora"
        "visual-studio-code"
        "webull"
        "workman"
        "zoom"
      ];
    masApps = {
      "1Password for Safari" = 1569813296;
      "Amphetamine" = 937984704;
      "Xcode" = 497799835;
      "Windows App" = 1295203466;
    };
  };

  system.activationScripts.quickLookQuarantine = lib.stringAfter [ "homebrew" ] ''
    quickLookDir="/Users/${config.system.primaryUser}/Library/QuickLook"
    if [ -d "$quickLookDir" ]; then
      echo "Removing quarantine from Quick Look plugins..."
      xattr -dr com.apple.quarantine "$quickLookDir" 2>/dev/null || true
    fi
  '';
}

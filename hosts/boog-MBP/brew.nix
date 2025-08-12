# Remove Quarantine Attribute:
# xattr -r ~/Library/QuickLook
# xattr -d -r com.apple.quarantine ~/Library/QuickLook

{ ... }: {
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = false;
      upgrade = false;
      cleanup = "zap";
    };
    taps = [
      "qmk/qmk"
    ];
    brews = [
      "displayplacer"
      "qmk"
      "tfenv"
    ];
    casks =
      let
        noQuarantine = name: {
          inherit name;
          args = { no_quarantine = true; };
        };
      in
      [
        "1password-cli"
        "1password"
        # "amazon-chime"
        # "bartender" # Using jordanbaird-ice instead, due to security issues
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
        "logi-options+" # Not good software
        "microsoft-teams"
        "monitorcontrol"
        "nextcloud"
        "parsec"
        "pgadmin4"
        "podman-desktop" # Using Docker Desktop for the time being
        # "postico" # Using pgAdmin4 instead
        # "postman" # Using Insomnia instead
        "provisionql"
        (noQuarantine "qlcolorcode")
        (noQuarantine "qlimagesize")
        (noQuarantine "qlmarkdown")
        (noQuarantine "qlstephen")
        (noQuarantine "qlvideo")
        (noQuarantine "quicklook-json")
        "rectangle"
        # "signal" # Blocked on Firm laptop
        "slack"
        "spotify"
        "stay"
        # "steam" # Blocked on Firm laptop
        "sublime-text"
        "typora"
        "visual-studio-code"
        "webex-meetings"
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
}

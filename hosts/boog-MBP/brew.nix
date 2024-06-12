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
        # "bartender"
        "bettertouchtool"
        "dash"
        # "displayplacer"
        "docker"
        "finicky"
        "firefox"
        "google-chrome"
        "hex-fiend"
        "iina"
        "insomnia"
        "iterm2"
        "jordanbaird-ice"
        "keka"
        "logi-options-plus"
        "microsoft-teams"
        "monitorcontrol"
        "nextcloud"
        "parsec"
        "podman-desktop"
        "postico"
        "postman"
        "provisionql"
        (noQuarantine "qlcolorcode")
        (noQuarantine "qlimagesize")
        (noQuarantine "qlmarkdown")
        (noQuarantine "qlstephen")
        (noQuarantine "qlvideo")
        (noQuarantine "quicklook-json")
        "rectangle"
        # "signal" # Blocked firm laptop
        "slack"
        "spotify"
        "stay"
        # "steam" # Blocked on firm laptop
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
    };
  };
}

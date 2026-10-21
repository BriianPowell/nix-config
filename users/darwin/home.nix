# Home Manager profile for Brian_Powell (macOS), on top of users/common/home.nix.
_: {
  fonts.enable = true;
  # Loads each repo's `.envrc` (`use flake`) on entry; fish integration is automatic.
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
  displayplacer.enable = true;
  finicky.enable = true;
  ssh.configFile = ./ssh.config;
  tooling.onePasswordAgentConfig = ./1password-agent.toml;
  home.file.".cursorignore".source = ./cursorignore;
}

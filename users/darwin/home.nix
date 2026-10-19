# Home Manager profile for Brian_Powell (macOS), on top of users/common/home.nix.
_: {
  fonts.enable = true;
  displayplacer.enable = true;
  finicky.enable = true;
  ssh.configFile = ./ssh.config;
  tooling.onePasswordAgentConfig = ./1password-agent.toml;
}

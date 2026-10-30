# Home Manager profile for Brian_Powell (macOS), on top of users/common/home.nix.
{ config, ... }:
{
  agents.enable = true;
  opencode = {
    enable = true;
    graphify.enable = true;
    mcp.presets = [
      "nixos"
      "context7"
      "github"
    ];
    # Set to an `op://` reference to read the token from 1Password instead of `gh`.
    # mcp.githubTokenRef = "op://Private/GitHub MCP/token";
  };
  # One model, loaded on demand and unloaded after 15 minutes without requests. The
  # endpoint, model id and context size reach OpenCode from here (home/modules/llm.nix).
  llm = {
    enable = true;
    defaultModel = "qwen";
    models.qwen = {
      name = "Qwen 3.5 122B A10B (UD-Q4_K_M)";
      file = "Qwen3.5-122B-A10B-MTP-GGUF/UD-Q4_K_M/Qwen3.5-122B-A10B-UD-Q4_K_M-00001-of-00003.gguf";
      ttl = 900;
    };
  };
  fonts.enable = true;
  # Loads each repo's `.envrc` (`use flake`) on entry; fish integration is automatic.
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
  # Default flake for `envrc_init` (home/fish/functions/envrc_init.fish).
  home.sessionVariables.ENVRC_FLAKE = config.agents.nixConfigPath;
  displayplacer.enable = true;
  finicky.enable = true;
  ssh.configFile = ./ssh.config;
  tooling.onePasswordAgentConfig = ./1password-agent.toml;
  home.file.".cursorignore".source = ./cursorignore;
}

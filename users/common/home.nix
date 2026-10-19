# Home Manager profile shared by every account I use (macOS and Linux/WSL):
# the module set, the modules enabled everywhere, and the values they share.
# Per-user files add to this; they only list what differs.
_: {
  imports = [
    ../../home
    ./atuin.nix
    ./git.nix
  ];

  atuin.enable = true;
  git.enable = true;
  fish.enable = true;
  ssh.enable = true;
  tmux.enable = true;
  tooling.enable = true;
  vim.enable = true;
}

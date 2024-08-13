{ dotfiles, pkgs, ... }: {
  home.file =
    if pkgs.system == "aarch64-darwin" then {
      ".ssh/config".source = "${dotfiles}/home/.ssh/darwin.config";
    } else {
      ".ssh/config".source = "${dotfiles}/home/.ssh/linux.config";
    };
}

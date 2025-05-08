{ pkgs, ... }: {
  security = {
    sudo.enable = false;
    # sudo-rs = {
    #   enable = true;
    #   execWheelOnly = true;
    #   wheelNeedsPassword = false;
    # };
    wrappers.sudo-rs = {
      #source = "${lib.getExe pkgs.sudo-rs}";
      source = "${pkgs.sudo-rs}/bin/sudo";
      setuid = true;
      setgid = true;
      owner = "0";
      group = "0";
    };
  };
}

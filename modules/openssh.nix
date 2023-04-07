{ ... }: {
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      # disable password authentication
      PasswordAuthentication = false;
      # challengeResponseAuthentication = false;
      KbdInteractiveAuthentication = false;
      X11Forwarding = false;
    };
  };
}

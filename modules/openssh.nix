{ ... }: {
  services.openssh = {
    enable = true;
    permitRootLogin = "no";

    # disable password authentication
    passwordAuthentication = false;
    # challengeResponseAuthentication = false;
    kbdInteractiveAuthentication = false;

    forwardX11 = false;
  };
}

{ ... }: {
  security = {
    # pam.services.sudo_local.touchIdAuth = true;
    pam.enableSudoTouchIdAuth = true;
  };
}

{ ... }:
{
  security = {
    pam.services.sudo_local.touchIdAuth = true;
    pam.services.sudo_local.watchIdAuth = true;
  };
}

# WSL host. Everything shared by WSL distros is in modules/wsl; this file only
# names the machine and its login user.
_: {
  networking.hostName = "gehenna";
  wsl.defaultUser = "boog";
}

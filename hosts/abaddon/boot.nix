{
  # Loader, kernel modules, sysctls and the remote-unlock initrd live in modules/server/boot.nix.
  server.luksUuid = "a4296409-c3b8-4984-ab51-17cec9209d32";
  server.nicDrivers = [ "e1000e" ];
}

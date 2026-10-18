{
  # Loader, kernel modules, sysctls and the remote-unlock initrd live in modules/server-boot.nix.
  server.luksUuid = "32155fc1-0d72-4cf5-a22b-280b8bf6896b";
  server.nicDrivers = [
    "e1000e"
    "r8169"
  ];

  # https://docs.k3s.io/security/hardening-guide#ensure-protect-kernel-defaults-is-set
  boot.kernel.sysctl = {
    "vm.panic_on_oom" = 0;
    "vm.overcommit_memory" = 1;
    "kernel.panic" = 10;
    "kernel.panic_on_oops" = 1;
  };
}

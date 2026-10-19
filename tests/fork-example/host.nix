# A made-up server for the fork acceptance check: only the values a fork must supply
# for a host on top of the server role, a site and a user.
_: {
  imports = [ ./site.nix ];

  networking.hostName = "example-node";
  networking.interfaces.eth0.useDHCP = true;

  server = {
    luksUuid = "00000000-0000-0000-0000-000000000001";
    nicDrivers = [ "e1000e" ];
    disks = {
      root = "00000000-0000-0000-0000-000000000002";
      efi = "AAAA-AAAA";
      home = "00000000-0000-0000-0000-000000000003";
    };
  };

  services.k3s.role = "server";
}

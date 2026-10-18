# Values that describe a location (network and who administers it) rather than a
# machine or a role. Shared modules read `config.site.*`; each location supplies
# them in one file under sites/, which its hosts import. There are no defaults, so
# a host that forgets to import a site fails to build instead of inheriting
# someone else's network.
{ lib, ... }:
{
  options.site = {
    gateway = lib.mkOption {
      type = lib.types.str;
      example = "192.168.1.1";
      description = "Default IPv4 gateway for the servers at this site.";
    };

    dns = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      example = [ "192.168.1.1" ];
      description = "DNS resolvers, also used as the fallback and inside the initrd.";
    };

    initrdAuthorizedKeys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = ''
        Public SSH keys allowed to unlock the disks over ssh at boot. Each can
        only run `systemctl default` (see modules/server/boot.nix).
      '';
    };
  };
}

# Tailscale for a NixOS host. Off by default; a host turns it on and points it at an
# agenix auth key (see docs/TAILSCALE.md for creating the key and the tailnet side).
#
# https://tailscale.com/kb/1096/nixos-minecraft
# https://search.nixos.org/options?query=services.tailscale
{ config, lib, ... }:
let
  cfg = config.tailscale;
  secretName = "tailscale/auth-key";
in
{
  options.tailscale = {
    enable = lib.mkEnableOption "Tailscale";

    authKeyFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = ''
        agenix file holding a Tailscale auth key. It is only used when the node is not
        logged in yet; after that the node keeps its own identity across reboots and
        rebuilds. Use a tagged, pre-approved key so the node is not tied to a person.
      '';
    };

    tags = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "tag:server" ];
      description = "Tags the node advertises. They must be allowed for the auth key and defined in the tailnet's ACL policy.";
    };

    allowedTCPPorts = lib.mkOption {
      type = lib.types.listOf lib.types.port;
      default = [ 22 ];
      description = ''
        TCP ports reachable through the tailnet interface. The interface is not trusted,
        so anything not listed stays closed to the tailnet, whatever the ACLs say.
      '';
    };

    acceptDns = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Let Tailscale manage this host's DNS (MagicDNS). Off, so a node's resolver stays what the site file says.";
    };

    advertiseRoutes = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "192.168.1.0/24" ];
      description = "Subnets this host routes for the tailnet (a subnet router). The routes still have to be approved in the Tailscale admin console.";
    };

    extraUpFlags = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Extra flags for the first `tailscale up`.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.authKeyFile != null;
        message = "tailscale.enable needs tailscale.authKeyFile (an agenix file); without it the node never joins the tailnet.";
      }
    ];

    age.secrets.${secretName}.file = cfg.authKeyFile;

    services.tailscale = {
      enable = true;
      authKeyFile = config.age.secrets.${secretName}.path;
      # A subnet router needs IP forwarding; a plain node only needs loose reverse-path
      # filtering, which the module sets for either value except "none".
      useRoutingFeatures = if cfg.advertiseRoutes == [ ] then "client" else "both";
      extraUpFlags =
        lib.optional (cfg.tags != [ ]) "--advertise-tags=${lib.concatStringsSep "," cfg.tags}"
        ++ lib.optional (
          cfg.advertiseRoutes != [ ]
        ) "--advertise-routes=${lib.concatStringsSep "," cfg.advertiseRoutes}"
        ++ [ "--accept-dns=${lib.boolToString cfg.acceptDns}" ]
        ++ cfg.extraUpFlags;
    };

    # Not a trusted interface: open only what is listed.
    networking.firewall.interfaces.${config.services.tailscale.interfaceName}.allowedTCPPorts =
      cfg.allowedTCPPorts;
  };
}

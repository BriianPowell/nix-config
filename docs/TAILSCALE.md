# Tailscale

`modules/tailscale.nix` is an opt-in NixOS module (off by default; the server role
imports it). Tracking issue: [#70](https://github.com/BriianPowell/nix-config/issues/70).

**Status: not used on my hosts.** I tried it on one node and removed it again: a device
policy on the machine I use most blocks Tailscale's system extension, and the UDM's
WireGuard server already covers remote access. The module stays for anyone who wants
it. It was last used with the steps below; nothing in this repo creates the auth key
or the secret for you.

## Design

- Servers join with a **tagged, pre-approved auth key**, so they belong to a tag, not to
  a person's login. The key is only used on the first start; afterwards a node keeps its
  own identity across reboots and rebuilds.
- The `tailscale0` interface is **not trusted**. Only `tailscale.allowedTCPPorts`
  (default SSH) is open on it, whatever the tailnet's ACLs say.
- MagicDNS is off on servers by default (`tailscale.acceptDns = false`), so a node's
  resolver stays what the site file says.
- Tailscale is not running during the initrd, so it does not help the remote LUKS
  unlock. After a power cut, unlocking still needs a LAN path.
- If both servers are down, there is no remote access until someone unlocks them.
- Do not run Tailscale on the UniFi router. To reach the whole LAN, advertise a subnet
  from a server (`tailscale.advertiseRoutes`) and approve the route in the admin console.
  `modules/server/tcp-hardening.nix` sets strict reverse-path filtering, which can drop
  asymmetric traffic through a subnet router; check that before relying on one.

## Turning it on

1. In the Tailscale admin console, define the tag in the ACL policy and let your user
   own it, for example `"tagOwners": { "tag:server": ["autogroup:admin"] }`, and allow
   your devices to reach `tag:server` on the ports you open.
2. Create an auth key: reusable, pre-approved, with the tag `tag:server`. An OAuth
   client that mints short-lived keys is better where you can use one.
3. Store it, from the dev shell (see `secrets/ssh/README.md` for the agenix setup):

   ```sh
   cd secrets && printf '%s' "$KEY" | agenix -e tailscale/auth-key.age
   ```

4. Add its rule to `secrets/agenix-rules.nix`:

   ```nix
   "tailscale/auth-key.age".publicKeys = hosts ++ users;
   ```

   `nix flake check` fails if a rule has no file or a file has no rule.
5. Enable it on a host:

   ```nix
   tailscale = {
     enable = true;
     authKeyFile = ../../secrets/tailscale/auth-key.age;
     tags = [ "tag:server" ];
     allowedTCPPorts = [ 22 6443 ];
   };
   ```

6. Deploy one node first (`nixos_remote test abaddon`) and check that it appears in the
   admin console with its tag before enabling the second.

## Not done yet

The Mac as a client, `nixos_remote` preferring the tailnet address off the LAN, a subnet
router, and Keycloak as the sign-in provider. They are listed in the issue.

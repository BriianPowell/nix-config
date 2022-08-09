# Nix Server

## [Installation](docs/installation.md)

How to do the initial NixOS installtion

## Using unstable

```sh
sudo nix-channel --add https://nixos.org/channels/nixos-unstable nixos-unstable
sudo nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixpkgs
sudo nix-channel --update nixpkgs
```

## Troubleshooting

### Random issues with Home Manager?

Try updating channels:

```sh
sudo nix-channel --update
```

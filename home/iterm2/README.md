# iTerm2 configuration (per user)

Managed by `home/modules/iterm2.nix`.

## Per-user setup

```nix
# users/darwin/iterm2.nix
{ pkgs, ... }: {
  iterm2 = {
    enable = true;
    plistFile = ../../home/iterm2/com.googlecode.iterm2.plist;
    extraSettings.Command = "${pkgs.fish}/bin/fish";
  };
}
```

## Export main plist

Quit iTerm2, then:

```bash
cp ~/Library/Preferences/com.googlecode.iterm2.plist \
   home/iterm2/com.googlecode.iterm2.plist
```

## Apply

```bash
darwin-rebuild switch --flake .#boog-MBP
```

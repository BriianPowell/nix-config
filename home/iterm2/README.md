# iTerm2 configuration (per user)

Managed by `home/modules/iterm2.nix`.

## Per-user setup

```nix
# users/darwin/iterm2.nix
{ dotfiles, pkgs, ... }: {
  programs.iterm2 = {
    enable = true;
    plistFile = "${dotfiles}/settings/iTerm2/com.googlecode.iterm2.plist";
    extraSettings = {
      Command = "${pkgs.fish}/bin/fish";
    };
    dynamicProfiles = [ ../../home/iterm2/dynamic-profiles/work.json ];
  };
}
```

Wire the file in `users/darwin/default.nix`:

```nix
home-manager.users.Brian_Powell.imports = [
  import ../../home
  ./rectangle.nix
  ./iterm2.nix
];
```

## Options

| Option | Purpose |
|--------|---------|
| `plistFile` | Full `com.googlecode.iterm2.plist` (themes, keys, status bar, etc.) |
| `dynamicProfiles` | JSON profile files → `~/Library/Application Support/iTerm2/DynamicProfiles/` |
| `extraSettings` | Flat plist keys merged with `defaults import` (shell path, etc.) |

## Export / update main plist

```bash
# Quit iTerm2 first
cp ~/Library/Preferences/com.googlecode.iterm2.plist \
   /path/to/dotfiles/settings/iTerm2/com.googlecode.iterm2.plist

# Or XML export
defaults export com.googlecode.iterm2 - > com.googlecode.iterm2.plist
```

Review for secrets (AI API keys, tokens) before committing.

## Dynamic profiles only

iTerm → Settings → Profiles → Other actions → Export JSON.

Save under `home/iterm2/dynamic-profiles/` and list paths in `dynamicProfiles`.

## Apply

```bash
darwin-rebuild switch --flake .#boog-MBP
killall iTerm2; open -a iTerm
```

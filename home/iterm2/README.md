# iTerm2 configuration (per user)

Managed by `home/modules/iterm2.nix`.

## Per-user setup

```nix
# users/darwin/iterm2.nix
{ pkgs, ... }: {
  iterm2 = {
    enable = true;
    plistFile = ../../home/iterm2/com.googlecode.iterm2.plist;
    dynamicProfiles = [
      ../../home/iterm2/BooG.json
    ];
    extraSettings.Command = "${pkgs.fish}/bin/fish";
  };
}
```

Dynamic profiles are installed to
`~/Library/Application Support/iTerm2/DynamicProfiles/`.
The main plist must reference the profile you want as default (see `Default Bookmark Guid`).

## Export dynamic profile

In iTerm → **Settings → Profiles → [your profile] → Other Actions → Save Profile as JSON**.

That export is a single profile object. The module wraps it as `{ "Profiles": [ … ] }` automatically.

```bash
cp ~/Library/Application\ Support/iTerm2/DynamicProfiles/BooG.json \
   home/iterm2/BooG.json
```

Add the path to `dynamicProfiles` in `users/darwin/iterm2.nix`, then re-export the main plist if you changed the default profile.

Verify after rebuild:

```bash
ls -la ~/.config/iterm2/dynamic-profiles/
ls -la ~/Library/Application\ Support/iTerm2/DynamicProfiles/
# BooG.json should symlink into ~/.config/iterm2/dynamic-profiles/
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

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

**Font name:** iTerm uses the font’s **PostScript name**, not the `.ttf` filename. For `nerd-fonts.jetbrains-mono` on macOS that is usually `JetBrainsMonoNFM-Regular` (mono) or `JetBrainsMonoNF-Regular` (non-mono). Names like `JetBrainsMonoNerdFont-Regular` are not registered and iTerm falls back to Menlo at 11pt.

```bash
cp ~/Library/Application\ Support/iTerm2/DynamicProfiles/BooG.json \
   home/iterm2/BooG.json
```

Add the path to `dynamicProfiles` in `users/darwin/iterm2.nix`, then re-export the main plist if you changed the default profile.

Dynamic profiles are installed to
`~/Library/Application Support/iTerm2/DynamicProfiles/`.
The main plist must reference the profile you want as default (see `Default Bookmark Guid`).
BooG is defined only in `BooG.json` — do not also embed it in `New Bookmarks` in the plist.

## Verify after rebuild

```bash
# Dynamic profile symlink into the nix store
ls -la ~/Library/Application\ Support/iTerm2/DynamicProfiles/

# Plist must be a real file, not a nix-store symlink
file ~/Library/Preferences/com.googlecode.iterm2.plist

# cfprefsd should expose the default profile GUID
defaults read com.googlecode.iterm2 "Default Bookmark Guid"
# Expected: e31bc19a-e56a-4f41-84e2-ae803b7a8c79
```

If `defaults read` says the domain does not exist, the plist is still symlinked or import
did not run. Quit iTerm, rebuild, or manually:

```bash
PLIST="$(readlink -f ~/Code/personal/nix-config/home/iterm2/com.googlecode.iterm2.plist)"
cp "$PLIST" ~/Library/Preferences/com.googlecode.iterm2.plist
defaults import com.googlecode.iterm2 ~/Library/Preferences/com.googlecode.iterm2.plist
killall cfprefsd
```

Test with a fresh window (⌘N), not a restored session. To ignore restored windows:

```bash
osascript -e 'quit app "iTerm"'
rm -rf ~/Library/Application\ Support/iTerm2/SavedState/*
open -a iTerm
```

## Export main plist

Preferences are applied with `defaults import` on each rebuild (not only the plist symlink). Quit iTerm2 first if changes do not show up.

Quit iTerm2, then:

```bash
cp ~/Library/Preferences/com.googlecode.iterm2.plist \
   home/iterm2/com.googlecode.iterm2.plist
```

## Apply

```bash
darwin-rebuild switch --flake .#boog-MBP
```

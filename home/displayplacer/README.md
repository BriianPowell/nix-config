# displayplacer layouts

Managed by `home/modules/displayplacer.nix`. Requires the `displayplacer` Homebrew formula.

## Regenerate layout

Display IDs change when you unplug monitors or change cables:

```bash
displayplacer list
```

Update `desk-layout.sh` with the new `displayplacer "id:…" …` line (or only the quoted segments—see module).

## Apply

```bash
display-desk
```

## Per-user

```nix
# users/darwin/displayplacer.nix
{
  displayplacer = {
    enable = true;
    layoutFile = ../../home/displayplacer/desk-layout.sh;
  };
}
```

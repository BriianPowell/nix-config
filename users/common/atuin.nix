# Atuin sync server shared by every account I use.
# Options: https://docs.atuin.sh/configuration/config/
_: {
  atuin.settings = {
    sync_address = "https://atuin.powell.place";

    # Typo-tolerant search instead of the default full-text match.
    search_mode = "fuzzy";

    # Compact list that takes 20 lines under the prompt instead of the whole screen.
    style = "compact";
    inline_height = 20;

    # Never record lines that look like they contain keys, tokens or passwords (the default in
    # recent versions; stated here so an older client behaves the same).
    secrets_filter = true;
  };
}

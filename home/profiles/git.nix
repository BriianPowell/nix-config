{ ... }: {
  programs.git = {
    enable = true;
    userName = "Brian Powell";
    userEmail = "brian@powell.place";
    extraConfig = {
      core = {
        editor = "vim";
      };
      url = {
        "git@github.com:" = {
          insteadOf = "https://github.com/";
        };
      };
      pull = {
        rebase = true;
      };
    };
    ignores = [ ".DS_Store" ];
  };
}

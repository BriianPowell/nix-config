{ pkgs, inputs, ... }: {
  environment = {
    shells = with pkgs; [ fish ];

    variables = {
      EDITOR = "vim";
      VISUAL = "vim";
    };

    systemPackages = with pkgs; [
      # Secrets Management
      inputs.agenix.packages."${system}".default

      # Build Tools
      # deno # https://deno.land/
      # ruby # https://www.ruby-lang.org/en/
      rbenv # https://github.com/rbenv/rbenv
      pyenv # https://github.com/pyenv/pyenv

      # Terminal Tools
      atuin # https://docs.atuin.sh/
      fish # https://fishshell.com/
      eternal-terminal # https://eternalterminal.dev/
      tmux # https://github.com/tmux/tmux
      git # https://git-scm.com/
      bat # https://github.com/sharkdp/bat
      lynx # https://lynx.invisible-island.net/
      most # https://www.jedsoft.org/most/index.html
      ncdu # https://dev.yorhel.nl/ncdu
      curl # https://curl.se/
      wget # https://www.gnu.org/software/wget/
      nurl # https://github.com/nix-community/nurl
      # httpie # https://httpie.io/

      nixpkgs-fmt # https://github.com/nix-community/nixpkgs-fmt
      nil # https://github.com/oxalica/nil
      jq # https://stedolan.github.io/jq/
      ripgrep # https://github.com/BurntSushi/ripgrep

      # helix # https://helix-editor.com/

      # System Monitoring
      htop # https://github.com/htop-dev/htop/
      bottom # https://github.com/ClementTsang/bottom
      bind # https://www.isc.org/bind/
      # dig # https://www.isc.org/bind/
      pciutils # https://mj.ucw.cz/sw/pciutils/
      smartmontools # https://www.smartmontools.org/

      # k8s
      argocd # https://argo-cd.readthedocs.io/en/stable/
      fluxcd # https://fluxcd.io/
      kubectl # https://github.com/kubernetes/kubectl
      kubernetes-helm # https://github.com/helm/helm
      kubeseal # https://github.com/bitnami-labs/sealed-secrets
    ];
  };
}

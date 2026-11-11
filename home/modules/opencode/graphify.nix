# graphify: a code knowledge graph the agent can query (used by /bootstrap).
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.opencode;

  # graphify re-executes itself with PYTHONHASHSEED=0 through the bare interpreter,
  # which cannot see the nix site-packages; setting it up front skips that step.
  # The query log is off unless you turn it on.
  graphify = pkgs.symlinkJoin {
    name = "graphify-wrapped";
    paths = [ pkgs.graphify ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/graphify \
        --set PYTHONHASHSEED 0 \
        --set-default GRAPHIFY_QUERY_LOG_DISABLE 1
    '';
  };
in
{
  options.opencode.graphify.enable = lib.mkEnableOption "graphify, a code knowledge graph the agent can query";

  config = lib.mkIf (cfg.enable && cfg.graphify.enable) {
    home.packages = [ graphify ];
  };
}

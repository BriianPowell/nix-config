# OpenCode config pointing at a local OpenAI-compatible server, plus shared commands,
# skills and plugins from home/opencode/.
#
#   permission.nix  read/bash rules from agents.protect, and disabled tools
#   mcp.nix         MCP server presets (nixos, context7, github) and extra servers
#   graphify.nix    the graphify code-graph tool (/bootstrap in OpenCode uses it)
#   (this file)     provider, models and agent options; writes opencode.json
#
# Per user: opencode.enable = true;
# Overrides: opencode.baseURL / models / permission / extraSettings
# MCP servers: opencode.mcp.presets or opencode.mcp.servers
# Code graph:  opencode.graphify.enable
#
# With llm.enable (home/modules/llm.nix) the endpoint, the model ids, the context sizes
# and the default model all come from llm.models, so they match what llama-swap
# serves. Without it, this assumes one `llama-server` you start yourself, e.g.
#   llama-server -m ~/models/<model>.gguf --port 8080 --jinja -c 131072
# and opencode.contextLimit has to equal its -c: OpenCode decides when to compact from it.
#
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.opencode;
  json = pkgs.formats.json { };

  inherit (config) llm;
  llmModelNames = lib.attrNames llm.models;
in
{
  imports = [
    ./graphify.nix
    ./mcp.nix
    ./permission.nix
  ];

  options.opencode = {
    enable = lib.mkEnableOption "OpenCode config for a local llama-server";

    baseURL = lib.mkOption {
      type = lib.types.str;
      default = if llm.enable then "http://${llm.listen}/v1" else "http://127.0.0.1:8080/v1";
      defaultText = lib.literalExpression ''"http://''${config.llm.listen}/v1" when llm.enable, else "http://127.0.0.1:8080/v1"'';
      description = "OpenAI-compatible endpoint of the local server.";
    };

    apiKey = lib.mkOption {
      type = lib.types.str;
      default = "local";
      description = ''
        Placeholder key. The local server does not check it, but some
        OpenAI-compatible clients refuse to start without one. Not a secret.
      '';
    };

    requestTimeout = lib.mkOption {
      type = lib.types.ints.positive;
      default = 1800000;
      description = ''
        Milliseconds OpenCode waits for a response from the local server, and between
        streamed chunks. The default is 5 minutes, but a large local model can spend
        longer reading a long prompt before its first token, or queue a request behind
        another one when the server has a single slot (-np 1). A timed-out request is
        retried, which repeats the same wait.
      '';
    };

    providerName = lib.mkOption {
      type = lib.types.str;
      default = "llama";
      description = "Provider id used in OpenCode (shown as <id>/<model>).";
    };

    contextLimit = lib.mkOption {
      type = lib.types.ints.positive;
      default = 131072;
      description = "Context window of the served model; must match llama-server -c.";
    };

    outputLimit = lib.mkOption {
      type = lib.types.ints.positive;
      default = 16384;
      description = "Max tokens per response OpenCode reserves; must be below contextLimit.";
    };

    models = lib.mkOption {
      type = lib.types.attrsOf lib.types.attrs;
      default =
        if llm.enable then
          lib.mapAttrs (id: m: {
            name = if m.name != null then m.name else id;
            tool_call = true;
            limit = {
              context = m.contextSize;
              output = m.outputLimit;
            };
          }) llm.models
        else
          {
            # A lone llama-server serves whichever model it loaded and ignores
            # this id, so the key is just a label.
            local = {
              name = "Local model (llama-server)";
              tool_call = true;
              limit = {
                context = cfg.contextLimit;
                output = cfg.outputLimit;
              };
            };
          };
      defaultText = lib.literalExpression "llm.models when llm.enable, else { local = { ... }; }";
      description = "Models registered under the provider. The keys must be the ids the server reports.";
    };

    defaultModel = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default =
        if !llm.enable then
          "local"
        else if llm.defaultModel != null then
          llm.defaultModel
        else if lib.length llmModelNames == 1 then
          lib.head llmModelNames
        else
          null;
      defaultText = lib.literalExpression "llm.defaultModel (or the only llm model); \"local\" without llm";
      description = "Model key to select by default; null to leave unset.";
    };

    smallModel = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Use the default model for OpenCode's small tasks (titles, summaries).
        Otherwise it tries a hosted small model that is not configured here.
      '';
    };

    defaultAgent = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = "plan";
      description = "Agent to start in. plan cannot edit or run commands without asking.";
    };

    extraSettings = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Merged (shallow) into the top level of opencode.json.";
    };

    # Fragments from permission.nix and mcp.nix; merged into opencode.json below.
    settings = lib.mkOption {
      inherit (json) type;
      default = { };
      internal = true;
      description = "opencode.json content contributed by the opencode modules.";
    };
  };

  config = lib.mkIf cfg.enable {
    opencode.settings = {
      "$schema" = "https://opencode.ai/config.json";
      provider.${cfg.providerName} = {
        npm = "@ai-sdk/openai-compatible";
        name = "llama.cpp (local)";
        options = {
          inherit (cfg) baseURL apiKey;
          timeout = cfg.requestTimeout;
          chunkTimeout = cfg.requestTimeout;
        };
        inherit (cfg) models;
      };
    }
    // lib.optionalAttrs (cfg.defaultModel != null) {
      model = "${cfg.providerName}/${cfg.defaultModel}";
    }
    // lib.optionalAttrs (cfg.defaultModel != null && cfg.smallModel) {
      small_model = "${cfg.providerName}/${cfg.defaultModel}";
    }
    // lib.optionalAttrs (cfg.defaultAgent != null) {
      default_agent = cfg.defaultAgent;
    };

    xdg.configFile = {
      # extraSettings win over everything above (shallow merge).
      "opencode/opencode.json".source = json.generate "opencode.json" (cfg.settings // cfg.extraSettings);

      # Per-file links so ~/.config/opencode stays a real directory
      # (OpenCode keeps node_modules and bun.lock there).
      "opencode/commands" = {
        source = ../../opencode/commands;
        recursive = true;
      };
      "opencode/skills" = {
        source = ../../opencode/skills;
        recursive = true;
      };
      "opencode/plugins" = {
        source = ../../opencode/plugins;
        recursive = true;
      };
    };
  };
}

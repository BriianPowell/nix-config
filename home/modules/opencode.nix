# OpenCode config pointing at a local OpenAI-compatible server, plus shared commands,
# skills and plugins from home/opencode/.
#
# Per user: opencode.enable = true;
# Overrides: opencode.baseURL / models / permission / extraSettings
# MCP servers: opencode.mcp.presets (nixos, context7, github) or opencode.mcp.servers
# Code graph:  opencode.graphify.enable (installs graphify; /bootstrap in OpenCode uses it)
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

  disabledToolPermissions = lib.genAttrs cfg.disabledTools (_: "deny");

  inherit (config) llm;
  llmModelNames = lib.attrNames llm.models;

  # Servers are started from nix store paths, never `npx -y`, so nothing is
  # downloaded and run at launch. Each server adds its tool descriptions to every
  # request, which costs context on a local model, so presets stay few.
  githubMcp = pkgs.writeShellScript "github-mcp" ''
    ${
      if cfg.mcp.githubTokenRef != null then
        "GITHUB_PERSONAL_ACCESS_TOKEN=$(op read ${lib.escapeShellArg cfg.mcp.githubTokenRef})"
      else
        "GITHUB_PERSONAL_ACCESS_TOKEN=$(${pkgs.gh}/bin/gh auth token)"
    }
    export GITHUB_PERSONAL_ACCESS_TOKEN
    exec ${pkgs.github-mcp-server}/bin/github-mcp-server stdio \
      ${lib.optionalString cfg.mcp.githubReadOnly "--read-only"} \
      --toolsets repos,issues,pull_requests
  '';

  mcpPresets = {
    nixos = {
      type = "local";
      command = [ "${pkgs.mcp-nixos}/bin/mcp-nixos" ];
    };
    context7 = {
      type = "local";
      command = [ "${pkgs.context7-mcp}/bin/context7-mcp" ];
    };
    github = {
      type = "local";
      command = [ "${githubMcp}" ];
    };
  };

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

    disabledTools = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [
        "question"
        "todowrite"
      ];
      description = "Built-in tools to deny; each removed tool shrinks the system prompt.";
    };

    permission = lib.mkOption {
      type = lib.types.attrs;
      # Attribute names are serialised in sorted order and OpenCode applies the
      # last matching rule, so every "*" catch-all must sort before the specific
      # patterns below it (it does: "*" is a prefix of all of them).
      default = {
        read = {
          "*" = "allow";
          "*.env" = "deny";
          "*.env.*" = "deny";
          "*.env.example" = "allow";
          "*.age" = "deny";
          "*.key" = "deny";
          "*/secrets/*" = "deny";
          "secrets/*" = "deny";
        };
        bash = {
          "*" = "allow";
          "darwin-rebuild switch*" = "ask";
          # An .envrc runs code on load; approving one is the user's decision.
          "direnv allow*" = "ask";
          "direnv reload*" = "ask";
          "git commit*" = "ask";
          "git push*" = "ask";
          "kubectl apply*" = "ask";
          "kubectl delete*" = "ask";
          "rm -rf *" = "ask";
          "sudo *" = "ask";
        };
      };
      description = "Merged into the top-level permission block of opencode.json.";
    };

    mcp = {
      presets = lib.mkOption {
        type = lib.types.listOf (lib.types.enum (lib.attrNames mcpPresets));
        default = [ ];
        example = [
          "nixos"
          "context7"
        ];
        description = ''
          Ready-made MCP servers:
            nixos     NixOS, Home Manager and nix-darwin option and package lookup
            context7  current library documentation (queries leave the machine)
            github    repos, issues and pull requests (read-only by default)
        '';
      };

      servers = lib.mkOption {
        type = lib.types.attrsOf lib.types.attrs;
        default = { };
        description = "Extra entries for the `mcp` block of opencode.json; same shape as OpenCode's mcp config.";
      };

      githubTokenRef = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        example = "op://Private/GitHub MCP/token";
        description = ''
          1Password secret reference (not the secret) that the github preset reads
          with `op read` at launch. Null falls back to `gh auth token`, which carries
          whatever scopes `gh` was logged in with.
        '';
      };

      githubReadOnly = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Start the github server with --read-only.";
      };
    };

    graphify.enable = lib.mkEnableOption "graphify, a code knowledge graph the agent can query";

    extraSettings = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Merged (shallow) into the top level of opencode.json.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = lib.optional cfg.graphify.enable graphify;

    xdg.configFile = {
      "opencode/opencode.json".source = json.generate "opencode.json" (
        {
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
          permission = cfg.permission // disabledToolPermissions;
        }
        // lib.optionalAttrs (cfg.defaultModel != null) {
          model = "${cfg.providerName}/${cfg.defaultModel}";
        }
        // lib.optionalAttrs (cfg.defaultModel != null && cfg.smallModel) {
          small_model = "${cfg.providerName}/${cfg.defaultModel}";
        }
        // lib.optionalAttrs (cfg.defaultAgent != null) {
          default_agent = cfg.defaultAgent;
        }
        // lib.optionalAttrs (cfg.mcp.presets != [ ] || cfg.mcp.servers != { }) {
          mcp = lib.genAttrs cfg.mcp.presets (name: mcpPresets.${name}) // cfg.mcp.servers;
        }
        // cfg.extraSettings
      );

      # Per-file links so ~/.config/opencode stays a real directory
      # (OpenCode keeps node_modules and bun.lock there).
      "opencode/commands" = {
        source = ../opencode/commands;
        recursive = true;
      };
      "opencode/skills" = {
        source = ../opencode/skills;
        recursive = true;
      };
      "opencode/plugins" = {
        source = ../opencode/plugins;
        recursive = true;
      };
    };
  };
}

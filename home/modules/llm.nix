# Local LLM serving: llama-swap in front of llama.cpp's `llama-server`.
#
# llama-swap starts a model when the first request arrives, proxies the
# OpenAI-compatible API, and unloads the model again after `ttl` seconds without
# requests, so a large model does not hold memory while the Mac is used for
# other things. It runs as a login item (launchd user agent) on `listen`.
#
# One list of models drives everything: the llama-swap config and, through
# opencode.nix, the OpenCode provider (same ids, same context sizes), so the
# three places that have to agree cannot drift apart.
#
# Per user: llm.enable = true; llm.models.<id> = { file = "<path under modelsDir>"; };
# Overrides: llm.modelsDir / listen / ttl / defaultModel, per model contextSize,
# outputLimit, extraArgs.
#
# Models are GGUF files (llama.cpp cannot load safetensors). Download with e.g.
#   hf download <org>/<repo> --include "<quant>/*" --local-dir ~/models/<repo>
# and point `file` at the first shard (`-00001-of-N`) of a split model.
#
# https://github.com/mostlygeek/llama-swap
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.llm;
  yaml = pkgs.formats.yaml { };

  llamaServer = "${pkgs.llama-cpp}/bin/llama-server";

  modelPath = m: if lib.hasPrefix "/" m.file then m.file else "${cfg.modelsDir}/${m.file}";

  swapConfig = {
    # Loading a model of this size from disk takes a while; the default is too short.
    healthCheckTimeout = cfg.loadTimeout;
    models = lib.mapAttrs (id: m: {
      name = if m.name != null then m.name else id;
      inherit (m) ttl;
      # llama-swap substitutes ${PORT} with a free port for each server it starts.
      cmd = lib.concatStringsSep " " (
        [
          llamaServer
          "--port"
          "\${PORT}"
          "--model"
          (modelPath m)
          "--ctx-size"
          (toString m.contextSize)
        ]
        ++ m.extraArgs
      );
    }) cfg.models;
  };
in
{
  options.llm = {
    enable = lib.mkEnableOption "llama-swap serving local GGUF models";

    listen = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1:8080";
      description = ''
        Address llama-swap listens on. Keep it on loopback: the API has no
        authentication, so binding it to the network would expose the models.
      '';
    };

    modelsDir = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/models";
      defaultText = lib.literalExpression ''"''${config.home.homeDirectory}/models"'';
      description = "Directory model `file` paths are relative to.";
    };

    loadTimeout = lib.mkOption {
      type = lib.types.ints.positive;
      default = 600;
      description = "Seconds to wait for a model to finish loading before giving up.";
    };

    defaultModel = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Model id OpenCode selects by default. Null picks the only model when there is exactly one.";
    };

    models = lib.mkOption {
      default = { };
      description = "Models by id. The id is what clients put in the `model` field of a request.";
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            file = lib.mkOption {
              type = lib.types.str;
              example = "Qwen3.5-122B-A10B-MTP-GGUF/UD-Q4_K_M/Qwen3.5-122B-A10B-UD-Q4_K_M-00001-of-00003.gguf";
              description = "GGUF file, relative to modelsDir or absolute. For a split model, the first shard.";
            };
            name = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "Display name; defaults to the id.";
            };
            contextSize = lib.mkOption {
              type = lib.types.ints.positive;
              default = 131072;
              description = "Context window passed to llama-server (--ctx-size). OpenCode uses the same value to decide when to compact.";
            };
            outputLimit = lib.mkOption {
              type = lib.types.ints.positive;
              default = 16384;
              description = "Max tokens per response OpenCode reserves; must be below contextSize.";
            };
            ttl = lib.mkOption {
              type = lib.types.ints.unsigned;
              default = 900;
              description = "Seconds without requests before the model is unloaded. 0 keeps it loaded.";
            };
            extraArgs = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [
                "-ngl"
                "99"
                "-fa"
                "on"
                "-np"
                "1"
                "--jinja"
                "--reasoning-format"
                "deepseek"
              ];
              description = "Further llama-server arguments (GPU layers, flash attention, one slot, chat template).";
            };
          };
        }
      );
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.models != { };
        message = "llm.enable needs at least one entry in llm.models.";
      }
      {
        assertion = lib.all (m: m.outputLimit < m.contextSize) (lib.attrValues cfg.models);
        message = "llm.models: each outputLimit must be below its contextSize.";
      }
      {
        assertion = cfg.defaultModel == null || cfg.models ? ${cfg.defaultModel};
        message = "llm.defaultModel must be one of llm.models.";
      }
    ];

    xdg.configFile."llama-swap/config.yaml".source = yaml.generate "llama-swap.yaml" swapConfig;

    home.packages = [ pkgs.llama-swap ];

    launchd.agents.llama-swap = {
      enable = true;
      config = {
        ProgramArguments = [
          "${pkgs.llama-swap}/bin/llama-swap"
          "--config"
          "${config.xdg.configHome}/llama-swap/config.yaml"
          "--listen"
          cfg.listen
        ];
        RunAtLoad = true;
        KeepAlive = true;
        StandardOutPath = "${config.home.homeDirectory}/Library/Logs/llama-swap.log";
        StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/llama-swap.log";
      };
    };
  };
}

{ config, lib, pkgs, username, ... }:
let
  cfg = config.services.ai;
in {
  options = {
    services.ai = {
      enable = lib.mkEnableOption "AI services (Ollama, Open WebUI)";
      acceleration = lib.mkOption {
        type = lib.types.enum [ "rocm" "cuda" "false" ];
        default = "false";
        description = "Hardware acceleration for AI workloads (rocm, cuda, or false to disable)";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.ollama = {
      enable = true;
      package = if cfg.acceleration == "false"
        then pkgs.unstable.ollama
        else pkgs.unstable."ollama-${cfg.acceleration}";
    };

    services.open-webui = {
      enable = false;
      package = pkgs.unstable.open-webui;
      port = 3000;
      environment = {
        OLLAMA_API_BASE_URL = "http://127.0.0.1:11434";
        # Disable Open WebUI built-in auth for local-only use
        WEBUI_AUTH = "False";
      };
    };

    # Ensure the user has GPU access groups for ROCm/CUDA acceleration
    users.users.${username}.extraGroups =
      lib.optionals (cfg.acceleration == "rocm") [ "render" "video" ];
  };
}

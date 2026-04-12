{ config, lib, pkgs, username, ... }:
let
  ai-tools = config.ai-tools;
in {
  options = {
    ai-tools = {
      enable = lib.mkEnableOption "AI tools support";
      acceleration = lib.mkOption {
        type = lib.types.enum [ "rocm" "cuda" "false" ];
        default = "false";
        description = "Hardware acceleration for AI workloads (rocm, cuda, or false to disable)";
      };
    };
  };

  config = lib.mkIf ai-tools.enable {
    services.ollama = {
      enable = true;
      package = pkgs.unstable.ollama;
      acceleration = ai-tools.acceleration;
    };

    services.open-webui = {
      enable = true;
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
      lib.optionals (ai-tools.acceleration == "rocm") [ "render" "video" ];
  };
}

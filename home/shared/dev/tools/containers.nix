{pkgs, config, lib, ...} :
let
  cfg = config.dev.tools;
in {
  options = {
    dev.tools.containers = {
      enable = lib.mkEnableOption "Container development tools";
    };
  };

  config = lib.mkIf cfg.containers.enable {
    home.packages = with pkgs; [ 
      dive
    ];
  };
}

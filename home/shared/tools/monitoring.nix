{pkgs, config, lib, ...} :
let
  cfg = config.tools;
in {
  options = {
    tools.monitoring = {
      enable = lib.mkEnableOption "System monitoring tools";
    };
  };

  config = lib.mkIf cfg.monitoring.enable {
    home.packages = with pkgs; [ 
      fastfetch
      glances
    ];

    programs.htop.enable = true;
    programs.bottom.enable = true;
  };
}

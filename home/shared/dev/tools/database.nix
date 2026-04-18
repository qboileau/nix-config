{pkgs, config, lib, ...} :
let
  cfg = config.dev.tools;
in {
  options = {
    dev.tools.database = {
      enable = lib.mkEnableOption "Database tools and clients";
    };
  };

  config = lib.mkIf cfg.database.enable {
    home.packages = with pkgs; [ 
      pgcli
      postgresql
    ];
  };
}

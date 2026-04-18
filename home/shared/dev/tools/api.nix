{pkgs, config, lib, ...} :
let
  cfg = config.dev.tools;
in {
  options = {
    dev.tools.api = {
      enable = lib.mkEnableOption "API development and testing tools";
    };
  };

  config = lib.mkIf cfg.api.enable {
    home.packages = with pkgs; [ 
      postman
      nixfmt-rfc-style
      ascii-draw
    ];
  };
}

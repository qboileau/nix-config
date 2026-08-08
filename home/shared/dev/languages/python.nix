{pkgs, config, lib, ...} :
let
  cfg = config.dev.languages;
in {
  options = {
    dev.languages.python = {
      enable = lib.mkEnableOption "Python development tools";
    };
  };

  config = lib.mkIf cfg.python.enable {
    home.packages = with pkgs; [ 
      python3
      python314Packages.uv
    ];

    # UV tools directory
    home.sessionPath = ["${config.home.homeDirectory}/.local/bin"];
  };

}

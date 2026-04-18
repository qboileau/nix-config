{pkgs, config, lib, ...} :
let
  cfg = config.dev.languages;
in {
  options = {
    dev.languages.nodejs = {
      enable = lib.mkEnableOption "Node.js development tools";
    };
  };

  config = lib.mkIf cfg.nodejs.enable {
    home.packages = with pkgs; [ 
      nodejs
      yarn
    ];

    home.file.".cache/npm/global/.keep".text = "placeholder";
    home.file.".npmrc".text = ''
      prefix=${config.home.homeDirectory}/.cache/npm/global
    '';
    home.sessionPath = ["${config.home.homeDirectory}/.cache/npm/global/bin"];
  };
}

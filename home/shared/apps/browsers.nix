{pkgs, config, lib, ...} :
let
  cfg = config.apps.browsers;
in {
  options = {
    apps.browsers = {
      firefox = {
        enable = lib.mkEnableOption "Firefox web browser";
      };
      brave = {
        enable = lib.mkEnableOption "Brave web browser";
      };
      chromium = {
        enable = lib.mkEnableOption "Chromium web browser";
      };
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.firefox.enable {
      programs.firefox.enable = true;
      programs.firefox.configPath = ".mozilla/firefox";
    })
    
    (lib.mkIf cfg.brave.enable {
      home.packages = with pkgs; [ 
        unstable.brave
      ];
    })
    
    (lib.mkIf cfg.chromium.enable {
      home.packages = with pkgs; [ 
        chromium
      ];
    })
  ];
}

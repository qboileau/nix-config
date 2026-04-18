{pkgs, config, lib, ...} :
let
  cfg = config.apps.communication;
in {
  options = {
    apps.communication = {
      discord = {
        enable = lib.mkEnableOption "Discord (PTB version)";
      };
      slack = {
        enable = lib.mkEnableOption "Slack";
      };
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.discord.enable {
      home.packages = with pkgs; [ 
        unstable.discord-ptb
      ];
    })
    
    (lib.mkIf cfg.slack.enable {
      home.packages = with pkgs; [ 
        slack
      ];
    })
  ];
}

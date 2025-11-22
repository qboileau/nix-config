{config, lib, pkgs, ...} :
with lib;
let
  gaming = config.gaming;   
in {
    
  options = {
    gaming = {
      enable = lib.mkEnableOption "Gaming support";
    };
  };
  
  config = mkIf gaming.enable {
    # https://nix-community.github.io/home-manager/options.xhtml#opt-programs.lutris.enable
    programs.lutris = {
        enable = true;
        package = pkgs.unstable.lutris;
    };

    # https://nix-community.github.io/home-manager/options.xhtml#opt-programs.mangohud.enable
    programs.mangohud = {
        enable = true;
        package = pkgs.unstable.mangohud;
    };

    home.packages = with pkgs; [
        unstable.discord-ptb
        unstable.goverlay
    ];

    # https://nix-community.github.io/home-manager/options.xhtml#opt-programs.discord.enable
    #programs.discord.enable = true;
  };
}

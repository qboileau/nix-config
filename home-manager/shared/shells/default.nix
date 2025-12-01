{config, pkgs, ...} :
{
    imports = [
      ./bash.nix
      ./zsh.nix
    ];

    home.packages = with pkgs; [ 
      alacritty
      starship
      asciinema_3
      asciinema-agg
    ];

    programs.alacritty.enable = true;
    home.file.alacritty = {
      enable = true;
      source = ./cfg/alacritty.toml;
      target = ".config/alacritty/alacritty.toml";
    };

    programs.starship.enable = true;
    home.file.starship = {
      enable = true;
      source = ./cfg/starship.toml;
      target = ".config/starship.toml";
    };

    home.file.bashFunctions = {
      enable = true;
      source =./cfg/functions.bashrc;
      target = ".bashrc.d/functions.bashrc";
    };

    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
      config = {
        global = {
          load_dotenv = true;
        };
        whitelist = {
          prefix = [ 
            "${config.home.homeDirectory}/projects/perso"
            "${config.home.homeDirectory}/projects/work"
            "${config.home.homeDirectory}/projects/conduktor"
          ];
        };
      };
    };

}
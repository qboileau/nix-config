{pkgs, ...} :
{
    import = [
      ./bash.nix
      ./zsh.nix
    ];

    home.packages = with pkgs; [ 
      alacritty
      starship
    ];

    home.file.alacritty = {
      enable = true;
      source = ./cfg/alacritty.yml;
      target = ".config/alacritty/alacritty.yml";
    };

    home.file.starship = {
      enable = true;
      source = ./cfg/starship.toml;
      target = ".config/starship.toml";
    };

    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    
}
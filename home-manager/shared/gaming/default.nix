{config, pkgs, ...} :
{

    # https://nix-community.github.io/home-manager/options.xhtml#opt-programs.lutris.enable
    programs.lutris.enable = true;

    # https://nix-community.github.io/home-manager/options.xhtml#opt-programs.mangohud.enable
    programs.mangohud.enable = true;

    home.packages = with pkgs; [

    ];

    # https://nix-community.github.io/home-manager/options.xhtml#opt-programs.discord.enable
    #programs.discord.enable = true;
}

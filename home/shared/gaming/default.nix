{config, lib, pkgs, ...} :
with lib;
let
  gaming = config.gaming;   
in {
    
  options = {
    gaming = {
      enable = lib.mkEnableOption "Gaming support";
      gameLocations = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "Filesystem paths to expose to gaming Flatpak apps (Heroic, Lutris, Bottles).";
        example = [ "/mnt/LinuxGames/" "/run/media/qboileau/games/" ];
      };
    };
  };
  
  config = mkIf gaming.enable {
    # lutris, bottles and heroic installed via Flatpak to avoid FHS-env local builds
    services.flatpak.packages = [
      { appId = "net.lutris.Lutris"; origin = "flathub"; }
      { appId = "com.usebottles.bottles"; origin = "flathub"; }
      { appId = "com.heroicgameslauncher.hgl"; origin = "flathub"; }
    ];

    # Expose game library paths to all three gaming Flatpak apps
    services.flatpak.overrides = mkIf (gaming.gameLocations != []) (
      lib.genAttrs
        [ "com.heroicgameslauncher.hgl" "net.lutris.Lutris" "com.usebottles.bottles" ]
        (_: { Context.filesystems = gaming.gameLocations; })
    );

    # https://nix-community.github.io/home-manager/options.xhtml#opt-programs.mangohud.enable
    programs.mangohud = {
        enable = true;
        package = pkgs.unstable.mangohud;
    };

    home.packages = with pkgs; [
        unstable.goverlay
        owmods-gui # https://outerwildsmods.com/mod-manager/
    ];

    # https://nix-community.github.io/home-manager/options.xhtml#opt-programs.discord.enable
    #programs.discord.enable = true;
  };
}

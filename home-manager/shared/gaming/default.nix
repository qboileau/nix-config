
{pkgs, ...} :
{

    hardware.opengl = {
      enable = true;
      driSupport = true;
      driSupport32bit = true;
    };

    programs.gamemode.enable = true;

    programs.steam = {
      enable = true; # install steam
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      #dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    };
    programs.steam.gamescopeSession.enable = true;

    # https://nix-community.github.io/home-manager/options.xhtml#opt-programs.lutris.enable
    programs.lutris.enable = true;

    # https://nix-community.github.io/home-manager/options.xhtml#opt-programs.mangohud.enable
    programs.mangohud.enable = true;

    environment.systemPackages = with pkgs; [
        heroic
        protonup-qt
#         (retroarch.override {
#             cores = with libretro; [ # decide what emulators you want to include
#             snes9x
#             scummvm
#             ];
#         })
        bottles # wine prefix manager
    ];

    # https://nix-community.github.io/home-manager/options.xhtml#opt-programs.discord.enable
    programs.discord.enable = true;
}

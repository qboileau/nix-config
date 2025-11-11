{config, pkgs, ...} :
{

    programs.gamemode.enable = true;

    programs.steam = {
      enable = true; # install steam
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      #dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    };
    programs.steam.gamescopeSession.enable = true;

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
}

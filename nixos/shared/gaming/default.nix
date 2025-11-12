{config, pkgs, ...} :
{

  programs.gamemode = {
    enable = true;
    settings = {
      general = {
        softrealtime = "on";
        inhibit_screensaver = 1;
      };
      gpu = {
        apply_gpu_optimisations = "accept-responsibility";
        gpu_device = 1; # /sys/class/drm/card1
        amd_performance_level = "high";
      };
    };
  };

  programs.steam = {
    enable = true; # install steam
    package = pkgs.unstable.steam;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    #dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };
  programs.steam.gamescopeSession.enable = true;

  environment.systemPackages = with pkgs; [
      unstable.heroic
      unstable.protonup-qt
#         (retroarch.override {
#             cores = with libretro; [ # decide what emulators you want to include
#             snes9x
#             scummvm
#             ];
#         })
      unstable.bottles # wine prefix manager
  ];
}

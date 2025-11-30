{config, lib, pkgs, ...} :
with lib;
let
  gaming = config.gaming;

  gameEnv = {
    MANGOHUD = true;
    PROTON_ENABLE_WAYLAND = true;
    PROTON_ENABLE_HDR = true;
    ENABLE_HDR_WSI = true;
    PROTON_FSR4_RDNA3_UPGRADE = true;
    PROTON_FSR4_UPGRADE = true;
    PROTON_USE_FSR4 = true;
    PROTON_USE_NTSYNC = true;
  };
in {
  options = {
    gaming = {
      enable = lib.mkEnableOption "Gaming support";
    };
  };

  config = mkIf gaming.enable {
    # Add support of game devices
    hardware.uinput.enable = true;
    services.udev.packages = with pkgs; [
      unstable.game-devices-udev-rules
    ];

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
      package = pkgs.unstable.steam.override {
        extraEnv = gameEnv;
      };
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      #dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    };
    programs.steam.gamescopeSession.enable = true;
    programs.steam.protontricks.enable = true;
    hardware.steam-hardware.enable = true;

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
        unstable.vulkan-tools
    ];
  };
}

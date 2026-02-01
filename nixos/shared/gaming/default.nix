{config, lib, pkgs, ...} :
with lib;
let
  gaming = config.gaming;

  amdEnv = optionalAttrs gaming.amd.enable {
      PROTON_FSR4_RDNA3_UPGRADE = true;
      PROTON_FSR4_UPGRADE = true;
      PROTON_USE_FSR4 = true;
  };
  baseEnv = {
      MANGOHUD = true;
      PROTON_ENABLE_WAYLAND = true;
      PROTON_ENABLE_HDR = true;
      ENABLE_HDR_WSI = true;
      PROTON_USE_NTSYNC = true;
  };

  gameEnv = baseEnv // amdEnv ;
in {
  imports = [
    ./options.nix
    ./vr.nix
  ];

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
        gpu = mkIf gaming.amd.enable {
          apply_gpu_optimisations = "accept-responsibility";
          gpu_device = 1; # /sys/class/drm/card1
          amd_performance_level = "high";
        };
      };
    };

    programs.steam = {
      enable = true;
      package = pkgs.unstable.steam.override {
        extraEnv = gameEnv;
      };

      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
      localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
      gamescopeSession.enable = true;
      protontricks.enable = true;
    };

    hardware.steam-hardware.enable = true;

    environment.systemPackages = with pkgs.unstable; [
        heroic
        protonup-qt
        bottles # wine prefix manager
        vulkan-tools
    ] ++ optionals gaming.emulators.enable  [
      (retroarch.withCores (cores: with cores; [
        snes9x
        beetle-psx-hw
      ]))
      ryubing # switch emulator
      rpcs3 # ps3 emulator
    ];

    # Enable SCX service https://wiki.cachyos.org/configuration/sched-ext/
    services.scx = mkIf gaming.scx_lavd.enable {
      enable = true;
      scheduler = "scx_lavd"; # https://wiki.cachyos.org/configuration/sched-ext/#scx_lavd
    };
  };
}

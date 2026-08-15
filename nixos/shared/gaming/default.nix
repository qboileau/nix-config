{config, lib, pkgs, ...} :
with lib;
let
  gaming = config.gaming;

  amdEnv = optionalAttrs gaming.amd.enable {
      # PROTON_FSR4_RDNA3_UPGRADE = true;
      # PROTON_FSR4_UPGRADE = true;
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
    # ntsync is built-in on linux_latest; on LTS it ships as a module that
    # must be explicitly loaded for PROTON_USE_NTSYNC to take effect.
    boot.kernelModules = mkIf (!config.boot.useLatestKernel) [ "ntsync" ];

    # Add support of game devices
    hardware.uinput.enable = true;
    services.udev.packages = with pkgs; [
      unstable.game-devices-udev-rules
    ];

    programs.gamemode = {
      enable = true;
      settings = {
        general = {
          softrealtime = "auto";
          inhibit_screensaver = 1;
        };
        gpu = mkIf gaming.amd.enable {
          apply_gpu_optimisations = "accept-responsibility";
          gpu_device = 1; # /sys/class/drm/card1
          amd_performance_level = "high";
        };
      };
    };

    programs.gamescope = {
      enable = true;
      capSysNice = true;
    };

    programs.steam = {
      enable = true;
      package = pkgs.unstable.steam.override {
        extraEnv = gameEnv;
      };
      extraPackages = with pkgs; [
        extest # 64bit version
        hidapi
      ];
      extraCompatPackages = with pkgs; [
        proton-ge-bin
      ];

      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
      localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
      gamescopeSession.enable = true;
      protontricks.enable = true;
      extest.enable = true; # translate X11 input events to uinput events
    };

    hardware.steam-hardware.enable = true;

    environment.systemPackages = with pkgs.unstable; [
        protonup-qt
        vulkan-tools
        vulkan-loader
        libGL
        python313Packages.ds4drv # DualShock 4 driver  : ds4drv --hidraw --emulate-xbox-360
    ] ++ optionals gaming.emulators.enable  [
      (retroarch.withCores (cores: with cores; [
        snes9x
        beetle-psx-hw
      ]))
      ryubing # switch emulator
      # rpcs3 0.0.40 (rev 96f73f4) uses AVCodec.pix_fmts, removed in ffmpeg 9.0 which is
      # the new nixpkgs-unstable default. Pin to ffmpeg_8 (8.1.2), the version it built
      # against pre-update. Drop the override once nixpkgs bumps rpcs3 to an ffmpeg-9 fix.
      (rpcs3.override {ffmpeg = ffmpeg_8;}) # ps3 emulator
    ];

    # Enable SCX service https://wiki.cachyos.org/configuration/sched-ext/
    services.scx = mkIf gaming.scx_lavd.enable {
      enable = true;
      scheduler = "scx_lavd"; # https://wiki.cachyos.org/configuration/sched-ext/#scx_lavd
    };
  };
}

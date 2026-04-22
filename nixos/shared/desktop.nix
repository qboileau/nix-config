{
  config,
  lib,
  pkgs,
  username,
  ...
}: let
  cfg = config.desktop;
in {
  options.desktop = {
    enableAutoLogin = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable automatic login (not recommended for security)";
    };

    enablePlasma = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable KDE Plasma Desktop Environment";
    };

    sddm = {
      theme = lib.mkOption {
        type = lib.types.str;
        default = "breeze";
        description = "SDDM theme to use";
      };

      wayland = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Wayland support in SDDM";
      };
    };
  };

  config = lib.mkMerge [
    # Basic display manager configuration
    {
      services.displayManager.sddm = {
        enable = true;
        wayland.enable = cfg.sddm.wayland;
        theme = cfg.sddm.theme;
      };

      # Enable Flatpak for GUI application management
      services.flatpak.enable = true;
      
      # XDG Desktop Portal for proper desktop integration (required for Flatpak)
      xdg.portal = {
        enable = true;
        extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
      };
    }

    # Auto-login configuration (if enabled)
    (lib.mkIf cfg.enableAutoLogin {
      services.displayManager.autoLogin = {
        enable = true;
        user = username;
      };
    })

    # KDE Plasma configuration
    (lib.mkIf cfg.enablePlasma {
      services.desktopManager.plasma6.enable = true;

      # KDE-specific packages
      environment.systemPackages = with pkgs; [
        kdePackages.breeze
        kdePackages.breeze-icons
        kdePackages.breeze-gtk
      ];
    })
  ];
}
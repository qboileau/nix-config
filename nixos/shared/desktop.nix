{
  config,
  lib,
  pkgs,
  username,
  ...
}: let
  cfg = config.desktop;
  # Preconfigured sddm-astronaut greeter. Pick a bundled variant with
  # embeddedTheme (astronaut, purple_leaves, cyberpunk, black_hole,
  # jake_the_dog, hyprland_kath, japanese_aesthetic, pixel_sakura,
  # post-apocalyptic_hacker) and override its Themes/<name>.conf [General]
  # keys via themeConfig. Full key list:
  # https://github.com/Keyitdev/sddm-astronaut-theme
  custom-sddm-theme = pkgs.sddm-astronaut.override {
    embeddedTheme = "astronaut";
    themeConfig = {
      HeaderText = "Welcome";
      Font = "Noto Sans";
      FontSize = "12";
      HideVirtualKeyboard = "true";
      PartialBlur = "false";
    };
  };
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
        default = "sddm-astronaut-theme";
        description = "SDDM theme to use (directory name under share/sddm/themes).";
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
        extraPackages = with pkgs; [
          kdePackages.qtmultimedia
          kdePackages.qtvirtualkeyboard
          kdePackages.qtsvg
          custom-sddm-theme
        ];
      };

      # Enable Flatpak for GUI application management
      services.flatpak.enable = true;
      
      # XDG Desktop Portal for proper desktop integration (required for Flatpak)
      xdg.portal = {
        enable = true;
        extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
      };
      
      # Enable getty on TTY2-6 for emergency access
      # (TTY1 is used by SDDM, but TTY2-6 provide fallback login)
      systemd.services."getty@tty2".enable = true;
      systemd.services."getty@tty3".enable = true;
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
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
  custom-sddm-astronaut-theme = pkgs.sddm-astronaut.override {
    embeddedTheme = "astronaut";
    themeConfig = {
      HeaderText = "Welcome";
      Font = "Noto Sans";
      FontSize = "12";
      HideVirtualKeyboard = "true";
      PartialBlur = "false";
    };
  };
  # Qt6 port of the chili theme (pkgs/sddm-chili-qt6). themeConfig keys map 1:1
  # to theme.conf [General]: background, blur, recursiveBlurRadius,
  # recursiveBlurLoops, PasswordFieldOutlined, FontPointSize, AvatarPixelSize,
  # PowerIconSize, ScreenWidth, ScreenHeight, translation{Reboot,Suspend,PowerOff}.
  # The greeter runs as user `sddm`, which cannot traverse /home/${username} (0700),
  # so a wallpaper under $HOME silently fails to load. Stage it into a world-readable
  # location at boot and point the theme there instead.
  sddmWallpaperSource = "/home/${username}/Dropbox/wallpapers/2x1/black_hole.jpg";
  sddmWallpaperDir = "/var/lib/sddm-theme";
  sddmWallpaper = "${sddmWallpaperDir}/wallpaper.jpg";
  custom-sddm-chili-theme = pkgs.local.sddm-chili-qt6.override {
    themeConfig = {
      background = sddmWallpaper;
      blur = true;
      recursiveBlurRadius = 3;
      recursiveBlurLoops = 2;
      PasswordFieldOutlined = true;
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
    };
  };

  config = lib.mkMerge [
    # Basic display manager configuration
    {
      # sddm.extraPackages only extends the greeter's QML import path; the theme
      # is looked up in ThemeDir (/run/current-system/sw/share/sddm/themes).
      environment.systemPackages = [
        custom-sddm-astronaut-theme
        custom-sddm-chili-theme
       ];
      services.displayManager.sddm = {
        enable = true;
        wayland.enable = true;
        theme = cfg.sddm.theme;
        extraPackages = with pkgs; [
          kdePackages.qtmultimedia
          kdePackages.qtvirtualkeyboard
          kdePackages.qtsvg
          kdePackages.qt5compat # chili: Qt5Compat.GraphicalEffects
          custom-sddm-astronaut-theme
          custom-sddm-chili-theme
        ];
      };

      systemd.tmpfiles.rules = [
        "d ${sddmWallpaperDir} 0755 root root -"
        "C+ ${sddmWallpaper} 0444 root root - ${sddmWallpaperSource}"
        # Every nix store file carries mtime 1970-01-01 and the theme is loaded through
        # the stable /run/current-system path, so Qt's (path, mtime) disk-cache check
        # never invalidates across rebuilds and the greeter keeps running old QML.
        "R! /var/lib/sddm/.cache/sddm-greeter-qt6 - - - - -"
      ];

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
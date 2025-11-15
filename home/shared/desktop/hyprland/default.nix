{config, pkgs, lib,inputs, ...} :
with lib;
{

  options = {
    hyprland = {
      autolock = {
        enable = lib.mkEnableOption "Enable Hyprland lock support";
      };
    };
  };

  imports = [
    # inputs.hyprland.nixosModules.default
    ./binds.nix
    ./hypridle.nix
    ./hyprlock.nix
    ./hyprpaper.nix
    ./waybar.nix
    ./flameshot.nix
    ./../dunst.nix
    #./rules.nix
    #./settings.nix
    #./smartgaps.nix
  ];

  config = {
    home.packages = with pkgs; [ 
      rose-pine-hyprcursor
    ];

    programs.kitty.enable = true; # required for the default Hyprland config
    services.hyprpolkitagent.enable = true;

    wayland.windowManager.hyprland = {
      enable = true;
      systemd.enable = true;
      xwayland.enable = true;
      package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
      portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
      extraConfig = ''
        plugin = ${inputs.hy3.packages.x86_64-linux.hy3}/lib/libhy3.so
      '';
    };

    wayland.windowManager.hyprland.settings = {
      # See https://wiki.hyprland.org/Configuring/Monitors/
      "monitor" = [
        "eDP-1,2256x1504,0x0,1,bitdepth,10" #main framework laptop monitor
        "desc:Philips Consumer Electronics Company 49M2C8900 AU42415000050,5120x1440,auto-right,1,bitdepth,10,cm,hdr,sdrbrightness,1.3,sdrsaturation,1.0,vrr,3"
        #"DP-4,5120x1440,auto-right,1"
      ];
      xwayland.force_zero_scaling = true;

      "$mod" = "SUPER";
      "$terminal" = "alacritty";
      "$fileManager" = "dolphin";
      "$lock" = "hyprlock";
      "$menu" = "wofi --show drun";
      env = [
        #https://wiki.hypr.land/Configuring/Environment-variables/#xdg-specifications
        "XDG_CURRENT_DESKTOP,Hyprland"
        "XDG_SESSION_TYPE,wayland"
        "XDG_SESSION_DESKTOP,Hyprland"
        "XDG_MENU_PREFIX,plasma-" # fix xdg file associations for Dolphin
        
        #https://wiki.hypr.land/Configuring/Environment-variables/#qt-variables
        "QT_QPA_PLATFORM,wayland;xcb"
        "QT_AUTO_SCREEN_SCALE_FACTOR,1"
        "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
        "QT_QPA_PLATFORMTHEME,qt5ct"

        #https://wiki.hypr.land/Configuring/Environment-variables/#toolkit-backend-variables
        "GDK_BACKEND,wayland,x11,*"
        "SDL_VIDEODRIVER,wayland"
        "CLUTTER_BACKEND,wayland"

        "XCURSOR_SIZE,25"
        "HYPRCURSOR_SIZE,25"
        "HYPRCURSOR_THEME,rose-pine-hyprcursor"
        "MOZ_ENABLE_WAYLAND,1"
        "SDL_VIDEODRIVER,wayland"
        "_JAVA_AWT_WM_NONREPARENTING,1"
        "GDK_DPI_SCALE,1"
        "GDK_SCALE,1"
        "NIXOS_OZONE_WL,1" # tell Electron/Chromium to run on Wayland
      ];
      

      exec-once = [
        "nm-applet"
        "blueman-applet"
        "systemctl --user start hyprpolkitagent"
        "dropbox start"
        "synology-drive"
        "touchegg"
        #https://gist.github.com/brunoanc/2dea6ddf6974ba4e5d26c3139ffb7580#editing-the-configuration-file
        "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
        # https://wiki.hypr.land/Hypr-Ecosystem/xdg-desktop-portal-hyprland/#share-picker-doesnt-use-the-system-theme
        "dbus-update-activation-environment --systemd --all"
        "systemctl --user import-environment QT_QPA_PLATFORMTHEME"
      ];


      # https://wiki.hyprland.org/Configuring/Variables/#general
      general = {
        #layout = "hy3";
        layout = "dwindle";
        #force_split = 2; # dwindle i3 like force create to right
        gaps_in = 1;
        gaps_out = 1;
        border_size = 1;
        "col.inactive_border" = "0xff444444";
        "col.active_border" = "0xffffffff";
        "col.nogroup_border" = "0xff444444";
        "col.nogroup_border_active" = "0xffffffff";
      };

      group = {
        "col.border_inactive" = "0xff444444";
        "col.border_active" = "0xffffffff";
        "col.border_locked_inactive" = "0xff444444";
        "col.border_locked_active" = "0xffffffff";
        groupbar = {
          font_size = 12;
          font_weight_active = "bold";
          "col.active" = "0x6600BCD1";
          "col.inactive" = "0x66006A75";  
          "col.locked_active" = "0x6600BCD1";
          "col.locked_inactive" = "0x66006A75";
        };
      };
      

      animations.enabled = true;

      animation = [
        "border, 1, 2, default"
        "fade, 1, 4, default"
        "windows, 1, 3, default, popin 80%"
        "workspaces, 1, 2, default, slide"
      ];

      # https://wiki.hyprland.org/Configuring/Variables/#input
      input = {
        kb_layout = "us";
        kb_variant = "alt-intl";
        kb_model = "pc104";
        kb_options = "terminate:ctrl_alt_bksp";
        # kb_rules =;

        follow_mouse = 1;

        sensitivity = 0; # -1.0 - 1.0, 0 means no modification.

        touchpad = {
            natural_scroll = false;
        };
      };
      windowrule = [
        #https://wiki.hyprland.org/FAQ/#how-do-i-screenshot
        #https://ryanwise.me/blog/flameshot-on-hyprland/
        "move 0 0,class:(flameshot),title:(flameshot)"
        "pin,class:(flameshot),title:(flameshot)"
        "fullscreenstate,class:(flameshot),title:(flameshot)"
        "float,class:(flameshot),title:(flameshot)"
        # "noanim, class:^(flameshot)$"
        # "float, class:^(flameshot)$"
        # "move 0 0, class:^(flameshot)$"
        # "pin, class:^(flameshot)$"
        # set this to your leftmost monitor id, otherwise you have to move your cursor to the leftmost monitor
        # before executing flameshot
        # "monitor 1, class:^(flameshot)$"
  
        # Screen sharing Xwayland
        "opacity 0.0 override, class:^(xwaylandvideobridge)$"
        "noanim, class:^(xwaylandvideobridge)$"
        "noinitialfocus, class:^(xwaylandvideobridge)$"
        "maxsize 1 1, class:^(xwaylandvideobridge)$"
        "noblur, class:^(xwaylandvideobridge)$"
        "nofocus, class:^(xwaylandvideobridge)$"

        "float, class:galculator"
        "float, class:vlc"
        "float, class:mpv"
        "float, class:brave,title:(.*)(wants to open)"
        "float, class:brave,title:(.*)(wants to save)"
      ];
      windowrulev2 = [
        #https://wiki.hyprland.org/FAQ/#how-do-i-screenshot
        #https://ryanwise.me/blog/flameshot-on-hyprland/
        "move 0 0,class:(flameshot),title:(flameshot)"
        "pin,class:(flameshot),title:(flameshot)"
        "fullscreenstate,class:(flameshot),title:(flameshot)"
        "float,class:(flameshot),title:(flameshot)"
        
        # intellij 
        "nofocus,class:^jetbrains-(?!toolbox),floating:1,title:^win\d+$"
      ];
    };
    # home.file.hyperland = {
    #   enable = true;
    #   source = ./cfg/hyperland.conf;
    #   target = ".config/hypr/hyprland.conf";
    # };
  };
}
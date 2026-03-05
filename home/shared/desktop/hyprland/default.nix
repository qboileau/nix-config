{config, pkgs, lib,inputs, ...} :
with lib;
{

  options = {
    hyprland = {
      autolock = {
        enable = lib.mkEnableOption "Enable Hyprland lock support";
      };
      autostart = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "List of applications to autostart with Hyprland";
      };
      bar = lib.mkOption {
        type = lib.types.enum [
          "waybar"
          "ironbar"
        ];
        default = "waybar";
        description = "Select the bar to use with Hyprland. Either waybar or ironbar";
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
    # ./ironbar.nix
    # ./flameshot.nix
    ./satty.nix
    ./../dunst.nix
    #./rules.nix
    #./settings.nix
    #./smartgaps.nix
  ];

  

  config = {
    home.packages = with pkgs; [ 
      hyprland-qt-support
      # inputs.hyprqt6engine.packages.${pkgs.stdenv.hostPlatform.system}.hyprqt6engine
      kdePackages.qt6ct
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
      # extraConfig = ''
      #   plugin = ${inputs.hy3.packages.x86_64-linux.hy3}/lib/libhy3.so
      # '';
    };

    wayland.windowManager.hyprland.settings = {
      # See https://wiki.hyprland.org/Configuring/Monitors/
      # "monitor" = [
      #   "eDP-1,2256x1504,0x0,1,bitdepth,10" #main framework laptop monitor
      #   "desc:Philips Consumer Electronics Company 49M2C8900 AU42415000050,5120x1440,auto-right,1,bitdepth,10,cm,hdr,sdrbrightness,1.3,sdrsaturation,1.0,vrr,3"
      #   "desc:Iiyama North America PL2440HS 1179410502548,1920x1080,auto-up,1"
      #   #"DP-4,5120x1440,auto-right,1"
      # ];

      monitorv2 = [
        {
          output = "eDP-1";
          mode = "2256x1504";
          position = "0x0";
          scale = 1;
          bitdepth = 10;
        }
        {
          output = "desc:Philips Consumer Electronics Company 49M2C8900 AU42415000050";
          mode = "5120x1440@240.49Hz";
          position = "auto-right";
          scale = 1;
          bitdepth = 10;
          cm = "hdr";
          supports_wide_color = 1;
          supports_hdr = 1;
          sdr_min_luminance = 0.05;
          min_luminance = 0.05;
          sdr_max_luminance = 200;
          max_luminance = 400;
          sdrbrightness = 1.0;
          sdrsaturation = 1.0;
          vrr = 3;
        }
        {
          output = "desc:Iiyama North America PL2440HS 1179410502548";
          mode = "1920x1080";
          position = "auto-up";
          scale = 1;
          bitdepth = 10;
        }
      ];

      xwayland.force_zero_scaling = true;

      render = {
        direct_scanout = 2; # auto scanout to reduce lag, set to 0 if game/app have glitches 
        cm_enabled = true;
        cm_auto_hdr = 1; # switch to hdr
        cm_sdr_eotf = 3; # Treat unspecified as sRGB
      };

      "$mod" = "SUPER";
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
        "QT_QPA_PLATFORMTHEME,qt6ct"
        # "QT_QPA_PLATFORMTHEME,hyprqt6engine"
        "QT_QUICK_CONTROLS_STYLE,org.hyprland.style"
        "QT_SCALE_FACTOR,1"

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
        "ELECTRON_OZONE_PLATFORM_HINT,auto" # https://www.electronjs.org/docs/latest/api/environment-variables
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
      ] ++ config.hyprland.autostart;


      # https://wiki.hyprland.org/Configuring/Variables/#general
      general = {
        #layout = "hy3";
        layout = "dwindle";
        gaps_in = 1;
        gaps_out = 1;
        border_size = 1;
        "col.inactive_border" = "0xff444444";
        "col.active_border" = "0xffffffff";
        "col.nogroup_border" = "0xff444444";
        "col.nogroup_border_active" = "0xffffffff";
      };

      group = {
        insert_after_current = false; # insert at last in group
        drag_into_group = 2; # drag to groupbar add to group
        merge_groups_on_groupbar = false; # groups don't merge into each other
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
      
      dwindle = {
        force_split = 2; # always split to the right/bottom (i3-like)
        preserve_split = true; # keep split direction when windows are removed
        smart_resizing = true; # prevent automatic resize adjustments
      };

      binds = {
        workspace_back_and_forth = true;
        scroll_event_delay = 100; # default is 300
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
        "move 0 0,match:class (flameshot),match:title (flameshot)"
        "pin true,match:class (flameshot),match:title (flameshot)"
        "fullscreen_state 3 3,match:class (flameshot),match:title (flameshot)"
        "float true,match:class (flameshot),match:title (flameshot)"
        # "noanim, match:class ^(flameshot)$"
        # "float, match:class ^(flameshot)$"
        # "move 0 0, match:class ^(flameshot)$"
        # "pin, match:class ^(flameshot)$"
        # set this to your leftmost monitor id, otherwise you have to move your cursor to the leftmost monitor
        # before executing flameshot
        # "monitor 1, match:class ^(flameshot)$"
  
        # Screen sharing Xwayland
        "opacity 0.0 override, match:class ^(xwaylandvideobridge)$"
        "no_anim true, match:class ^(xwaylandvideobridge)$"
        "no_initial_focus true, match:class ^(xwaylandvideobridge)$"
        "max_size 1 1, match:class ^(xwaylandvideobridge)$"
        "no_blur true, match:class ^(xwaylandvideobridge)$"
        "no_focus true, match:class ^(xwaylandvideobridge)$"

        "float true, match:class galculator"
        "size 341 378, match:class galculator"
        "float true, match:class vlc"
        "float true, match:class mpv"
        "float true, match:class Bitwarden"
        "float true, match:class brave,match:title (.*)(wants to open)"
        "float true, match:class brave,match:title (.*)(wants to save)"
        # Firefox videos windows
        "float true, match:class firefox,match:title (Incrustation)(.*)"

        "no_focus true,match:class ^jetbrains-(?!toolbox),match:float true,match:title ^win\d+$"

        "workspace 2, match:class ^(steam)$"
        "workspace 4, match:class ^(discord)$"
      ];
      # windowrulev2 = [
      #   #https://wiki.hyprland.org/FAQ/#how-do-i-screenshot
      #   #https://ryanwise.me/blog/flameshot-on-hyprland/
      #   "move 0 0,match:class (flameshot),match:title (flameshot)"
      #   "pin,match:class (flameshot),match:title (flameshot)"
      #   "fullscreenstate,match:class (flameshot),match:title (flameshot)"
      #   "float,match:class (flameshot),match:title (flameshot)"
        
      #   # intellij 
      #   "nofocus,match:class ^jetbrains-(?!toolbox),floating:1,match:title ^win\d+$"
      # ];
    };
  };
}

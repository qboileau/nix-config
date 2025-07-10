{config, pkgs, inputs, ...} :
{
  imports = [
    # inputs.hyprland.nixosModules.default
    ./waybar.nix
    ./binds.nix
    #./rules.nix
    #./settings.nix
    #./smartgaps.nix
  ];

  programs.kitty.enable = true; # required for the default Hyprland config
  wayland.windowManager.hyprland.enable = true; # enable Hyprland
  wayland.windowManager.hyprland.systemd.enable = true;
  wayland.windowManager.hyprland.xwayland.enable = true;

  wayland.windowManager.hyprland.plugins = [
    pkgs.hyprlandPlugins.hy3
  ];

  programs.hyprlock.enable = true;
  home.file.hyprlock = {
    enable = true;
    source = ./cfg/hyprlock.conf;
    target = ".config/hypr/hyprlock.conf";
  };

  services.hypridle.enable = true;
  home.file.hypridle = {
    enable = true;
    source = ./cfg/hypridle.conf;
    target = ".config/hypr/hypridle.conf";
  };

  services.hyprpaper.enable = true;
  services.hyprpaper.settings = {
    preload =[ 
      "${config.home.homeDirectory}/Dropbox/wallpapers/1x1/1550593747663.png" 
      "${config.home.homeDirectory}/Dropbox/wallpapers/3x1/4205197.jpg"
    ];
    wallpaper = [
      "eDP-1,${config.home.homeDirectory}/Dropbox/wallpapers/1x1/1550593747663.png"
      "desc:Philips Consumer Electronics Company 49M2C8900 AU42415000050,${config.home.homeDirectory}/Dropbox/wallpapers/3x1/4205197.jpg"
    ];
  };
  services.hyprpolkitagent.enable = true;

  wayland.windowManager.hyprland.settings = {
    # See https://wiki.hyprland.org/Configuring/Monitors/
    "monitor" = [
      "eDP-1,2256x1504,0x0,1,bitdepth,10" #main framework laptop monitor
      "desc:Philips Consumer Electronics Company 49M2C8900 AU42415000050,5120x1440,auto-right,1,bitdepth,10"
      #"DP-4,5120x1440,auto-right,1"
    ];
    xwayland.force_zero_scaling = true;

    "$mod" = "SUPER";
    "$terminal" = "alacritty";
    "$fileManager" = "dolphin";
    "$lock" = "hyprlock";
    "$menu" = "wofi --show drun";
    env = [
      "XCURSOR_SIZE,23"
      "HYPRCURSOR_SIZE,23"
      "MOZ_ENABLE_WAYLAND,1"
      "QT_QPA_PLATFORM,wayland"
      "SDL_VIDEODRIVER,wayland"
      "_JAVA_AWT_WM_NONREPARENTING,1"
      "GDK_DPI_SCALE,1"
      "GDK_SCALE,1"
      "NIXOS_OZONE_WL,1" # tell Electron/Chromium to run on Wayland
    ];
    

    exec-once = [
      "nm-applet"
      "systemctl --user start hyprpolkitagent"
      "dropbox start"
      "synology-drive"
      "touchegg"
      #https://gist.github.com/brunoanc/2dea6ddf6974ba4e5d26c3139ffb7580#editing-the-configuration-file
      "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
    ];


    # https://wiki.hyprland.org/Configuring/Variables/#general
    general = {
      #layout = "hy3";
      gaps_in = 1;
      gaps_out = 1;
      border_size = 1;
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
      "noanim, class:^(flameshot)$"
      "float, class:^(flameshot)$"
      "move 0 0, class:^(flameshot)$"
      "pin, class:^(flameshot)$"
      # set this to your leftmost monitor id, otherwise you have to move your cursor to the leftmost monitor
      # before executing flameshot
      "monitor 1, class:^(flameshot)$"
 
      # Screen sharing Xwayland
      "opacity 0.0 override, class:^(xwaylandvideobridge)$"
      "noanim, class:^(xwaylandvideobridge)$"
      "noinitialfocus, class:^(xwaylandvideobridge)$"
      "maxsize 1 1, class:^(xwaylandvideobridge)$"
      "noblur, class:^(xwaylandvideobridge)$"
      "nofocus, class:^(xwaylandvideobridge)$"
    ];
  };

  # home.file.hyperland = {
  #   enable = true;
  #   source = ./cfg/hyperland.conf;
  #   target = ".config/hypr/hyprland.conf";
  # };

}
{pkgs, inputs, ...} :
{
  imports = [
    inputs.hyprland.nixosModules.default
    ./binds.nix
    #./rules.nix
    #./settings.nix
    #./smartgaps.nix
  ];

  programs.kitty.enable = true; # required for the default Hyprland config
  wayland.windowManager.hyprland.enable = true; # enable Hyprland

  wayland.windowManager.hyprland.settings = {
    # See https://wiki.hyprland.org/Configuring/Monitors/
    "monitor" = [
      "eDP-1,2256x1504,0x0,1"
      "desc:Philips Consumer Electronics Company 49M2C8900 AU42415000050,highres,auto-right,1"
    ];
    xwayland.force_zero_scaling = true;

    "$mod" = "SUPER";
    "$terminal" = "alacritty";
    "$fileManager" = "dolphin";
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
    ];
    

    exec-once = [
      "waybar"
      "nm-applet"
      "systemctl --user start hyprpolkitagent"
      "dropbox start"
      "synology-drive"
      "touchegg"
    ];


    # https://wiki.hyprland.org/Configuring/Variables/#general
    general = {
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
    ];
  };

  # https://github.com/Alexays/Waybar/wiki/Module:-Hyprland
  programs.waybar = {
    enable = true;
    settings = [{
      height = 20;
      layer = "top";
      position = "bottom";
      modules-center = [ "hyprland/window" ];
      modules-left = [ "hyprland/workspaces" ];
      modules-right = [
        "pulseaudio"
        "network"
        "cpu"
        "memory"
        "temperature"
        "battery" 
        "clock"
        "tray"
      ];
      battery = {
        format = "{capacity}% {icon}";
        format-alt = "{time} {icon}";
        format-charging = "{capacity}% ";
        format-icons = [ "" "" "" "" "" ];
        format-plugged = "{capacity}% ";
        states = {
          critical = 15;
          warning = 30;
        };
      };
      clock = {
        format-alt = "{:%Y-%m-%d}";
        tooltip-format = "{:%Y-%m-%d | %H:%M}";
      };
      cpu = {
        format = "{usage}% ";
        tooltip = false;
      };
      memory = { format = "{}% "; };
      network = {
        interval = 1;
        format-alt = "{ifname}: {ipaddr}/{cidr}";
        format-disconnected = "Disconnected ⚠";
        format-ethernet = "{ifname}: {ipaddr}/{cidr}   up: {bandwidthUpBits} down: {bandwidthDownBits}";
        format-linked = "{ifname} (No IP) ";
        format-wifi = "{essid} ({signalStrength}%) ";
        #on-click-right = ""
      };
      pulseaudio = {
        format = "{volume}% {icon} {format_source}";
        format-bluetooth = "{volume}% {icon} {format_source}";
        format-bluetooth-muted = " {icon} {format_source}";
        format-icons = {
          car = "";
          default = [ "" "" "" ];
          handsfree = "";
          headphones = "";
          headset = "";
          phone = "";
          portable = "";
        };
        format-muted = " {format_source}";
        format-source = "{volume}% ";
        format-source-muted = "";
        on-click = "pavucontrol";
      };
      temperature = {
        critical-threshold = 80;
        format = "{temperatureC}°C {icon}";
        format-icons = [ "" "" "" ];
      };
      tray = { 
        spacing = 10;
      };
    }];
  };

  # home.file.hyperland = {
  #   enable = true;
  #   source = ./cfg/hyperland.conf;
  #   target = ".config/hypr/hyprland.conf";
  # };

}
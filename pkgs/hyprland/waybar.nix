{pkgs, ...} :
{
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
        "mpris"
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

      "mpris" = {
        "format" = "{player}: {player_icon} {artist} - {title}";
        "format-paused" = "{player}: {status_icon} <i>{artist} - {title}</i>";
        "player-icons" = {
          "default" = "▶";
          "mpv" = "🎵";
          "spotify" = "  ";
        };
        "status-icons" = {
          "paused" =  "⏸" ;
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

      memory = { 
        format = "{}% "; 
      };

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


}
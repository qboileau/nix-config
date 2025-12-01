{pkgs, ...} :
{
  # https://github.com/Alexays/Waybar/wiki/Module:-Hyprland
  programs.waybar = {
    enable = true;
    systemd.enable = true;
    # systemd.target = ""; TODO target hyprland systemd target
    settings = [{
      height = 25;
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
        #"temperature"
        "battery" 
        "clock"
        "tray"
        "group/group-power"
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

      mpris = {
        "format" = "{player_icon}: {artist} - {title}  ";
        "format-paused" = "{player_icon}: {status_icon} <i>{artist} - {title}</i>  ";
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
        #tooltip-format = "{:%Y-%m-%d | %H:%M}";
        timezone = "Europe/Paris";
        format = "{:%H:%M}  ";
        format-alt = "{:%Y-%m-%d}  ";
        tooltip-format= "<tt>{calendar}</tt>";
        calendar = {
          mode = "month";
          mode-mon-col = 3;
          format = {
            months = "<span color='#ffead3' ><b>{}</b></span>";
            days = "<span color='#ecc6d9' ><b>{}</b></span>";
            weeks = "<span color='#99ffdd' ><b>W{}</b></span>";
            weekdays = "<span color='#ffcc66' ><b>{}</b></span>";
            today = "<span color='#ff6699' ><b><u>{}</u></b></span>";
          };
        };
        actions = {
          on-click-right = "mode";
          on-scroll-up = "shift_up";
          on-scroll-down = "shift_down";
        };
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
        on-scroll-up = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";
        on-scroll-down = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
      };

      temperature = {
        critical-threshold = 80;
        format = "{temperatureC}°C {icon}";
        format-icons = [ "" "" "" ];
      };

      "group/group-power" = {
          orientation = "inherit";
          drawer = {
              "transition-duration" = 500;
              "children-class" = "not-power";
              "transition-left-to-right" = false;
          };

          modules = [
              "custom/power"
              "custom/lock"
              "custom/quit"
              "custom/suspend"
              "custom/hibernate"
              "custom/reboot"
          ];
      };

      "custom/quit" = {
          format = "  ";
          tooltip = true;
          tooltip-format = "Quit";
          on-click = "hyprctl dispatch exit";
      };

      "custom/lock" = {
          format = "  ";
          tooltip = true;
          tooltip-format = "Lock";
          on-click = "hyprlock";
      };

      "custom/suspend" = {
          format = "  ";
          tooltip = true;
          tooltip-format = "Suspend";
          on-click = "systemctl suspend";
      };
      
      "custom/hibernate" = {
          format = "  ";
          tooltip = true;
          tooltip-format = "Hibernate";
          on-click = "systemctl hibernate";
      };

      "custom/reboot" = {
          format = "  ";
          tooltip = true;
          tooltip-format = "Reboot";
          on-click = "systemctl reboot";
      };

      "custom/power" = {
          format = "  ";
          tooltip = true;
          tooltip-format = "Power off";
          on-click = "systemctl poweroff";
      };

      tray = { 
        spacing = 10;
      };
    }];

    # TODO check https://github.com/coffebar/dotfiles/blob/main/.config/waybar/style.css
    # style = 
    # ''
    #   * {
    #     border: none;
    #     border-radius: 0;
    #     font-family: FontAwesome, Roboto, Helvetica, Arial, sans-serif;
    #   }
    #   window#waybar {
    #     background-color: rgba(43, 48, 59, 0.5);
    #     border-bottom: 3px solid rgba(100, 114, 125, 0.5);
    #     color: #ffffff;
    #     transition-property: background-color;
    #     transition-duration: .5s;
    #   }
    #   window#waybar.hidden {
    #     opacity: 0.2;
    #   }

    #   #workspaces button {
    #     padding: 0 5px;
    #   }
    # ''};
  };


}
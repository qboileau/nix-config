{ pkgs, config, ... }:
let
  enabled = config.hyprland.bar == "waybar";
in
{

  # https://github.com/Alexays/Waybar/wiki/Module:-Hyprland
  programs.waybar = {
    enable = enabled;
    systemd.enable = true;
    # systemd.target = ""; TODO target hyprland systemd target
    settings = [
      {
        height = 30;
        layer = "top";
        position = "bottom";
        reload_style_on_change = true;
        modules-center = [ "hyprland/window" ];
        modules-left = [ "hyprland/workspaces" ];
        modules-right = [
          "mpris"
          "pulseaudio"
          #"network"
          "cpu"
          "memory"
          #"temperature"
          "battery"
          "clock"
          "tray"
          "group/group-power"
        ];

        "hyprland/workspaces" = {
          format = "{id}";
        };

        "hyprland/window" = {
          format = "{title}";
          max-length = 50;
          separate-outputs = true;
        };

        battery = {
          format = "{capacity}% {icon}";
          format-alt = "{time} {icon}";
          format-charging = "{capacity}% ";
          format-icons = [
            ""
            ""
            ""
            ""
            ""
          ];
          format-plugged = "{capacity}% ";
          states = {
            critical = 15;
            warning = 30;
          };
        };

        mpris = {
          format = "{player_icon}: {artist} - {title}  ";
          format-paused = "{player_icon}: {status_icon} <i>{artist} - {title}</i>  ";
          format-len = 40;
          ignored-players = [
            "brave"
            "brave.instance4584"
            "firefox"
          ];
          player-icons = {
            default = "▶";
            mpv = "🎵";
            spotify = "  ";
          };
          status-icons = {
            paused = "⏸";
          };
        };

        clock = {
          #tooltip-format = "{:%Y-%m-%d | %H:%M}";
          timezone = "Europe/Paris";
          format = "{:%H:%M}  ";
          format-alt = "{:%Y-%m-%d}  ";
          tooltip-format = "<tt>{calendar}</tt>";
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
          interval = 5;
          format-alt = "{ifname}: {ipaddr}/{cidr}";
          format-disconnected = "Disconnected ⚠";
          format-ethernet = "{ifname}: {ipaddr}/{cidr}   up: {bandwidthUpBits} down: {bandwidthDownBits}";
          format-linked = "{ifname} (No IP) ";
          format-wifi = "{essid} ({signalStrength}%) ";
          #on-click-right = ""
        };

        wireplumber = {
          format = "{volume}% {icon} {format_source}";
          format-muted = " {format_source}";
          format-source = "{source_volume}% ";
          format-source-muted = " ";
          format-icons = {
            default = [
              ""
              ""
              ""
            ];
            handsfree = "";
            headphones = "";
            headset = "";
            phone = "";
            portable = "";
          };
          on-click = "pwvucontrol";
          on-scroll-up = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";
          on-scroll-down = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
        };

        pulseaudio = {
          format = "{volume}% {icon} {format_source}";
          format-bluetooth = "{volume}% {icon} {format_source}";
          format-bluetooth-muted = " {icon} {format_source}";
          format-icons = {
            default = [
              ""
              ""
              ""
            ];
            handsfree = "";
            headphones = "";
            headset = "";
            phone = "";
            portable = "";
          };
          format-muted = " {format_source}";
          format-source = "{volume}% ";
          format-source-muted = "";
          on-click = "pwvucontrol";
          on-scroll-up = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";
          on-scroll-down = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
        };

        temperature = {
          critical-threshold = 80;
          format = "{temperatureC}°C {icon}";
          format-icons = [
            ""
            ""
            ""
          ];
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
          show-passive-items = true;
        };
      }
    ];

    # TODO check https://github.com/coffebar/dotfiles/blob/main/.config/waybar/style.css
    style = ''
      * {
          border: none;
          border-radius: 0;
          font-family: "Ubuntu Nerd Font";
          font-size: 13px;
          min-height: 0;
      }

      window#waybar {
          background: rgba(0, 0, 0, 0.95);
          color: white;
      }

      tooltip {
        background: rgba(43, 48, 59, 0.5);
        border: 1px solid rgba(100, 114, 125, 0.5);
      }
      tooltip label {
        color: white;
      }

      #workspaces, #window, #mpris, #pulseaudio, #wireplumber, #network, #cpu, #memory, #battery, #clock, #tray, #custom-group-power {
          background: transparent;
          color: white;

          padding: 0 3px;
          margin: 0 2px;

          font-family: "Fira Code Nerd Font";
      }

      #window {
          font-weight: bold;
          font-family: "Fira Code Nerd Font";
      }

      #workspaces button {
          padding: 0 5px;
          color: white;
          border-top: 2px solid transparent;
      }

      #workspaces button.active {
          border-bottom: 2px solid rgba(255, 255, 255, 0.8);
      }

      #workspaces button:hover {
          background: rgba(255, 255, 255, 0.1);
      }

      #clock {
          font-weight: bold;
          font-family: "Fira Code Nerd Font";
          color: white;
          font-size: 16px;
          padding: 1px 15px 1px;
      }

      #mpris {
          font-style: italic;
      }

      #mpris, #pulseaudio, #wireplumber {
          border-bottom: 1px solid rgba(63, 63, 176, 0.568);
      }

      #network, #cpu, #memory, #battery {
          border-bottom: 1px solid rgba(75, 168, 75, 0.568);
      }
    '';
  };
}

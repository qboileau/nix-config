# ashell (https://malpenzibo.github.io/ashell), selected with `hyprland.bar = "ashell"`.
# Layout mirrors waybar.nix; audio/network/bluetooth/battery/power all live inside ashell's
# single Settings menu instead of separate modules.
{ pkgs, config, ... }:
let
  enabled = config.hyprland.bar == "ashell";

  # Same split as waybar.nix: `hyprctl dispatch` evaluates its argument as lua under a lua config.
  quit =
    if config.hyprland.configType == "lua"
    then "hyprctl dispatch 'hl.dsp.exit()'"
    else "hyprctl dispatch exit";
in
{
  programs.ashell = {
    enable = enabled;
    # 0.9.0 picks its dispatch protocol at runtime from `configProvider` in `hyprctl status`, so
    # it drives both hyprlang and lua configs. nixpkgs 26.05 is still on 0.8.0, which only speaks
    # the legacy hyprlang socket protocol — under a lua config the bar renders but workspace
    # clicks do nothing. Hence unstable.
    package = pkgs.unstable.ashell;
    systemd.enable = true;

    settings = {
      position = "Bottom";
      layer = "Top"; # ashell defaults to the Bottom layer, i.e. behind windows

      modules = {
        left = [ "Workspaces" ];
        center = [ "WindowTitle" ];
        right = [
          "MediaPlayer"
          "SystemInfo"
          [ "Tray" "Tempo" "Privacy" "Settings" ]
        ];
      };

      window_title = {
        mode = "Title";
        truncate_title_after_length = 50;
      };

      system_info = {
        indicators = [ "Cpu" "Memory" ];
        interval = 5;
      };

      media_player.max_title_length = 40;

      tempo = {
        clock_format = "%H:%M";
        formats = [ "%H:%M" "%Y-%m-%d" ]; # click cycles, like waybar's format-alt
        weather_indicator = "None";
      };

      settings = {
        lock_cmd = "hyprlock";
        logout_cmd = quit;
        shutdown_cmd = "systemctl poweroff";
        reboot_cmd = "systemctl reboot";
        suspend_cmd = "systemctl suspend";
        hibernate_cmd = "systemctl hibernate";
        audio_sinks_more_cmd = "pwvucontrol";
        audio_sources_more_cmd = "pwvucontrol";
        wifi_more_cmd = "nm-connection-editor";
        vpn_more_cmd = "nm-connection-editor";
        bluetooth_more_cmd = "blueman-manager";
      };

      # waybar's look: solid black bar, white text, white accent (same as the Hyprland
      # active-border colour).
      appearance = {
        style = "Solid";
        font_name = "FiraCode Nerd Font";
        opacity = 0.95;
        primary_color = "#ffffff";
        text_color = "#ffffff";
        success_color = "#4ba84b";
        warning_color = "#ffcc66";
        danger_color = "#ff6699";
        background_color = {
          base = "#000000";
          weak = "#1a1a1a";
          strong = "#333333";
        };
      };
    };
  };
}

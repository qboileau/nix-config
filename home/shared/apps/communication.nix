{pkgs, config, lib, ...} :
let
  cfg = config.apps.communication;
in {
  options = {
    apps.communication = {
      discord = {
        enable = lib.mkEnableOption "Discord";
      };
      slack = {
        enable = lib.mkEnableOption "Slack";
      };
      signal = {
        enable = lib.mkEnableOption "Signal messenger";
      };
    };
  };

  config = lib.mkMerge [
    # Discord - Nix version (Flatpak had webapp timeout issues)
    (lib.mkIf cfg.discord.enable {
      home.packages = with pkgs; [ unstable.discord-ptb ];
      # Flatpak version (had issues after self-update):
      # services.flatpak = {
      #   enable = true;
      #   packages = [
      #     { appId = "com.discordapp.Discord"; origin = "flathub"; }
      #   ];
      # };
    })
    
    # Slack - Flatpak version with X11 fallback for Electron compatibility
    (lib.mkIf cfg.slack.enable {
      # services.flatpak = {
      #   enable = true;
      #   packages = [
      #     { appId = "com.slack.Slack"; origin = "flathub"; }
      #   ];
      #   overrides."com.slack.Slack" = {
      #     # Allow X11 fallback since Electron apps may need it
      #     Context.sockets = ["wayland" "fallback-x11" "x11"];
      #   };
      # };
      # Nix version (uncomment to use instead):
      home.packages = with pkgs; [ slack ];
    })
    
    # Signal - Flatpak version with password store override and X11 fallback
    (lib.mkIf cfg.signal.enable {
      # services.flatpak = {
      #   enable = true;
      #   packages = [
      #     { appId = "org.signal.Signal"; origin = "flathub"; }
      #   ];
      #   overrides."org.signal.Signal" = {
      #     # Allow X11 fallback since Electron apps may need it
      #     Context.sockets = ["wayland" "fallback-x11" "x11"];
      #     Environment = {
      #       SIGNAL_PASSWORD_STORE = "gnome-libsecret";
      #     };
      #   };
      # };
      # Nix version (uncomment to use instead):
      home.packages = with pkgs; [ signal-desktop ];
    })
  ];
}

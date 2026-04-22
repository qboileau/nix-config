{config, lib, ...} :
let
  cfg = config.services.flatpak;
in {
  # Global Flatpak configuration
  # This module sets up Flatpak with sensible defaults for Wayland, themes, and common fixes
  # Individual apps are installed via their respective modules (media.nix, communication.nix, etc.)
  #
  # NOTE: Electron apps (Discord, Slack, Signal, Spotify, Bitwarden) may need X11 fallback.
  # Add per-app overrides with: Context.sockets = ["wayland" "fallback-x11" "x11"];
  
  # Uninstall app : flatpak uninstall xxx.yyy.zzz
  # Clear app data : ~/.var/app/xxx.yyy.zzz/
  
  config = lib.mkIf cfg.enable {
    services.flatpak = {
      # Enable automatic updates weekly
      update.auto = {
        enable = lib.mkDefault true;
        onCalendar = lib.mkDefault "weekly";
      };
      
      # Don't update on every activation (for reproducibility)
      update.onActivation = lib.mkDefault false;
      
      # Manage all Flatpak packages declaratively - uninstall anything not in config
      uninstallUnmanaged = lib.mkDefault true;
      
      # Ensure flathub is available
      remotes = lib.mkDefault [{
        name = "flathub";
        location = "https://flathub.org/repo/flathub.flatpakrepo";
      }];
      
      # Global overrides for all Flatpaks
      overrides = {
        # Global settings for all applications
        global = {
          # Force Wayland where possible for better performance and security
          Context.sockets = lib.mkDefault ["wayland" "!x11" "!fallback-x11"];
          
          Environment = {
            # Fix cursor theme in Flatpak apps
            XCURSOR_PATH = "/run/host/user-share/icons:/run/host/share/icons";
            
            # Use system GTK theme
            GTK_THEME = lib.mkDefault "Adwaita:dark";
            
            # Qt scaling
            QT_AUTO_SCREEN_SCALE_FACTOR = "1";
          };
        };
      };
      
      # Retry on network failures
      restartOnFailure = {
        enable = lib.mkDefault true;
        restartDelay = lib.mkDefault "60s";
      };
    };

    # Add Flatpak export directories to XDG data dirs for app launcher integration
    # This is needed for Hyprland/Sway to find Flatpak desktop files
    xdg.systemDirs.data = [
      "$HOME/.local/share/flatpak/exports/share"
      "/var/lib/flatpak/exports/share"
    ];
  };
}

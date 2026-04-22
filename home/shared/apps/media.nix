{pkgs, config, lib, inputs, ...} :
let
  cfg = config.apps.media;
in {
  options = {
    apps.media = {
      spotify = {
        enable = lib.mkEnableOption "Spotify music streaming";
      };
      qbz = {
        enable = lib.mkEnableOption "QBZ backup tool";
      };
    };
  };

  config = lib.mkMerge [
    # Spotify - Flatpak version with X11 fallback for Electron compatibility
    (lib.mkIf cfg.spotify.enable {
      services.flatpak = {
        enable = true;
        packages = [
          { appId = "com.spotify.Client"; origin = "flathub"; }
        ];
      };
      # Nix version (uncomment to use instead):
      # home.packages = with pkgs; [ unstable.spotify ];
    })
    
    # QBZ - Flatpak version (default)
    (lib.mkIf cfg.qbz.enable {
      services.flatpak = {
        enable = true;
        packages = [
          { appId = "com.blitzfc.qbz"; origin = "flathub"; }
        ];
      };
      # Nix version from flake input (uncomment to use instead):
      # home.packages = [ inputs.qbz.packages.${pkgs.system}.default ];
    })
  ];
}

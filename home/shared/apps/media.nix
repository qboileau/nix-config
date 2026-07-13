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
      mpv = {
        enable = lib.mkEnableOption "mpv media player with uosc and full ffmpeg";
      };
    };
  };

  config = lib.mkMerge [
    # Default media players installed on all hosts
    {
      home.packages = with pkgs; [
        vlc
        imv
      ];
    }

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
      # home.packages = [ inputs.qbz.packages.${pkgs.stdenv.hostPlatform.system}.default ];
    })

    # MPV - Nix version with uosc and full ffmpeg
    (lib.mkIf cfg.mpv.enable {
      programs.mpv = {
        enable = true;
        package = pkgs.mpv.override {
          scripts = with pkgs.mpvScripts; [
            uosc
          ];
          mpv-unwrapped = pkgs.mpv-unwrapped.override {
            ffmpeg = pkgs.ffmpeg-full;
          };
        };
      };
    })
  ];
}

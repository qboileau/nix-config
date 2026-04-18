{pkgs, config, lib, ...} :
let
  cfg = config.apps.media;
in {
  options = {
    apps.media = {
      spotify = {
        enable = lib.mkEnableOption "Spotify music streaming";
      };
    };
  };

  config = lib.mkIf cfg.spotify.enable {
    home.packages = with pkgs; [ 
      unstable.spotify
    ];
  };
}

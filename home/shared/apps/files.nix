{pkgs, config, lib, ...} :
let
  cfg = config.apps.files;
in {
  options = {
    apps.files = {
      filezilla = {
        enable = lib.mkEnableOption "FileZilla FTP client";
      };
    };
  };

  config = lib.mkIf cfg.filezilla.enable {
    home.packages = with pkgs; [ 
      filezilla
    ];
  };
}

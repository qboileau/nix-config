{pkgs, config, lib, ...} :
let
  cfg = config.editors;
in {
  options = {
    editors.zed = {
      enable = lib.mkEnableOption "Zed editor";
    };
  };

  config = lib.mkIf cfg.zed.enable {
    home.packages = with pkgs; [ 
      zed-editor
    ];
  };
}
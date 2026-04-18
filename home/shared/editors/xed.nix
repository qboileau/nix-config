{pkgs, config, lib, ...} :
let
  cfg = config.editors;
in {
  options = {
    editors.xed = {
      enable = lib.mkEnableOption "Xed text editor";
    };
  };

  config = lib.mkIf cfg.xed.enable {
    home.packages = with pkgs; [ 
      xed-editor
    ];
  };
}
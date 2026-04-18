{pkgs, config, lib, ...} :
let
  cfg = config.tools;
in {
  options = {
    tools.bluetooth = {
      enable = lib.mkEnableOption "Bluetooth management tools";
    };
  };

  config = lib.mkIf cfg.bluetooth.enable {
    home.packages = with pkgs; [ 
      overskride  # Bluetooth GUI
    ];
  };
}

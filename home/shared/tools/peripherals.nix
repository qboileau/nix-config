{pkgs, config, lib, ...} :
let
  cfg = config.tools;
in {
  options = {
    tools.peripherals = {
      enable = lib.mkEnableOption "Peripheral device management tools";
    };
  };

  config = lib.mkIf cfg.peripherals.enable {
    home.packages = with pkgs; [
      solaar              # Logitech devices GUI
      local.openlogi      # Logitech HID++ companion
      cameractrls-gtk4    # Camera controls
      ddcui               # Display control utility
    ];
  };
}

{pkgs, config, lib, ...} :
let
  cfg = config.apps;
in {
  options = {
    apps.productivity = {
      enable = lib.mkEnableOption "Productivity applications (calculator, notes, text editor)";
    };
  };

  config = lib.mkIf cfg.productivity.enable {
    home.packages = with pkgs; [ 
      galculator
      xournalpp
    ];

    # Desktop entry for calculator
    xdg.desktopEntries.calculator = {
      name = "Calculator";
      exec = "galculator";
      terminal = false;
      type = "Application";
      categories = ["System"];
    };
  };
}

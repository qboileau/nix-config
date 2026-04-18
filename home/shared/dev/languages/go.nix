{pkgs, config, lib, ...} :
let
  cfg = config.dev.languages;
in {
  options = {
    dev.languages.go = {
      enable = lib.mkEnableOption "Go development tools";
    };
  };

  config = lib.mkIf cfg.go.enable {
    home.packages = with pkgs; [ 
      go
      gopls  # Go language server
      unstable.golangci-lint
    ];
  };
}

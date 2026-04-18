{pkgs, config, lib, ...} :
let
  cfg = config.dev.tools;
in {
  options = {
    dev.tools.build = {
      enable = lib.mkEnableOption "Build tools and compilers";
    };
  };

  config = lib.mkIf cfg.build.enable {
    home.packages = with pkgs; [ 
      gcc
      libllvm
      pre-commit
      checkov
    ];
  };
}

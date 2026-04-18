{pkgs, config, lib, ...} :
let
  cfg = config.dev.tools;
in {
  options = {
    dev.tools.docs = {
      enable = lib.mkEnableOption "Documentation and diagramming tools";
    };
  };

  config = lib.mkIf cfg.docs.enable {
    home.packages = with pkgs; [ 
      graphviz      # Graph visualization
      ascii-draw    # ASCII diagrams
    ];
  };
}

{pkgs, config, lib, ...} :
let
  cfg = config.dev.tools;
in {
  options = {
    dev.tools.kubernetes = {
      enable = lib.mkEnableOption "Kubernetes and container orchestration tools";
    };
  };

  config = lib.mkIf cfg.kubernetes.enable {
    home.packages = with pkgs; [ 
      kubectl
      kubernetes-helm
      kubernetes-helmPlugins.helm-diff
      fluxcd
      kustomize
      kubeconform
      k9s
      k3d
      freelens-bin
      chart-testing
      openshift
      # Custom packages
      local.openlens
      local.helm-readme-generator
    ];
    
    # kubectl extensions
    programs.krewfile = {
      enable = true;
      krewPackage = pkgs.krew;
      plugins = [
        "resource-capacity"  # https://github.com/robscott/kube-capacity
      ];
    };
    
    home.sessionVariables = {
      KUBECONFIG = "\$(generate_kubeconfig)";
    };
  };
}

{pkgs, ...} :
{

  home.packages = with pkgs; [ 
    kubectl
    kubernetes-helm
    fluxcd
    kustomize
    k9s
    k3d
    lens
    openlens
    chart-testing
    openshift
  ];

  # kubectl extensions
  programs.krewfile = {
    enable = true;
    krewPackage = pkgs.krew;
    plugins = [
      "resource-capacity" # https://github.com/robscott/kube-capacity
    ];
  };

  
  home.sessionVariables = {
    # TODO find a way to use variable for home name
   KUBECONFIG = "\$(generate_kubeconfig)";
  };
}
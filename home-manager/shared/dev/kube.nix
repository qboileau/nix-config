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
    chart-testing
    openshift
    # custom packages
    openlens
    helm-readme-generator
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
{pkgs, ...} :
{

  home.packages = with pkgs; [ 
    kubectl
    kubernetes-helm
    fluxctl
    k9s
    k3d
    lens
    chart-testing
  ];
}
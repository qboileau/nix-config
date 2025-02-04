{pkgs, ...} :
{

  home.packages = with pkgs; [ 
    kubectl
    kubernetes-helm
    fluxctl
    k9s
    lens
    chart-testing
  ];
}
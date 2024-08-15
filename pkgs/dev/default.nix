{pkgs, ...} :
{
  imports = [
    ./kube.nix
    #./virt.nix # FIXME
    ./build-tools.nix
    ./sdk.nix
  ];

  
  home.packages = with pkgs; [ 

  ];

}
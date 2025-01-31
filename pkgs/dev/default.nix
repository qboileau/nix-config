{pkgs, ...} :
{
  imports = [
    ./tools.nix
    ./kube.nix
    ./build-tools.nix
    ./sdk.nix
    #./virt.nix # FIXME
  ];

  
  home.packages = with pkgs; [ 

  ];

}
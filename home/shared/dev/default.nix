{pkgs, ...} :
{
  imports = [
    ./tools.nix
    ./kube.nix
    ./build-tools.nix
    ./sdk.nix
    ./ai.nix
    #./virt.nix # FIXME
  ];

  
  home.packages = with pkgs; [ 
    ascii-draw
  ];

}

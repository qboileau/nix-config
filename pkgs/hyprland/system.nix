# i3 setup to be imported in nixOS configuration.nix 
{pkgs, ...} :
{

  programs.hyprland.enable = true;
  
  
  environment.systemPackages = with pkgs; [
    kitty
    wofi
  ];
}
# i3 setup to be imported in nixOS configuration.nix 
{inputs, pkgs, ...} :
{

  #https://wiki.hyprland.org/Nix/Cachix/
  nix.settings = {
    substituters = ["https://hyprland.cachix.org"];
    trusted-substituters = ["https://hyprland.cachix.org"];
    trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
  };

  programs.hyprland = {
    enable = true;
    # set the flake package
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    # make sure to also set the portal package, so that they are in sync
    portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;

    withUWSM  = false; # use SDDM
    xwayland.enable = true;
  };

  programs.uwsm.enable = false; # use SDDM
  programs.hyprlock.enable = true;
  services.hypridle.enable = true;
  
  environment.systemPackages = with pkgs; [
    kitty
    waybar # TODO flake https://github.com/Alexays/Waybar/wiki/Installation#nixos
    #eww #https://github.com/elkowar/eww
    wofi
    wlprop
    wlr-randr
    nwg-displays
    brightnessctl
    playerctl
    hyprpaper
    hyprlock
    hypridle
    hyprcursor
    hyprpolkitagent
    #hyprsysteminfo
  ];
}
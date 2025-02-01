# sway setup to be imported in nixOS configuration.nix 
{pkgs, ...} :
{

  environment.pathsToLink = [ "/libexec" ];
  
  services.xserver.enable = true;

  services.gnome.gnome-keyring.enable = true;

  #Sway
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    extraPackages = with pkgs; [
      grim # screenshot functionality
      slurp # screenshot functionality
      wl-clipboard # wl-copy and wl-paste for copy/paste from stdin / stdout
      mako # notification system developed by swaywm maintainer
      xorg.xhost
    ];
  };

  
}
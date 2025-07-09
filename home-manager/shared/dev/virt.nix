{pkgs, ...} :
{
  
  nixpkgs.config.allowUnfree = true;
  virtualisation.virtualbox.host.enable = true;
  virtualisation.virtualbox.host.enableExtensionPack = true;
  users.extraGroups.vboxusers.members = [ "qboileau" ]; # FIXME

  home.packages = with pkgs; [ 
    vagrant
  ];
  
}
{pkgs, config, lib, ...} :
let
  cfg = config.dev.tools;
in {
  options = {
    dev.tools.virtualization = {
      enable = lib.mkEnableOption "Virtualization tools (VirtualBox, Vagrant)";
    };
  };

  config = lib.mkIf cfg.virtualization.enable {
    nixpkgs.config.allowUnfree = true;
    
    # Note: These are system-level options that need to be enabled in NixOS configuration
    # virtualisation.virtualbox.host.enable = true;
    # virtualisation.virtualbox.host.enableExtensionPack = true;
    # users.extraGroups.vboxusers.members = [ "qboileau" ];
    
    home.packages = with pkgs; [ 
      vagrant
    ];
  };
}

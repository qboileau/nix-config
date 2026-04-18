{pkgs, config, lib, inputs, ...} :
let
  cfg = config.services.cloudSync;
in {
  options = {
    services.cloudSync = {
      dropbox = {
        enable = lib.mkEnableOption "Dropbox cloud storage service";
      };
      synology = {
        enable = lib.mkEnableOption "Synology Drive client";
      };
      qbz = {
        enable = lib.mkEnableOption "QBZ backup tool";
      };
      tailscale = {
        enable = lib.mkEnableOption "Tailscale VPN tray";
      };
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.dropbox.enable {
      services.dropbox.enable = true;
    })
    
    (lib.mkIf cfg.synology.enable {
      home.packages = with pkgs; [ 
        synology-drive-client
      ];
    })
    
    (lib.mkIf cfg.qbz.enable {
      home.packages = [
        inputs.qbz.packages.${pkgs.system}.default
      ];
    })
    
    (lib.mkIf cfg.tailscale.enable {
      home.packages = with pkgs; [ 
        unstable.tail-tray
      ];
    })
  ];
}

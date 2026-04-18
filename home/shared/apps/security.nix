{pkgs, config, lib, ...} :
let
  cfg = config.apps.security;
in {
  options = {
    apps.security = {
      bitwarden = {
        enable = lib.mkEnableOption "Bitwarden password manager";
      };
      onepassword = {
        enable = lib.mkEnableOption "1Password password manager";
      };
      proton = {
        enable = lib.mkEnableOption "Proton suite (VPN, Pass, Authenticator)";
      };
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.bitwarden.enable {
      home.packages = with pkgs; [ 
        bitwarden-desktop
      ];
    })
    
    (lib.mkIf cfg.onepassword.enable {
      home.packages = with pkgs; [ 
        _1password-gui
      ];
    })
    
    (lib.mkIf cfg.proton.enable {
      home.packages = with pkgs; [ 
        proton-pass
        protonvpn-gui
        unstable.proton-authenticator
      ];
    })
  ];
}

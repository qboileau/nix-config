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
    # Bitwarden - Flatpak version with X11 fallback for Electron compatibility
    (lib.mkIf cfg.bitwarden.enable {
      services.flatpak = {
        enable = true;
        packages = [
          { appId = "com.bitwarden.desktop"; origin = "flathub"; }
        ];
        overrides."com.bitwarden.desktop" = {
          # Allow X11 fallback since Electron apps may need it
          Context.sockets = ["wayland" "fallback-x11" "x11"];
        };
      };
      # Nix version (uncomment to use instead):
      # home.packages = with pkgs; [ bitwarden-desktop ];
    })
    
    (lib.mkIf cfg.onepassword.enable {
      home.packages = with pkgs; [
        unstable._1password-gui
        unstable._1password-cli
      ];
    })
    
    (lib.mkIf cfg.proton.enable {
      home.packages = with pkgs; [ 
        proton-pass
        proton-vpn
        unstable.proton-authenticator
      ];
    })
  ];
}

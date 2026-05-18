{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.security;
in {
  options.security = {
    enableClamAv = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable ClamAV antivirus daemon";
    };
    enableFingerprintAuth = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable fingerprint authentication via fprintd";
    };
  };

  config = lib.mkMerge [
    # Common security configuration
    {
      security = {
        polkit.enable = true;
        pam = {
          sshAgentAuth.enable = true;
          services = {
            sddm = {
              kwallet.enable = true;
              gnupg.enable = true;
              fprintAuth = cfg.enableFingerprintAuth;
            };
            login = {
              kwallet.enable = true;
              gnupg.enable = true;
              fprintAuth = cfg.enableFingerprintAuth;
            };
            sudo.fprintAuth = cfg.enableFingerprintAuth;
          };
        };
      };
      # Enable Gnome keyring for some GTK apps like protonvpn
      services.gnome.gnome-keyring.enable = true;
      # Disable gnome-keyring's SSH agent (we use ssh-agent + ksshaskpass)
      services.gnome.gcr-ssh-agent.enable = false;


      # Common GnuPG configuration
      programs.gnupg.agent.enable = true;

      # SSH 
      programs.ssh = {
        startAgent = true;
        enableAskPassword = true;
        askPassword = "${pkgs.kdePackages.ksshaskpass}/bin/ksshaskpass";
      };

      environment.systemPackages = with pkgs; [
        openssl
        kdePackages.kwallet
        kdePackages.kwallet-pam
        kdePackages.kwalletmanager
        kdePackages.ksshaskpass # For SSH agent password prompts
      ];

      services.openssh = {
        enable = true;
        settings = {
          # Opinionated: forbid root login through SSH.
          PermitRootLogin = "no";
          # Opinionated: use keys only.
          # Remove if you want to SSH using passwords
          PasswordAuthentication = false;
        };
      };
    }

    # ClamAV antivirus configuration
    (lib.mkIf cfg.enableClamAv {
      services.clamav = {
        daemon.enable = true;
        updater.enable = true;
      };

      environment.systemPackages = with pkgs; [
        clamav
      ];
    })
  ];
}
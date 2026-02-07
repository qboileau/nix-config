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
            };
            login = {
              kwallet.enable = true;
              gnupg.enable = true;
            };
          };
        };
      };

      # Common GnuPG configuration
      programs.gnupg.agent.enable = true;

      environment.systemPackages = with pkgs; [
        openssl
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
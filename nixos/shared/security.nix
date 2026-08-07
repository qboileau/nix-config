{
  config,
  lib,
  pkgs,
  hostUsers,
  ...
}:
let
  cfg = config.security;
in
{
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
    onepassword = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Enable the 1Password GUI and CLI system-wide. This has to be a NixOS
          module rather than a home-manager one: the GUI needs a setuid helper
          and a polkit policy for system authentication, and the CLI needs its
          setgid wrapper to talk to the desktop app.
        '';
      };
      polkitPolicyOwners = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = hostUsers;
        defaultText = lib.literalExpression "hostUsers";
        description = ''
          Users allowed to use the 1Password polkit policy, which is what
          enables system authentication (unlock with login password/fingerprint)
          and GUI <-> CLI integration.
        '';
      };
      customAllowedBrowsers = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        example = [ ".brave-wrapped" ];
        description = ''
          Extra browser binary names allowed to talk to the desktop app over the
          browser-integration socket. Nixpkgs browsers are launched through a
          wrapper, so the name 1Password sees is usually the `.<name>-wrapped`
          one — check with `ps aux` if an extension refuses to connect.
        '';
      };
      enableSshAgent = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Point SSH at the 1Password agent socket instead of the ssh-agent
          started by this module. Requires "Use the SSH agent" to be turned on
          in the 1Password developer settings first, otherwise the socket does
          not exist and SSH breaks.
        '';
      };
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
      # KDE KWallet (kwalletd6 + ksecretd) handles all secret storage, including
      # the org.freedesktop.secrets SecretService API used by GTK apps. Keeping
      # GNOME Keyring disabled avoids a D-Bus race where it grabs
      # org.freedesktop.secrets before ksecretd can, causing the ~1 min delay
      # in Brave's first startup after each boot.
      services.gnome.gnome-keyring.enable = false;

      # Common GnuPG configuration
      programs.gnupg.agent.enable = true;

      # SSH
      programs.ssh = {
        startAgent = true;
        enableAskPassword = true;
        askPassword = "${pkgs.kdePackages.ksshaskpass}/bin/ksshaskpass";
        extraConfig = ''
          AddKeysToAgent 1h
        '';
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

    # 1Password (GUI + CLI). Tracks unstable because 1Password force-updates the
    # clients and stable nixpkgs can lag behind the minimum supported version.
    (lib.mkIf cfg.onepassword.enable {
      programs._1password = {
        enable = true;
        package = pkgs.unstable._1password-cli;
      };

      programs._1password-gui = {
        enable = true;
        package = pkgs.unstable._1password-gui;
        inherit (cfg.onepassword) polkitPolicyOwners;
      };

      environment.etc."1password/custom_allowed_browsers" =
        lib.mkIf (cfg.onepassword.customAllowedBrowsers != [ ])
          {
            text = lib.concatLines cfg.onepassword.customAllowedBrowsers;
            mode = "0755";
          };

      programs.ssh.extraConfig = lib.mkIf cfg.onepassword.enableSshAgent ''
        Host *
          IdentityAgent ~/.1password/agent.sock
      '';
    })
  ];
}

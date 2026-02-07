{
  pkgs,
  config,
  lib,
  options,
  ...
}: let
  cfg = config.networking;
in {
  options.networking = {
    useAdvancedDns = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Use advanced DNS setup with dnsmasq instead of standard NetworkManager DNS";
    };

    enableKdeConnect = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable firewall ports for KDE Connect";
    };

    customTimeServers = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Add custom time servers (Cloudflare and French pool)";
    };

  };

  config = lib.mkMerge [
    # Common networking configuration
    {
      networking.networkmanager.enable = true;
      networking.wireguard.enable = true;
      services.tailscale.enable = true;
      programs.openvpn3.enable = true;

      # Samba
      services.samba.enable = true;
      services.samba-wsdd.enable = true; # samba discovery
      services.samba.winbindd.enable = true;
      services.gvfs.enable = true; # https://nixos.wiki/wiki/Samba#Browsing_samba_shares_with_GVFS
      services.gvfs.package = pkgs.gvfs;
      environment.systemPackages = with pkgs; [
        cifs-utils # Samba client
      ];
    }

    # Standard DNS configuration (when not using advanced)
    (lib.mkIf (!cfg.useAdvancedDns) {
      # Standard NetworkManager DNS handling
    })

    # Advanced DNS configuration with dnsmasq
    (lib.mkIf cfg.useAdvancedDns {
      services.dnsmasq = {
        enable = true;
        settings = {
          domain-needed = true;
          domain = "localhost";
          expand-hosts = true;

          address = [
            "/localhost/127.0.0.1"
            "/local/127.0.0.1"
            "/private/127.0.0.1"
          ];

          server = [
            "1.1.1.1"
            "1.0.0.1"
          ];
        };
      };

      networking = {
        nat.enable = true;
        networkmanager.dns = "none"; # Disable NetworkManager's internal DNS resolution
        useDHCP = false; # These options are unnecessary when managing DNS ourselves
        dhcpcd.enable = false;
        nameservers = [ "127.0.0.1" ]; # use DNSmasq
      };
    })

    # KDE Connect firewall configuration
    (lib.mkIf cfg.enableKdeConnect {
      networking.firewall = {
        checkReversePath = false;
        allowedTCPPortRanges = [ { from = 1714; to = 1764; } ];
        allowedUDPPortRanges = [ { from = 1714; to = 1764; } ];
      };
    })

    # Custom time servers
    (lib.mkIf cfg.customTimeServers {
      networking.timeServers = options.networking.timeServers.default ++ [ 
        "time.cloudflare.com" 
        "fr.pool.ntp.org" 
      ];
    })
  ];
}
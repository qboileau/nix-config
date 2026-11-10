{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.networking.wifi.mt7925Patched;
in {
  options.networking.wifi.mt7925Patched = {
    enable = lib.mkEnableOption ''
      out-of-tree patched mt76 driver from github.com/zbowling/mt7925.

      Workaround for MLO/RTNL/nl80211 deadlocks, NULL derefs, and
      suspend/resume hangs on mt7925 (Wi-Fi 7) / mt7921 chips in stock Linux
      6.8 – 6.19. Disable once the active LTS kernel carries the backports
    '';
  };

  config = lib.mkMerge [
    {
      environment.systemPackages = with pkgs; [
        iw
      ];

      hardware.wirelessRegulatoryDatabase = true;

      # Pin the regulatory country learnt from the AP's beacons as a user hint, so the
      # regdom doesn't fall back to world (00) and drop 6 GHz / higher TX power.
      networking.networkmanager.dispatcherScripts = [
        {
          type = "basic";
          source = pkgs.writeShellScript "pin-wifi-regdom" ''
            [ -d "/sys/class/net/$1/wireless" ] && [ "$2" = "up" ] || exit 0
            cc=$(${pkgs.iw}/bin/iw reg get | ${pkgs.gawk}/bin/awk '/^global/{g=1} g && /^country/{print substr($2,1,2); exit}')
            [ -n "$cc" ] && [ "$cc" != "00" ] && ${pkgs.iw}/bin/iw reg set "$cc"
          '';
        }
      ];
    }

    (lib.mkIf cfg.enable {
      boot.extraModulePackages = [
        (config.boot.kernelPackages.callPackage ../../pkgs/mt76-mt7925 {})
      ];

      assertions = [
        {
          assertion =
            !(config.boot.kernelPackages.kernel.kernelOlder "6.17"
              || config.boot.kernelPackages.kernel.kernelAtLeast "6.20");
          message = ''
            networking.wifi.mt7925Patched supports kernels 6.17 – 6.19 only.
            Check whether the running kernel already carries the upstream fix
            and disable this option if so.
          '';
        }
      ];
    })
  ];
}

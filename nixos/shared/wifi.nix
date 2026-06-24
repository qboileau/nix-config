{
  config,
  lib,
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

  config = lib.mkIf cfg.enable {
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
  };
}

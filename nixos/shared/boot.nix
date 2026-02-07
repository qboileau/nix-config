{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.boot;
in {
  options.boot = {
    useLatestKernel = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Use latest kernel instead of LTS for gaming performance";
    };

    kernelVersion = lib.mkOption {
      type = lib.types.str;
      default = if cfg.useLatestKernel then "latest" else "6_18";
      description = "Kernel version to use (LTS 6_18 for stability, latest for performance)";
    };
  };

  config = {
    # Bootloader configuration
    boot.loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    # Kernel selection based on configuration
    boot.kernelPackages = 
      if cfg.useLatestKernel 
      then pkgs.linuxPackages_latest
      else pkgs.linuxPackages_6_18;
  };
}
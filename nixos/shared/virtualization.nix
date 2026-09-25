{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.virtualisation;
in {
  options.virtualisation = {
    docker = {
      enableUnstable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Use unstable Docker package instead of stable";
      };

      enableRootless = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable rootless Docker (may cause issues with K3s)";
      };
    };

    enableLibvirtd = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable libvirtd for KVM/QEMU virtualization";
    };

    enableVirtManager = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable virt-manager GUI";
    };

    enableBinfmt = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable binfmt support for multi-platform containers";
    };
  };

  config = lib.mkMerge [
    # Docker configuration
    {
      virtualisation.docker = {
        enable = true;
        package = if cfg.docker.enableUnstable then pkgs.unstable.docker else pkgs.docker;
        storageDriver = "btrfs";
        
        daemon.settings = {
          experimental = true;
          features = {
            buildkit = true;
          };
        };

        # Rootless Docker (optional, disabled by default due to K3s issues)
        rootless = lib.mkIf cfg.docker.enableRootless {
          enable = true;
          setSocketVariable = true;
          daemon.settings = {
            "storage-driver" = "btrfs";
            experimental = true;
            features = {
              buildkit = true;
            };
          };
        };
      };

      # Chromium aborts in-flight requests (ERR_NETWORK_CHANGED) on any IP address change, and the
      # kernel assigns fe80:: to every docker veth/bridge; daemon.json has no option to prevent it.
      # https://github.com/docker/for-linux/issues/914
      services.udev.extraRules = ''
        ACTION=="add", SUBSYSTEM=="net", KERNEL=="veth*|br-*|docker0", RUN+="${pkgs.procps}/bin/sysctl -w net.ipv6.conf.$name.disable_ipv6=1"
      '';
    }

    # libvirtd and virt-manager
    (lib.mkIf cfg.enableLibvirtd {
      virtualisation.libvirtd.enable = true;
      environment.systemPackages = with pkgs; [
        qemu
      ];
    })

    (lib.mkIf cfg.enableVirtManager {
      programs.virt-manager.enable = true;
    })

    # Binfmt support for multi-platform containers
    (lib.mkIf cfg.enableBinfmt {
      boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
      boot.binfmt.preferStaticEmulators = true;
    })
  ];
}
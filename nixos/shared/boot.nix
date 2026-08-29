{
  config,
  lib,
  pkgs,
  inputs,
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

    bootloader = lib.mkOption {
      type = lib.types.enum [ "systemd-boot" "grub" ];
      default = "systemd-boot";
      description = "Bootloader to use (systemd-boot or grub)";
    };

    grub = {
      theme = lib.mkOption {
        type = lib.types.enum [ "breeze" "stylish" "fallback" ];
        default = "breeze";
        description = "GRUB theme to use";
      };

      resolution = lib.mkOption {
        type = lib.types.str;
        default = "1920x1080";
        description = "GRUB display resolution";
      };

      timeout = lib.mkOption {
        type = lib.types.int;
        default = 5;
        description = "GRUB menu timeout in seconds";
      };
    };
  };

  config = lib.mkMerge [
    # Kernel selection based on configuration
    {
      boot.kernelPackages =
        if cfg.useLatestKernel
        then pkgs.linuxPackages_latest
        else pkgs.linuxPackages_6_18;
    }

    # Performance and gaming sysctl tuning
    {
      boot.kernel.sysctl = {
        "kernel.split_lock_mitigate" = 0;
        "kernel.nmi_watchdog" = 0;
        "vm.max_map_count" = 16777216;
        "vm.swappiness" = 10;
        "vm.vfs_cache_pressure" = 50;
        "vm.dirty_bytes" = 268435456;
        "vm.dirty_background_bytes" = 67108864;
        "vm.dirty_writeback_centisecs" = 1500;
        "vm.page-cluster" = 0;
      };

      zramSwap = {
        enable = true;
        algorithm = "zstd";
        memoryPercent = 25;
        priority = 5;
      };
    }

    # systemd-boot configuration
    (lib.mkIf (cfg.bootloader == "systemd-boot") {
      boot.loader = {
        systemd-boot.enable = true;
        efi.canTouchEfiVariables = true;
      };
    })

    # GRUB configuration
    # Migration 
    # 1. backup : sudo cp -r /boot /boot.backup
    # 2. Test and build nixos-rebuild
    # 3. Check Grub : 
    #    sudo efibootmgr -v  # Check EFI boot entries
    #    ls /boot/EFI/GRUB   # Verify GRUB files
    # 4. If boot fails:
    #  Boot from a NixOS live USB
    #  Mount your system and chroot into it
    #  Switch back to systemd-boot temporarily
    #  sudo efibootmgr -v  # Check EFI boot entries
    #  Reinstall GRUB if needed:
    #  sudo grub-install --target=x86_64-efi --efi-directory=/boot
    #  sudo grub-mkconfig -o /boot/grub/grub.cfg
    (lib.mkIf (cfg.bootloader == "grub") {
      boot.loader = {
        systemd-boot.enable = false;
        efi.canTouchEfiVariables = true;
        
        grub = {
          enable = true;
          efiSupport = true;
          device = "nodev"; # UEFI mode
          useOSProber = true; # Detect other operating systems
          configurationLimit = 10; # Keep last 10 generations
          
          # Theme configuration
          theme = lib.mkIf (cfg.grub.theme == "breeze") (pkgs.stdenv.mkDerivation {
            name = "grub-breeze-theme";
            src = pkgs.fetchFromGitHub {
              owner = "gustawho";
              repo = "grub2-theme-breeze";
              rev = "v5.14";
              sha256 = "sha256-1M5OeiLpJhIU0q4NHPv4H7rh1+0W5a5ck3VsM2PH9+E=";
            };
            installPhase = ''
              mkdir -p $out
              cp -r breeze $out/
            '';
          });
          
          splashImage = lib.mkIf (cfg.grub.theme == "breeze") null; # Use theme background
          
          # Display settings
          gfxmodeEfi = "auto";
          gfxmodeBios = "auto";
          
          # Menu settings
          timeout = cfg.grub.timeout;
          
          # Custom menu entries (optional)
          extraEntries = ''
            menuentry "System Settings (UEFI)" {
              fwsetup
            }
            menuentry "Reboot" {
              reboot
            }
            menuentry "Shutdown" {
              halt
            }
          '';

          # Custom GRUB configuration
          extraConfig = ''
            # Set theme colors if no theme package is used
            set color_normal=white/black
            set color_highlight=black/light-gray
            
            # Enable graphical terminal
            if loadfont unicode ; then
              set gfxmode=auto
              insmod gfxterm
              insmod all_video
              terminal_output gfxterm
            fi
            
            # Load video modules
            insmod efi_gop
            insmod efi_uga
            insmod video_bochs
            insmod video_cirrus

            # Additional video configuration
            insmod png
            insmod jpeg
      
            # Set timeout style
            set timeout_style=menu

            # Set console resolution to match graphics mode
            set gfxpayload=keep
          '';
        };
      };

      # Install GRUB theme packages
      environment.systemPackages = with pkgs; lib.optionals (cfg.grub.theme == "breeze") [
        # Add theme-related packages if needed
      ];
    })
    
    # Plymouth configuration (uses official boot.plymouth.enable option)
    (lib.mkIf cfg.plymouth.enable {
      boot.plymouth = {
        nixos-loading.variant = "spin";
        theme = "nixos-loading-default";
        themePackages = [
          inputs.nixos-loading-plymouth.packages.${pkgs.stdenv.hostPlatform.system}.nixos-loading-default
        ];
      };
    })
  ];
}
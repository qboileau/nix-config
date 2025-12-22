# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  hostUsers,
  ...
}: {
  # You can import other NixOS modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/nixos):
    # outputs.nixosModules.example

    # Or modules from other flakes (such as nixos-hardware):
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd

    # You can also split up your configuration and import pieces of it here:
    # ./users.nix

    # Import your generated (nixos-generate-config) hardware configuration
    ./hardware-configuration.nix
    ./disks.nix
    #../shared/desktop/i3/system.nix
    # ../shared/desktop/sway/system.nix
    ../shared/desktop/hyprland/system.nix
    ../shared/gaming
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

  nix = let
    flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
  in {
    settings = {
      # Enable flakes and new 'nix' command
      experimental-features = "nix-command flakes";
      # Opinionated: disable global registry
      flake-registry = "";
      # Workaround for https://github.com/NixOS/nix/issues/9574
      nix-path = config.nix.nixPath;

      auto-optimise-store = true;
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };

    channel.enable = true;

    # Opinionated: make flake registry and nix path match flake inputs
    registry = lib.mapAttrs (_: flake: {inherit flake;}) flakeInputs;
    nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
  };

  # Bootloader.
  boot = {
    kernelPackages = pkgs.linuxPackages_6_18; # force latest LTS kernel 
    loader = { 
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
      # migrate sudo nixos-rebuild --install-bootloader boot
      # Delete old /boot/EFI/BOOT/BOOTX64.EFI from systemd-boot 
      # grub = {
      #     enable = true;
      #     efiSupport = true;
      #     device = "nodev";
      # };
    };
  };

  services.dnsmasq = {
    enable = true;
    settings = {
      # bind-interfaces = true;
      # interface = "wlp170s0";
      # listen-address= ["127.0.0.1"];
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
    hostName = "framework"; # Define your hostname.
    nat.enable = true;
    hosts = {
      "127.0.0.1" = ["framework"];
      "::1" = ["framework"];
    };

    networkmanager.enable = true;
    networkmanager.dns = "none"; # Disable NetworkManager's internal DNS resolution
    useDHCP = false; # These options are unnecessary when managing DNS ourselves
    dhcpcd.enable = false;
    nameservers = [ "127.0.0.1" ]; # use DNSmasq
  };
  services.tailscale.enable = true;

  time.timeZone = "Europe/Paris";
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "fr_FR.UTF-8";
    LC_IDENTIFICATION = "fr_FR.UTF-8";
    LC_MEASUREMENT = "fr_FR.UTF-8";
    LC_MONETARY = "fr_FR.UTF-8";
    LC_NAME = "fr_FR.UTF-8";
    LC_NUMERIC = "fr_FR.UTF-8";
    LC_PAPER = "fr_FR.UTF-8";
    LC_TELEPHONE = "fr_FR.UTF-8";
    LC_TIME = "fr_FR.UTF-8";
  };

  #Framework firmware update `fwupdmgr update` 
  services.fwupd.enable = true;

  # services.xserver.enable = false;

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "chili";
  };
  # Enable the KDE Plasma Desktop Environment.
  # services.desktopManager.plasma6.enable = false;

  # XFCE
  #services.xserver.desktopManager.xfce.enable = true;
 
  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "alt-intl";
  };

  # Configure console keymap
  console.keyMap = "us";

  services.printing.enable = false;
  services.libinput.enable = true;

  # Enable sound with pipewire.
  # https://wiki.nixos.org/wiki/PipeWire#
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  systemd.user.services.pipewire.environment.PIPEWIRE_DEBUG = "5";
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    wireplumber.enable = true;
    wireplumber.extraConfig."10-bluez" = {
      "monitor.bluez.properties" = {
        "bluez5.enable-sbc-xq" = true;
        "bluez5.enable-msbc" = true;
        "bluez5.enable-hw-volume" = true;
        # https://pipewire.pages.freedesktop.org/wireplumber/daemon/configuration/bluetooth.html#monitor-properties
        "bluez5.roles" = [
          "a2dp_sink" 
          "a2dp_source"
          "bap_sink" 
          "bap_source"
          "hsp_hs"
          "hsp_ag"
          "hfp_hf"
          "hfp_ag"
        ];
      };
    };
    extraConfig = {
      pipewire = {
        "switch-on-connect" = {
          "pulse.cmd" = [
            {
              cmd = "load-module";
              args = "module-always-sink";
              flags = [ ];
            }
            {
              cmd = "load-module";
              args = "module-switch-on-connect";
            }
          ];
        };
      };
    };
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Experimental = true; # Show battery charge of Bluetooth devices
      };
    };
  };
  services.blueman.enable = true;

  powerManagement.enable = true;
  services.power-profiles-daemon.enable = false;
  programs.auto-cpufreq.enable = true;
  programs.auto-cpufreq.settings = {
    battery = {
      governor = "powersave";
      turbo = "never";
    };
    charger = {
      governor = "performance";
      turbo = "auto";
    };
  };

  # Fprint
  systemd.services.fprintd = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "simple";
  };

  services.fprintd.enable = true;
  services.fprintd.tod.enable = true;
  services.fprintd.tod.driver = pkgs.libfprint-2-tod1-goodix; # Goodix driver module

  virtualisation.docker = { 
    enable = true;
    package = pkgs.unstable.docker;
    storageDriver = "btrfs";
    # Optionally customize rootless Docker daemon settings
    daemon.settings = {
      experimental = true;
      features = {
        buildkit = true;
      };
    };
    # Disable rootless Docker because it cause issues with K3s cluster https://github.com/NixOS/nixpkgs/issues/385044
    # rootless = {
    #   enable = true;
    #   setSocketVariable = true;
    #   # Optionally customize rootless Docker daemon settings
    #   daemon.settings = {
    #     "storage-driver" = "btrfs";
    #     experimental = true;
    #     features = {
    #       buildkit = true;
    #     };
    #   };
    # };
  };

  # Enable binfmt support for multi-platform containers
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  # Use self-contained, static emulators that work inside containers
  boot.binfmt.preferStaticEmulators = true;

  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;
  
  services.touchegg.enable = true;

  programs.obs-studio = {
    enable = true;
    enableVirtualCamera = true;
    plugins = with pkgs; [
      obs-studio-plugins.wlrobs
    ];
  };


  programs.firefox.enable = true;
  
  environment.pathsToLink = [ "/share/bash-completion" ]; # needed for bash completion

  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
   home-manager
   pavucontrol
   pwvucontrol
   gparted
   wget
   git
   gnumake
   unzip
   p7zip
   statix
   bzip2
   pciutils
   usbutils
   hwinfo
   age
   sops 
   openssl
   ddcutil
   i2c-tools
   fprintd
   qemu
   sddm-chili-theme
   samba
   cifs-utils # Samba client
   framework-tool
  ];
  services.clamav.daemon.enable = true;

  services.gvfs.enable = true; # https://nixos.wiki/wiki/Samba#Browsing_samba_shares_with_GVFS

  # TODO: Configure your system-wide user settings (groups, etc), add more users as needed.
  users.users = builtins.listToAttrs (map (user: lib.nameValuePair user {
    isNormalUser = true;
    #initialPassword = "changeme";
    shell = pkgs.bash;
    openssh.authorizedKeys.keys = [
      # TODO: Add your SSH public key(s) here, if you plan on using SSH to connect
    ];
    # TODO: Be sure to add any other groups you need (such as networkmanager, audio, docker, etc)
    extraGroups = ["wheel" "networkmanager" "docker" "libvirtd"];
  }) hostUsers);


  programs.gnupg.agent.enable = true;

  # This setups a SSH server. Very important if you're setting up a headless system.
  # Feel free to remove if you don't need it.
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

  # Custom options
  gaming.enable = true;
  gaming.vr.enable = false;
  gaming.amd.enable = false;


  services.udev.extraRules = ''
    # allow keychron k2 HE keyboard
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="3434", ATTRS{idProduct}=="0e20", MODE="0666", GROUP="users", TAG+="uaccess", TAG+="udev-acl"
    # keychron k2 HE stm bootloader
    SUBSYSTEM=="usb", ATTRS{idVendor}=="3434", ATTRS{idProduct}=="0e20", MODE="0666", GROUP="users", TAG+="uaccess", TAG+="udev-acl"
    # keychron link
    SUBSYSTEM=="usb", ATTRS{idVendor}=="3434", ATTRS{idProduct}=="d030", MODE="0666", GROUP="users", TAG+="uaccess", TAG+="udev-acl"
  '';

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; 
  #system.autoUpgrade.enable = true;
  #system.autoUpgrade.channel = "https://channels.nixos.org/nixos-24.11";

}

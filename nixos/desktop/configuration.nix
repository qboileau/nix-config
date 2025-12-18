{
  inputs,
  outputs,
  options,
  lib,
  config,
  pkgs,
  hostUsers,
  username,
  ...
}: {
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../shared/desktop/hyprland/system.nix
      ../shared/gaming

      outputs.nixosModules.noctalia
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
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;


  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "desktop"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  
  networking.timeServers = options.networking.timeServers.default ++ [ "time.cloudflare.com" "fr.pool.ntp.org" ];

  # Enable networking
  networking.networkmanager.enable = true;
  networking.firewall = {
    checkReversePath = false;
    #KDE connect ports https://wiki.nixos.org/wiki/KDE_Connect
    allowedTCPPortRanges = [ { from = 1714; to = 1764; } ];
    allowedUDPPortRanges = [ { from = 1714; to = 1764; } ];
  };
  services.tailscale.enable = true;

  # Time zone and Local
  time.timeZone = "Europe/Paris";
  i18n.defaultLocale = "fr_FR.UTF-8";
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

  services.displayManager = { 
    # Enable automatic login for the user.security
    autoLogin = {
      enable = true;
      user = "${username}";
    };
    sddm = {
      enable = true;
      wayland.enable = true;
       # TODO uncomment whtn commenting plasma6
      # package = pkgs.kdePackages.sddm;
      # theme = "breeze";
      # extraPackages = with pkgs.kdePackages; [ 
      #   breeze-icons
      #   kirigami
      #   libplasma
      #   qtsvg
      #   qtvirtualkeyboard
      # ];
    };
  };
  
  # Enable the KDE Plasma Desktop Environment.
  services.desktopManager.plasma6.enable = true;

  security = {
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
    polkit = {
      enable = true;
    };
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "alt-intl";
  };

  # Configure console keymap
  console.keyMap = "us";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
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

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  users.users.${username} = {
    uid = 1000;
    group = "users";
    isNormalUser = true;
    shell = pkgs.bash;
    openssh.authorizedKeys.keys = [
      # TODO: Add your SSH public key(s) here, if you plan on using SSH to connect
    ];
    # TODO: Be sure to add any other groups you need (such as networkmanager, audio, docker, etc)
    extraGroups = ["wheel" "networkmanager" "docker" "libvirtd" "gamemode"];
    packages = with pkgs; [];
  };

  # Install firefox.
  programs.firefox.enable = true;

  programs.gnupg.agent.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
    gnumake
    gparted
    wget
    git
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
    qemu
    pavucontrol
    pwvucontrol
    cifs-utils # Samba client
    wireguard-tools
    openvpn3

    # KDE packages
    kdePackages.breeze
    kdePackages.breeze-icons
    kdePackages.breeze-gtk
    kdePackages.kwallet
    kdePackages.kwallet-pam
    kdePackages.kwalletmanager
  ];
  services.samba.enable = true;
  services.gvfs.enable = true; # https://nixos.wiki/wiki/Samba#Browsing_samba_shares_with_GVFS
  services.gvfs.package = pkgs.gvfs;

  services.udev.packages = with pkgs; [
    unstable.logitech-udev-rules
    unstable.keychron-udev-rules
  ];

  services.udev.extraRules = ''
    # allow keychron k2 HE keyboard
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="3434", ATTRS{idProduct}=="0e20", MODE="0666", GROUP="users", TAG+="uaccess", TAG+="udev-acl"
    # keychron k2 HE stm bootloader
    SUBSYSTEM=="usb", ATTRS{idVendor}=="3434", ATTRS{idProduct}=="0e20", MODE="0666", GROUP="users", TAG+="uaccess", TAG+="udev-acl"
    # keychron link
    SUBSYSTEM=="usb", ATTRS{idVendor}=="3434", ATTRS{idProduct}=="d030", MODE="0666", GROUP="users", TAG+="uaccess", TAG+="udev-acl"
  '';

  # Custom options
  gaming.enable = true;
  gaming.vr.enable = true;

  noctalia.enable = false;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

}

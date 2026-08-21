{
  inputs,
  outputs,
  options,
  lib,
  config,
  pkgs,
  username,
  ...
}: {
  imports = [
    # Hardware configuration
    ./hardware-configuration.nix
    
    # Shared modules
    ../shared
    
    # Desktop environment
    ../shared/desktop/hyprland/system.nix
    
    # Host-specific modules
    ../shared/gaming
    ../shared/services/printing
    ../shared/services/ai

    outputs.nixosModules.noctalia
  ];

  # Ensure overlays are available for home-manager (useGlobalPkgs)
  nixpkgs.overlays = [
    outputs.overlays.additions
    outputs.overlays.modifications
    outputs.overlays.unstable-packages
  ];

  # Configure shared modules for gaming desktop
  boot.useLatestKernel = true; # Use latest kernel for gaming performance
  boot.bootloader = "systemd-boot";
  boot.plymouth.enable = true; # Enable Plymouth boot splash screen
  # boot.bootloader = "grub"; # Switch to GRUB
  # boot.grub = {
  #   theme = "breeze"; # Match your desktop theme
  #   resolution = "1920x1080"; # Adjust to your display
  #   timeout = 5;
  # };


  networking = {
    hostName = "desktop";
    useAdvancedDns = false; # Standard NetworkManager setup
    enableKdeConnect = true; # Enable KDE Connect ports
    customTimeServers = true; # Add custom time servers
  };

  desktop = {
    enableAutoLogin = false;
    enablePlasma = false;
    sddm.theme = "chili";
    # sddm.theme defaults to "sddm-astronaut-theme" (see nixos/shared/desktop.nix),
    # which installs a preconfigured astronaut greeter + greeter Qt modules.
    # To change the variant or its [General] keys, edit the custom-sddm-theme
    # override in nixos/shared/desktop.nix.
  };

  virtualisation = {
    docker.enableUnstable = true;
    docker.enableRootless = false;
    enableLibvirtd = true; # Enable for VMs
    enableVirtManager = true;
    enableBinfmt = true; # Enable for multi-platform containers
  };

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
    extraGroups = ["wheel" "networkmanager" "docker" "libvirtd" "gamemode" "i2c"];
    packages = with pkgs; [];
  };

  environment.pathsToLink = [ "/share/bash-completion" ]; # needed for bash completion

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  ];


  # Custom options
  gaming = { 
    enable = true;
    vr.enable = true;
    amd.enable = true;
    emulators.enable = true;
  };

  services.ai = {
    enable = true;
    acceleration = "rocm";
  };

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

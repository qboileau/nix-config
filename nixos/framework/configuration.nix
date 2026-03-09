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
    # Hardware and disk configuration
    ./hardware-configuration.nix
    ./disks.nix
    
    # Shared modules
    ../shared
    
    # Desktop environment
    ../shared/desktop/hyprland/system.nix
    
    # Host-specific modules
    ../shared/gaming
  ];

  # Ensure overlays are available for home-manager (useGlobalPkgs)
  nixpkgs.overlays = [
    outputs.overlays.additions
    outputs.overlays.modifications
    outputs.overlays.unstable-packages
  ];


  # Configure shared modules for framework (work laptop)
  boot.useLatestKernel = false; # Use LTS for stability

  # Configure networking for work laptop
  networking = {
    hostName = "framework";
    useAdvancedDns = true; # Use dnsmasq for advanced DNS setup
    hosts = {
      "127.0.0.1" = ["framework"];
      "::1" = ["framework"];
    };
  };

  # Configure desktop for framework
  desktop = {
    sddm.theme = "breeze";
    enableAutoLogin = false; # No auto-login on work laptop
    enablePlasma = true; # Using Hyprland
  };

  # Configure virtualization for development work
  virtualisation = {
    docker.enableUnstable = true; # Use unstable Docker
    docker.enableRootless = true; # Disabled due to K3s issues
    enableLibvirtd = true; # Not needed on work laptop
    enableVirtManager = true;
    enableBinfmt = true;
  };

  programs.obs-studio = {
    enable = true;
    enableVirtualCamera = true;
    plugins = with pkgs; [
      obs-studio-plugins.wlrobs
    ];
  };
  
  environment.pathsToLink = [ "/share/bash-completion" ]; # needed for bash completion

  environment.systemPackages = with pkgs; [
   sddm-chili-theme
  ];

  security.enableClamAv = true;

  # TODO: Configure your system-wide user settings (groups, etc), add more users as needed.
  users.users = builtins.listToAttrs (map (user: lib.nameValuePair user {
    isNormalUser = true;
    #initialPassword = "changeme";
    shell = pkgs.bash;
    openssh.authorizedKeys.keys = [
      # TODO: Add your SSH public key(s) here, if you plan on using SSH to connect
    ];
    # TODO: Be sure to add any other groups you need (such as networkmanager, audio, docker, etc)
    extraGroups = ["wheel" "networkmanager" "docker" "libvirtd" "i2c"];
  }) hostUsers);


  # Custom options
  gaming = { 
    enable = true;
    vr.enable = false;
    amd.enable = false;
    emulators.enable = false;
  };

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

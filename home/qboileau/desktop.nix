# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  outputs,
  lib,
  config,
  configLib,
  pkgs,
  username,
  ...
}: {
  
  # You can import other home-manager modules here
  imports = [
    ../shared
    ../shared/desktop/hyprland
  ];

  # Enable home-manager
  programs.home-manager.enable = true;

  home = {
    username = "${username}";
    homeDirectory = "/home/${username}";
  };

  # Add stuff for your user as you see fit:
  home.packages = with pkgs; [
    kdePackages.kate
    prusa-slicer
    samba
  ];

  # Custom options
  gaming.enable = true;
  gaming.gameLocations = [ "/mnt/LinuxGames/" ];
  
  # Apps
  apps.productivity.enable = true;
  apps.communication.discord.enable = true;
  apps.communication.signal.enable = true;
  apps.security.bitwarden.enable = true;
  apps.security.proton.enable = true;
  apps.media.spotify.enable = true;
  apps.media.qbz.enable = true;
  apps.media.mpv.enable = true;
  apps.browsers.firefox.enable = true;
  apps.browsers.brave.enable = true;
  
  # Tools
  tools.monitoring.enable = true;
  tools.bluetooth.enable = true;
  tools.peripherals.enable = true;
  
  # Services
  services.cloudSync.dropbox.enable = true;
  services.cloudSync.synology.enable = true;
  services.cloudSync.tailscale.enable = true;
  
  # Dev tools - minimal profile for desktop
  dev.languages.python.enable = true;
  dev.languages.nodejs.enable = true;
  dev.tools.ai.enable = true;
  dev.tools.security.enable = true;
  
  # Editors
  editors.vim.enable = true;
  editors.vim.defaultEditor = true;
  editors.xed.enable = true;
  editors.vscode.enable = true;
  hyprland.configType = "lua";
  hyprland.autolock.enable = false;
  hyprland.autostart = [  
    "bitwarden"
    "firefox"
    "steam"
    "discord"  # Flatpak: com.discordapp.Discord
    "protonvpn-app"
    "signal-desktop"  # Flatpak: org.signal.Signal
    #"tail-tray"
  ];

  # Background deamon
  #nm-applet
  services.network-manager-applet.enable = true;
  services.dropbox.enable = true;
  services.kdeconnect.enable = true;
  services.kdeconnect.indicator = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.11";
}

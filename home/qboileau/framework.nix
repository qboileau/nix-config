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
    # ../shared/desktop/i3
    # ../shared/desktop/sway
  ];

  home = {
    username = "${username}";
    homeDirectory = "/home/${username}";
  };

  home.packages = with pkgs; [ 
    vlc
    imv
  ];

  programs.mpv = {
    enable = true;
    package = (
      pkgs.mpv-unwrapped.wrapper {
        scripts = with pkgs.mpvScripts; [
          uosc
        ];
        mpv = pkgs.mpv-unwrapped.override {
          ffmpeg = pkgs.ffmpeg-full;
        };
      }
    );
  };

  # Custom options
  defaultBrowser = {
    package = pkgs.unstable.brave;
    desktopFile = "brave-browser.desktop";
  };
  gaming.enable = false;
  
  # Apps
  apps.productivity.enable = true;
  apps.communication.slack.enable = true;  # Work communication
  apps.security.onepassword.enable = true;  # Work password manager
  apps.browsers.firefox.enable = true;
  apps.browsers.brave.enable = true;
  apps.browsers.chromium.enable = true;
  apps.media.spotify.enable = true;
  apps.media.qbz.enable = true;

  # Tools
  tools.monitoring.enable = true;
  tools.bluetooth.enable = true;
  
  # Services
  services.cloudSync.dropbox.enable = true;
  
  # Dev tools - full profile for work laptop
  # Languages
  dev.languages.java.enable = true;
  dev.languages.rust.enable = true;
  dev.languages.nodejs.enable = true;
  dev.languages.go.enable = true;
  dev.languages.python.enable = true;
  
  # DevOps/Backend tools
  dev.tools.build.enable = true;
  dev.tools.kubernetes.enable = true;
  dev.tools.cloud.enable = true;
  dev.tools.database.enable = true;
  dev.tools.network.enable = true;
  dev.tools.containers.enable = true;
  dev.tools.api.enable = true;
  dev.tools.ai.enable = true;
  dev.tools.security.enable = true;
  dev.tools.docs.enable = true;  # Documentation tools
  # dev.tools.virtualization.enable = true;  # Uncomment if needed
  
  # Editors
  editors.vim.enable = true;
  editors.vim.defaultEditor = false;
  editors.vscode.enable = true;
  editors.intellij.enable = true;
  editors.zed.enable = true;
  hyprland.autolock.enable = true;
  hyprland.autostart = [];

  # Background deamon
  #nm-applet
  services.network-manager-applet.enable = true;
  services.dropbox.enable = true;

  # Enable home-manager
  programs.home-manager.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.11";
}

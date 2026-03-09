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
    ../shared/xdg.nix
    ../shared/theme.nix
    ../shared/base-tools.nix
    ../shared/work-tools.nix
    ../shared/shells
    ../shared/dev
    ../shared/editors
    ../shared/gaming

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

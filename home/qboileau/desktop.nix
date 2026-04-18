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
#     ../shared/work-tools.nix
    ../shared/shells
    ../shared/dev
    ../shared/editors
    ../shared/gaming
    ../shared/desktop/hyprland
  ];

  # Enable home-manager
  programs.home-manager.enable = true;

  home = {
    username = "${username}";
    homeDirectory = "/home/${username}";
  };

  # Add stuff for your user as you see fit:
  # programs.neovim.enable = true;
  home.packages = with pkgs; [ 
    kdePackages.kate
    vlc
    unstable.brave
    chromium
    signal-desktop-bin
    prusa-slicer
    samba
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
  gaming.enable = true;
  
  # Dev tools - minimal profile for desktop
  dev.languages.python.enable = true;
  dev.languages.nodejs.enable = true;
  dev.tools.ai.enable = true;
  hyprland.autolock.enable = false;
  hyprland.autostart = [  
    "bitwarden"
    "firefox"
    "steam"
    "discordptb"
    "protonvpn-app"
    "signal-desktop"
    "tail-tray"
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

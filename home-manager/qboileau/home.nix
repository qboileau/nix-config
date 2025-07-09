# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  outputs,
  lib,
  config,
  configLib,
  pkgs,
  ...
}: {
  
  # You can import other home-manager modules here
  imports = [
    ../shared/base-tools.nix
    ../shared/work-tools.nix
    ../shared/shells
    ../shared/dev
    ../shared/editors

    ../shared/desktop/hyprland
    ../shared/desktop/i3
    ../shared/desktop/sway
  ] ++ map configLib.relativeToRoot [
    #"pkgs/shells"
    #"pkgs/base-tools.nix"
    #"pkgs/work-tools.nix"

    #"pkgs/dev"
    #"pkgs/editors"
    #"pkgs/i3"
    #"pkgs/sway"
    #"pkgs/hyprland"
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

  home = {
    username = "qboileau";
    homeDirectory = "/home/qboileau";
  };

  # Add stuff for your user as you see fit:
  # programs.neovim.enable = true;
  home.packages = with pkgs; [ 
    vlc
 ];

  # Background deamon
  #nm-applet
  services.network-manager-applet.enable = true;
  services.dropbox.enable = true;

  # Enable home-manager
  programs.home-manager.enable = true;

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "inode/directory" = "pcmanfm.desktop";
      "text/html" = "brave-browser.desktop";
      "application/pdf" = "okular.desktop";
      "application/yaml" = "code.desktop";
      "application/xml" = "code.desktop";
      "application/json" = "code.desktop";
      "application/x-gzip" = "org.kde.ark.desktop";
      "application/zip" = "org.kde.ark.desktop";
      "application/rar" = "org.kde.ark.desktop";
      "application/7z" = "org.kde.ark.desktop";
      "application/*tar" = "org.kde.ark.desktop";
      "image/*" = "org.kde.gwenview.desktop";
      "image/gif" = "org.kde.gwenview.desktop";
      "image/jpeg" = "org.kde.gwenview.desktop";
      "image/png" = "org.kde.gwenview.desktop";
      "image/webp" = "org.kde.gwenview.desktop";
      "video/*" = "vlc.desktop";
      "audio/*" = "vlc.desktop";
      "x-scheme-handler/slack" = "slack.desktop";
    };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.11";
}

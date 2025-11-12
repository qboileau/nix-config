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
    ../shared/base-tools.nix
#     ../shared/work-tools.nix
    ../shared/shells
#     ../shared/dev
    ../shared/editors

    ../shared/gaming

    ../shared/desktop/hyprland
    # ../shared/desktop/i3
    # ../shared/desktop/sway
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
  ];

  # Custom options
  gaming.enable = true;
  hyprland.autolock.enable = false;

  # Background deamon
  #nm-applet
  services.network-manager-applet.enable = true;
  services.dropbox.enable = true;

  xdg = {

    portal = {
      enable = true;
      extraPortals = [
        pkgs.xdg-desktop-portal-gtk
      ];
      config.common.default = "hyprland;gtk";
      config.common."org.freedesktop.impl.portal.FileChooser" = "gtk";
      config.common."org.freedesktop.portal.FileChooser" = "gtk";
    };

    mimeApps = {
      enable = true;
      defaultApplications = {
        "inode/directory" = "dolphin.desktop";
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
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  home.pointerCursor = {
    gtk.enable = true;
    # x11.enable = true;
    package = pkgs.adwaita-icon-theme;
    name = "Adwaita";
    size = 24;
  };

  gtk = {
    enable = true;

    cursorTheme = {
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
      size = 24;
    };

    theme = {
      package = pkgs.flat-remix-gtk;
      name = "Flat-Remix-GTK-Blue-Dark";
    };

    iconTheme = {
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
    };

    font = {
      name = "Noto Sans";
      size = 11;
    };

    gtk3.extraConfig = {
      "gtk-application-prefer-dark-theme" = "true";
      "gtk-enable-primary-paste" = "true";
      "gtk-enable-event-sounds" = "false";
      "gtk-enable-input-feedback-sounds" = "false";
      "gtk-enable-animations" = "true";
    };

    gtk4.extraConfig = {
      "gtk-application-prefer-dark-theme" = "true";
      "gtk-enable-primary-paste" = "true";
      "gtk-enable-event-sounds" = "false";
      "gtk-enable-input-feedback-sounds" = "false";
      "gtk-enable-animations" = "true";
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "gtk";
    style = {
      name = "gtk2";
      package = pkgs.qt6Packages.qt6gtk2;
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.11";
}

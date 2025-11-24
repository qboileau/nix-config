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
    mpv
    unstable.brave
  ];

  # Custom options
  gaming.enable = true;
  hyprland.autolock.enable = false;
  hyprland.autostart = [  
    "bitwarden"
    "firefox"
    "steam"
    "discordptb"
    "protonvpn-app"
  ];

  # Background deamon
  #nm-applet
  services.network-manager-applet.enable = true;
  services.dropbox.enable = true;
  services.kdeconnect.enable = true;
  services.kdeconnect.indicator = true;

  xdg = {
    enable = true;
    portal = {
      enable = true;
      extraPortals = [
        pkgs.xdg-desktop-portal-gtk
      ];
      config.common.default = "hyprland;gtk";
      config.common."org.freedesktop.impl.portal.FileChooser" = "gtk";
      config.common."org.freedesktop.portal.FileChooser" = "gtk";
    };

    mime.enable = true;
    mimeApps = let 
      codeEditor = "code.desktop";
      archive = "org.kde.ark.desktop";
      imageViewer = "org.kde.gwenview.desktop";
      videoPlayer = "mpv.desktop";
      browser = "firefox.desktop";
      fileManager = "dolphin.desktop";
    in {
      enable = true;
      defaultApplications = {
        "inode/directory" = fileManager;
        "text/html" = browser;
        "application/pdf" = "okular.desktop";
        "application/yaml" = codeEditor;
        "application/xml" = codeEditor;
        "application/json" = codeEditor;
        "application/x-gzip" = archive;
        "application/zip" = archive;
        "application/rar" = archive;
        "application/7z" = archive;
        "application/*tar" = archive;
        "image/*" = imageViewer;
        "image/gif" = imageViewer;
        "image/jpeg" = imageViewer;
        "image/png" = imageViewer;
        "image/webp" = imageViewer;
        "video/*" = videoPlayer;
        "video/mp4" = videoPlayer;
        "video/x-matroska" = videoPlayer;
        "video/x-ms-wmv" = videoPlayer;
        "video/quicktime" = videoPlayer;
        "video/vnd.avi" = videoPlayer;
        "audio/*" = videoPlayer;
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

{pkgs, ...}:
{
  
  home.packages = with pkgs; [
    # Adwaita
    qadwaitadecorations
    qadwaitadecorations-qt6
    adwaita-icon-theme
    adwaita-qt
    adwaita-qt6

    # Breeze
    kdePackages.breeze
    kdePackages.breeze-icons

    # extracted from https://github.com/nix-community/home-manager/blob/release-25.11/modules/misc/qt.nix#L25-L28
    libsForQt5.qtstyleplugins
    kdePackages.qt6gtk2

    # Dark mode tools
    xdg-desktop-portal
  ];

  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.kdePackages.breeze-icons;
    name = "Breeze Dark";
    size = 24;
  };

  gtk = {
    enable = true;
    gtk2.enable = true;
    gtk3.enable = true;
    

    cursorTheme = {
      package = pkgs.kdePackages.breeze-icons;
      name = "Breeze Dark";
      size = 24;
    };

    theme = {
      package = pkgs.kdePackages.breeze-gtk;
      name = "Breeze-Dark";
    };

    iconTheme = {
      package = pkgs.kdePackages.breeze-icons;
      name = "Breeze Dark";
    };

    font = {
      name = "Noto Sans";
      size = 11;
    };

    gtk2.extraConfig = ''
      gtk-enable-primary-paste = true
      gtk-enable-event-sounds = false
      gtk-enable-input-feedback-sounds = false
    '';

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
    platformTheme.name = "qt6ct";
    # style = {
    #   name = "qt6ct-style";
    #   package = pkgs.kdePackages.qt6ct;
    # };

    qt6ctSettings = {
      Appearance = {
        style = "Breeze";
        icon_theme = "Breeze Dark";
        color_scheme_path = "${pkgs.kdePackages.breeze}/share/color-schemes/BreezeDark.colors";
        standar_dialogs = "xdgdesktopportal";
      };
      Fonts = {
        fixed = "\"Noto Sans,11\"";
        general = "\"Noto Sans,11\"";
      };
    };
  };

  # Set dark mode preference via dconf (used by many apps)
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      gtk-theme = "Breeze-Dark";
    };
  };

}
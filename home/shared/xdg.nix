{pkgs, lib, config, inputs,...}:
let
  cfg = config.defaultBrowser;
in {
  options.defaultBrowser = {
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.firefox;
      description = "The browser package to use as default";
    };
    desktopFile = lib.mkOption {
      type = lib.types.str;
      default = "firefox.desktop";
      description = "The .desktop file name for the default browser";
    };
  };

  config = {
    home.packages = with pkgs; [
      xdg-utils
    ];

    home.sessionVariables.DEFAULT_BROWSER = lib.getExe cfg.package;

    xdg = {
      enable = true;

      userDirs = {
        enable = true;
        createDirectories = true;
        setSessionVariables = true;
      };

      # avoid conflict on mimeapps.list
      configFile."mimeapps.list".force = lib.mkForce true;

      portal = {
        enable = true;
        extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
        config.common.default = "hyprland;gtk";
        config.common."org.freedesktop.impl.portal.FileChooser" = "gtk";
        config.common."org.freedesktop.portal.FileChooser" = "gtk";
        config.common."org.freedesktop.impl.portal.Settings" = "gtk";
        xdgOpenUsePortal = true;
      };

      # list of .desktop
      # ls /run/current-system/sw/share/applications # for global packages
      # ls /etc/profiles/per-user/$(id -n -u)/share/applications # for user packages
      # ls ~/.nix-profile/share/applications # for home-manager packages
      mime.enable = true;
      mimeApps = let 
        codeEditor = "code.desktop";
        archive = "org.kde.ark.desktop";
        imageViewer = "org.kde.gwenview.desktop";
        videoPlayer = "mpv.desktop";
        browser = cfg.desktopFile;
        fileManager = "org.kde.dolphin.desktop";
      in {
        enable = true;
        defaultApplications = {
          "inode/directory" = fileManager;
          "text/html" = browser;
          "x-scheme-handler/http" = browser;
          "x-scheme-handler/https" = browser;
          "x-scheme-handler/about" = browser;
          "x-scheme-handler/unknown" = browser;
          "application/pdf" = "org.kde.okular.desktop";
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
  };
}
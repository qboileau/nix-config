# i3 setup to be imported in nixOS configuration.nix 
{inputs, pkgs, ...} :
{

  services.displayManager.defaultSession = "hyprland";

  #https://wiki.hyprland.org/Nix/Cachix/
  nix.settings = {
    substituters = ["https://hyprland.cachix.org"];
    trusted-substituters = ["https://hyprland.cachix.org"];
    trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
  };

  programs.hyprland = {
    enable = true;
    # set the flake package
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    # make sure to also set the portal package, so that they are in sync
    portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;

    withUWSM  = false; # use SDDM
    xwayland.enable = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ 
      inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland 
    ];

    config.common.default = "*";
    config."org.freedesktop.impl.portal.ScreenCast".default = "hyprland";
  };

  programs.uwsm.enable = false; # use SDDM
  programs.hyprlock.enable = true;
  services.hypridle.enable = true;
  
  # Register kio-fuse D-Bus session service so it auto-activates
  # when Dolphin needs to open remote files with external apps (mpv, vlc, etc.)
  services.dbus.packages = [ pkgs.kdePackages.kio-fuse ];

  environment.systemPackages = with pkgs; [
    kitty
    waybar # TODO flake https://github.com/Alexays/Waybar/wiki/Installation#nixos
    #eww #https://github.com/elkowar/eww
    wofi
    wev
    wayland
    wayland-protocols
    wayland-utils
    wl-mirror
    wf-recorder
    wl-clipboard 
    wlroots
    wlr-randr
    #xwaylandvideobridge # exposes Wayland windows to X11 screen capture
    libsForQt5.qt5.qtwayland
    nwg-displays
    nwg-look
    brightnessctl
    playerctl
    hyprprop
    hyprpicker
    hyprpaper
    hyprlock
    hypridle
    hyprcursor
    hyprpolkitagent
    grim
    slurp
    dunst
    pcmanfm
    #hyprsysteminfo

    # KDE apps
    kdePackages.ark
    kdePackages.okular
    kdePackages.gwenview
    kdePackages.dolphin
    kdePackages.dolphin-plugins
    kdePackages.qtsvg
    kdePackages.kio
    kdePackages.kio-fuse
    kdePackages.kio-extras
    kdePackages.breeze
    kdePackages.breeze-icons
    kdePackages.breeze-gtk
    kdePackages.kwallet
    kdePackages.kwallet-pam
    kdePackages.kwalletmanager

    kdePackages.knewstuff
    kdePackages.ksvg
  ];
}

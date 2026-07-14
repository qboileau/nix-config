# i3 setup to be imported in nixOS configuration.nix
{pkgs, ...} :
{

  imports = [
    # KDE apps (Dolphin, Okular, ...) and KIO/kio-fuse integration.
    ../kde
  ];

  services.displayManager.defaultSession = "hyprland";

  #https://wiki.hyprland.org/Nix/Cachix/
  nix.settings = {
    substituters = ["https://hyprland.cachix.org"];
    trusted-substituters = ["https://hyprland.cachix.org"];
    trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
  };

  programs.hyprland = {
    enable = true;
    # Using pkgs.unstable.hyprland (fully cached via cache.nixos.org, hy3 plugin always in sync).
    # To switch back to flake pin, replace the two lines below with:
    #   package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    #   portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
    package = pkgs.unstable.hyprland;
    portalPackage = pkgs.unstable.xdg-desktop-portal-hyprland;

    withUWSM  = false; # use SDDM
    xwayland.enable = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.unstable.xdg-desktop-portal-hyprland
      # flake pin alternative:
      # inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland
    ];

    config.common.default = "*";
    config."org.freedesktop.impl.portal.ScreenCast".default = "hyprland";
  };

  programs.uwsm.enable = false; # use SDDM

  # NOTE: we deliberately do NOT use programs.hyprlock.enable. That module only
  # adds hyprlock to systemPackages (already done below + via home-manager) and
  # sets up PAM, but it ALSO force-enables the system-level services.hypridle
  # unit. hypridle's config (~/.config/hypr/hypridle.conf) is only deployed by
  # home-manager when hyprland.autolock.enable is true, so on hosts with autolock
  # off (desktop) that unit starts with no config and crash-loops:
  # "Could not find config ... /etc/hypr" -> start-limit-hit. Instead we enable
  # only the piece we need — hyprlock's PAM stack — so it authenticates via PAM
  # rather than falling back to `su`. Where idle IS wanted (framework,
  # autolock=true) home-manager runs its own hypridle unit + config.
  security.pam.services.hyprlock = { };

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
  ];
}

# Shared KDE applications and KIO (Dolphin) integration.
# Imported by the desktop environment modules (e.g. hyprland/system.nix).
{pkgs, ...} :
{

  # Register kio-fuse D-Bus session service so it auto-activates
  # when Dolphin needs to open remote files with external apps (mpv, vlc, etc.)
  services.dbus.packages = [ pkgs.kdePackages.kio-fuse ];

  # The D-Bus file above only registers the name org.kde.KIOFuse and delegates
  # activation to `SystemdService=kio-fuse.service`. kio-fuse ships that unit
  # under $out/share/systemd/user, but NixOS only scans etc|lib/systemd/{system,user}
  # for `systemd.packages`, so the unit is never linked and activation fails with
  # "kio-fuse.service could not be found". Without it, Dolphin cannot FUSE-mount
  # smb:// shares and instead COPIES the whole remote file into a temp dir before
  # launching mpv/vlc — which blows up memory and destabilises the session for
  # large videos. Declaring the unit here mirrors the upstream one (kio-fuse-5.1.1).
  systemd.user.services.kio-fuse = {
    description = "Fuse interface for KIO";
    partOf = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "dbus";
      BusName = "org.kde.KIOFuse";
      ExecStart = "${pkgs.kdePackages.kio-fuse}/libexec/kio-fuse -f";
      Slice = "background.slice";
    };
  };

  environment.systemPackages = with pkgs; [
    kdePackages.ark
    kdePackages.okular
    kdePackages.gwenview
    kdePackages.dolphin
    kdePackages.dolphin-plugins
    kdePackages.qtsvg
    kdePackages.kio
    kdePackages.kio-fuse
    kdePackages.kio-extras
    kdePackages.kservice # kbuildsycoca6 resolve MIME type -> default application
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

{pkgs, ...}:
{
  # Shared modules index - import all common and configurable modules
  imports = [
    ./nix.nix
    ./locale.nix
    ./sound.nix
    ./security.nix
    ./secrets.nix
    ./boot.nix
    ./network.nix
    ./virtualization.nix
    ./desktop.nix
    ./udev.nix
  ];

  # Allow dynamically linked executables (e.g. VS Code extensions with native binaries)
  programs.nix-ld.enable = true;

  # Common basic system tools and programs
  programs.firefox.enable = true;
  environment.systemPackages = with pkgs; [
    # nix utils
    nix
    comma
    nix-inspect
    statix
    age
    sops

    # archives
    unzip
    p7zip
    bzip2

    gnumake
    wget
    curl
    git
    vim
    killall
    htop

    gparted
    pciutils
    usbutils
    hwinfo
    i2c-tools
    ddcutil
    ffmpeg-full
  ];
}
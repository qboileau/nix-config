{pkgs, ...}:
{
  # Shared modules index - import all common and configurable modules
  imports = [
    ./nix.nix
    ./locale.nix
    ./sound.nix
    ./security.nix
    ./boot.nix
    ./network.nix
    ./virtualization.nix
    ./desktop.nix
    ./udev.nix
  ];

  # Common basic system tools and programs
  programs.firefox.enable = true;
  environment.systemPackages = with pkgs; [
    # nix utils
    nix
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

    gparted
    pciutils
    usbutils
    hwinfo
    i2c-tools
    ddcutil
    ffmpeg-full
  ];
}
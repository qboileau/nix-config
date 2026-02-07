{pkgs, ...}:
{

  services.udev.enable = true;
  services.udev.packages = with pkgs; [
    unstable.logitech-udev-rules
    unstable.keychron-udev-rules
  ];

  services.udev.extraRules = ''
    # allow keychron k2 HE keyboard
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="3434", ATTRS{idProduct}=="0e20", MODE="0666", GROUP="users", TAG+="uaccess", TAG+="udev-acl"
    # keychron k2 HE stm bootloader
    SUBSYSTEM=="usb", ATTRS{idVendor}=="3434", ATTRS{idProduct}=="0e20", MODE="0666", GROUP="users", TAG+="uaccess", TAG+="udev-acl"
    # keychron link
    SUBSYSTEM=="usb", ATTRS{idVendor}=="3434", ATTRS{idProduct}=="d030", MODE="0666", GROUP="users", TAG+="uaccess", TAG+="udev-acl"
  '';

}
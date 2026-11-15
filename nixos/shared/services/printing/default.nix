{
  config,
  lib,
  pkgs,
  username,
  ...
}: let
  cfg = config.services.printing.canonMP620;
in {
  options.services.printing.canonMP620.enable =
    lib.mkEnableOption "the USB-attached Canon PIXMA MP620 as default print queue and scanner";

  config = lib.mkMerge [
    {
      # https://nixos.wiki/wiki/Printing
      services.printing.enable = true;
      services.printing.drivers = with pkgs; [
        gutenprint  # Generic
        cnijfilter2 # Canon Pixma
      ];

      # network autodiscovery
      services.avahi = {
        enable = true;
        nssmdns4 = true;
        openFirewall = true;
      };

      environment.systemPackages = with pkgs; [
        cups-bjnp
        kdePackages.print-manager
      ];
    }

    (lib.mkIf cfg.enable {
      hardware.printers = {
        ensureDefaultPrinter = "Canon_MP620";
        ensurePrinters = [{
          name = "Canon_MP620";
          description = "Canon PIXMA MP620";
          deviceUri = "usb://Canon/MP620%20series?serial=20305E&interface=1";
          model = "gutenprint.5.3://bjc-MULTIPASS-MP620/expert";
        }];
      };

      hardware.sane.enable = true;
      users.users.${username}.extraGroups = [ "scanner" "lp" ];
      environment.systemPackages = [ pkgs.simple-scan ];
    })
  ];
}

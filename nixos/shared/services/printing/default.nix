
{pkgs, ...} :
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
    kdePackages.print-manager
  ];
}
{pkgs, config, lib, ...} :
let
  cfg = config.dev.tools;
in {
  options = {
    dev.tools.network = {
      enable = lib.mkEnableOption "Network debugging and testing tools";
    };
  };

  config = lib.mkIf cfg.network.enable {
    home.packages = with pkgs; [ 
      socat
      dig
      httpie
      nss  # certutil
      mkcert
      apacheHttpd
      teleport_17
    ];
  };
}

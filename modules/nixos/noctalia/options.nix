{ pkgs, inputs, lib, ... }:{

  options = {
    noctalia = {
      enable = lib.mkEnableOption "Noctalia support";
    };
  };
}
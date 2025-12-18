{config, lib, pkgs, ...} :
{
  options = {
    gaming = {
      enable = lib.mkEnableOption "Gaming support";
      vr = {
        enable = lib.mkEnableOption "VR support";
      };
    };
  };
}
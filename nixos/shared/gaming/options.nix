{config, lib, pkgs, ...} :
{
  options = {
    gaming = {
      enable = lib.mkEnableOption "Gaming support";
      vr = {
        enable = lib.mkEnableOption "VR support";
      };
      amd = {
        enable = lib.mkEnableOption "AMD GPU optimizations for gaming";
      };
    };
  };
}
{config, lib, pkgs, ...} :
{
  config = lib.mkIf config.gaming.vr.enable {

    # https://wiki.nixos.org/wiki/VR
    services.monado = {
      enable = true;
      defaultRuntime = true; # Register as default OpenXR runtime
    };

    systemd.user.services.monado.environment = {
      STEAMVR_LH_ENABLE = "1";
      XRT_COMPOSITOR_COMPUTE = "1";
    };
  };
}
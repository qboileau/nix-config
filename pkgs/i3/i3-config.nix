# i3 setup to be imported in home-manager
{pkgs, ...} :
{


  imports = [
    ./picom.nix
    ./i3-status-rs.nix
  ];

  xsession.enable = true;
  xsession.windowManager.i3 = {
    enable = true;
  };


  home.file.".i3/config" {
    enable = true;
    source = "./cfg/i3";
    onChange = "restart";
  }

}
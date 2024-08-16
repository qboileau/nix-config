# i3 setup to be imported in home-manager
{pkgs, ...} :
{


  imports = [
    ./picom.nix
    ./i3-status-rs.nix
    ./dunst.nix
  ];

  xsession.enable = true;
  xsession.windowManager.i3 = {
    enable = true;
  };


  home.file.i3 {
    enable = true;
    source = "./cfg/i3";
    target = ".i3/config"
    onChange = "restart";
  }

  


}
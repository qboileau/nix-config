{pkgs, ...} :
{

  home.file.".jdks/jetbrains".source = pkgs.jetbrains.jdk;
  home.packages = with pkgs; [ 
    jetbrains.idea-ultimate
    
    # go debugger need to be added in Help->Edit Custom VM options -Ddlv.path=/home/<username>/.nix-profile/bin/dlv
    delve 
  ];

  # https://youtrack.jetbrains.com/issue/IJPL-122525/Menu-bar-missing-on-all-windows-except-one-on-tiling-WM-under-WSLg
  # home.file.".config/JetBrains/idea64.vmoptions".text = ''
  # -Dide.linux.hide.native.title=false
  # '';


}
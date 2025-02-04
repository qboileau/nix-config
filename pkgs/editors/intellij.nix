{pkgs, ...} :
{

  home.file.".jdks/jetbrains".source = pkgs.jetbrains.jdk;
  home.packages = with pkgs; [ 
    jetbrains.idea-ultimate
    
    # go debugger need to be added in Help->Edit Custom VM options -Ddlv.path=/home/<username>/.nix-profile/bin/dlv
    delve 
  ];


}
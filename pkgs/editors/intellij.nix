{pkgs, ...} :
{

  home.file.".jdks/jetbrains".source = pkgs.jetbrains.jdk;
  home.packages = with pkgs; [ 
    # jetbrains.jdk
    jetbrains.idea-ultimate
  ];
}
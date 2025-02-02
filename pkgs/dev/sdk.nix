{pkgs, ...} :
{

  programs.java.enable=true;

  # home.file."jdks/default".source = pkgs.jdk;
  # home.sessionVariables = {
    # JAVA_HOME=pkgs.jdk.home;
  # };
}
{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.dev.languages;
in
{
  options = {
    dev.languages.java = {
      enable = lib.mkEnableOption "Java development tools";
    };
  };

  config = lib.mkIf cfg.java.enable {
    programs.java.enable = true;

    home.packages = with pkgs; [
      maven
      sbt
    ];

    home.shellAliases = {
      mvncis = "mvn clean install -DskipTests --show-version";
      mvnc = "mvn clean --show-version";
      mvni = "mvn install --show-version";
      mvnis = "mvn install -DskipTests --show-version";
      mvnci = "mvn clean install --show-version";
      mvnt = "mvn test --show-version";
    };

    home.sessionVariables = {
      MAVEN_OPTS = "-Xmx1g -XX:MaxMetaspaceSize=512m";
      SBT_OPTS = "-Xms256m -Xmx4G -XX:+UseG1GC -XX:+UseStringDeduplication";
    };
  };
}

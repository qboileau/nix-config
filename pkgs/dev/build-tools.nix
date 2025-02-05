    {pkgs, ...} :
{

  home.packages = with pkgs; [ 
    maven
    sbt
    rustc 
    cargo
    nodejs
    go  
    gcc
    libllvm
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
    MAVEN_OPTS = "-Xmx1g -XX:MaxPermSize=512m";
    SBT_OPTS = "-Xms256m -Xmx2G";
  };
}
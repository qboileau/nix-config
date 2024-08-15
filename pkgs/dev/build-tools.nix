    {pkgs, ...} :
{

  home.packages = with pkgs; [ 
    maven
    sbt
    
    rustc 
    nodejs
    go  
  ];
    
  home.shellAliases = {
    mvncis = "mvn clean install -DskipTests --show-version";
    mvnc = "mvn clean --show-version";
    mvni = "mvn install --show-version";
    mvnis = "mvn install -DskipTests --show-version";
    mvnci = "mvn clean install --show-version";
    mvnt = "mvn test --show-version";
  };
}
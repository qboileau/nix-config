{config, pkgs, ...} :
{

  home.packages = with pkgs; [ 
    maven
    sbt
    rustup # run `rustup default stable` to setup rustc/cargo
    #rustc 
    #cargo
    nodejs
    yarn
    go
    gcc
    libllvm
    python3
    python313Packages.uv
    pre-commit
    checkov
  ];
    
  home.shellAliases = {
    mvncis = "mvn clean install -DskipTests --show-version";
    mvnc = "mvn clean --show-version";
    mvni = "mvn install --show-version";
    mvnis = "mvn install -DskipTests --show-version";
    mvnci = "mvn clean install --show-version";
    mvnt = "mvn test --show-version";
  };


  home.file.".cache/npm/global/.keep".text = "placeholder";
  home.file.".npmrc".text = ''
  prefix=${config.home.homeDirectory}/.cache/npm/global
  '';
  home.sessionPath = ["${config.home.homeDirectory}/.cache/npm/global/bin"];

  home.sessionVariables = {
    MAVEN_OPTS = "-Xmx1g -XX:MaxPermSize=512m";
    SBT_OPTS = "-Xms256m -Xmx2G";
  };
}